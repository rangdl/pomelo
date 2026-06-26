import 'package:flutter/foundation.dart';

/// 健壮的 DateTime 解析，兼容多种格式避免因格式不正确而抛异常
///
/// 支持：
/// - DateTime（直接返回）
/// - int（epoch 毫秒）
/// - ISO 8601 字符串（DateTime.tryParse）
/// - 常见字符串格式：yyyy-MM-dd HH:mm:ss、yyyy/MM/dd HH:mm:ss、yyyy-MM-dd 等
DateTime? tryParseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is String) {
    final str = value.trim();
    if (str.isEmpty) return null;

    // 1. 优先尝试 ISO 8601（DateTime.tryParse 兼容多种 ISO 变体）
    final iso = DateTime.tryParse(str);
    if (iso != null) return iso;

    // 2. 统一分隔符后重试（/ 和 . 替换为 -）
    final normalized = str.replaceAll('/', '-').replaceAll('.', '-');
    final retry = DateTime.tryParse(normalized);
    if (retry != null) return retry;

    // 3. 尝试 "yyyy-MM-dd HH:mm:ss" 等带空格的格式（DateTime.tryParse 已支持）
    //    上述重试已覆盖，此处无需额外处理
  }
  return null;
}

/// 将 DateTime 序列化为 ISO 8601 字符串（null 安全）
String? dateTimeToJson(DateTime? value) =>
    value?.toIso8601String();

@immutable
class DateTimeHelper {
  const DateTimeHelper._();
}
