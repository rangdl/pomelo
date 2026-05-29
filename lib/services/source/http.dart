/// musicsdk_flutter - HTTP 工具函数
/// 对应 JS SDK: src/http.ts

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// 默认 User-Agent
const String defaultUserAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';

/// 发送 GET 请求并返回响应体字符串
///
/// @throws [HttpException] 或 [FormatException] 等网络/解析错误
Future<String> httpGet(String url, {Map<String, String>? headers}) async {
  final mergedHeaders = {
    'User-Agent': defaultUserAgent,
    if (headers != null) ...headers,
  };

  final response = await http.get(Uri.parse(url), headers: mergedHeaders);
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw HttpException(
        'HTTP ${response.statusCode}: ${response.reasonPhrase ?? ''}');
  }
  return utf8.decode(response.bodyBytes);
}

/// 发送 POST 请求并返回响应体字符串
///
/// @throws [HttpException] 或 [FormatException] 等网络/解析错误
Future<String> httpPost(String url, String body,
    {Map<String, String>? headers}) async {
  final mergedHeaders = {
    'User-Agent': defaultUserAgent,
    if (headers != null) ...headers,
  };

  final response = await http.post(
    Uri.parse(url),
    headers: mergedHeaders,
    body: body,
  );
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw HttpException(
        'HTTP ${response.statusCode}: ${response.reasonPhrase ?? ''}');
  }
  return utf8.decode(response.bodyBytes);
}

/// 发送 POST JSON 请求
///
/// @throws [HttpException] 或 [FormatException] 等网络/解析错误
Future<String> httpPostJson(String url, Object data,
    {Map<String, String>? headers}) async {
  final mergedHeaders = {
    'Content-Type': 'application/json',
    if (headers != null) ...headers,
  };

  final jsonBody = jsonEncode(data);
  return httpPost(url, jsonBody, headers: mergedHeaders);
}

/// 发送 POST Form 请求
///
/// @throws [HttpException] 或 [FormatException] 等网络/解析错误
Future<String> httpPostForm(String url, Map<String, String> formData,
    {Map<String, String>? headers}) async {
  final mergedHeaders = {
    'Content-Type': 'application/x-www-form-urlencoded',
    if (headers != null) ...headers,
  };

  final body = formData.entries
      .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');

  return httpPost(url, body, headers: mergedHeaders);
}