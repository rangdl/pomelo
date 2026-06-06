import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_js/flutter_js.dart';

// JsEngine 负责在 Dart 中创建一个 quickjs 运行环境，并注入 fetch 实现，供 quickjs 代码调用。
class JsEngine {
  final Dio _dio;
  late final JavascriptRuntime _jsRuntime;
  JavascriptRuntime get jsRuntime => _jsRuntime;
  JsEngine({JavascriptRuntime? jsRuntime, Dio? dio})
    : _dio = dio ?? Dio(),
      _jsRuntime = jsRuntime ?? getJavascriptRuntime(xhr: false) {
    init();
  }
  void init() {
    _setupFetch();
    _setupCrypto();
    _setupAES();
  }

  // 注入 fetch 实现，供 quickjs 代码调用
  void _setupFetch() {
    _jsRuntime.evaluate("""
var __native_fetch_callback = {};
var __native_fetch_id = -1;
function fetch(url, options) {
  __native_fetch_id += 1;
  options = options || {};
  var method=(options.method||'GET').toUpperCase();
  var reqHeaders={};
  if(options.headers){
    if(options.headers instanceof Map){options.headers.forEach(function(v,k){reqHeaders[k]=v})}
    else if(typeof options.headers==='object'){reqHeaders=options.headers}
  }
  if(method==='GET'&&reqHeaders['Content-Type'])delete reqHeaders['Content-Type'];
  return new Promise(function(resolve,reject){
    __native_fetch_callback[__native_fetch_id] = {
      callback: function(err, resp) {
        delete __native_fetch_callback[__native_fetch_id];
        if (err){
          reject(new Error('fetch error: '+(err.message||String(err))));
          return
        }
        var body = resp.body ?? ''
        resolve({
          ok: resp&&resp.statusCode>=200&&resp.statusCode<300,
          status:resp?resp.statusCode:0,
          statusText:resp?(resp.statusMessage||''):'',
          headers:resp.headers,
          url:url,
          text:function(){return Promise.resolve(body)},
          json:function(){return Promise.resolve(JSON.parse(body))},
          arrayBuffer:function(){var bytes=new Uint8Array(body.length);for(var i=0;i<body.length;i++)bytes[i]=body.charCodeAt(i);return Promise.resolve(bytes.buffer);}
        });
      }
    };
    var args = [];
    args[0] = method;
    args[1] = url;
    args[2] = options.body??null;
    args[3] = {headers: reqHeaders};
    args[4] = __native_fetch_id;
    sendMessage('__native_fetch__', JSON.stringify(args));
  });
}
    """);

    _jsRuntime.onMessage('__native_fetch__', (arguments) {
      String method = arguments[0] as String;
      String url = arguments[1] as String;
      Object? body = arguments[2];
      Map? options = arguments[3];
      int nativeFetchId = arguments[4] as int;
      Map<String, dynamic> headers = options?['headers'] ?? {};
      if (headers['User-Agent'] == null) {
        headers['User-Agent'] =
            'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36';
      }
      int timeout = options?['response_timeout'] ?? 60000;
      _dio
          .request(
            url,
            data: body,
            options: Options(
              method: method,
              headers: headers,
              connectTimeout: const Duration(seconds: 5),
              sendTimeout: Duration(milliseconds: timeout),
              receiveTimeout: Duration(milliseconds: timeout),
              // responseType: ResponseType.bytes,
            ),
          )
          .then((response) {
            Map<String, String> headersMap = {};
            response.headers.forEach((name, values) {
              headersMap[name] = values.join(', ');
            });

            final resp = {
              'status': response.statusCode,
              'statusCode': response.statusCode,
              'statusMessage': response.statusMessage,
              'headers': headersMap,
              'body': response.data,
            };
            final respText = jsonEncode(resp);
            _jsRuntime.evaluate(
              "globalThis.__native_fetch_callback[$nativeFetchId].callback(null,$respText)",
            );
          })
          .catchError((err) {
            _jsRuntime.evaluate(
              "globalThis.__native_fetch_callback[$nativeFetchId].callback(`${err.response.toString()}`,null)",
            );
          });
    });
  }

  // 注入 crypto 实现，供 quickjs 代码调用 MD5 / SHA256
  void _setupCrypto() {
    _jsRuntime.evaluate("""
function __go_crypto_md5(str) {
  return sendMessage('__native_crypto__', JSON.stringify(['md5', str]));
}

function __go_crypto_sha256(data) {
  return sendMessage('__native_crypto__', JSON.stringify(['sha256', data]));
}
    """);

    _jsRuntime.onMessage('__native_crypto__', (arguments) {
      String type = arguments[0] as String;
      String input = arguments[1] as String;
      if (type == 'md5') {
        return md5.convert(utf8.encode(input)).toString();
      }
      return sha256.convert(utf8.encode(input)).toString();
    });
  }

  // 注入 AES 加密实现，供 quickjs 代码调用
  // mode 格式: "aes-128-cbc", "aes-256-ecb", "cbc" 等 Node.js 风格
  void _setupAES() {
    _jsRuntime.evaluate("""
function __go_crypto_aes_encrypt(dataHex, mode, keyHex, ivHex) {
  return sendMessage('__native_aes_encrypt__', JSON.stringify([dataHex, mode, keyHex, ivHex]));
}
    """);

    _jsRuntime.onMessage('__native_aes_encrypt__', (arguments) {
      String dataHex = arguments[0] as String;
      String mode = arguments[1] as String;
      String keyHex = arguments[2] as String;
      String ivHex = arguments[3] as String;

      final key = Key.fromBase16(keyHex);
      final iv = ivHex.isNotEmpty ? IV.fromBase16(ivHex) : null;

      // 解析 Node.js 风格 mode: "aes-128-cbc" → "cbc"
      String modeName = mode.toLowerCase();
      if (modeName.startsWith('aes-')) {
        modeName = modeName.split('-').last;
      }

      final aesMode = _parseAESMode(modeName);
      final aes = AES(key, mode: aesMode, padding: 'PKCS7');
      final encrypter = Encrypter(aes);

      // dataHex 作为 hex 字节数组加密
      final data = Encrypted.fromBase16(dataHex).bytes;
      final encrypted = encrypter.encryptBytes(data, iv: iv);

      return encrypted.base16;
    });
  }

  AESMode _parseAESMode(String mode) {
    switch (mode) {
      case 'cbc':
        return AESMode.cbc;
      case 'cfb':
      case 'cfb8':
      case 'cfb128':
        return AESMode.cfb64;
      case 'ctr':
        return AESMode.ctr;
      case 'ecb':
        return AESMode.ecb;
      case 'ofb':
      case 'ofb64':
        return AESMode.ofb64;
      case 'gcm':
        return AESMode.gcm;
      case 'sic':
        return AESMode.sic;
      default:
        throw ArgumentError('Unsupported AES mode: $mode');
    }
  }

  void dispose() {
    _jsRuntime.dispose();
  }
}
