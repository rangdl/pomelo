import 'dart:convert';

import 'package:html/parser.dart';
import 'package:quickjs_engine/quickjs_engine.dart';

import 'lx_crypto.dart';

/// MusicFree 插件兼容层。
///
/// MusicFree 插件普遍依赖 `require("axios")` / `require("he")`，而本项目的
/// QuickJS 运行时只提供 fetch 与 JS 内建对象。兼容层在运行时里注册一个最小
/// 的 CommonJS 模块表：`axios` 翻译成基于 fetch 的垫片，`he.decode` 通过
/// Dart 桥交给 `package:html` 的 HTML5 tokenizer。插件源码因此可以保持上游
/// 原样（不再需要在每个插件头部注入代码）。
///
/// 使用顺序：[LxCompat.prelude] 先定义 `__pluginModules` 与 `__pluginRequire`，
/// 再执行 [bootstrap] 注册模块，最后才执行插件源码。
class MusicfreeCompat {
  const MusicfreeCompat._();

  /// 注册 Dart 侧同步桥（必须在脚本执行前调用）。
  ///
  /// `he.decode` 交给 `package:html` 的 HTML5 tokenizer 处理，覆盖全部命名
  /// 实体与数字实体；无 `&` 的普通文本直接返回，不进入解析。
  static void installBridges(JavascriptRuntime js) {
    js.onMessage('mfHeDecode', (dynamic args) {
      final input = '${args is List && args.isNotEmpty ? args.first : args}';
      if (!input.contains('&')) return input;
      // 真实尖括号先转义，避免被当作标签解析掉；已有实体不受影响。
      final escaped = input.replaceAll('<', '&lt;').replaceAll('>', '&gt;');
      return parseFragment(escaped).text ?? '';
    });

    // crypto-js 的 MD5 垫片：插件常用 `CryptoJS.MD5(x).toString()` 生成签名，
    // 走 Dart 侧 md5（与 LX 一致）。入参为 JSON：{text} 纯文本或 {data} base64 字节。
    js.onMessage('mfMd5', (dynamic args) {
      final payload = args is Map
          ? Map<String, dynamic>.from(args)
          : <String, dynamic>{};
      final data = payload['data'];
      if (data is String) return LxCrypto.md5Bytes(base64.decode(data));
      final text = payload['text'];
      if (text is String) return LxCrypto.md5Hex(text);
      return LxCrypto.md5Hex('$args');
    });
  }

  /// 注册 `axios` / `he` 模块；必须在 prelude 之后、插件源码之前执行。
  static const String bootstrap = r'''
(function () {
  if (typeof __pluginModules !== 'object' || __pluginModules === null) {
    throw new Error('MusicFree 兼容层未初始化：缺少 __pluginModules');
  }
  if (typeof fetch !== 'function') {
    throw new Error('MusicFree 兼容层需要全局 fetch');
  }

  // ---- TextEncoder / TextDecoder 垫片 -----------------------------------
  // 部分插件（如咪咕解密）用到 TextEncoder/TextDecoder，QuickJS 默认没有。
  // 这里实现 UTF-8 编解码的最小版本。
  if (typeof globalThis.TextEncoder === 'undefined') {
    globalThis.TextEncoder = function () {};
    globalThis.TextEncoder.prototype.encode = function (str) {
      str = String(str === undefined ? '' : str);
      var bytes = [];
      for (var i = 0; i < str.length; i++) {
        var c = str.charCodeAt(i);
        if (c < 0x80) bytes.push(c);
        else if (c < 0x800) {
          bytes.push(0xc0 | (c >> 6), 0x80 | (c & 0x3f));
        } else if (c >= 0xd800 && c <= 0xdbff) {
          var c2 = str.charCodeAt(++i);
          var cp = 0x10000 + ((c - 0xd800) << 10) + (c2 - 0xdc00);
          bytes.push(0xf0 | (cp >> 18), 0x80 | ((cp >> 12) & 0x3f),
            0x80 | ((cp >> 6) & 0x3f), 0x80 | (cp & 0x3f));
        } else {
          bytes.push(0xe0 | (c >> 12), 0x80 | ((c >> 6) & 0x3f), 0x80 | (c & 0x3f));
        }
      }
      return new Uint8Array(bytes);
    };
  }
  if (typeof globalThis.TextDecoder === 'undefined') {
    globalThis.TextDecoder = function () {};
    globalThis.TextDecoder.prototype.decode = function (input) {
      var u8 = (input instanceof Uint8Array) ? input : new Uint8Array(input || []);
      var out = '';
      for (var i = 0; i < u8.length;) {
        var c = u8[i++];
        if (c < 0x80) out += String.fromCharCode(c);
        else if (c < 0xe0) out += String.fromCharCode(((c & 0x1f) << 6) | (u8[i++] & 0x3f));
        else if (c < 0xf0) out += String.fromCharCode(((c & 0x0f) << 12) | ((u8[i++] & 0x3f) << 6) | (u8[i++] & 0x3f));
        else {
          var cp = ((c & 0x07) << 18) | ((u8[i++] & 0x3f) << 12) | ((u8[i++] & 0x3f) << 6) | (u8[i++] & 0x3f);
          cp -= 0x10000;
          out += String.fromCharCode(0xd800 + (cp >> 10), 0xdc00 + (cp & 0x3ff));
        }
      }
      return out;
    };
  }

  // ---- axios 垫片（基于 fetch 的最小子集） ---------------------------------
  function __pmQsPart(key, value) {
    if (value === undefined || value === null) return null;
    if (value instanceof Date) value = value.toISOString();
    else if (typeof value === 'object') {
      try { value = JSON.stringify(value); } catch (e) { value = String(value); }
    }
    return encodeURIComponent(key) + '=' + encodeURIComponent(String(value));
  }

  function __pmQs(params) {
    if (!params) return '';
    var parts = [];
    Object.keys(params).forEach(function (key) {
      var value = params[key];
      if (Array.isArray(value)) {
        value.forEach(function (item) {
          var part = __pmQsPart(key, item);
          if (part !== null) parts.push(part);
        });
      } else {
        var part = __pmQsPart(key, value);
        if (part !== null) parts.push(part);
      }
    });
    return parts.join('&');
  }

  // 用 XHR 以 arraybuffer 模式取二进制响应，返回 Promise<ArrayBuffer>。
  function __pmXhrArrayBuffer(method, url, headers, body) {
    return new Promise(function (resolve, reject) {
      var xhr = new XMLHttpRequest();
      xhr.open(method || 'GET', url, true);
      xhr.responseType = 'arraybuffer';
      if (headers) {
        Object.keys(headers).forEach(function (k) {
          try { xhr.setRequestHeader(k, headers[k]); } catch (e) {}
        });
      }
      xhr.onload = function () {
        if (xhr.status >= 200 && xhr.status < 300) {
          resolve(xhr.response || new ArrayBuffer(0));
        } else {
          var err = new Error('Request failed with status code ' + xhr.status);
          err.isAxiosError = true;
          reject(err);
        }
      };
      xhr.onerror = function () { reject(new Error('Network request failed')); };
      xhr.ontimeout = function () { reject(new Error('Network request timed out')); };
      xhr.send(body || null);
    });
  }

  async function __pmRequest(config) {    config = config || {};
    var method = String(config.method || 'get').toUpperCase();
    var url = String(config.url || config.uri || '');
    if (config.baseURL && url && url.indexOf('http') !== 0) {
      url = String(config.baseURL).replace(/\/+$/, '') + '/' + url.replace(/^\/+/, '');
    }
    var query = __pmQs(config.params);
    if (query) url += (url.indexOf('?') === -1 ? '?' : '&') + query;

    var headers = {};
    var srcHeaders = config.headers || {};
    Object.keys(srcHeaders).forEach(function (key) {
      if (srcHeaders[key] === undefined || srcHeaders[key] === null) return;
      // fetch 禁止/忽略的请求头（Host/Connection 等），设置会导致报错，统一丢弃。
      var lk = String(key).toLowerCase();
      if (lk === 'host' || lk === 'connection' || lk === 'content-length' ||
          lk === 'accept-encoding' || lk === 'transfer-encoding' ||
          lk === 'keep-alive' || lk === 'upgrade') return;
      headers[key] = String(srcHeaders[key]);
    });

    var body;
    if (config.data !== undefined && config.data !== null) {
      if (typeof config.data === 'string') {
        body = config.data;
      } else {
        body = JSON.stringify(config.data);
        if (!headers['Content-Type'] && !headers['content-type']) {
          headers['Content-Type'] = 'application/json';
        }
      }
    }

    // 二进制响应（responseType=arraybuffer）：fetch 垫片只给文本，改用 XHR 拿原始
    // ArrayBuffer。咪咕等平台的取链接口返回加密二进制，必须拿到字节再自行解密。
    if (config.responseType === 'arraybuffer') {
      var ab = await __pmXhrArrayBuffer(method, url, headers, body);
      return {
        data: ab,
        status: 200,
        statusText: '',
        headers: {},
        config: config,
        request: null
      };
    }

    var response = await fetch(url, { method: method, headers: headers, body: body });
    var text = await response.text();
    var data = text;
    if (config.responseType !== 'text') {
      try { data = JSON.parse(text); } catch (e) { /* 非 JSON 保持原文 */ }
    }

    var result = {
      data: data,
      status: response.status,
      statusText: response.statusText || '',
      headers: response.headers,
      config: config,
      request: null
    };

    var validate = typeof config.validateStatus === 'function'
      ? config.validateStatus
      : function (status) { return status >= 200 && status < 300; };
    if (!validate(response.status)) {
      var error = new Error('Request failed with status code ' + response.status);
      error.isAxiosError = true;
      error.config = config;
      error.response = result;
      throw error;
    }
    return result;
  }

  function __pmWithTimeout(promise, timeout) {
    if (!timeout || timeout <= 0) return promise;
    return new Promise(function (resolve, reject) {
      var settled = false;
      var timer = setTimeout(function () {
        if (settled) return;
        settled = true;
        var error = new Error('timeout of ' + timeout + 'ms exceeded');
        error.code = 'ECONNABORTED';
        error.isAxiosError = true;
        reject(error);
      }, timeout);
      promise.then(function (value) {
        if (settled) return;
        settled = true;
        clearTimeout(timer);
        resolve(value);
      }, function (error) {
        if (settled) return;
        settled = true;
        clearTimeout(timer);
        reject(error);
      });
    });
  }

  var axios = function (config) {
    if (typeof config === 'string') config = { url: config };
    config = config || {};
    return __pmWithTimeout(__pmRequest(config), config.timeout);
  };
  axios.request = axios;

  function __pmMethod(method) {
    return function (url, config) {
      config = config || {};
      config.url = url;
      config.method = method;
      return __pmWithTimeout(__pmRequest(config), config.timeout);
    };
  }
  ['get', 'delete', 'head', 'options'].forEach(function (method) {
    axios[method] = __pmMethod(method);
  });

  function __pmDataMethod(method) {
    return function (url, data, config) {
      config = config || {};
      config.url = url;
      config.method = method;
      config.data = data;
      return __pmWithTimeout(__pmRequest(config), config.timeout);
    };
  }
  ['post', 'put', 'patch'].forEach(function (method) {
    axios[method] = __pmDataMethod(method);
  });

  axios.default = axios;

  // ---- he 垫片（decode 走 Dart 桥的 HTML5 tokenizer，encode 本地实现） ------
  var he = {
    decode: function (input) {
      if (input === undefined || input === null) return '';
      return sendMessage('mfHeDecode', JSON.stringify([String(input)]));
    },
    encode: function (input) {
      return String(input === undefined || input === null ? '' : input)
        .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;').replace(/'/g, '&#x27;');
    }
  };
  he.decodeStrict = he.decode;
  he.encodeStrict = he.encode;
  he.escape = he.encode;
  he.unescape = he.decode;
  he.default = he;

  __pluginModules['axios'] = axios;
  __pluginModules['he'] = he;

  // ---- crypto-js 垫片（常用 MD5；其余算法暂不实现）-----------------------
  // 插件绝大多数只用到 CryptoJS.MD5(x).toString() 做签名。实现一个近似
  // WordArray 的返回对象：has toString() 给出小写 hex，链式 enc 也兼容。
  function __pmMd5Result(hex) {
    return {
      toString: function () { return hex; },
      valueOf: function () { return hex; }
    };
  }
  var CryptoJS = {
    MD5: function (input) {
      var s = String(input === undefined || input === null ? '' : input);
      // sendMessage 的第二参数若是裸字符串会被引擎当作 JSON 解析，必须传 JSON。
      var hex = sendMessage('mfMd5', JSON.stringify({ text: s }));
      return __pmMd5Result(hex);
    },
    enc: { Hex: { stringify: function (w) { return '' + w; } } }
  };
  CryptoJS.default = CryptoJS;
  __pluginModules['crypto-js'] = CryptoJS;

  // ---- cheerio 最小桩 ---------------------------------------------------
  // 少数插件用 cheerio 解析 HTML（歌手专辑/导入歌单等边缘能力）。核心的
  // 搜索 / 取链 / 歌词 / 榜单并不依赖它。这里提供一个「查不到就返回空」的
  // 宽松桩，保证插件能加载、核心方法可跑；依赖 DOM 解析的边缘方法会返回空。
  function __pmEmptySelection() {
    var sel = function () { return sel; };
    sel.find = function () { return sel; };
    sel.each = function () { return sel; };
    sel.attr = function () { return undefined; };
    sel.text = function () { return ''; };
    sel.html = function () { return ''; };
    sel.hasClass = function () { return false; };
    sel.length = 0;
    sel.eq = function () { return sel; };
    sel.first = function () { return sel; };
    return sel;
  }
  var cheerio = {
    load: function () { return __pmEmptySelection(); },
    default: null
  };
  cheerio.default = cheerio;
  __pluginModules['cheerio'] = cheerio;
})();
''';

  /// 兼容 CommonJS 的 `module.exports.default` 导出形态。
  ///
  /// parcel 打包的插件（如小蜗）只把实例挂在 `default` 上，宿主读的是
  /// `module.exports.platform` 等顶层属性，这里把 default 的属性铺平。
  static const String normalizeExports = r'''
(function () {
  var m = __pluginModule.exports;
  if (!m || typeof m !== 'object') return;
  var hasMethod = false;
  Object.keys(m).forEach(function (key) {
    if (typeof m[key] === 'function') hasMethod = true;
  });
  var fallback = m.default;
  if (!hasMethod && fallback && typeof fallback === 'object') {
    Object.keys(fallback).forEach(function (key) {
      if (!(key in m)) m[key] = fallback[key];
    });
  }
})();
''';
}
