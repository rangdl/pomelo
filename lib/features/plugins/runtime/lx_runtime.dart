import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:quickjs_engine/extensions/xhr.dart';
import 'package:quickjs_engine/quickjs_engine.dart';

import 'lx_crypto.dart';

/// LX Music UserApi 脚本运行时（辅助协议：按平台解析播放链接）。
///
/// 与 MusicFree 主协议的分工：
///   - MusicFree 负责搜索、歌单、专辑等**内容发现**
///   - LX 负责按平台把歌曲解析成**播放直链**（musicUrl）
///
/// 脚本协议（与 lx-music-mobile 一致）：
///   lx.on('request', async ({source, action, info}) => ...)
///   lx.send('inited', {status: true, sources: {...}})
///   lx.request(url, options, callback)
///   lx.utils.crypto / lx.utils.buffer
class LxUserApiRuntime {
  LxUserApiRuntime._(this._js);

  final JavascriptRuntime _js;

  /// 脚本声明的源：kw / kg / tx / wy / mg / xm / local
  final Map<String, dynamic> sources = {};

  bool initialized = false;
  String? initError;

  JavascriptRuntime get js => _js;

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
    final rt = LxUserApiRuntime._(js);
    rt.installNativeCrypto();
    return rt;
  }

  /// 注入 LX 沙箱全局对象并执行脚本。
  void loadScript(String source, {required String id, required String name}) {
    _js.evaluate(_prelude(id: id, name: name));
    _js.evaluate(_bridgeCode);
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

  String _prelude({required String id, required String name}) =>
      '''
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

var __lx = {
  version: '2.0.0',
  env: 'mobile',
  EVENT_NAMES: { request: 'request', inited: 'inited', updateAlert: 'updateAlert' },
  currentScriptInfo: {
    name: ${jsonEncode(name)},
    id: ${jsonEncode(id)},
    description: '', version: '0.0.0', author: '', homepage: '', rawScript: ''
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
  utils: null  // 在 __lx_bridge 中填充
};

globalThis.lx = __lx;
globalThis.console = __lx_console;
''';

  /// 同步桥 + crypto/buffer 实现。
  ///
  /// `sendMessage(channel, payload)` 在 quickjs_engine 中是**同步**的：
  /// Dart 侧注册的回调直接把返回值转成 JS 值返回给脚本。
  /// 所以脚本里 `sendMessage('lxMd5', s)` 能立刻拿到字符串。
  static const String _bridgeCode = r'''
function __lx_b64_to_bytes(b64) {
  var bin = atob(b64);
  var out = new Uint8Array(bin.length);
  for (var i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}
function __lx_bytes_to_b64(bytes) {
  var s = '';
  for (var i = 0; i < bytes.length; i++) s += String.fromCharCode(bytes[i]);
  return btoa(s);
}
function __lx_to_bytes(input, encoding) {
  if (typeof input === 'string') {
    if (encoding === 'base64') return __lx_b64_to_bytes(input);
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
  return input instanceof Uint8Array ? input : new Uint8Array(input);
}

__lx.utils = {
  crypto: {
    md5: function(input) {
      return sendMessage('lxMd5', JSON.stringify([String(input)]));
    },
    aesEncrypt: function(input, mode, key, iv) {
      // 输入与 key/iv 一律按 base64 字符串传输，Dart 侧解码后加密。
      var payload = {
        data: __lx_bytes_to_b64(__lx_to_bytes(input)),
        mode: mode,
        key: __lx_bytes_to_b64(__lx_to_bytes(key)),
        iv: __lx_bytes_to_b64(__lx_to_bytes(iv || new Uint8Array(0)))
      };
      var outB64 = sendMessage('lxAesEncrypt', JSON.stringify(payload));
      return __lx_b64_to_bytes(outB64);
    },
    rsaEncrypt: function(input, key) {
      var payload = {
        data: __lx_bytes_to_b64(__lx_to_bytes(input)),
        key: String(key)
      };
      var outB64 = sendMessage('lxRsaEncrypt', JSON.stringify(payload));
      return __lx_b64_to_bytes(outB64);
    },
    randomBytes: function(size) {
      var out = new Uint8Array(size);
      for (var i = 0; i < size; i++) out[i] = Math.floor(Math.random() * 256);
      return out;
    }
  },
  buffer: {
    from: function(input, encoding) { return __lx_to_bytes(input, encoding); },
    bufToString: function(buf, format) {
      var bytes = buf instanceof Uint8Array ? buf : new Uint8Array(buf);
      if (format === 'base64') return __lx_bytes_to_b64(bytes);
      if (format === 'hex') {
        var h = '';
        for (var i = 0; i < bytes.length; i++) {
          h += ('0' + bytes[i].toString(16)).slice(-2);
        }
        return h;
      }
      var out = '';
      for (var k = 0; k < bytes.length; k++) out += String.fromCharCode(bytes[k]);
      try { return decodeURIComponent(escape(out)); } catch (e) { return out; }
    }
  }
};

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
      callback(null, {
        statusCode: resp.status, statusMessage: resp.statusText,
        headers: headers, body: body
      }, body);
    });
  }).catch(function(err) { callback(err, null, null); });
}
''';

  /// 注册同步桥接通道。
  ///
  /// quickjs_engine 的 `sendMessage` 是同步的：Dart 回调的返回值会被直接
  /// 转成 JS 值回传给脚本，因此脚本里可以写成同步调用。
  ///
  /// 必须在 `loadScript` **之前**调用。
  void installNativeCrypto() {
    _js.onMessage('lxMd5', (dynamic args) {
      final input = (args is List && args.isNotEmpty)
          ? '${args.first}'
          : '$args';
      return LxCrypto.md5Hex(input);
    });

    _js.onMessage('lxAesEncrypt', (dynamic args) {
      final payload = _asMap(args);
      return LxCrypto.aesEncryptBase64(
        dataB64: '${payload['data'] ?? ''}',
        mode: '${payload['mode'] ?? 'aes-128-cbc'}',
        keyB64: '${payload['key'] ?? ''}',
        ivB64: '${payload['iv'] ?? ''}',
      );
    });

    _js.onMessage('lxRsaEncrypt', (dynamic args) {
      final payload = _asMap(args);
      return LxCrypto.rsaEncryptBase64(
        dataB64: '${payload['data'] ?? ''}',
        key: '${payload['key'] ?? ''}',
      );
    });
  }

  Map<String, dynamic> _asMap(dynamic args) {
    if (args is Map) return args.cast<String, dynamic>();
    if (args is List && args.isNotEmpty && args.first is Map) {
      return (args.first as Map).cast<String, dynamic>();
    }
    return const {};
  }

  Future<bool> waitForInit({
    Duration timeout = const Duration(seconds: 10),
  }) async {
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
        final payload = _js.evaluate(
          'JSON.stringify(globalThis.__lx_initPayload)',
        );
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

  String? evaluateString(String code) {
    final r = _js.evaluate('JSON.stringify($code)');
    if (r.isError) return null;
    final text = r.stringResult;
    if (text == 'undefined' || text == 'null') return null;
    try {
      return jsonDecode(text)?.toString();
    } catch (_) {
      return text;
    }
  }

  /// 取播放直链。
  ///
  /// [source] 必须是脚本在 `lx.send('inited', ...)` 里声明过的源。
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
