import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:quickjs_engine/extensions/xhr.dart';
import 'package:quickjs_engine/quickjs_engine.dart';

import 'lx_compat.dart';

/// 插件加载结果。
///
/// 宿主只关心这份结果，不区分插件是自有格式还是 LX 脚本——LX 脚本已由兼容层
/// 包装成同形的 `getMediaSource`。
class PluginLoadResult {
  const PluginLoadResult({
    required this.isLxCompat,
    required this.platform,
    required this.version,
    required this.author,
    required this.description,
    required this.supportedMethods,
    this.srcUrl,
    this.sourceKeys = const [],
    this.qualitys = const {},
    this.updateAlert,
  });

  /// 是否由 LX 兼容层包装而来。
  final bool isLxCompat;

  /// 插件身份标识（自有格式=导出 platform，LX=脚本名）。
  final String platform;
  final String version;
  final String author;
  final String description;

  /// 插件实际实现的方法（LX 包装插件固定为 `getMediaSource`）。
  final List<String> supportedMethods;

  /// 更新源地址（自有格式=srcUrl，LX=updateAlert.updateUrl）。
  final String? srcUrl;

  /// 可处理的音源 key 集合：自有格式为 `[platform]`，LX 为其声明的全部源。
  final List<String> sourceKeys;

  /// 音源 key → 该源支持的音质列表（仅 LX 有值）。
  final Map<String, List<String>> qualitys;

  /// LX 脚本上报的更新提示（`{log, updateUrl}`），非空即"有更新"。
  final Map<String, dynamic>? updateAlert;

  bool get hasUpdateAlert => updateAlert != null && updateAlert!.isNotEmpty;
}

/// 统一插件运行时：每插件一个 QuickJS 实例，同时承载自有格式插件与 LX 脚本。
///
/// - 自有格式：`module.exports = { platform, search, getMediaSource, ... }`
/// - LX 脚本：`lx.on('request', ...)` + `lx.send('inited', ...)`，由 [LxCompat]
///   包装成同形导出（只提供 `getMediaSource`）。
///
/// 两条路径互不干扰，格式在加载后自动判定，宿主无感知。
class PomeloPluginRuntime {
  PomeloPluginRuntime._(this._js);

  final JavascriptRuntime _js;

  /// LX 脚本声明的源（`kw/kg/tx/wy/mg/qs…`）。
  final Map<String, dynamic> sources = {};

  /// 源 → 音质列表。
  Map<String, List<String>> qualitys = const {};

  /// LX 上报的更新提示。
  Map<String, dynamic>? updateAlert;

  bool initialized = false;
  String? initError;

  bool _loaded = false;

  /// 串行队列：同一插件的 `__lastResult/__lastError` 是全局位，并发调用会互相覆盖。
  Future<void> _tail = Future<void>.value();

  String _platform = '';
  String _version = '';
  String _author = '';
  String _description = '';

  /// 创建实例。
  ///
  /// 不能直接用 `getJavascriptRuntime()`：它内部调用 `enableFetch()` 但不 await，
  /// 而 fetch polyfill 要异步读 bundle，会导致脚本执行时 `fetch is not defined`。
  static Future<PomeloPluginRuntime> create({
    int stackSize = 1024 * 1024,
  }) async {
    final js = QuickJsRuntime2(stackSize: stackSize);
    js.onMessage('pluginLog', (dynamic args) {
      if (kDebugMode) debugPrint('[plugin] $args');
    });
    js.onMessage('lxLog', (dynamic args) {
      if (kDebugMode) debugPrint('[lx] $args');
    });
    js.enableXhr();
    final polyfill = await rootBundle.loadString(
      'packages/quickjs_engine/assets/js/fetch.js',
    );
    js.evaluate(polyfill);
    js.enableHandlePromises();
    LxCompat.installBridges(js);
    return PomeloPluginRuntime._(js);
  }

  JavascriptRuntime get js => _js;

  /// 加载插件源码并自动判定格式。
  ///
  /// 判定顺序：先看 `module.exports` 是否有方法 → 自有格式；否则看脚本是否
  /// 注册了 LX request handler / 上报了 inited → LX 兼容模式；都没有则报错。
  Future<PluginLoadResult> loadPlugin(
    String source, {
    String name = 'plugin',
    Duration initTimeout = const Duration(seconds: 20),
  }) async {
    final meta = LxScriptMeta.parse(source);
    final scriptName = (meta.name?.trim().isNotEmpty ?? false)
        ? meta.name!.trim()
        : name;
    _platform = scriptName;
    _version = meta.version ?? '';
    _author = meta.author ?? '';
    _description = meta.description ?? '';

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
      ),
    );
    _js.evaluate(LxCompat.bridge);

    // 不用 "use strict"：部分 LX 脚本依赖非严格模式的隐式全局赋值。
    // 脚本异常先落到 __lx_loadError，再按格式统一抛出。
    final wrapped =
        '''
(function(module, exports, require, console, env) {
try {
$source
} catch (e) {
  globalThis.__lx_loadError = String((e && e.message) || e);
}
})(__pluginModule, __pluginModule.exports, __noRequire, __pluginConsole, __pluginEnv);
''';
    final result = _js.evaluate(wrapped, sourceUrl: '$name.js');
    if (result.isError) {
      throw StateError('插件加载失败: ${result.stringResult}');
    }
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
    srcUrl: m.srcUrl || ''
  };
})()
''') as Map<String, dynamic>? ??
        const {};

    final methods = (reflect['methods'] as List?)?.cast<String>() ?? const [];

    if (methods.isNotEmpty) {
      // 顶层代码抛异常时模块可能已导出部分方法，静默成功会掩盖问题。
      final loadError = _evalRaw('globalThis.__lx_loadError || null');
      if (loadError is String && loadError.isNotEmpty) {
        debugPrint(
          '[pomelo] 插件 ${_pickString(reflect['platform']) ?? name} '
          '加载时有异常: $loadError',
        );
      }
      final platform = _pickString(reflect['platform']) ?? _platform;
      _platform = platform;
      _version = _pickString(reflect['version']) ?? _version;
      _author = _pickString(reflect['author']) ?? _author;
      _description = _pickString(reflect['description']) ?? _description;
      final declaredKeys =
          (reflect['sourceKeys'] as List?)?.map((e) => '$e').toList() ??
          const [];
      return PluginLoadResult(
        isLxCompat: false,
        platform: platform,
        version: _version,
        author: _author,
        description: _description,
        supportedMethods: methods,
        srcUrl: _pickString(reflect['srcUrl']),
        sourceKeys: declaredKeys.isEmpty ? [platform] : declaredKeys,
      );
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

    final ok = await waitForInit(timeout: initTimeout);
    if (!ok) {
      throw StateError('LX 脚本初始化失败: ${initError ?? "未知原因"}');
    }

    final lxMethods = <String>['getMediaSource'];
    if (_lxSupportsAction('lyric')) lxMethods.add('getLyric');

    return PluginLoadResult(
      isLxCompat: true,
      platform: _platform,
      version: _version,
      author: _author,
      description: _description,
      supportedMethods: lxMethods,
      srcUrl: _pickString(updateAlert?['updateUrl']),
      sourceKeys: sources.keys.toList()..sort(),
      qualitys: qualitys,
      updateAlert: updateAlert,
    );
  }

  String? _pickString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  /// 等待 LX 脚本上报 `inited` 并完成包装。非 LX 插件直接返回 true。
  Future<bool> waitForInit({
    Duration timeout = const Duration(seconds: 20),
  }) async {
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

  /// LX 源是否声明了某个 action（如 `lyric`）。
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

  // ---------------------------------------------------------------------------
  // 调用
  // ---------------------------------------------------------------------------

  /// 调用插件方法并等待 Promise 结算。内部串行执行，避免结果位互相覆盖。
  Future<dynamic> invoke(
    String method,
    List<dynamic> args, {
    Duration timeout = const Duration(seconds: 20),
  }) {
    return _serial(() => _invoke(method, args, timeout));
  }

  Future<T> _serial<T>(Future<T> Function() task) {
    final completer = Completer<void>();
    final previous = _tail;
    _tail = completer.future;
    return previous.then((_) => task()).whenComplete(completer.complete);
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

    // 轮询只查轻量标志位：搜索结果/榜单可能上百条，每轮序列化大 JSON 会卡住
    // 主 isolate（真机表现为无响应）。
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

  /// 求值并解析 JSON 结果（null 表示 JS 侧给出 null/undefined）。
  Map<String, dynamic>? evaluateJson(String code) {
    final value = _evalRaw(code);
    return value is Map<String, dynamic> ? value : null;
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
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // 便捷方法（全部可选，插件未实现时抛 UnsupportedError）
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> search(
    String query, {
    int page = 1,
    String type = 'music',
  }) async {
    final result = await invoke('search', [query, page, type]);
    if (result is Map<String, dynamic>) {
      final data = result['data'];
      return {
        'isEnd': result['isEnd'] ?? true,
        'data': data is List ? data : const [],
      };
    }
    return {'isEnd': true, 'data': const []};
  }

  /// 获取播放地址，返回 `{url, headers?}`；取不到返回 null。
  ///
  /// [sourceKey] 供 LX 包装插件选择具体音源；自有格式插件会忽略这个多余实参。
  Future<Map<String, dynamic>?> getMediaSource(
    Map<String, dynamic> musicItem,
    String quality, {
    String? sourceKey,
  }) async {
    final args = <dynamic>[musicItem, quality];
    if (sourceKey != null && sourceKey.isNotEmpty) args.add(sourceKey);
    final result = await invoke('getMediaSource', args);
    if (result is Map<String, dynamic>) {
      final url = result['url'];
      if (url is String && url.isNotEmpty) return result;
      return null;
    }
    if (result is String && result.isNotEmpty) return {'url': result};
    return null;
  }

  /// 单曲详情（部分插件会补齐歌词、音质等信息）。
  Future<Map<String, dynamic>?> getMusicInfo(
    Map<String, dynamic> musicItem,
  ) async {
    final result = await invoke('getMusicInfo', [musicItem]);
    if (result is Map<String, dynamic>) return result;
    if (result is Map && result['data'] is Map) {
      return (result['data'] as Map).cast<String, dynamic>();
    }
    return null;
  }

  /// 评论列表。返回 `{isEnd, data}` 里的 `data`。
  Future<List<Map<String, dynamic>>> getMusicComments(
    Map<String, dynamic> musicItem, {
    int page = 1,
    String sort = 'hot',
  }) async {
    final result = await invoke('getMusicComments', [
      musicItem,
      page,
      sort,
    ], timeout: const Duration(seconds: 30));
    final list = result is List
        ? result
        : (result is Map ? (result['data'] ?? result['comments']) : null);
    if (list is List) {
      return list
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    }
    return const [];
  }

  /// 歌手详情。
  Future<Map<String, dynamic>?> getArtistInfo(
    Map<String, dynamic> artistItem,
  ) async {
    final result = await invoke('getArtistInfo', [artistItem]);
    if (result is Map<String, dynamic>) return result;
    if (result is Map && result['data'] is Map) {
      return (result['data'] as Map).cast<String, dynamic>();
    }
    return null;
  }

  /// 导入分享的歌单，返回曲目列表。
  Future<List<Map<String, dynamic>>> importMusicSheet(String url) async {
    final result = await invoke('importMusicSheet', [
      url,
    ], timeout: const Duration(seconds: 45));
    final list = result is List
        ? result
        : (result is Map ? (result['data'] ?? result['musicList']) : null);
    if (list is List) {
      return list
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    }
    return const [];
  }

  /// 导入分享的单曲。
  Future<Map<String, dynamic>?> importMusicItem(String url) async {
    final result = await invoke('importMusicItem', [
      url,
    ], timeout: const Duration(seconds: 45));
    if (result is Map<String, dynamic>) return result;
    if (result is Map && result['data'] is Map) {
      return (result['data'] as Map).cast<String, dynamic>();
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getTopLists() async {
    try {
      final result = await invoke('getTopLists', []);
      if (result is List) {
        return result
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
      }
    } catch (_) {
      // 插件未实现或出错：静默返回空。
    }
    return const [];
  }

  Future<List<Map<String, dynamic>>> getTopListDetail(
    Map<String, dynamic> topListItem, {
    int page = 1,
  }) async {
    final result = await getTopListDetailPage(topListItem, page: page);
    return result.data;
  }

  /// 榜单详情（带 `isEnd`，用于分页）。
  Future<({List<Map<String, dynamic>> data, bool isEnd})> getTopListDetailPage(
    Map<String, dynamic> topListItem, {
    int page = 1,
  }) async {
    final result = await invoke('getTopListDetail', [
      topListItem,
      page,
    ], timeout: const Duration(seconds: 45));
    return _pageResult(result, dataKey: 'musicList', altKeys: ['data']);
  }

  /// 推荐歌单标签列表。
  Future<List<Map<String, dynamic>>> getRecommendSheetTags() async {
    try {
      final result = await invoke(
        'getRecommendSheetTags',
        [],
        timeout: const Duration(seconds: 30),
      );
      if (result is List) return _maps(result);
      if (result is Map && result['data'] is List) {
        return _maps(result['data'] as List);
      }
    } catch (_) {
      // 插件未实现：静默返回空。
    }
    return const [];
  }

  /// 按标签分页获取推荐歌单（tag 为 getRecommendSheetTags 返回的标签对象）。
  Future<({List<Map<String, dynamic>> data, bool isEnd})>
  getRecommendSheetsByTag(dynamic tag, {int page = 1}) async {
    final result = await invoke('getRecommendSheetsByTag', [
      tag,
      page,
    ], timeout: const Duration(seconds: 45));
    return _pageResult(result, dataKey: 'data');
  }

  /// 歌单详情（歌曲列表）。
  Future<({List<Map<String, dynamic>> data, bool isEnd})> getMusicSheetInfo(
    Map<String, dynamic> sheetItem, {
    int page = 1,
  }) async {
    final result = await invoke('getMusicSheetInfo', [
      sheetItem,
      page,
    ], timeout: const Duration(seconds: 60));
    return _pageResult(result, dataKey: 'musicList', altKeys: const ['data']);
  }

  /// 歌手作品：`type` 为 `music`（单曲）或 `album`（专辑）。
  Future<({List<Map<String, dynamic>> data, bool isEnd})> getArtistWorks(
    Map<String, dynamic> artistItem, {
    int page = 1,
    String type = 'music',
  }) async {
    final result = await invoke('getArtistWorks', [
      artistItem,
      page,
      type,
    ], timeout: const Duration(seconds: 45));
    return _pageResult(
      result,
      dataKey: 'data',
      altKeys: const ['musicList', 'albumList'],
    );
  }

  /// 专辑详情（歌曲列表）。
  Future<({List<Map<String, dynamic>> data, bool isEnd})> getAlbumInfo(
    Map<String, dynamic> albumItem, {
    int page = 1,
  }) async {
    final result = await invoke('getAlbumInfo', [
      albumItem,
      page,
    ], timeout: const Duration(seconds: 45));
    return _pageResult(result, dataKey: 'musicList', altKeys: const ['data']);
  }

  /// 搜索建议（部分插件实现）。
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      final result = await invoke('getSearchSuggestions', [
        query,
      ], timeout: const Duration(seconds: 15));
      if (result is List) {
        return result
            .map((e) => '$e'.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } catch (_) {
      // 未实现：静默返回空。
    }
    return const [];
  }

  List<Map<String, dynamic>> _maps(List list) =>
      list.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();

  /// 兼容插件返回 `{isEnd, data/musicList}` 与直接返回数组两种形态。
  ({List<Map<String, dynamic>> data, bool isEnd}) _pageResult(
    dynamic result, {
    required String dataKey,
    List<String> altKeys = const [],
  }) {
    if (result is List) {
      return (data: _maps(result), isEnd: true);
    }
    if (result is Map) {
      dynamic list = result[dataKey];
      for (final key in altKeys) {
        if (list is List) break;
        list = result[key];
      }
      final isEnd = result['isEnd'];
      return (
        data: list is List ? _maps(list) : const <Map<String, dynamic>>[],
        isEnd: isEnd == null ? true : isEnd == true,
      );
    }
    return (data: const <Map<String, dynamic>>[], isEnd: true);
  }

  /// 直接触发 LX 脚本的 request 处理器（歌词等其它 action）。
  ///
  /// 仅 LX 兼容插件可用；自有格式插件没有 request 处理器，调用会抛错。
  Future<dynamic> lxRequest({
    required String source,
    required String action,
    required Map<String, dynamic> info,
    Duration timeout = const Duration(seconds: 15),
  }) {
    return _serial(() => _lxRequest(source, action, info, timeout));
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

  void dispose() => _js.dispose();
}
