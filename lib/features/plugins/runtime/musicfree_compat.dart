import 'package:html/parser.dart';
import 'package:quickjs_engine/quickjs_engine.dart';

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

  async function __pmRequest(config) {
    config = config || {};
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
      if (srcHeaders[key] !== undefined && srcHeaders[key] !== null) {
        headers[key] = String(srcHeaders[key]);
      }
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
