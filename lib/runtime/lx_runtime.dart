import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:quickjs_engine/extensions/xhr.dart';
import 'package:quickjs_engine/quickjs_engine.dart';

/// LX Music UserApi 脚本运行时（辅助协议）。
///
/// 与 MusicFree 主协议的分工：
///   - MusicFree 负责搜索、歌单、专辑、作者等**内容发现**
///   - LX 负责按平台解析**播放链接**（musicUrl）
///
/// LX 脚本协议（来自 lx-music-mobile / LX-Y-Music 实现）：
///   lx.on('request', async ({source, action, info}) => ...)
///   lx.send('inited', {status: true, sources: {...}})
///   lx.request(url, options, callback)
///   lx.utils.crypto / lx.utils.buffer
class LxUserApiRuntime {
  LxUserApiRuntime._(this._js);

  final JavascriptRuntime _js;

  /// 创建实例（与 MusicFreeRuntime 相同，需等待 fetch polyfill 注入完成）。
  static Future<LxUserApiRuntime> create({int stackSize = 1024 * 1024}) async {
    final js = QuickJsRuntime2(stackSize: stackSize);
    js.onMessage('lxLog', (dynamic args) {
      if (kDebugMode) debugPrint('[lx] $args');
    });
    js.enableXhr();
    final polyfill = await rootBundle.loadString(
      'packages/quickjs_engine/assets/js/fetch.js',
    );
    js.evaluate(polyfill);
    js.enableHandlePromises();
    return LxUserApiRuntime._(js);
  }

  /// 脚本内声明的源：kw / kg / tx / wy / mg / xm / local
  final Map<String, dynamic> sources = {};

  /// 脚本是否成功 inited
  bool initialized = false;

  String? initError;

  JavascriptRuntime get js => _js;

  /// 注入 LX 沙箱全局对象并执行脚本。
  void loadScript(String source, {required String id, required String name}) {
    _js.evaluate('''
var __lx_console = {
  log: function() { __lx_send_log('log', arguments); },
  info: function() { __lx_send_log('info', arguments); },
  warn: function() { __lx_send_log('warn', arguments); },
  error: function() { __lx_send_log('error', arguments); }
};
function __lx_send_log(level, args) {
  var parts = [];
  for (var i = 0; i < args.length; i++) {
    var a = args[i];
    parts.push(typeof a === 'string' ? a : (a && a.stack) ? a.stack : JSON.stringify(a));
  }
  sendMessage('lxLog', JSON.stringify([level].concat(parts)));
}

var __lx_requestHandler = null;
var __lx_pendingInit = false;

var __lx = {
  version: '2.0.0',
  env: 'mobile',
  EVENT_NAMES: { request: 'request', inited: 'inited', updateAlert: 'updateAlert' },
  currentScriptInfo: {
    name: ${jsonEncode(name)},
    id: ${jsonEncode(id)},
    description: '',
    version: '0.0.0',
    author: '',
    homepage: '',
    rawScript: ''
  },
  on: function(eventName, handler) {
    if (eventName !== 'request') {
      return Promise.reject(new Error('The event is not supported: ' + eventName));
    }
    __lx_requestHandler = handler;
    return Promise.resolve();
  },
  send: function(eventName, data) {
    if (eventName === 'inited') {
      __lx_pendingInit = true;
      globalThis.__lx_initPayload = data || null;
      return Promise.resolve();
    }
    if (eventName === 'updateAlert') {
      globalThis.__lx_updateAlert = data || null;
      return Promise.resolve();
    }
    return Promise.reject(new Error('The event is not supported: ' + eventName));
  },
  request: function(url, options, callback) {
    __lx_do_request(url, options || {}, callback);
    return function() {};
  },
  utils: {
    crypto: {
      md5: function(str) { return __lx_md5(String(str)); },
      aesEncrypt: function(buf, mode, key, iv) { return __lx_aes_encrypt(buf, mode, key, iv || ''); },
      rsaEncrypt: function(buf, key) { return __lx_rsa_encrypt(buf, key); },
      randomBytes: function(size) {
        var out = new Uint8Array(size);
        for (var i = 0; i < size; i++) out[i] = Math.floor(Math.random() * 256);
        return out;
      }
    },
    buffer: {
      from: function(input, encoding) { return __lx_buffer_from(input, encoding); },
      bufToString: function(buf, format) { return __lx_buf_to_string(buf, format); }
    }
  }
};

// 脚本可见的沙箱全局
globalThis.lx = __lx;
globalThis.console = __lx_console;
''');

    // fetch 负责 lx.request 的底部实现（不需要额外的 Dart 桥）
    _js.evaluate('''
function __lx_do_request(url, options, callback) {
  fetch(url, {
    method: (options.method || 'get').toUpperCase(),
    headers: options.headers || {},
    body: options.body || undefined
  }).then(function(resp) {
    return resp.text().then(function(body) {
      var headers = {};
      if (resp.headers && resp.headers.entries) {
        resp.headers.entries().forEach(function(e) { headers[e[0]] = e[1]; });
      }
      callback(null, { statusCode: resp.status, statusMessage: resp.statusText, headers: headers, body: body }, body);
    });
  }).catch(function(err) { callback(err, null, null); });
}
function __lx_buffer_from(input, encoding) {
  if (typeof input === 'string') {
    if (encoding === 'base64') return __b64_to_bytes(input);
    if (encoding === 'hex') {
      var arr = [];
      for (var i = 0; i < input.length; i += 2) arr.push(parseInt(input.substr(i, 2), 16));
      return new Uint8Array(arr);
    }
    var utf8 = unescape(encodeURIComponent(input));
    var bytes = new Uint8Array(utf8.length);
    for (var j = 0; j < utf8.length; j++) bytes[j] = utf8.charCodeAt(j);
    return bytes;
  }
  return new Uint8Array(input);
}
function __b64_to_bytes(b64) {
  var binary = atob(b64);
  var bytes = new Uint8Array(binary.length);
  for (var i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes;
}
function __lx_buf_to_string(buf, format) {
  var bytes = buf instanceof Uint8Array ? buf : new Uint8Array(buf);
  if (format === 'base64') {
    var s = '';
    for (var i = 0; i < bytes.length; i++) s += String.fromCharCode(bytes[i]);
    return btoa(s);
  }
  var out = '';
  for (var k = 0; k < bytes.length; k++) out += String.fromCharCode(bytes[k]);
  try { return decodeURIComponent(escape(out)); } catch (e) { return out; }
}
function __lx_md5(str) {
  // 占位：由 Dart 侧注入真正的 MD5（见 setMd5Provider）
  if (globalThis.__lx_md5_impl) return globalThis.__lx_md5_impl(str);
  throw new Error('md5 is not available');
}
function __lx_aes_encrypt(buf, mode, key, iv) {
  if (globalThis.__lx_aes_impl) return globalThis.__lx_aes_impl(buf, mode, key, iv);
  throw new Error('aesEncrypt is not available');
}
function __lx_rsa_encrypt(buf, key) {
  if (globalThis.__lx_rsa_impl) return globalThis.__lx_rsa_impl(buf, key);
  throw new Error('rsaEncrypt is not available');
}
''');

    final r = _js.evaluate(
      'try { $source\n } catch (e) { globalThis.__lx_loadError = String(e && e.message || e); }',
      sourceUrl: '$id.user-api.js',
    );
    if (r.isError) {
      throw StateError('LX 脚本加载失败: ${r.stringResult}');
    }
    final err = _js.evaluate(
      'typeof globalThis.__lx_loadError === "string" ? globalThis.__lx_loadError : ""',
    );
    if (err.stringResult != '""' && err.stringResult != '') {
      throw StateError('LX 脚本异常: ${err.stringResult}');
    }
  }

  /// 等待脚本调用 `lx.send('inited', ...)`。
  Future<bool> waitForInit({Duration timeout = const Duration(seconds: 10)}) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      _js.executePendingJob();
      final state = _js.evaluate(
        'JSON.stringify({ init: globalThis.__lx_initPayload !== undefined, '
        'handler: typeof __lx_requestHandler === "function", '
        'err: globalThis.__lx_loadError || null })',
      );
      final map = jsonDecode(state.stringResult) as Map<String, dynamic>;
      if (map['err'] != null) {
        initError = map['err'] as String;
        return false;
      }
      if (map['init'] == true) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        _js.executePendingJob();
        final payload = _js.evaluate('JSON.stringify(globalThis.__lx_initPayload)');
        final decoded = jsonDecode(payload.stringResult);
        if (decoded is Map<String, dynamic>) {
          if (decoded['status'] == false) {
            initError = (decoded['message'] ?? 'init failed').toString();
            return false;
          }
          final src = decoded['sources'];
          if (src is Map) sources.addAll(src.cast<String, dynamic>());
        }
        initialized = true;
        return true;
      }
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    initError = '初始化超时';
    return false;
  }

  /// 请求播放链接等资源。返回插件给出的原始响应。
  ///
  /// [source] 例如 `kw` / `tx`；[action] 例如 `musicUrl`；[info] 是歌曲信息。
  Future<dynamic> request({
    required String source,
    required String action,
    required Map<String, dynamic> info,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    if (!initialized) throw StateError('LX 脚本尚未初始化');

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
      final st = _js.evaluate(
        'JSON.stringify({ done: globalThis.__lx_requestInFlight === false, '
        'r: globalThis.__lx_result === undefined ? null : globalThis.__lx_result, '
        'e: globalThis.__lx_resultError || null })',
      );
      final m = jsonDecode(st.stringResult) as Map<String, dynamic>;
      if (m['done'] == true) {
        if (m['e'] != null) throw StateError('LX 请求失败: ${m['e']}');
        return m['r'];
      }
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    throw StateError('LX 请求超时');
  }

  /// 预留：Dart 侧加密注入。
  ///
  /// 注意：QuickJS 的 sendMessage 是异步的，无法支撑脚本里**同步**调用的
  /// `lx.utils.crypto.md5()`。若要支持，需要给原生桥加同步调用，或把纯 JS 版
  /// 的 crypto 实现打成资源随引擎预加载。当前 LX 脚本若只用 musicUrl 的
  /// 常见实现（多数不需要 md5）可以正常工作。
  /// 求值一个表达式并取字符串结果。
  String? evaluateString(String code) {
    final r = _js.evaluate('JSON.stringify($code)');
    if (r.isError) return null;
    final text = r.stringResult;
    if (text == 'undefined' || text == 'null') return null;
    try {
      final v = jsonDecode(text);
      return v?.toString();
    } catch (_) {
      return text;
    }
  }

  /// 取播放链接：调用脚本的 request(musicUrl) 并归一化结果。
  ///
  /// [source] 必须是脚本 `lx.send('inited', ...)` 里声明过的源。
  Future<String> resolveMusicUrl({
    required String source,
    required Map<String, dynamic> musicInfo,
    String quality = '320k',
  }) async {
    if (!sources.containsKey(source)) {
      throw StateError('该脚本未声明源 "$source"，可用: ${sources.keys.join(", ")}');
    }
    final raw = await request(
      source: source,
      action: 'musicUrl',
      info: {'type': quality, 'musicInfo': musicInfo},
    );
    final url = raw is String ? raw : (raw is Map ? raw['url'] : null);
    if (url is! String || url.isEmpty) {
      throw StateError('脚本未返回有效播放链接');
    }
    return url;
  }

  void dispose() => _js.dispose();
}
