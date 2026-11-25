import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:quickjs_engine/extensions/xhr.dart';
import 'package:quickjs_engine/quickjs_engine.dart';

/// MusicFree 风格插件运行时骨架。
///
/// 插件协议（受限于 fetch + JSON，无 npm 依赖）：
///   module.exports = { platform, version, search, getMediaSource, ... }
/// 宿主把插件包在 CommonJS 包装函数里执行，注入 require/module/exports/console/env。
class MusicFreeRuntime {
  MusicFreeRuntime._(this._js);

  final JavascriptRuntime _js;
  bool _loaded = false;

  JavascriptRuntime get js => _js;

  /// 创建实例。
  ///
  /// 不能直接用 `getJavascriptRuntime()`：它内部调用 `enableFetch()` 但
  /// 不 await，而 `enableFetch` 要通过 rootBundle 异步读取 fetch polyfill，
  /// 导致 fetch 尚未注入脚本就执行（实测报 `fetch is not defined`）。
  static Future<MusicFreeRuntime> create({int stackSize = 1024 * 1024}) async {
    final js = QuickJsRuntime2(stackSize: stackSize);
    js.onMessage('pluginLog', (dynamic args) {
      if (kDebugMode) debugPrint('[plugin] $args');
    });
    // 顺序执行：先 XHR，再 fetch polyfill（都依赖异步资源），最后 Promise 支持
    js.enableXhr();
    final polyfill = await rootBundle.loadString(
      'packages/quickjs_engine/assets/js/fetch.js',
    );
    js.evaluate(polyfill);
    js.enableHandlePromises();
    return MusicFreeRuntime._(js);
  }

  /// 执行插件源码。插件须使用 `module.exports = {...}` 导出实例。
  void loadPlugin(String source, {String name = 'plugin'}) {
    // CommonJS 包装：与 MusicFree 的 Function(...) 包装保持一致，
    // 但不注入 axios/cheerio 等 npm 包——只给 console 与 env。
    final wrapped =
        '''
(function(module, exports, require, console, env) {
  "use strict";
  $source
})(__pluginModule, __pluginModule.exports, __noRequire, __pluginConsole, __pluginEnv);
__pluginModule.exports;
''';

    final prelude = '''
var __pluginModule = { exports: {} };
function __noRequire(name) {
  throw new Error('require("' + name + '") is not available in this runtime. ' +
    'Only fetch() and standard JS builtins are provided.');
}
var __pluginConsole = {
  log: function() { sendMessage('pluginLog', JSON.stringify(Array.prototype.slice.call(arguments).map(String))); },
  info: function() { sendMessage('pluginLog', JSON.stringify(Array.prototype.slice.call(arguments).map(String))); },
  warn: function() { sendMessage('pluginLog', JSON.stringify(Array.prototype.slice.call(arguments).map(String))); },
  error: function() { sendMessage('pluginLog', JSON.stringify(Array.prototype.slice.call(arguments).map(String))); }
};
var __pluginEnv = {
  appVersion: '0.1.0',
  userVariables: {},
  os: 'android'
};
''';

    _js.evaluate(prelude);
    final result = _js.evaluate(wrapped, sourceUrl: '$name.js');
    if (result.isError) {
      throw StateError('插件加载失败: ${result.stringResult}');
    }
    _loaded = true;
  }

  /// 调用插件方法，等待 Promise 结算并返回 JSON 可序列化结果。
  ///
  /// [timeout] 控制等待上限：歌词等可能拉大响应的接口需要更长时间。
  Future<dynamic> invoke(
    String method,
    List<dynamic> args, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
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

    // 驱动 JS 事件循环（Promise 微任务 + 我们注入的异步任务）
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      _js.executePendingJob();
      final done = _js.evaluate(
        'JSON.stringify({r: globalThis.__lastResult, e: globalThis.__lastError, '
        'finished: globalThis.__lastResult !== undefined || globalThis.__lastError !== undefined})',
      );
      final state = jsonDecode(done.stringResult) as Map<String, dynamic>;
      if (state['finished'] == true) {
        if (state['e'] != null) throw StateError('插件方法异常: ${state['e']}');
        final r = state['r'];
        if (r is Map && r['__unsupported'] == true) {
          throw UnsupportedError('插件未实现 $method');
        }
        return r;
      }
      // fetch 的回调在 Dart 事件队列里，让出一下
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    throw StateError('调用 $method 超时');
  }

  /// 求值并解析 JSON 结果（返回 null 表示 JS 侧给出 null/undefined）。
  Map<String, dynamic>? evaluateJson(String code) {
    final r = _js.evaluate('JSON.stringify($code)');
    if (r.isError) throw StateError('求值失败: ${r.stringResult}');
    final text = r.stringResult;
    if (text == 'undefined' || text == 'null') return null;
    // evaluate 可能把字符串结果再包一层引号，先解包一次
    try {
      final decoded = jsonDecode(text);
      if (decoded is String) {
        final inner = jsonDecode(decoded);
        return inner is Map<String, dynamic> ? inner : null;
      }
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  /// 搜索。返回 `{isEnd, data}`。
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

  /// 获取播放地址。返回 `{url, headers?}`；插件未实现时返回 null。
  Future<Map<String, dynamic>?> getMediaSource(
    Map<String, dynamic> musicItem,
    String quality,
  ) async {
    final result = await invoke('getMediaSource', [musicItem, quality]);
    if (result is Map<String, dynamic> && result['url'] is String) {
      return result;
    }
    if (result is String) return {'url': result};
    return null;
  }

  /// 获取榜单列表。协议返回 `[{title, data: [{id, title, ...}]}]`。
  /// 插件不支持时返回空列表。
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

  /// 获取某个榜单详情（歌曲列表）。协议返回 `{isEnd, musicList}`。
  Future<List<Map<String, dynamic>>> getTopListDetail(
    Map<String, dynamic> topListItem, {
    int page = 1,
  }) async {
    // 榜单详情接口响应较大（几十到几百 KB），给更宽松的超时。
    final result = await invoke(
      'getTopListDetail',
      [topListItem, page],
      timeout: const Duration(seconds: 45),
    );
    if (result is Map<String, dynamic>) {
      final list = result['musicList'];
      if (list is List) {
        return list
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
      }
    }
    return const [];
  }

  void dispose() => _js.dispose();
}
