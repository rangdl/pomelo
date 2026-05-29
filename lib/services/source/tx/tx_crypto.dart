/// musicsdk_flutter - 腾讯音乐加密工具
/// 对应 JS SDK: src/tx_crypto.ts

import '../util/util.dart';

/// 腾讯音乐平台加密相关常量
const String txAppKey = 'c9a3b1d4e7f8a2c5b6d9e0f1a3c5b7d9';
const String txAppSecret = 'f8a2c5b6d9e0f1a3c5b7d9e2f4a6c8d0';

/// 腾讯音乐 MD5 签名生成
/// @param params 请求参数（Map）
/// @param timestamp 时间戳（秒）
/// @returns 签名字符串（小写 hex）
String txSign(Map<String, dynamic> params, int timestamp) {
  final List<String> keys = params.keys.toList()..sort();
  final List<String> pairs = [];
  for (final key in keys) {
    final value = params[key];
    if (value != null) {
      pairs.add('$key=$value');
    }
  }
  final String paramString = pairs.join('&');
  final String signStr =
      '$paramString&app_key=$txAppKey&time_stamp=$timestamp&format=json&nonce_str=${randomString(16)}&app_secret=$txAppSecret';
  return md5(signStr).toLowerCase();
}

/// 腾讯音乐 API 加密请求（通用封装）
/// @param url API 地址
/// @param params 请求参数
/// @returns 加密后的完整 URL
String txEncryptUrl(String url, Map<String, dynamic> params) {
  final int timestamp = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
  final String sign = txSign(params, timestamp);

  final List<String> queryParts = [];
  for (final entry in params.entries) {
    queryParts.add(
      '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value.toString())}',
    );
  }
  queryParts.add('app_key=${Uri.encodeComponent(txAppKey)}');
  queryParts.add('time_stamp=$timestamp');
  queryParts.add('format=json');
  queryParts.add('nonce_str=${Uri.encodeComponent(randomString(16))}');
  queryParts.add('sign=${Uri.encodeComponent(sign)}');

  return '$url?${queryParts.join('&')}';
}
