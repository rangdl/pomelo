import 'dart:convert';

import 'package:quickjs_engine/quickjs_engine.dart';

import 'lx_crypto.dart';

/// LX UserApi 脚本头部注释里的元信息（`@name` / `@version` / `@author` ...）。
///
/// LX 脚本没有 `module.exports`，名称与版本只能从注释块解析。
class LxScriptMeta {
  const LxScriptMeta({
    this.name,
    this.description,
    this.version,
    this.author,
    this.homepage,
  });

  final String? name;
  final String? description;
  final String? version;
  final String? author;
  final String? homepage;

  bool get isEmpty =>
      name == null &&
      description == null &&
      version == null &&
      author == null &&
      homepage == null;

  /// 解析脚本开头的注释块；字段缺失返回 null。
  static LxScriptMeta parse(String source) {
    final head = source.length > 8000 ? source.substring(0, 8000) : source;

    String? pick(String key) {
      final match = RegExp('@${RegExp.escape(key)}[ \\t]+([^\\r\\n]+)')
          .firstMatch(head);
      final raw = match?.group(1);
      if (raw == null) return null;
      final value = raw
          .replaceAll(RegExp(r'\*+/\s*$'), '')
          .replaceAll(RegExp(r'\s*\*+\s*$'), '')
          .trim();
      return value.isEmpty ? null : value;
    }

    return LxScriptMeta(
      name: pick('name'),
      description: pick('description'),
      version: pick('version'),
      author: pick('author'),
      homepage: pick('homepage'),
    );
  }
}

/// LX 音源脚本兼容层。
///
/// 统一运行时**无条件**注入本层的 `lx` 全局对象：自有格式插件完全不碰它，
/// LX 脚本则按原生协议 `lx.on/lx.send/lx.request` 注册自己。脚本注册完成后，
/// 兼容层把 LX 能力包装成一个与自有格式同形的导出对象，宿主因此完全不需要
/// 区分插件出身。
class LxCompat {
  const LxCompat._();

  /// 注册 Dart 侧同步加密桥（必须在脚本执行前调用）。
  static void installBridges(JavascriptRuntime js) {
    js.onMessage('lxMd5', (dynamic args) {
      // 新协议传 base64 字节（与原生 LX 一致，支持字符串与 Buffer）。
      final payload = _asMap(args);
      final data = payload['data'];
      if (data is String) return LxCrypto.md5Bytes(base64.decode(data));
      final input = (args is List && args.isNotEmpty)
          ? '${args.first}'
          : '$args';
      return LxCrypto.md5Hex(input);
    });

    js.onMessage('lxAesEncrypt', (dynamic args) {
      final payload = _asMap(args);
      return LxCrypto.aesEncryptBase64(
        dataB64: '${payload['data'] ?? ''}',
        mode: '${payload['mode'] ?? 'aes-128-cbc'}',
        keyB64: '${payload['key'] ?? ''}',
        ivB64: '${payload['iv'] ?? ''}',
      );
    });

    js.onMessage('lxAesDecrypt', (dynamic args) {
      final payload = _asMap(args);
      return LxCrypto.aesDecryptBase64(
        dataB64: '${payload['data'] ?? ''}',
        mode: '${payload['mode'] ?? 'aes-128-cbc'}',
        keyB64: '${payload['key'] ?? ''}',
        ivB64: '${payload['iv'] ?? ''}',
      );
    });

    js.onMessage('lxRsaEncrypt', (dynamic args) {
      final payload = _asMap(args);
      return LxCrypto.rsaEncryptBase64(
        dataB64: '${payload['data'] ?? ''}',
        key: '${payload['key'] ?? ''}',
      );
    });
  }

  static Map<String, dynamic> _asMap(dynamic args) {
    if (args is Map) return args.cast<String, dynamic>();
    if (args is List && args.isNotEmpty && args.first is Map) {
      return (args.first as Map).cast<String, dynamic>();
    }
    return const {};
  }

  /// 每个插件加载前执行的沙箱前奏：日志、`lx` 全局对象、CommonJS 容器。
  ///
  /// [rawScript] 必须是插件源码原文：部分脚本会把它作为请求头做完整性校验
  /// （如野花音源），留空会被服务端拒绝。
  static String prelude({
    required String id,
    required String name,
    String version = '',
    String author = '',
    String description = '',
    String homepage = '',
    String rawScript = '',
  }) =>
      '''
var __pluginModule = { exports: {} };
function __noRequire(requireName) {
  throw new Error('require("' + requireName + '") is not available in this runtime. ' +
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
  os: 'android',
  getUserVariables: function() { return __pluginEnv.userVariables || {}; }
};

function __lx_send_log(level, args) {
  var parts = [];
  for (var i = 0; i < args.length; i++) {
    var a = args[i];
    parts.push(typeof a === 'string' ? a : (a && a.stack) ? a.stack : JSON.stringify(a));
  }
  sendMessage('lxLog', JSON.stringify([level].concat(parts)));
}
var __lx_console = {
  log: function() { __lx_send_log('log', arguments); },
  info: function() { __lx_send_log('info', arguments); },
  warn: function() { __lx_send_log('warn', arguments); },
  error: function() { __lx_send_log('error', arguments); }
};

var __lx_requestHandler = null;

var __lx = {
  version: '2.0.0',
  env: 'mobile',
  EVENT_NAMES: { request: 'request', inited: 'inited', updateAlert: 'updateAlert' },
  currentScriptInfo: {
    name: ${jsonEncode(name)},
    id: ${jsonEncode(id)},
    description: ${jsonEncode(description)},
    version: ${jsonEncode(version.isEmpty ? '0.0.0' : version)},
    author: ${jsonEncode(author)},
    homepage: ${jsonEncode(homepage)},
    rawScript: ${jsonEncode(rawScript)}
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
  utils: null
};

globalThis.lx = __lx;
globalThis.console = __lx_console;
''';

  /// 兼容层实现：crypto/buffer 工具、请求桥、以及把 LX 能力包装成
  /// 自有格式导出对象的工厂函数。
  static const String bridge = r'''
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
      // 原生 LX 支持字符串与字节缓冲区；按 base64 传字节避免编码丢失。
      var payload = { data: __lx_bytes_to_b64(__lx_to_bytes(input)) };
      return sendMessage('lxMd5', JSON.stringify(payload));
    },
    aesEncrypt: function(input, mode, key, iv) {
      var payload = {
        data: __lx_bytes_to_b64(__lx_to_bytes(input)),
        mode: mode,
        key: __lx_bytes_to_b64(__lx_to_bytes(key)),
        iv: __lx_bytes_to_b64(__lx_to_bytes(iv || new Uint8Array(0)))
      };
      var outB64 = sendMessage('lxAesEncrypt', JSON.stringify(payload));
      return __lx_b64_to_bytes(outB64);
    },
    aesDecrypt: function(input, mode, key, iv) {
      var payload = {
        data: __lx_bytes_to_b64(__lx_to_bytes(input)),
        mode: mode,
        key: __lx_bytes_to_b64(__lx_to_bytes(key)),
        iv: __lx_bytes_to_b64(__lx_to_bytes(iv || new Uint8Array(0)))
      };
      var outB64 = sendMessage('lxAesDecrypt', JSON.stringify(payload));
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
  var headers = {};
  var passed = options.headers || {};
  for (var k in passed) headers[k] = passed[k];

  var hasUa = false;
  var hasCt = false;
  for (var name in headers) {
    var lower = name.toLowerCase();
    if (lower === 'user-agent') hasUa = true;
    if (lower === 'content-type') hasCt = true;
  }
  // 与 LX 桌面端一致：缺省带上浏览器 UA，部分接口会校验。
  if (!hasUa) {
    headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; WOW64) '
      + 'AppleWebKit/537.36 (KHTML, like Gecko) '
      + 'Chrome/69.0.3497.100 Safari/537.36';
  }

  var body = options.body;
  if (body == null && options.form && typeof options.form === 'object') {
    // 原生 LX 会把 form 对象编码为 x-www-form-urlencoded。
    var pairs = [];
    for (var f in options.form) {
      pairs.push(encodeURIComponent(f) + '=' + encodeURIComponent(options.form[f]));
    }
    body = pairs.join('&');
    if (!hasCt) {
      headers['Content-Type'] = 'application/x-www-form-urlencoded';
      hasCt = true;
    }
  } else if (body != null && typeof body === 'object' && !(body instanceof Uint8Array)) {
    // 原生 LX 用 needle 的 json 选项序列化对象请求体。
    body = JSON.stringify(body);
    if (!hasCt) {
      headers['Content-Type'] = 'application/json';
      hasCt = true;
    }
  }

  fetch(url, {
    method: (options.method || 'get').toUpperCase(),
    headers: headers,
    body: body == null ? undefined : body
  }).then(function(resp) {
    return resp.text().then(function(text) {
      var outHeaders = {};
      if (resp.headers && resp.headers.entries) {
        resp.headers.entries().forEach(function(e) { outHeaders[e[0]] = e[1]; });
      }
      // 原生 LX 会对响应体尝试 JSON.parse（失败则保留字符串）。
      var parsed = text;
      try { parsed = JSON.parse(text); } catch (e) {}
      var raw = new Uint8Array(text.length);
      for (var i = 0; i < text.length; i++) raw[i] = text.charCodeAt(i) & 0xff;
      callback(null, {
        statusCode: resp.status, statusMessage: resp.statusText,
        headers: outHeaders, bytes: raw.length, raw: raw, body: parsed
      }, parsed);
    });
  }).catch(function(err) { callback(err, null, null); });
}

// ---- 音源声明与音质降级 -------------------------------------------------

function __lx_sources_map() {
  var payload = globalThis.__lx_initPayload || {};
  var sources = payload.sources;
  return (sources && typeof sources === 'object') ? sources : {};
}

function __lx_qualitys_of(key) {
  var s = __lx_sources_map()[key];
  if (Array.isArray(s)) return s;
  if (s && Array.isArray(s.qualitys)) return s.qualitys;
  return [];
}

// 宿主统一用 standard/higher/highest；不可用时按 flac > 320k > 128k 逐级降档。
function __lx_quality_chain(requested) {
  var target = (requested === 'highest' || requested === 'flac') ? 'flac'
    : (requested === 'higher' || requested === '320k') ? '320k'
    : (requested === 'standard' || requested === '128k') ? '128k'
    : requested;
  var order = ['flac', '320k', '128k'];
  var idx = order.indexOf(target);
  if (idx < 0) return [target];
  return order.slice(idx);
}

function __lx_pick_quality(key, requested) {
  var chain = __lx_quality_chain(requested);
  var supported = __lx_qualitys_of(key);
  if (!supported.length) return chain[0];
  for (var i = 0; i < chain.length; i++) {
    if (supported.indexOf(chain[i]) >= 0) return chain[i];
  }
  // 声明了非常规音质名（如 hires）时，退而用它声明的第一项，保证可播。
  return supported[0];
}

function __lx_create_virtual_exports(platform, version, author, description) {
  var keys = Object.keys(__lx_sources_map());

  function declOf(key) {
    var s = __lx_sources_map()[key];
    return (s && typeof s === 'object' && !Array.isArray(s)) ? s : {};
  }

  function actionsOf(key) {
    var d = declOf(key);
    return Array.isArray(d.actions) ? d.actions : [];
  }

  function anySupports(action) {
    for (var i = 0; i < keys.length; i++) {
      if (actionsOf(keys[i]).indexOf(action) >= 0) return true;
    }
    return false;
  }

  function resolveKey(sourceKey) {
    var key = (typeof sourceKey === 'string' && sourceKey)
      ? sourceKey
      : (keys.length === 1 ? keys[0] : null);
    if (!key) {
      throw new Error('该脚本声明了多个音源，需要指定音源 key: ' + keys.join(','));
    }
    if (keys.length && keys.indexOf(key) < 0) {
      throw new Error('该脚本未声明音源 "' + key + '"，可用: ' + keys.join(','));
    }
    return key;
  }

  // 只保留插件原始字段，剔除宿主内部标记。
  function cleanItem(musicItem) {
    var src = musicItem || {};
    var info = {};
    for (var k in src) {
      if (k === '_pluginId' || k === '_sourceKey' || k === 'lxSource') continue;
      info[k] = src[k];
    }
    return info;
  }

  // 跨插件兜底时曲目来自别的插件，字段命名与 LX 脚本惯用名不同（如 title/artist
  // vs name/singer），直接交给 LX 取链会因缺少 songmid/hash 等字段而失败。
  // 这里按 LX 生态的通用字段补齐别名，原始字段保持不变。
  function normalizeItem(musicItem) {
    var info = cleanItem(musicItem);
    if (info.songmid == null || info.songmid === '') {
      if (info.id != null) info.songmid = info.id;
    }
    if (info.hash == null || info.hash === '') {
      if (info.id != null) info.hash = info.id;
    }
    if (info.name == null || info.name === '') {
      if (info.title != null) info.name = info.title;
    }
    if (info.singer == null || info.singer === '') {
      info.singer = info.artist != null ? info.artist
        : (info.artists != null ? info.artists : '');
    }
    if (info.albumName == null || info.albumName === '') {
      info.albumName = info.album != null ? info.album : '';
    }
    if (info.interval == null && info.duration != null) {
      info.interval = info.duration;
    }
    return info;
  }

  function getMediaSource(musicItem, quality, sourceKey) {
    return new Promise(function(resolve, reject) {
      var key, q;
      try {
        key = resolveKey(sourceKey);
        q = __lx_pick_quality(key, quality);
        if (!q) throw new Error('音源 "' + key + '" 不支持任何可用音质');
      } catch (e) {
        reject(e);
        return;
      }
      if (typeof __lx_requestHandler !== 'function') {
        reject(new Error('脚本未注册 request 处理器'));
        return;
      }
      Promise.resolve()
        .then(function() {
          return __lx_requestHandler({
            source: key,
            action: 'musicUrl',
            info: { type: q, musicInfo: normalizeItem(musicItem) }
          });
        })
        .then(function(r) {
          if (typeof r === 'string') { resolve({ url: r }); return; }
          if (r && typeof r === 'object' && typeof r.url === 'string') {
            resolve(r);
            return;
          }
          reject(new Error('脚本未返回有效播放链接'));
        })
        .catch(reject);
    });
  }

  function getLyric(musicItem, sourceKey) {
    return new Promise(function(resolve, reject) {
      var key;
      try {
        key = resolveKey(sourceKey);
      } catch (e) {
        reject(e);
        return;
      }
      if (typeof __lx_requestHandler !== 'function') {
        reject(new Error('脚本未注册 request 处理器'));
        return;
      }
      Promise.resolve()
        .then(function() {
          return __lx_requestHandler({
            source: key,
            action: 'lyric',
            info: { musicInfo: normalizeItem(musicItem) }
          });
        })
        .then(function(r) { resolve(r === undefined ? null : r); })
        .catch(reject);
    });
  }

  var exports = {
    platform: platform,
    version: version,
    author: author,
    description: description,
    sourceKeys: keys,
    compat: 'lx',
    getMediaSource: getMediaSource
  };
  // 只有脚本真的声明了 lyric action 才暴露歌词能力。
  if (anySupports('lyric')) exports.getLyric = getLyric;
  return exports;
}
''';

  /// 生成"把 LX 脚本包装成自有格式导出"的 JS 语句。
  static String createVirtualExports({
    required String platform,
    required String version,
    required String author,
    required String description,
  }) =>
      '__pluginModule.exports = __lx_create_virtual_exports('
      '${jsonEncode(platform)}, ${jsonEncode(version)}, '
      '${jsonEncode(author)}, ${jsonEncode(description)});';
}
