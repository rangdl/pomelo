import 'dart:async';
import 'dart:convert';
import 'dart:io' show gzip, zlib;
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:quickjs_engine/extensions/xhr.dart';
import 'package:quickjs_engine/quickjs_engine.dart';

import 'lx_compat.dart';
import 'musicfree_compat.dart';

/// 插件 worker 进程内运行的 JS 引擎句柄（主 isolate 侧）。
///
/// 每个插件跑在独立 Isolate 里：插件脚本死循环/疯狂递归只会卡住该 Isolate，
/// UI isolate 依然流畅；超时后直接 kill 掉 Isolate 即可彻底止损。
class PluginHost {
  PluginHost._(this._isolate, this._commands, this._inbox);

  final Isolate _isolate;
  final SendPort _commands;
  final ReceivePort _inbox;

  final Map<int, Completer<dynamic>> _pending = {};
  int _nextId = 1;
  bool _closed = false;

  /// 插件日志回调（`[plugin]` / `[lx]`）。
  void Function(String tag, String message)? onLog;

  /// 启动 worker 并完成握手。
  static Future<PluginHost> spawn({
    required String fetchPolyfill,
    int stackSize = 1024 * 1024,
    int? memoryLimit,
  }) async {
    final inbox = ReceivePort();
    final ready = Completer<SendPort>();
    PluginHost? host;

    void handleMessage(dynamic message) {
      if (message is SendPort) {
        if (!ready.isCompleted) ready.complete(message);
        return;
      }
      // isolate 的未捕获异常/退出会以 [error, stackTrace] 或 null 发到错误监听端口。
      // 启动失败（如原生库缺失）必须立刻失败，否则调用方只能干等到超时。
      if (message is List && message.isNotEmpty) {
        final error = StateError('插件运行时异常: ${message.first}');
        if (!ready.isCompleted) {
          ready.completeError(error);
        } else {
          host?._failAll(error);
        }
        return;
      }
      if (message == null) {
        if (!ready.isCompleted) {
          ready.completeError(StateError('插件运行时启动失败'));
        } else {
          host?._failAll(StateError('插件运行时已退出'));
        }
        return;
      }
      if (message is! Map) return;
      final map = message.cast<dynamic, dynamic>();
      if (map['type'] == 'log') {
        host?.onLog?.call('${map['tag']}', '${map['message']}');
        return;
      }
      final id = map['id'];
      if (id is! int) return;
      final completer = host?._pending.remove(id);
      if (completer == null || completer.isCompleted) return;
      if (map['ok'] == true) {
        completer.complete(map['data']);
      } else {
        completer.completeError(StateError('${map['error']}'));
      }
    }

    final isolate = await Isolate.spawn(
      pluginWorkerMain,
      <String, dynamic>{
        'reply': inbox.sendPort,
        'fetchPolyfill': fetchPolyfill,
        'stackSize': stackSize,
        'memoryLimit': memoryLimit,
      },
      debugName: 'pomelo-plugin',
      errorsAreFatal: true,
    );

    inbox.listen(handleMessage);
    isolate.addErrorListener(inbox.sendPort);
    isolate.addOnExitListener(inbox.sendPort);

    final SendPort commands;
    try {
      commands = await ready.future.timeout(const Duration(seconds: 30));
    } catch (_) {
      // 握手失败：回收端口与 isolate，避免泄漏。
      inbox.close();
      isolate.kill(priority: Isolate.immediate);
      rethrow;
    }
    host = PluginHost._(isolate, commands, inbox);
    return host;
  }

  bool get closed => _closed;

  /// 让所有在途调用立即失败（isolate 异常退出时调用）。
  void _failAll(Object error) {
    if (_closed) return;
    _closed = true;
    for (final completer in _pending.values) {
      if (!completer.isCompleted) completer.completeError(error);
    }
    _pending.clear();
  }

  /// 调用 worker 内的一个方法，超时即终止整个运行时（插件死循环无法从外部
  /// 打断，只能杀 Isolate 重建）。
  Future<dynamic> call(
    String method,
    List<dynamic> args, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (_closed) throw StateError('插件运行时已关闭');
    final id = _nextId++;
    final completer = Completer<dynamic>();
    _pending[id] = completer;
    _commands.send({'id': id, 'method': method, 'args': args});
    try {
      return await completer.future.timeout(timeout);
    } on TimeoutException {
      _pending.remove(id);
      await close();
      throw StateError('插件执行超时，已终止该插件运行时');
    }
  }

  /// 关闭运行时：先尝试优雅释放，再强行结束 Isolate。
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    for (final completer in _pending.values) {
      if (!completer.isCompleted) {
        completer.completeError(StateError('插件运行时已关闭'));
      }
    }
    _pending.clear();
    try {
      _inbox.close();
    } catch (_) {
      // 忽略。
    }
    try {
      _isolate.kill(priority: Isolate.immediate);
    } catch (_) {
      // 忽略。
    }
  }
}

/// worker Isolate 入口。
Future<void> pluginWorkerMain(Map<String, dynamic> message) async {
  final reply = message['reply'] as SendPort;
  final commands = ReceivePort();
  // 先回传命令端口，主 isolate 收到后才算握手完成。
  reply.send(commands.sendPort);

  final engine = _WorkerEngine(
    reply: reply,
    fetchPolyfill: '${message['fetchPolyfill'] ?? ''}',
    stackSize: message['stackSize'] as int? ?? 1024 * 1024,
    memoryLimit: message['memoryLimit'] as int?,
  );

  await for (final dynamic raw in commands) {
    if (raw is! Map) continue;
    final id = raw['id'];
    if (id is! int) continue;
    final method = '${raw['method']}';
    final args = (raw['args'] as List?) ?? const [];
    try {
      final data = await engine.handle(method, args);
      reply.send({'id': id, 'ok': true, 'data': data});
    } catch (e) {
      reply.send({'id': id, 'ok': false, 'error': '$e'});
    }
  }
}

/// 运行在 worker Isolate 内的引擎与插件逻辑。
class _WorkerEngine {
  _WorkerEngine({
    required this.reply,
    required String fetchPolyfill,
    required int stackSize,
    int? memoryLimit,
  }) : _js = QuickJsRuntime2(stackSize: stackSize, memoryLimit: memoryLimit) {
    _js.onMessage('pluginLog', (dynamic args) => _log('plugin', args));
    _js.onMessage('lxLog', (dynamic args) => _log('lx', args));
    _js.enableXhr();
    if (fetchPolyfill.isNotEmpty) {
      _js.evaluate(fetchPolyfill);
    }
    _js.enableHandlePromises();
    LxCompat.installBridges(_js);
    MusicfreeCompat.installBridges(_js);
    // LX 的 HTTP 请求已统一走 XHR（见 quickjs_engine 的 xhr 扩展），仅保留 zlib 桥。
    _js.onMessage('LxZlib', (dynamic args) => _lxZlib(args));
  }

  final SendPort reply;
  final QuickJsRuntime2 _js;

  final Map<String, dynamic> sources = {};
  Map<String, List<String>> qualitys = const {};
  Map<String, dynamic>? updateAlert;
  bool initialized = false;
  String? initError;
  bool _loaded = false;

  String _platform = '';
  String _version = '';
  String _author = '';
  String _description = '';

  void _log(String tag, dynamic args) {
    if (kDebugMode) debugPrint('[$tag] $args');
    reply.send({'type': 'log', 'tag': tag, 'message': '$args'});
  }

  Future<dynamic> handle(String method, List<dynamic> args) async {
    switch (method) {
      case 'load':
        return _load(
          '${args[0]}',
          name: args.length > 1 ? '${args[1]}' : 'plugin',
          initTimeout: Duration(
            milliseconds: args.length > 2 ? (args[2] as int) : 20000,
          ),
          userVariables: args.length > 3 && args[3] is Map
              ? Map<String, dynamic>.from(args[3] as Map)
              : const {},
        );
      case 'invoke':
        return _invoke(
          '${args[0]}',
          (args[1] as List?) ?? const [],
          Duration(milliseconds: args.length > 2 ? (args[2] as int) : 20000),
        );
      case 'lxRequest':
        return _lxRequest(
          '${args[0]}',
          '${args[1]}',
          Map<String, dynamic>.from((args[2] as Map?) ?? const {}),
          Duration(milliseconds: args.length > 3 ? (args[3] as int) : 15000),
        );
      case 'ping':
        return true;
      case 'dispose':
        _js.dispose();
        return true;
      default:
        throw UnsupportedError('未知的插件运行时方法: $method');
    }
  }

  /// 加载插件源码并自动判定格式，返回可跨 Isolate 传输的元信息。
  Future<Map<String, dynamic>> _load(
    String source, {
    required String name,
    required Duration initTimeout,
    required Map<String, dynamic> userVariables,
  }) async {
    final meta = LxScriptMeta.parse(source);
    final scriptName = (meta.name?.trim().isNotEmpty ?? false)
        ? meta.name!.trim()
        : name;
    _platform = scriptName;
    _version = meta.version ?? '';
    _author = meta.author ?? '';
    _description = meta.description ?? '';
    sources.clear();
    qualitys = const {};
    updateAlert = null;
    initialized = false;
    initError = null;

    _js.evaluate(
      LxCompat.prelude(
        id: name,
        name: scriptName,
        version: meta.version ?? '',
        author: meta.author ?? '',
        description: meta.description ?? '',
        homepage: meta.homepage ?? '',
        // 部分脚本（如野花）会校验源码原文，必须传原始脚本。
        rawScript: source,
        userVariables: userVariables,
      ),
    );
    // MusicFree 原始插件依赖 require("axios"/"he")，由兼容层在运行时注册。
    _js.evaluate(MusicfreeCompat.bootstrap);
    _js.evaluate(LxCompat.bridge);

    // 不用 "use strict"：部分 LX 脚本依赖非严格模式的隐式全局赋值。
    final wrapped =
        '''
(function(module, exports, require, console, env) {
try {
$source
} catch (e) {
  globalThis.__lx_loadError = String((e && e.message) || e);
}
})(__pluginModule, __pluginModule.exports, __pluginRequire, __pluginConsole, __pluginEnv);
''';
    final result = _js.evaluate(wrapped, sourceUrl: '$name.js');
    if (result.isError) {
      throw StateError('插件加载失败: ${result.stringResult}');
    }
    // parcel 打包插件只导出 default，铺平后才能被宿主按顶层方法读取。
    _js.evaluate(MusicfreeCompat.normalizeExports);
    _loaded = true;

    final reflect =
        _evalRaw('''
(function() {
  var m = __pluginModule.exports;
  if (!m || typeof m !== 'object') return { methods: [] };
  var methods = Object.keys(m).filter(function(k) {
    return typeof m[k] === 'function';
  });
  var declaredKeys = Array.isArray(m.sourceKeys) ? m.sourceKeys
    : (typeof m.lxSource === 'string' && m.lxSource ? [m.lxSource] : []);
  return {
    methods: methods,
    sourceKeys: declaredKeys,
    platform: m.platform || '',
    version: m.version || '',
    author: m.author || '',
    description: m.description || '',
    srcUrl: m.srcUrl || '',
    supportedSearchTypes: Array.isArray(m.supportedSearchType) ? m.supportedSearchType : [],
    defaultSearchType: typeof m.defaultSearchType === 'string' ? m.defaultSearchType : ''
  };
})()
''') as Map<String, dynamic>? ??
        const {};

    final methods = (reflect['methods'] as List?)?.cast<String>() ?? const [];

    if (methods.isNotEmpty) {
      // 顶层代码抛异常时模块可能已导出部分方法，静默成功会掩盖问题。
      final loadError = _evalRaw('globalThis.__lx_loadError || null');
      if (loadError is String && loadError.isNotEmpty) {
        debugPrint('[pomelo] 插件 $scriptName 加载时有异常: $loadError');
      }
      final platform = _pickString(reflect['platform']) ?? _platform;
      _platform = platform;
      _version = _pickString(reflect['version']) ?? _version;
      _author = _pickString(reflect['author']) ?? _author;
      _description = _pickString(reflect['description']) ?? _description;
      final declaredKeys =
          (reflect['sourceKeys'] as List?)?.map((e) => '$e').toList() ??
          const [];
      return {
        'isLxCompat': false,
        'platform': platform,
        'version': _version,
        'author': _author,
        'description': _description,
        'supportedMethods': methods,
        'srcUrl': _pickString(reflect['srcUrl']),
        'sourceKeys': declaredKeys.isEmpty ? [platform] : declaredKeys,
        'qualitys': const <String, List<String>>{},
        'updateAlert': null,
        'supportedSearchTypes':
            (reflect['supportedSearchTypes'] as List?)?.map((e) => '$e').toList() ??
            const <String>[],
        'defaultSearchType': _pickString(reflect['defaultSearchType']) ?? '',
        'initialized': initialized,
        'initError': initError,
      };
    }

    // 没有导出方法：只有注册过 LX handler / 上报过 inited 才算 LX 脚本。
    final looksLx =
        _evalRaw(
          'typeof __lx_requestHandler === "function" || '
          'globalThis.__lx_initPayload !== undefined',
        ) ==
        true;
    if (!looksLx) {
      final loadError = _evalRaw('globalThis.__lx_loadError || null');
      if (loadError is String && loadError.isNotEmpty) {
        throw StateError('插件加载失败: $loadError');
      }
      throw StateError('无法识别的插件格式：既没有导出插件方法，也不是 LX 音源脚本');
    }

    final ok = await _waitForInit(initTimeout);
    if (!ok) {
      throw StateError('LX 脚本初始化失败: ${initError ?? "未知原因"}');
    }

    final lxMethods = <String>['getMediaSource'];
    if (_lxSupportsAction('lyric')) lxMethods.add('getLyric');

    return {
      'isLxCompat': true,
      'platform': _platform,
      'version': _version,
      'author': _author,
      'description': _description,
      'supportedMethods': lxMethods,
      'srcUrl': _pickString(updateAlert?['updateUrl']),
      // 宿主需要 sources 判断音源能力（也用于歌词等 action 探测）。
      'sources': sources,
      'sourceKeys': sources.keys.toList()..sort(),
      'qualitys': qualitys,
      'updateAlert': updateAlert,
      'initialized': initialized,
      'initError': initError,
    };
  }

  String? _pickString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  Future<bool> _waitForInit(Duration timeout) async {
    if (initialized) return true;
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      _js.executePendingJob();
      final state =
          _evalRaw('''(function() {
  return {
    init: globalThis.__lx_initPayload !== undefined,
    err: globalThis.__lx_loadError || null
  };
})()''') as Map<String, dynamic>? ??
          const {};
      final err = state['err'];
      if (err is String && err.isNotEmpty) {
        initError = err;
        return false;
      }
      if (state['init'] == true) {
        // 给脚本一个微任务窗口把 send('inited') 后的收尾逻辑跑完。
        await Future<void>.delayed(const Duration(milliseconds: 5));
        _js.executePendingJob();
        return _finalizeLx();
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    initError = '初始化超时';
    return false;
  }

  bool _finalizeLx() {
    final payload = _evalRaw(
      'globalThis.__lx_initPayload || null',
    ) as Map<String, dynamic>?;
    if (payload != null && payload['status'] == false) {
      initError = '${payload['message'] ?? '初始化失败'}';
      return false;
    }
    final declared = payload?['sources'];
    if (declared is Map) {
      sources
        ..clear()
        ..addAll(declared.cast<String, dynamic>());
    }
    qualitys = {
      for (final entry in sources.entries) entry.key: _qualitysOf(entry.value),
    };
    updateAlert = _evalRaw(
      'globalThis.__lx_updateAlert || null',
    ) as Map<String, dynamic>?;
    _js.evaluate(
      LxCompat.createVirtualExports(
        platform: _platform,
        version: _version,
        author: _author,
        description: _description,
      ),
    );
    initialized = true;
    return true;
  }

  List<String> _qualitysOf(dynamic value) {
    if (value is List) return value.map((e) => '$e').toList();
    if (value is Map) {
      final q = value['qualitys'];
      if (q is List) return q.map((e) => '$e').toList();
    }
    return const [];
  }

  bool _lxSupportsAction(String action) {
    for (final value in sources.values) {
      if (value is Map) {
        final actions = value['actions'];
        if (actions is List && actions.map((e) => '$e').contains(action)) {
          return true;
        }
      }
    }
    return false;
  }

  Future<dynamic> _invoke(
    String method,
    List<dynamic> args,
    Duration timeout,
  ) async {
    if (!_loaded) throw StateError('插件尚未加载');
    final argsJson = jsonEncode(args);
    _js.evaluate('''
      globalThis.__lastResult = undefined;
      globalThis.__lastError = undefined;
      (async function() {
        try {
          var fn = __pluginModule.exports && __pluginModule.exports['$method'];
          if (typeof fn !== 'function') {
            __lastResult = { __unsupported: true };
            return;
          }
          var a = JSON.parse(${jsonEncode(argsJson)});
          var r = await fn.apply(__pluginModule.exports, a);
          __lastResult = (r === undefined ? null : r);
        } catch (e) {
          __lastError = (e && e.message) ? e.message : String(e);
        }
      })();
    ''');

    // 轮询只查轻量标志位：结果可能上百条，每轮序列化大 JSON 会拖慢执行。
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      _js.executePendingJob();
      final done = _js.evaluate(
        '(globalThis.__lastResult !== undefined || '
        'globalThis.__lastError !== undefined) ? "1" : "0"',
      );
      if (done.stringResult.contains('1')) {
        final state = _js.evaluate(
          'JSON.stringify({r: globalThis.__lastResult, e: globalThis.__lastError})',
        );
        final map = jsonDecode(state.stringResult) as Map<String, dynamic>;
        if (map['e'] != null) throw StateError('插件方法异常: ${map['e']}');
        final value = map['r'];
        if (value is Map && value['__unsupported'] == true) {
          throw UnsupportedError('插件未实现 $method');
        }
        return value;
      }
      await Future<void>.delayed(const Duration(milliseconds: 15));
    }
    throw StateError('调用 $method 超时');
  }

  Future<dynamic> _lxRequest(
    String source,
    String action,
    Map<String, dynamic> info,
    Duration timeout,
  ) async {
    if (!initialized) throw StateError('该插件不是 LX 音源脚本，未初始化');

    _js.evaluate('''
      globalThis.__lx_result = undefined;
      globalThis.__lx_resultError = undefined;
      globalThis.__lx_requestInFlight = true;
      (function() {
        var handler = __lx_requestHandler;
        if (typeof handler !== 'function') {
          __lx_resultError = 'request handler is not defined';
          __lx_requestInFlight = false;
          return;
        }
        Promise.resolve()
          .then(function() {
            return handler({ source: ${jsonEncode(source)}, action: ${jsonEncode(action)}, info: ${jsonEncode(info)} });
          })
          .then(function(r) { __lx_result = r; __lx_requestInFlight = false; })
          .catch(function(e) { __lx_resultError = (e && e.message) || String(e); __lx_requestInFlight = false; });
      })();
    ''');

    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      _js.executePendingJob();
      final state = _js.evaluate(
        'JSON.stringify({ done: globalThis.__lx_requestInFlight === false, '
        'r: globalThis.__lx_result === undefined ? null : globalThis.__lx_result, '
        'e: globalThis.__lx_resultError || null })',
      );
      final map = jsonDecode(state.stringResult) as Map<String, dynamic>;
      if (map['done'] == true) {
        if (map['e'] != null) throw StateError('LX 请求失败: ${map['e']}');
        return map['r'];
      }
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    throw StateError('LX 请求超时');
  }

  // ---- LX zlib 桥 ------------------------------------------------------

  /// JS 侧 `sendMessage(channel, JSON.stringify(x))` 会被引擎解析成 Map/List，
  /// 但旧路径也可能直接传字符串，这里统一兼容。
  Map<String, dynamic> _mapArg(dynamic raw) {
    if (raw is Map) return raw.cast<String, dynamic>();
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) return decoded.cast<String, dynamic>();
      } catch (_) {
        // 非法 JSON。
      }
    }
    return const {};
  }

  dynamic _lxZlib(dynamic raw) {
    try {
      final msg = _mapArg(raw);
      final op = '${msg['op']}';
      final data = base64Decode('${msg['data']}');
      List<int> out;
      if (op == 'inflate') {
        final isGzip = data.length >= 2 && data[0] == 0x1f && data[1] == 0x8b;
        out = isGzip ? gzip.decode(data) : zlib.decode(data);
      } else if (op == 'deflate') {
        out = zlib.encode(data);
      } else {
        return jsonEncode({'error': 'unsupported zlib op: $op'});
      }
      return jsonEncode({'data': base64Encode(out)});
    } catch (e) {
      return jsonEncode({'error': '$e'});
    }
  }

  dynamic _evalRaw(String expr) {
    final result = _js.evaluate('JSON.stringify($expr)');
    if (result.isError) throw StateError('求值失败: ${result.stringResult}');
    final text = result.stringResult;
    if (text == 'undefined' || text == 'null') return null;
    try {
      final decoded = jsonDecode(text);
      // evaluate 可能把字符串结果再包一层引号，先解包一次。
      if (decoded is String) return jsonDecode(decoded);
      return decoded;
    } catch (_) {
      return text;
    }
  }
}
