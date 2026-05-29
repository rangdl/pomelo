/// musicsdk_flutter - 通用工具函数
/// 对应 JS SDK: src/util.ts

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;

/// MD5 哈希（返回 32 位小写 hex 字符串）
String md5(String input) {
  final bytes = utf8.encode(input);
  final digest = crypto.md5.convert(bytes);
  return digest.toString();
}

/// 随机字符串（指定长度，字符集 a-zA-Z0-9）
String randomString(int length) {
  final chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random();
  return String.fromCharCodes(
    List.generate(length, (i) => chars.codeUnitAt(rand.nextInt(chars.length))),
  );
}

/// 反转字符串
String reverseString(String s) {
  return s.split('').reversed.join('');
}

/// 字符串转 hex（UTF-8 编码）
String strToHex(String s) {
  final bytes = utf8.encode(s);
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
}

/// hex 转 base64
String hexToBase64(String hex) {
  final bytes = hex
      .split(RegExp(r'..'))
      .where((s) => s.isNotEmpty)
      .map((s) => int.parse(s, radix: 16))
      .toList();
  return base64Encode(Uint8List.fromList(bytes));
}

/// base64 转 hex
String base64ToHex(String base64) {
  final bytes = base64Decode(base64);
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
}

/// PKCS#7 填充（AES）
Uint8List pkcs7Pad(Uint8List data, int blockSize) {
  final padLen = blockSize - (data.length % blockSize);
  final padded = Uint8List(data.length + padLen);
  padded.setRange(0, data.length, data);
  for (int i = data.length; i < padded.length; i++) {
    padded[i] = padLen;
  }
  return padded;
}

/// PKCS#7 去填充（AES）
Uint8List pkcs7Unpad(Uint8List data) {
  final padLen = data[data.length - 1];
  if (padLen == 0 || padLen > 16) {
    throw ArgumentError('Invalid PKCS#7 padding: $padLen');
  }
  for (int i = data.length - padLen; i < data.length; i++) {
    if (data[i] != padLen) {
      throw ArgumentError('Invalid PKCS#7 padding content');
    }
  }
  return data.sublist(0, data.length - padLen);
}
