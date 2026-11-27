import 'dart:async';
import 'dart:convert';

import 'package:quickjs_engine/javascript_runtime.dart';
import 'package:http/http.dart' as http;

/*
 * Based on bits and pieces from different OSS sources
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// ignore: non_constant_identifier_names
var _XHR_DEBUG = false;

setXhrDebug(bool value) => _XHR_DEBUG = value;

const HTTP_GET = "get";
const HTTP_POST = "post";
const HTTP_PATCH = "patch";
const HTTP_DELETE = "delete";
const HTTP_PUT = "put";
const HTTP_HEAD = "head";

enum HttpMethod { put, get, post, delete, patch, head }

String _debugSendNativeCallback() {
  if (_XHR_DEBUG) {
    return """console.log("XMLHttpRequest._send_native_callback");
      console.log("arguments");
      console.log(arguments);
      console.log(responseInfo);
      console.log(responseText);
      console.log(error);""";
  } else
    return "";
}

final String xhrJsCode = """
function XMLHttpRequest() {
  this._send_native = XMLHttpRequestExtension_send_native;
  this._httpMethod = null;
  this._url = null;
  this._requestHeaders = [];
  this._responseHeaders = [];
  this.response = null;
  this.responseText = null;
  this.responseXML = null;
  this.responseType = "";
  this.onreadystatechange = null;
  this.onloadstart = null;
  this.onprogress = null;
  this.onabort = null;
  this.onerror = null;
  this.onload = null;
  this.onloadend = null;
  this.ontimeout = null;
  this.timeout = 0;
  this.readyState = 0;
  this.status = 0;
  this.statusText = "";
  this.withCredentials = null;
};
// readystate enum
XMLHttpRequest.UNSENT = 0;
XMLHttpRequest.OPENED = 1;
XMLHttpRequest.HEADERS = 2;
XMLHttpRequest.LOADING = 3;
XMLHttpRequest.DONE = 4;
XMLHttpRequest.prototype.constructor = XMLHttpRequest;
XMLHttpRequest.prototype.open = function(httpMethod, url) {
  this._httpMethod = httpMethod;
  this._url = url;
  this.readyState = XMLHttpRequest.OPENED;
  if (typeof this.onreadystatechange === "function") {
    //console.log("Calling onreadystatechange(OPENED)...");
    this.onreadystatechange();
  }
};
XMLHttpRequest.prototype.send = function(data) {
  this.readyState = XMLHttpRequest.LOADING;
  if (typeof this.onreadystatechange === "function") {
    //console.log("Calling onreadystatechange(LOADING)...");
    this.onreadystatechange();
  }
  if (typeof this.onloadstart === "function") {
    //console.log("Calling onloadstart()...");
    this.onloadstart();
  }
  var that = this;
  this._send_native(this._httpMethod, this._url, this._requestHeaders, data || null, function(responseInfo, responseText, error) {
    that._send_native_callback(responseInfo, responseText, error);
  }, this, this.timeout || 0);
};
XMLHttpRequest.prototype.abort = function() {
  this.readyState = XMLHttpRequest.UNSENT;
  // 通知 Dart 侧尽快取消/丢弃该请求（无法中断底层 socket 时至少不再回灌结果）。
  try {
    if (typeof this._idRequest === "number" && typeof globalThis.__xhrAbortNative === "function") {
      globalThis.__xhrAbortNative(this._idRequest);
    }
  } catch (e) {}
  // Note: this.onreadystatechange() is not supposed to be called according to the XHR specs
}
// responseInfo: {statusCode, statusText, responseHeaders}
XMLHttpRequest.prototype._send_native_callback = function(responseInfo, responseText, error) {
  ${_debugSendNativeCallback()}
  if (this.readyState === XMLHttpRequest.UNSENT) {
    console.log("XHR native callback ignored because the request has been aborted");
    if (typeof this.onabort === "function") {
      //console.log("Calling onabort()...");
      this.onabort();
    }
    return;
  }
  if (this.readyState != XMLHttpRequest.LOADING) {
    // Request was not expected
    console.log("XHR native callback ignored because the current state is not LOADING");
    return;
  }
  // Response info
  // TODO: responseXML?
  this.responseURL = this._url;
  this.status = responseInfo.statusCode;
  this.statusText = responseInfo.statusText;
  this._responseHeaders = responseInfo.responseHeaders || [];
  this.readyState = XMLHttpRequest.DONE;
  // Response
  this.response = null;
  this.responseText = null;
  this.responseXML = null;
  if (error) {
    this.responseText = error;
  } else {
    this.responseText = responseText;
    //console.log('RESPONSE TEXT: ' + responseText);
    switch (this.responseType) {
      case "":
      case "text":
        this.response = this.responseText;
        break;
      case "arraybuffer":
        // 原始字节由 Dart 侧以 base64 回灌在 responseInfo.bodyB64。
        try {
          var b64 = responseInfo && responseInfo.bodyB64;
          if (typeof b64 !== "string" || b64.length === 0) {
            this.response = new ArrayBuffer(0);
          } else {
            this.response = globalThis.__b64ToArrayBuffer(b64);
          }
        } catch (e) {
          error = "XHR arraybuffer decode failed: " + e;
        }
        break;
      case "document":
        this.response = this.responseText;
        this.responseXML = this.responseText;
        break;
      case "json":
        try {
            this.response = JSON.parse(responseText);
        }
        catch (e) {
            error = "Could not parse JSON response: " + responseText;
        }
        break;
      default:
        error = "Unsupported responseType: " + responseInfo.responseType;
    }
  }
  this.readyState = XMLHttpRequest.DONE;
  if (typeof this.onreadystatechange === "function") {
    //console.log("Calling onreadystatechange(DONE)...");
    this.onreadystatechange();
  }
  if (error === "timeout") {
    // Timeout
    console.warn("Got XHR timeout");
    if (typeof this.ontimeout === "function") {
      //console.log("Calling ontimeout()...");
      this.ontimeout(new Error("XHR timeout"));
    }
  } else if (error) {
    // Error
    console.warn("Got XHR error:", error);
    if (typeof this.onerror === "function") {
      //console.log("Calling onerror()...");
      this.onerror(new Error("XHR error: " + error));
    }
  } else {
    // Success
    //console.log("XHR success: response =", this.response);
    if (typeof this.onload === "function") {
      //console.log("Calling onload()...");
      this.onload();
    }
  }
  if (typeof this.onloadend === "function") {
    //console.log("Calling onloadend()...");
    this.onloadend();
  }
};
XMLHttpRequest.prototype.setRequestHeader = function(header, value) {
  this._requestHeaders.push([header, value]);
};
XMLHttpRequest.prototype.getAllResponseHeaders = function() {
  var ret = "";
  for (var i = 0; i < this._responseHeaders.length; i++) {
    var keyValue = this._responseHeaders[i];
    ret += keyValue[0] + ": " + keyValue[1] + "\\r\\n";
  }
  return ret;
};
XMLHttpRequest.prototype.getResponseHeader = function(name) {
  var ret = "";
  for (var i = 0; i < this._responseHeaders.length; i++) {
    var keyValue = this._responseHeaders[i];
    if (keyValue[0] !== name) continue;
    if (ret === "") ret += ", ";
    ret += keyValue[1];
  }
  return ret;
};
// XMLHttpRequest.prototype.overrideMimeType = function() {
//   // TODO
// };
this.XMLHttpRequest = XMLHttpRequest;""";

RegExp regexpHeader = RegExp("^([\\w-])+:(?!\\s*\$).+\$");

class XhrPendingCall {
  int? idRequest;
  String? method;
  String? url;
  Map<String, String> headers;
  String? body;

  /// 单次请求超时（毫秒）；0/空表示用默认超时。
  int? timeoutMs;

  /// multipart/form-data 字段列表（每项：{name, value|base64, filename?, contentType?}）。
  List<dynamic>? formData;

  XhrPendingCall({
    required this.idRequest,
    required this.method,
    required this.url,
    required this.headers,
    required this.body,
    this.timeoutMs,
    this.formData,
  });
}

const XHR_PENDING_CALLS_KEY = "xhrPendingCalls";

/// 已被 abort 的请求 id 集合：请求完成时若命中则丢弃结果，不再回灌 JS。
const XHR_ABORTED_IDS_KEY = "xhrAbortedIds";

/// 单次 XHR 请求的超时上限：避免网络异常（DNS/连接挂起）时请求永久悬挂。
const Duration _xhrRequestTimeout = Duration(seconds: 30);

http.Client? httpClient;

xhrSetHttpClient(http.Client client) {
  httpClient = client;
}

/// 该请求是否已被 JS 侧 abort()。
bool _isAborted(JavascriptRuntime rt, int? id) {
  if (id == null) return false;
  final set = rt.dartContext[XHR_ABORTED_IDS_KEY];
  return set is Set && set.contains(id);
}

/// 执行一次 XHR 请求（含 multipart/form-data 支持），返回 http.Response。
Future<http.Response> _executeXhrRequest(XhrPendingCall call) async {
  final uri = Uri.parse(call.url!);
  final method = (call.method ?? 'get').toLowerCase();
  final formData = call.formData;

  // multipart/form-data：用 MultipartRequest 组装。
  if (formData != null && formData.isNotEmpty) {
    final req = http.MultipartRequest(method.toUpperCase(), uri);
    req.headers.addAll(call.headers);
    for (final item in formData) {
      if (item is! Map) continue;
      final name = '${item['name'] ?? ''}';
      final b64 = item['base64'];
      final filename = item['filename'];
      final contentType = item['contentType'];
      final hasFile = filename != null && '$filename'.isNotEmpty;
      if (b64 is String && b64.isNotEmpty) {
        final bytes = base64Decode(b64);
        if (hasFile) {
          req.files.add(http.MultipartFile.fromBytes(
            name,
            bytes,
            filename: '$filename',
            contentType: contentType == null
                ? null
                : http.MediaType.parse('$contentType'),
          ));
        } else {
          req.fields[name] = utf8.decode(bytes, allowMalformed: true);
        }
      } else {
        req.fields[name] = '${item['value'] ?? ''}';
      }
    }
    final streamed = await httpClient!.send(req);
    return http.Response.fromStream(streamed);
  }

  final body = call.body;
  switch (method) {
    case 'head':
      return httpClient!.head(uri, headers: call.headers);
    case 'get':
      return httpClient!.get(uri, headers: call.headers);
    case 'post':
      return httpClient!.post(uri, headers: call.headers, body: body);
    case 'put':
      return httpClient!.put(uri, headers: call.headers, body: body);
    case 'patch':
      return httpClient!.patch(uri, headers: call.headers, body: body);
    case 'delete':
      return httpClient!.delete(uri, headers: call.headers, body: body);
    default:
      return httpClient!.get(uri, headers: call.headers);
  }
}

extension JavascriptRuntimeXhrExtension on JavascriptRuntime {
  List<dynamic>? getPendingXhrCalls() {
    return dartContext[XHR_PENDING_CALLS_KEY];
  }

  bool hasPendingXhrCalls() => getPendingXhrCalls()!.length > 0;
  void clearXhrPendingCalls() {
    dartContext[XHR_PENDING_CALLS_KEY] = [];
  }

  JavascriptRuntime enableXhr() {
    httpClient = httpClient ?? http.Client();
    dartContext[XHR_PENDING_CALLS_KEY] = [];
    dartContext[XHR_ABORTED_IDS_KEY] = <int>{};

    // 接收 JS 侧 abort 通知：记录 id，请求完成时据此丢弃结果。
    this.onMessage('XhrAbortNative', (arguments) {
      try {
        final id = arguments is List && arguments.isNotEmpty
            ? arguments.first
            : arguments;
        final idInt = id is num ? id.toInt() : int.tryParse('$id');
        if (idInt != null) {
          (dartContext[XHR_ABORTED_IDS_KEY] as Set<int>).add(idInt);
        }
      } catch (_) {}
      return '';
    });

    Timer.periodic(Duration(milliseconds: 40), (timer) {
      // exits if there is no pending call to remote
      if (!hasPendingXhrCalls()) return;

      // collect the pending calls into a local variable making copies
      List<dynamic> pendingCalls = List<dynamic>.from(getPendingXhrCalls()!);
      // clear the global pending calls list
      clearXhrPendingCalls();

      // for each pending call, calls the remote http service
      pendingCalls.forEach((element) async {
        final XhrPendingCall pendingCall = element as XhrPendingCall;
        try {
          // 已被 abort 的请求直接跳过。
          if (_isAborted(this, pendingCall.idRequest)) return;
          final Duration callTimeout = (pendingCall.timeoutMs != null &&
                  pendingCall.timeoutMs! > 0)
              ? Duration(milliseconds: pendingCall.timeoutMs!)
              : _xhrRequestTimeout;
          final response = await _executeXhrRequest(pendingCall)
              .timeout(callTimeout);
          // 请求完成时若在期间被 abort，丢弃结果，不回灌。
          if (_isAborted(this, pendingCall.idRequest)) return;
          // 二进制响应（如图片/加密音频）不能强解成 UTF-8，allowMalformed 防崩溃。
          String responseText = utf8.decode(response.bodyBytes, allowMalformed: true);
          try {
            responseText = jsonEncode(json.decode(responseText));
          } on Exception {}
          final xhrResult = XmlHttpRequestResponse(
            responseText: responseText,
            // 原始字节以 base64 一并回灌，供 responseType=arraybuffer 的调用方使用。
            bodyB64: base64.encode(response.bodyBytes),
            responseInfo: XhtmlHttpResponseInfo(
              statusCode: response.statusCode,
              statusText: response.reasonPhrase ?? '',
              bodyB64: base64.encode(response.bodyBytes),
            ),
          );

          final responseInfo = jsonEncode(xhrResult.responseInfo);
          final error = xhrResult.error;
          // 用车 JSON 编码把响应体变成安全的 JS 字符串字面量再回灌。
          // 原实现用 `` `$responseText` `` 反引号模板插入：当响应体含 `${...}`
          // 或反斜杠（真实 API 的 JSON 里极常见）时会被 JS 当表达式求值/破坏转义，
          // 导致 evaluate 抛错、XHR 回调永不触发、请求挂起到超时。
          final responseTextLiteral = jsonEncode(xhrResult.responseText ?? '');
          final errorLiteral = error == null
              ? 'null'
              : jsonEncode(error.toString());
          this.evaluate(
            "globalThis.xhrRequests[${pendingCall.idRequest}].callback($responseInfo, $responseTextLiteral, $errorLiteral);",
          );
        } catch (e) {
          // 网络异常（DNS 失败、连接超时等）不能让 Future 未捕获地抛到 Flutter
          // 层（否则会刷 Unhandled Exception 并可能拖垮调试会话），交回 JS 侧的
          // onerror，由插件的 fetch/axios 自行处理失败。
          try {
            this.evaluate(
              "globalThis.xhrRequests[${pendingCall.idRequest}].callback("
              "{statusCode: 0, statusText: '', responseHeaders: []}, null, ${jsonEncode(e.toString())});",
            );
          } catch (_) {
            // 请求已不存在（插件实例销毁）时忽略。
          }
        }
      });
    });

    final evalXhrSendNative = this.evaluate("""
    var xhrRequests = {};
    var idRequest = -1;
    // base64 → ArrayBuffer（纯 JS 实现，不依赖 atob）。
    globalThis.__b64ToArrayBuffer = function (b64) {
      var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
      var lookup = {};
      for (var i = 0; i < chars.length; i++) lookup[chars.charAt(i)] = i;
      var clean = String(b64).replace(/[^A-Za-z0-9+/]/g, '');
      var len = clean.length;
      var buffer = new ArrayBuffer((len * 3) >> 2);
      var bytes = new Uint8Array(buffer);
      var p = 0, bits = 0, val = 0;
      for (var j = 0; j < len; j++) {
        val = (val << 6) | lookup[clean.charAt(j)];
        bits += 6;
        if (bits >= 8) {
          bits -= 8;
          bytes[p++] = (val >> bits) & 0xff;
          // 清除已消费的高位，避免长时间累积溢出 32 位。
          val &= (1 << bits) - 1;
        }
      }
      return buffer;
    };
    function XMLHttpRequestExtension_send_native() {
      idRequest += 1;
      var cb = arguments[4];
      var context = arguments[5];
      var timeoutMs = arguments[6] || 0;
      // 记到实例上，供 abort() 通知 Dart 侧取消。
      if (context) { try { context._idRequest = idRequest; } catch (e) {} }
      xhrRequests[idRequest] = {
        callback: function(responseInfo, responseText, error) {
          cb(responseInfo, responseText, error);
        }
      };
      var args = [];
      args[0] = arguments[0];
      args[1] = arguments[1];
      args[2] = arguments[2];
      args[3] = arguments[3];
      args[4] = idRequest;
      args[5] = timeoutMs;
      sendMessage('SendNative', JSON.stringify(args));
    }
    // abort() 通知 Dart 侧取消指定请求。
    globalThis.__xhrAbortNative = function (id) {
      try { sendMessage('XhrAbortNative', JSON.stringify(id)); } catch (e) {}
    };
    """);

    final evalXhrResult = this.evaluate(xhrJsCode);
    localContext['enableXhr'] = evalXhrResult.rawResult;
    localContext['xhrSendNative'] = evalXhrSendNative.rawResult;
    if (_XHR_DEBUG) print('RESULT evalXhrResult: $evalXhrResult');

    this.onMessage('SendNative', (arguments) {
      try {
        String? method = arguments[0];
        String? url = arguments[1];
        dynamic headersList = arguments[2];
        dynamic bodyArg = arguments[3];
        int? idRequest = arguments[4];
        int? timeoutMs = (arguments.length > 5 && arguments[5] is num)
            ? (arguments[5] as num).toInt()
            : null;

        // body 为数组时视为 multipart/form-data 字段列表。
        String? body;
        List<dynamic>? formData;
        if (bodyArg is List) {
          formData = bodyArg;
        } else if (bodyArg != null) {
          body = '$bodyArg';
        }

        Map<String, String> headers = {};
        headersList.forEach((header) {
          // final headerMatch = regexpHeader.allMatches(value).first;
          // String? headerName = headerMatch.group(0);
          // String? headerValue = headerMatch.group(1);
          // if (headerName != null) {
          //   headers[headerName] = headerValue ?? '';
          // }
          String headerKey = header[0];
          headers[headerKey] = header[1];
        });
        (dartContext[XHR_PENDING_CALLS_KEY] as List<dynamic>).add(
          XhrPendingCall(
            idRequest: idRequest,
            method: method,
            url: url,
            headers: headers,
            body: body,
            timeoutMs: timeoutMs,
            formData: formData,
          ),
        );
      } on Error catch (e) {
        if (_XHR_DEBUG) print('ERROR calling sendNative on Dart: >>>> $e');
      } on Exception catch (e) {
        if (_XHR_DEBUG) print('Exception calling sendNative on Dart: >>>> $e');
      }
    });
    return this;
  }
}

class XhtmlHttpResponseInfo {
  final int? statusCode;
  final String? statusText;
  final List<List<String>> responseHeaders = [];

  /// 响应原始字节的 base64 编码（供 responseType=arraybuffer 使用）。
  String? bodyB64;

  XhtmlHttpResponseInfo({
    this.statusCode,
    this.statusText,
    this.bodyB64,
  });

  void addResponseHeaders(String name, String value) {
    responseHeaders.add([name, value]);
  }

  Map<String, Object?> toJson() {
    return {
      "statusCode": statusCode,
      "statusText": statusText,
      "responseHeaders": jsonEncode(responseHeaders),
      "bodyB64": bodyB64,
    };
  }
}

class XmlHttpRequestResponse {
  final String? responseText;
  final String? bodyB64;
  final String? error; // should be timeout in case of timeout
  final XhtmlHttpResponseInfo? responseInfo;

  XmlHttpRequestResponse({
    this.responseText,
    this.bodyB64,
    this.responseInfo,
    this.error,
  });

  Map<String, Object?> toJson() {
    return {
      'responseText': responseText,
      'bodyB64': bodyB64,
      'responseInfo': responseInfo!.toJson(),
      'error': error
    };
  }
}
