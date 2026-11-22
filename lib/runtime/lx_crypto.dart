import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as c;
import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/export.dart';

/// LX 脚本可用的加密原语。全部为**同步**实现，供 JS 同步桥调用。
class LxCrypto {
  /// MD5 十六进制小写。
  static String md5Hex(String input) {
    return c.md5.convert(utf8.encode(input)).toString();
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
    final key = base64.decode(keyB64);
    final iv = ivB64.isEmpty ? Uint8List(0) : base64.decode(ivB64);

    final spec = mode.toLowerCase();
    final isCbc = spec.contains('cbc');
    final noPadding = spec.contains('nopadding');

    if (key.length != 16) {
      throw ArgumentError('仅支持 AES-128（16 字节 key），实际 ${key.length}');
    }

    final cipher = PaddedBlockCipherImpl(
      noPadding
          ? _NoPadding()
          : PKCS7Padding(),
      CBCBlockCipher(AESEngine()),
    );
    final effectiveIv = isCbc
        ? (iv.length == 16 ? iv : Uint8List(16))
        : Uint8List(16);

    cipher.init(
      true,
      PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
        ParametersWithIV<KeyParameter>(KeyParameter(key), effectiveIv),
        null,
      ),
    );
    final out = cipher.process(data);
    return base64.encode(out);
  }

  /// RSA 加密（PKCS#1 v1.5），返回 base64。
  ///
  /// [keyB64OrPem] 可以是带 BEGIN/END 的 PEM，也可以是纯 base64 的 DER。
  static String rsaEncryptBase64({
    required String dataB64,
    required String key,
  }) {
    final der = _pemToDer(key);
    final sequence = ASN1Parser(der).nextObject() as ASN1Sequence;
    final elements = sequence.elements;
    if (elements == null || elements.length < 2) {
      throw ArgumentError('无效的 RSA 公钥（DER 结构异常）');
    }
    final modulus = elements[0] as ASN1Integer;
    final exponent = elements[1] as ASN1Integer;
    final publicKey = RSAPublicKey(modulus.integer!, exponent.integer!);

    final engine = PKCS1Encoding(RSAEngine())
      ..init(
        true,
        PublicKeyParameter<RSAPublicKey>(publicKey),
      );
    final data = base64.decode(dataB64);
    // PKCS1 填充要求数据长度不超过 key 长度 - 11
    final out = engine.process(data);
    return base64.encode(out);
  }

  static Uint8List _pemToDer(String key) {
    final cleaned = key
        .replaceAll(RegExp(r'-----(BEGIN|END)[^-]+-----'), '')
        .replaceAll(RegExp(r'\s'), '');
    return base64.decode(cleaned);
  }
}

/// 不做填充，用于服务端要求 NoPadding 的场景。
class _NoPadding implements Padding {
  @override
  String get algorithmName => 'None';

  @override
  void init([CipherParameters? params]) {}

  @override
  Uint8List process(bool pad, Uint8List data) => data;

  @override
  int addPadding(Uint8List data, int offset) => 0;

  @override
  int padCount(Uint8List data) => 0;
}
