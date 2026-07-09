import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:jsf/jsf.dart';
import 'package:pointycastle/asn1/asn1_parser.dart';
import 'package:pointycastle/asn1/primitives/asn1_bit_string.dart';
import 'package:pointycastle/asn1/primitives/asn1_integer.dart';
import 'package:pointycastle/asn1/primitives/asn1_sequence.dart';
import 'package:pointycastle/export.dart';

import 'polyfill.dart';

// JsEngine 负责在 Dart 中创建一个 quickjs 运行环境，并注入 fetch 实现，供 quickjs 代码调用。
class JsEngine {
  final Dio _dio;
  late final JsRuntime _jsRuntime;
  JsRuntime get jsRuntime => _jsRuntime;
  JsEngine({JsRuntime? jsRuntime, Dio? dio})
    : _dio = dio ?? Dio(),
      _jsRuntime = jsRuntime ?? JsRuntime() {
    init();
  }
  void init() {
    _setupSetTimeout();

    _jsRuntime.evalValue(polyfillJS);
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
  }

  void _setupSetTimeout() {
    _jsRuntime.eval("""
    var __NATIVE__setTimeoutCount = -1;
    var __NATIVE__setTimeoutCallbacks = {};
    globalThis.setTimeout = function(fnTimeout, timeout) {
      try {
        __NATIVE__setTimeoutCount += 1;
        var timeoutIndex = '' + __NATIVE__setTimeoutCount;
        __NATIVE__setTimeoutCallbacks[timeoutIndex] = fnTimeout;
        __native_setTimeout__(timeoutIndex, timeout);    
        } catch (e) {
          console.error('ERROR HERE',e.message);
        }
      };
    globalThis.clearTimeout = function(index) {
      delete __NATIVE__setTimeoutCallbacks[index];
    }
    """);
    _jsRuntime.registerFunction('__native_setTimeout__', (
      List<dynamic> args,
    ) async {
      int duration = args[0] ?? 0;
      String idx = args[1];
      Timer(Duration(milliseconds: duration), () {
        _jsRuntime.eval("""
        __NATIVE__setTimeoutCallbacks[$idx]?.call();
        delete __NATIVE__setTimeoutCallbacks[$idx];
      """);
      });
    });
  }

  void _setupFetch() {
    _jsRuntime.registerFunction('__native_fetch__', (List<dynamic> args) async {
      final String url = args[0] as String;
      final Map<String, dynamic>? options = args.length > 1
          ? args[1] as Map<String, dynamic>?
          : null;

      Map<String, dynamic> headers = Map<String, String>.from(
        options?['headers'] ?? {},
      );
      dynamic body = options?['body'];
      int timeout = options?['timeout'] ?? 60000;

      // 处理 body
      if (body != null) {
        // 如果 body 是 Map 或 List，自动 JSON 序列化并设置 Content-Type
        if (body is Map || body is List) {
          headers['Content-Type'] = 'application/json';
          body = jsonEncode(body);
        } else if (body is String) {
          // 保持原样；若用户未指定 Content-Type，Dio 默认不设置
        } else {
          // 其他类型（如数字、布尔）转为字符串
          body = body.toString();
        }
      }
      // 简单实现GET请求，你可以根据options扩展更多功能
      final response = await _dio.request(
        url,
        data: body,
        options: Options(
          method: options?['method'] as String? ?? 'GET',
          headers: headers,
          connectTimeout: Duration(milliseconds: timeout),
          receiveTimeout: Duration(milliseconds: timeout),
        ),
      );
      return {
        'ok':
            response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300,
        'status': response.statusCode,
        'statusText': response.statusMessage,
        'headers': response.headers.map, // 将 Headers 转为 Map
        'data': response.data, // 可能是 Map/List/String/等，JS 可直接使用
      };
    });
  }

  String __nativeCrypto(List<dynamic> args) {
    String type = args[0] as String;
    String input = args[1] as String;
    if (type == 'md5') {
      return md5.convert(utf8.encode(input)).toString();
    }
    return sha256.convert(utf8.encode(input)).toString();
  }

  // 注入 crypto 实现，供 quickjs 代码调用 MD5 / SHA256
  void _setupCrypto() {
    _jsRuntime.registerFunction('__native_crypto__', __nativeCrypto);
    _jsRuntime.registerFunction('__go_crypto_md5', (List<dynamic> args) {
      return __nativeCrypto(['md5', ...args]);
    });
    _jsRuntime.registerFunction('__go_crypto_sha256', (
      List<dynamic> args,
    ) async {
      return __nativeCrypto(['sha256', ...args]);
    });
  }

  // 注入 AES 加密实现，供 quickjs 代码调用
  // mode 格式: "cbc", "ecb"
  void _setupAES() {
    _jsRuntime.registerFunction('__go_crypto_aes_encrypt', (
      List<dynamic> args,
    ) {
      String dataHex = args[0] as String;
      String mode = args[1] as String;
      String keyHex = args[2] as String;
      String ivHex = args[3] ?? null as String?;

      return goCryptoAesEncrypt(dataHex, mode, keyHex, ivHex);
    });
  }

  // 注入 RSA 加密实现，供 quickjs 代码调用
  void _setupRSA() {
    _jsRuntime.registerFunction('__go_crypto_rsa_encrypt', (
      List<dynamic> args,
    ) {
      String dataHex = args[0] as String;
      String keyPEM = args[1] as String;

      return goCryptoRsaEncrypt(dataHex, keyPEM);
    });
  }

  // 注入 RandomBytes 随机字符实现，供 quickjs 代码调用
  void _setupCryptoRandomBytes() {
    _jsRuntime.registerFunction('__go_crypto_random_bytes', (
      List<dynamic> args,
    ) {
      int size = args[0] as int;
      return goCryptoRandomBytes(size);
    });
  }

  // 注入 BufferFrom 实现，供 quickjs 代码调用
  void _setupBufferFrom() {
    _jsRuntime.registerFunction('__go_buffer_from', (List<dynamic> args) {
      String data = args[0] as String;
      String encoding = args[1] as String;
      return goBufferFrom(data, encoding);
    });
  }

  // 注入 BufferToString 实现，供 quickjs 代码调用
  void _setupBufferToString() {
    _jsRuntime.registerFunction('__go_buffer_to_string', (List<dynamic> args) {
      String dataHex = args[0] as String;
      String encoding = args[1] as String;
      return goBufferToString(dataHex, encoding);
    });
  }

  // 注入 BufferFrom 实现，供 quickjs 代码调用
  void _setupZlibInflate() {
    _jsRuntime.registerFunction('__go_zlib_inflate', (List<dynamic> args) {
      String dataHex = args[0] as String;
      return goZlibInflate(dataHex);
    });
  }

  // 注入 BufferFrom 实现，供 quickjs 代码调用
  void _setupZlibDeflate() {
    _jsRuntime.registerFunction('__go_zlib_deflate', (List<dynamic> args) {
      String dataHex = args[0] as String;
      return goZlibDeflate(dataHex);
    });
  }

  // 注入 BufferFrom 实现，供 quickjs 代码调用
  void _setupRawInflate() {
    _jsRuntime.registerFunction('__go_raw_inflate', (List<dynamic> args) {
      String dataHex = args[0] as String;
      return goRawInflate(dataHex);
    });
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

  Future<dynamic> evalAsync(String expression) async {
    return await _jsRuntime.evalAsync(expression);
  }

  dynamic eval(String expression) {
    return _jsRuntime.eval(expression);
  }

  void dispose() {
    _jsRuntime.dispose();
  }
}
