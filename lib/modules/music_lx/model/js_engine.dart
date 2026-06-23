import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:pointycastle/asn1/asn1_parser.dart';
import 'package:pointycastle/asn1/primitives/asn1_bit_string.dart';
import 'package:pointycastle/asn1/primitives/asn1_integer.dart';
import 'package:pointycastle/asn1/primitives/asn1_sequence.dart';
import 'package:pointycastle/export.dart';
import 'package:pomelo/modules/music_lx/model/polyfill.dart';

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
    // fetch
    _setupFetch();
    // __go_crypto_md5
    // __go_crypto_sha256
    _setupCrypto();
    //__go_crypto_aes_encrypt
    _setupAES();
    // __go_crypto_rsa_encrypt
    _setupRSA();
    // __go_crypto_random_bytes
    _setupCryptoRandomBytes();
    // __go_buffer_from
    _setupBufferFrom();
    // __go_buffer_to_string
    _setupBufferToString();
    // __go_zlib_inflate
    _setupZlibInflate();
    // __go_zlib_deflate
    _setupZlibDeflate();
    // __go_raw_inflate
    _setupRawInflate();

    // polyfill
    _setupPolyfill();
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
          })
          .whenComplete(() {
            // 循环调用 executePendingJob() 排空所有微任务
            // executePendingJob 返回 int，表示执行的作业数量，0 表示没有更多
            while (_jsRuntime.executePendingJob() > 0) {}
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
  // mode 格式: "cbc", "ecb"
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
      String ivHex = arguments[3] ?? null as String?;

      return goCryptoAesEncrypt(dataHex, mode, keyHex, ivHex);
    });
  }

  // 注入 RSA 加密实现，供 quickjs 代码调用
  void _setupRSA() {
    _jsRuntime.evaluate("""
function __go_crypto_rsa_encrypt(dataHex, keyPEM) {
  return sendMessage('__native_rsa_encrypt__', JSON.stringify([dataHex, keyPEM]));
}
    """);

    _jsRuntime.onMessage('__native_rsa_encrypt__', (arguments) {
      String dataHex = arguments[0] as String;
      String keyPEM = arguments[1] as String;

      return goCryptoRsaEncrypt(dataHex, keyPEM);
    });
  }

  // 注入 RandomBytes 随机字符实现，供 quickjs 代码调用
  void _setupCryptoRandomBytes() {
    _jsRuntime.evaluate("""
function __go_crypto_random_bytes(size) {
  return sendMessage('__native_random_bytes_crypto__', JSON.stringify([size]));
}
    """);

    _jsRuntime.onMessage('__native_random_bytes_crypto__', (arguments) {
      int size = arguments[0] as int;
      return goCryptoRandomBytes(size);
    });
  }

  // 注入 BufferFrom 实现，供 quickjs 代码调用
  void _setupBufferFrom() {
    _jsRuntime.evaluate("""
function __go_buffer_from(data, encoding) {
  return sendMessage('__native_buffer_from__', JSON.stringify([data, encoding]));
}
    """);
    _jsRuntime.onMessage('__native_buffer_from__', (arguments) {
      String data = arguments[0] as String;
      String encoding = arguments[1] as String;
      return goBufferFrom(data, encoding);
    });
  }

  // 注入 BufferToString 实现，供 quickjs 代码调用
  void _setupBufferToString() {
    _jsRuntime.evaluate("""
function __go_buffer_to_string(dataHex, encoding) {
  return sendMessage('__native_buffer_to_string__', JSON.stringify([dataHex, encoding]));
}
    """);
    _jsRuntime.onMessage('__native_buffer_to_string__', (arguments) {
      String dataHex = arguments[0] as String;
      String encoding = arguments[1] as String;
      return goBufferToString(dataHex, encoding);
    });
  }

  // 注入 BufferFrom 实现，供 quickjs 代码调用
  void _setupZlibInflate() {
    _jsRuntime.evaluate("""
function __go_zlib_inflate(dataHex) {
  return sendMessage('__native_zlib_inflate__', JSON.stringify([dataHex]));
}
    """);
    _jsRuntime.onMessage('__native_zlib_inflate__', (arguments) {
      String dataHex = arguments[0] as String;
      return goZlibInflate(dataHex);
    });
  }

  // 注入 BufferFrom 实现，供 quickjs 代码调用
  void _setupZlibDeflate() {
    _jsRuntime.evaluate("""
function __go_zlib_deflate(dataHex) {
  return sendMessage('__native_zlib_deflate__', JSON.stringify([dataHex]));
}
    """);
    _jsRuntime.onMessage('__native_zlib_deflate__', (arguments) {
      String dataHex = arguments[0] as String;
      return goZlibDeflate(dataHex);
    });
  }

  // 注入 BufferFrom 实现，供 quickjs 代码调用
  void _setupRawInflate() {
    _jsRuntime.evaluate("""
function __go_raw_inflate(dataHex) {
  return sendMessage('__native_raw_inflate__', JSON.stringify([dataHex]));
}
    """);
    _jsRuntime.onMessage('__native_raw_inflate__', (arguments) {
      String dataHex = arguments[0] as String;
      return goRawInflate(dataHex);
    });
  }

  // 注入 polyfillJS 实现，供 quickjs 代码调用
  void _setupPolyfill() {
    _jsRuntime.evaluate(polyfillJS);
  }

  String goCryptoAesEncrypt(
    String dataHex,
    String mode,
    String keyHex,
    String ivHex,
  ) {
    try {
      // 十六进制解码
      final data = hex.decode(dataHex) as Uint8List;
      final key = hex.decode(keyHex) as Uint8List;
      Uint8List? iv;
      if (mode.toLowerCase() == 'cbc') {
        iv = hex.decode(ivHex) as Uint8List;
        if (iv.length != 16) throw Exception('IV must be 16 bytes for AES-CBC');
      }

      // PKCS#7 填充
      const blockSize = 16; // AES 块大小固定 16 字节
      final paddingLen = blockSize - (data.length % blockSize);
      final paddedData = Uint8List(data.length + paddingLen);
      paddedData.setAll(0, data);
      for (int i = 0; i < paddingLen; i++) {
        paddedData[data.length + i] = paddingLen;
      }

      final engine = AESEngine();
      Uint8List encrypted;

      switch (mode.toLowerCase()) {
        case 'cbc':
          final cipher = CBCBlockCipher(engine);
          cipher.init(true, ParametersWithIV(KeyParameter(key), iv!));
          encrypted = Uint8List(paddedData.length);
          for (int i = 0; i < paddedData.length; i += blockSize) {
            cipher.processBlock(paddedData, i, encrypted, i);
          }
          break;
        case 'ecb':
          engine.init(true, KeyParameter(key));
          encrypted = Uint8List(paddedData.length);
          for (int i = 0; i < paddedData.length; i += blockSize) {
            engine.processBlock(paddedData, i, encrypted, i);
          }
          break;
        default:
          throw Exception('Unsupported mode: $mode');
      }

      return hex.encode(encrypted);
    } catch (e) {
      // 出错时返回空字符串（与原 Go 行为一致）
      return '';
    }
  }

  String goCryptoRsaEncrypt(String dataHex, String keyPEM) {
    try {
      final data = hex.decode(dataHex) as Uint8List;

      // 解析 PEM：移除头尾及空白，Base64 解码
      String pemClean = keyPEM
          .replaceAll(RegExp(r'-----\w+ RSA PUBLIC KEY-----'), '')
          .replaceAll(RegExp(r'-----\w+ PUBLIC KEY-----'), '')
          .replaceAll(RegExp(r'\s'), '');
      final der = base64.decode(pemClean);

      // 提取 RSA 公钥（模数 n 和指数 e），自动识别 PKCS#1 或 PKIX 格式
      RSAPublicKey rsaPubKey;
      final parser = ASN1Parser(der);
      final topLevel = parser.nextObject() as ASN1Sequence;
      try {
        // 尝试 PKIX 格式（SubjectPublicKeyInfo）
        final bitString = topLevel.elements![1] as ASN1BitString;
        final innerSeq =
            ASN1Parser(bitString.valueBytes!).nextObject() as ASN1Sequence;
        final modulus = (innerSeq.elements![0] as ASN1Integer).integer!;
        final exponent = (innerSeq.elements![1] as ASN1Integer).integer!;
        rsaPubKey = RSAPublicKey(modulus, exponent);
      } catch (_) {
        // 回退到 PKCS#1 格式（直接 RSAPublicKey）
        final modulus = (topLevel.elements![0] as ASN1Integer).integer!;
        final exponent = (topLevel.elements![1] as ASN1Integer).integer!;
        rsaPubKey = RSAPublicKey(modulus, exponent);
      }

      // PKCS#1 v1.5 填充加密（与 Go 的 EncryptPKCS1v15 完全一致）
      final rsaEngine = RSAEngine();
      final pkcs1Engine = PKCS1Encoding(rsaEngine);
      pkcs1Engine.init(true, PublicKeyParameter<RSAPublicKey>(rsaPubKey));

      // 检查数据长度是否超过密钥容量
      final maxLen = pkcs1Engine.inputBlockSize;
      if (data.length > maxLen) {
        throw Exception('Data too long for RSA key (max $maxLen bytes)');
      }

      final encrypted = pkcs1Engine.process(data);
      return hex.encode(encrypted);
    } catch (e) {
      return ''; // 与原 Go 错误处理一致
    }
  }

  String goCryptoRandomBytes(int size) {
    try {
      final random = Random.secure();
      final bytes = Uint8List(size);
      for (int i = 0; i < size; i++) {
        bytes[i] = random.nextInt(256);
      }
      return hex.encode(bytes);
    } catch (e) {
      return '';
    }
  }

  /// 将数据按指定编码转为 hex 内部表示
  String goBufferFrom(String data, String encoding) {
    try {
      switch (encoding.toLowerCase()) {
        case "utf8":
        case "utf-8":
        case "":
          return hex.encode(utf8.encode(data));

        case "base64":
          // 模拟 Go 的 StdEncoding -> RawStdEncoding 回退
          List<int> decoded;
          String cleaned = data.trim();
          try {
            decoded = base64.decode(cleaned); // 标准解码（需要填充）
          } catch (_) {
            // 无填充解码：补充 '=' 到长度是4的倍数
            int padLen = (4 - (cleaned.length % 4)) % 4;
            String padded = cleaned + '=' * padLen;
            decoded = base64.decode(padded);
          }
          return hex.encode(decoded);

        case "hex":
          hex.decode(data); // 验证有效性
          return data;

        case "binary":
        case "latin1":
          List<int> bytes = [];
          for (int i = 0; i < data.length; i++) {
            bytes.add(data.codeUnitAt(i) & 0xFF);
          }
          return hex.encode(bytes);

        default:
          return hex.encode(utf8.encode(data));
      }
    } catch (_) {
      return '';
    }
  }

  /// 将 hex 内部表示转为指定编码字符串
  String goBufferToString(String dataHex, String encoding) {
    try {
      List<int> bytes = hex.decode(dataHex);
      switch (encoding.toLowerCase()) {
        case "utf8":
        case "utf-8":
        case "":
          return utf8.decode(bytes);

        case "base64":
          return base64.encode(bytes);

        case "hex":
          return dataHex;

        case "binary":
        case "latin1":
          return latin1.decode(bytes);

        default:
          return utf8.decode(bytes);
      }
    } catch (_) {
      return '';
    }
  }

  /// Zlib 解压（带 zlib 头/尾）
  /// [dataHex] : zlib 压缩数据的十六进制字符串
  /// 返回解压后的十六进制字符串，出错返回空字符串
  String goZlibInflate(String dataHex) {
    try {
      final List<int> compressed = hex.decode(dataHex);
      final List<int> decompressed = ZLibCodec().decode(compressed);
      return hex.encode(decompressed);
    } catch (_) {
      return '';
    }
  }

  /// Zlib 压缩（带 zlib 头/尾）
  /// [dataHex] : 原始数据的十六进制字符串
  /// 返回压缩后的十六进制字符串，出错返回空字符串
  String goZlibDeflate(String dataHex) {
    try {
      final List<int> data = hex.decode(dataHex);
      final List<int> compressed = ZLibCodec().encode(data);
      return hex.encode(compressed);
    } catch (_) {
      return '';
    }
  }

  /// Raw Deflate 解压（无 zlib 头/尾，RFC 1951）
  /// [dataHex] : raw deflate 压缩数据的十六进制字符串
  /// 返回解压后的十六进制字符串，出错返回空字符串
  String goRawInflate(String dataHex) {
    try {
      final List<int> compressed = hex.decode(dataHex);
      final List<int> decompressed = ZLibCodec(raw: true).decode(compressed);
      return hex.encode(decompressed);
    } catch (_) {
      return '';
    }
  }

  /// 统一的异步JS执行方法
  ///
  /// 执行 JS 表达式并处理 Promise，循环排空微任务，带超时保护。
  /// 返回 Promise resolve 的原始值。
  Future<dynamic> evalAsync(String expression) async {
    final result = await _jsRuntime.evaluateAsync(expression);
    // 循环调用排空所有微任务（Promise resolve 会触发多个 .then() 链）
    while (_jsRuntime.executePendingJob() > 0) {}

    if (result.isError) {
      throw Exception('JS执行错误: ${result.toString()}');
    }

    // 带超时等待 Promise 结果，防止无限等待
    final asyncResult = await _jsRuntime
        .handlePromise(result)
        .timeout(const Duration(seconds: 30));

    // 排空回调产生的新微任务
    while (_jsRuntime.executePendingJob() > 0) {}

    return asyncResult.rawResult;
  }

  void dispose() {
    _jsRuntime.dispose();
  }
}
