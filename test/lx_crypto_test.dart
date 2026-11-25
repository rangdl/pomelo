import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pomelo/features/plugins/runtime/lx_crypto.dart';
import 'package:pointycastle/export.dart';

void main() {
  group('md5Hex', () {
    test('与标准 MD5 一致', () {
      expect(LxCrypto.md5Hex('abc'), '900150983cd24fb0d6963f7d28e17f72');
      expect(
        LxCrypto.md5Hex('示例音频 A（SoundHelix）'),
        '354489871cec85647f5afb84f7928d48',
      );
      expect(LxCrypto.md5Hex(''), 'd41d8cd98f00b204e9800998ecf8427e');
    });
  });

  group('aesEncryptBase64', () {
    const key = '1234567890123456'; // 16 字节
    final keyB64 = base64.encode(utf8.encode(key));

    String encrypt(String plain, String mode, {String iv = '0000000000000000'}) {
      return LxCrypto.aesEncryptBase64(
        dataB64: base64.encode(utf8.encode(plain)),
        mode: mode,
        keyB64: keyB64,
        ivB64: base64.encode(utf8.encode(iv)),
      );
    }

    test('CBC + PKCS7 可用标准工具解密还原', () {
      const plain = 'hello pomelo';
      const iv = 'abcdefghijklmnop';
      final out = encrypt(plain, 'aes-128-cbc', iv: iv);

      final cipher = PaddedBlockCipherImpl(
        PKCS7Padding(),
        CBCBlockCipher(AESEngine()),
      )..init(
          false,
          PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
            ParametersWithIV<KeyParameter>(
              KeyParameter(Uint8List.fromList(utf8.encode(key))),
              Uint8List.fromList(utf8.encode(iv)),
            ),
            null,
          ),
        );
      final decrypted = utf8.decode(cipher.process(base64.decode(out)));
      expect(decrypted, plain);
    });

    test('ECB + NoPadding 长度与输入一致', () {
      const plain = '0123456789abcdef'; // 恰好一个块
      final out = encrypt(plain, 'aes-128-ecb-nopadding');
      expect(base64.decode(out).length, 16);
    });

    test('非 16 字节 key 报错', () {
      expect(
        () => LxCrypto.aesEncryptBase64(
          dataB64: base64.encode(utf8.encode('x')),
          mode: 'aes-128-cbc',
          keyB64: base64.encode(utf8.encode('short')),
          ivB64: '',
        ),
        throwsArgumentError,
      );
    });

    test('超过同步上限时报错', () {
      final big = base64.encode(List<int>.filled(LxCrypto.maxPlainBytes + 1, 0));
      expect(
        () => LxCrypto.aesEncryptBase64(
          dataB64: big,
          mode: 'aes-128-cbc',
          keyB64: keyB64,
          ivB64: base64.encode(utf8.encode('0000000000000000')),
        ),
        throwsArgumentError,
      );
    });
  });

  group('rsaEncryptBase64', () {
    late RSAPublicKey publicKey;
    late RSAPrivateKey privateKey;

    setUp(() {
      final pair = generateKeyPair();
      publicKey = pair.publicKey as RSAPublicKey;
      privateKey = pair.privateKey as RSAPrivateKey;
    });

    test('X.509 包装格式（BEGIN PUBLIC KEY）', () {
      final pem = _x509Pem(publicKey);
      final out = LxCrypto.rsaEncryptBase64(
        dataB64: base64.encode(utf8.encode('secret')),
        key: pem,
      );
      expect(_rsaDecrypt(out, privateKey), 'secret');
    });

    test('裸 PKCS#1 格式（BEGIN RSA PUBLIC KEY）', () {
      final pem = _pkcs1Pem(publicKey);
      final out = LxCrypto.rsaEncryptBase64(
        dataB64: base64.encode(utf8.encode('secret')),
        key: pem,
      );
      expect(_rsaDecrypt(out, privateKey), 'secret');
    });

    test('明文超出单块上限报错', () {
      final tooLong = base64.encode(List<int>.filled(512, 65));
      expect(
        () => LxCrypto.rsaEncryptBase64(
          dataB64: tooLong,
          key: _x509Pem(publicKey),
        ),
        throwsArgumentError,
      );
    });
  });
}

AsymmetricKeyPair<PublicKey, PrivateKey> generateKeyPair() {
  final keyGen = RSAKeyGenerator()
    ..init(ParametersWithRandom(
      RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64),
      SecureRandom('Fortuna')
        ..seed(KeyParameter(Uint8List.fromList(List<int>.generate(32, (i) => i + 1)))),
    ));
  return keyGen.generateKeyPair();
}

/// 构造 X.509 SubjectPublicKeyInfo PEM。
String _x509Pem(RSAPublicKey key) {
  final pkcs1 = _derSequence([_derInt(key.modulus!), _derInt(key.publicExponent!)]);
  final algorithm = _derSequence([
    _derOid([0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01]),
    _derNull(),
  ]);
  final spki = _derSequence([algorithm, _derBitString(pkcs1)]);
  return '-----BEGIN PUBLIC KEY-----\n${base64.encode(spki)}\n-----END PUBLIC KEY-----';
}

/// 构造裸 PKCS#1 RSAPublicKey PEM。
String _pkcs1Pem(RSAPublicKey key) {
  final pkcs1 = _derSequence([_derInt(key.modulus!), _derInt(key.publicExponent!)]);
  return '-----BEGIN RSA PUBLIC KEY-----\n${base64.encode(pkcs1)}\n'
      '-----END RSA PUBLIC KEY-----';
}

String _rsaDecrypt(String cipherB64, RSAPrivateKey key) {
  final engine = PKCS1Encoding(RSAEngine())
    ..init(false, PrivateKeyParameter<RSAPrivateKey>(key));
  return utf8.decode(engine.process(base64.decode(cipherB64)));
}

// --- 最小 DER 编码工具 ---

List<int> _derLen(int len) {
  if (len < 0x80) return [len];
  final bytes = <int>[];
  var v = len;
  while (v > 0) {
    bytes.insert(0, v & 0xFF);
    v >>= 8;
  }
  return [0x80 | bytes.length, ...bytes];
}

List<int> _derTag(int tag, List<int> body) => [tag, ..._derLen(body.length), ...body];

List<int> _derSequence(List<List<int>> items) =>
    _derTag(0x30, items.expand((e) => e).toList());

List<int> _derNull() => [0x05, 0x00];

List<int> _derInt(BigInt value) {
  var hex = value.toRadixString(16);
  if (hex.length.isOdd) hex = '0$hex';
  final bytes = <int>[
    for (var i = 0; i < hex.length; i += 2) int.parse(hex.substring(i, i + 2), radix: 16),
  ];
  // DER INTEGER 为正数时若最高位为 1，需要补 0x00
  if (bytes.isNotEmpty && (bytes.first & 0x80) != 0) bytes.insert(0, 0);
  return _derTag(0x02, bytes);
}

List<int> _derOid(List<int> body) => _derTag(0x06, body);

List<int> _derBitString(List<int> body) => _derTag(0x03, [0x00, ...body]);
