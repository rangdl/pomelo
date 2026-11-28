import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as c;
import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/export.dart';

/// LX 脚本可用的加密原语。全部为**同步**实现，供 JS 同步桥调用。
///
/// 注意：同步桥会阻塞 UI 线程，因此对单次数据量设上限。LX 音源脚本的
/// 典型用途（URL 签名、参数摘要）都在几百字节内，上限设得足够宽松。
class LxCrypto {
  /// 单次加密允许的最大明文长度（字节）。
  static const int maxPlainBytes = 64 * 1024;

  static void _checkSize(int length, String what) {
    if (length > maxPlainBytes) {
      throw ArgumentError(
        '$what 过大（$length 字节），同步加密上限为 $maxPlainBytes 字节；'
        '大文件请改用异步方案',
      );
    }
  }

  /// MD5 十六进制小写。
  static String md5Hex(String input) => md5Bytes(utf8.encode(input));

  /// 对任意字节做 MD5，返回十六进制小写（对应原生 LX 的 Buffer 入参）。
  static String md5Bytes(List<int> bytes) {
    return c.md5.convert(bytes).toString();
  }

  /// AES 加密，返回 base64。
  ///
  /// [mode] 支持 `aes-128-cbc` / `aes-128-ecb`（含 PKCS7 与 NoPadding 变体）。
  /// 输入、key、iv 均为 base64 字符串。
  static String aesEncryptBase64({
    required String dataB64,
    required String mode,
    required String keyB64,
    required String ivB64,
  }) {
    final data = base64.decode(dataB64);
    _checkSize(data.length, 'AES 明文');
    final key = base64.decode(keyB64);
    final iv = ivB64.isEmpty ? Uint8List(0) : base64.decode(ivB64);

    final spec = mode.toLowerCase();
    final isCbc = spec.contains('cbc');
    final noPadding = spec.contains('nopadding');

    if (key.length != 16) {
      throw ArgumentError('仅支持 AES-128（16 字节 key），实际 ${key.length}');
    }

    final effectiveIv = isCbc
        ? (iv.length == 16 ? iv : Uint8List(16))
        : Uint8List(16);
    final params = ParametersWithIV<KeyParameter>(
      KeyParameter(key),
      effectiveIv,
    );

    if (noPadding) {
      // NoPadding 必须整块对齐，且不能用 PaddedBlockCipherImpl
      // ——它会无条件多补一块。直接用底层分组密码。
      if (data.length % 16 != 0) {
        throw ArgumentError('NoPadding 模式要求明文长度为 16 的整数倍，实际 ${data.length} 字节');
      }
      // ECB 模式不接受 IV，只传 KeyParameter
      final cipher = isCbc
          ? (CBCBlockCipher(AESEngine())..init(true, params))
          : (ECBBlockCipher(AESEngine())..init(true, KeyParameter(key)));
      final out = Uint8List(data.length);
      for (var offset = 0; offset < data.length; offset += 16) {
        cipher.processBlock(data, offset, out, offset);
      }
      return base64.encode(out);
    }

    final cipherParams =
        PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
          // ECB 不接受 IV，只传 key。
          isCbc ? params : KeyParameter(key),
          null,
        );
    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      isCbc ? CBCBlockCipher(AESEngine()) : ECBBlockCipher(AESEngine()),
    )..init(true, cipherParams);
    return base64.encode(cipher.process(data));
  }

  /// AES 解密，输入 base64 密文，返回 base64 明文。
  ///
  /// 参数语义与 [aesEncryptBase64] 相同（`aes-128-cbc` / `aes-128-ecb`）。
  static String aesDecryptBase64({
    required String dataB64,
    required String mode,
    required String keyB64,
    required String ivB64,
  }) {
    final data = base64.decode(dataB64);
    _checkSize(data.length, 'AES 密文');
    final key = base64.decode(keyB64);
    final iv = ivB64.isEmpty ? Uint8List(0) : base64.decode(ivB64);

    final spec = mode.toLowerCase();
    final isCbc = spec.contains('cbc');
    final noPadding = spec.contains('nopadding');

    if (key.length != 16) {
      throw ArgumentError('仅支持 AES-128（16 字节 key），实际 ${key.length}');
    }

    final effectiveIv = isCbc
        ? (iv.length == 16 ? iv : Uint8List(16))
        : Uint8List(16);
    final params = ParametersWithIV<KeyParameter>(
      KeyParameter(key),
      effectiveIv,
    );

    if (noPadding) {
      if (data.length % 16 != 0) {
        throw ArgumentError('NoPadding 模式要求密文长度为 16 的整数倍');
      }
      final cipher = isCbc
          ? (CBCBlockCipher(AESEngine())..init(false, params))
          : (ECBBlockCipher(AESEngine())..init(false, KeyParameter(key)));
      final out = Uint8List(data.length);
      for (var offset = 0; offset < data.length; offset += 16) {
        cipher.processBlock(data, offset, out, offset);
      }
      return base64.encode(out);
    }

    final cipherParams =
        PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
          // ECB 不接受 IV，只传 key。
          isCbc ? params : KeyParameter(key),
          null,
        );
    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      isCbc ? CBCBlockCipher(AESEngine()) : ECBBlockCipher(AESEngine()),
    )..init(false, cipherParams);
    return base64.encode(cipher.process(data));
  }

  /// RSA 加密（PKCS#1 v1.5），返回 base64。
  ///
  /// [key] 支持两种常见公钥格式：
  ///   1. X.509 SubjectPublicKeyInfo（`BEGIN PUBLIC KEY`，lx-music 默认）
  ///   2. 裸 PKCS#1 RSAPublicKey（`BEGIN RSA PUBLIC KEY`）
  static String rsaEncryptBase64({
    required String dataB64,
    required String key,
  }) {
    final der = _pemToDer(key);
    final publicKey = _parseRsaPublicKey(der);

    final engine = PKCS1Encoding(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
    final data = base64.decode(dataB64);
    _checkSize(data.length, 'RSA 明文');
    // PKCS1 填充要求数据长度不超过 key 长度 - 11
    if (data.length > (engine.inputBlockSize - 11)) {
      throw ArgumentError(
        'RSA 明文 ${data.length} 字节超出单块上限 ${engine.inputBlockSize - 11} 字节',
      );
    }
    final out = engine.process(data);
    return base64.encode(out);
  }

  /// 解析 DER 公钥，自动区分 X.509 包装与裸 PKCS#1。
  static RSAPublicKey _parseRsaPublicKey(Uint8List der) {
    final top = ASN1Parser(der).nextObject() as ASN1Sequence;
    final elements = top.elements;
    if (elements == null || elements.isEmpty) {
      throw ArgumentError('无效的 RSA 公钥（DER 为空）');
    }

    // 裸 PKCS#1：SEQUENCE { INTEGER modulus, INTEGER exponent }
    if (elements.first is ASN1Integer) {
      return _rsaKeyFrom(elements);
    }

    // X.509：SEQUENCE { AlgorithmIdentifier, BIT STRING <PKCS#1 DER> }
    if (elements.length >= 2 && elements[1] is ASN1BitString) {
      final bits = (elements[1] as ASN1BitString).stringValues;
      if (bits == null || bits.isEmpty) {
        throw ArgumentError('无效的 RSA 公钥（BIT STRING 为空）');
      }
      final inner =
          ASN1Parser(Uint8List.fromList(bits)).nextObject() as ASN1Sequence;
      final innerElements = inner.elements;
      if (innerElements == null || innerElements.length < 2) {
        throw ArgumentError('无效的 RSA 公钥（内层结构异常）');
      }
      return _rsaKeyFrom(innerElements);
    }

    throw ArgumentError('无法识别的 RSA 公钥格式');
  }

  static RSAPublicKey _rsaKeyFrom(List<ASN1Object> elements) {
    if (elements.length < 2 ||
        elements[0] is! ASN1Integer ||
        elements[1] is! ASN1Integer) {
      throw ArgumentError('无效的 RSA 公钥（缺少 modulus/exponent）');
    }
    final modulus = elements[0] as ASN1Integer;
    final exponent = elements[1] as ASN1Integer;
    return RSAPublicKey(modulus.integer!, exponent.integer!);
  }

  static Uint8List _pemToDer(String key) {
    final cleaned = key
        .replaceAll(RegExp(r'-----(BEGIN|END)[^-]+-----'), '')
        .replaceAll(RegExp(r'\s'), '');
    return base64.decode(cleaned);
  }
}
