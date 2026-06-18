/// 日志条目数据模型
///
/// 表示一条应用内日志记录。
/// 遵循 M.A.R.S. 架构中的 Model 层。
class LogEntry {
  /// 日志级别
  final LogLevel level;

  /// 日志标签（用于分类过滤，如 "network"、"database"、"ui" 等）
  final String tag;

  /// 日志消息内容
  final String message;

  /// 日志记录时间
  final DateTime timestamp;

  /// 错误详情（可选）
  final Object? error;

  /// 堆栈跟踪（可选）
  final StackTrace? stackTrace;

  /// 来源模块标识
  final String? sourceModuleId;

  /// 附加元数据
  final Map<String, dynamic>? metadata;

  LogEntry({
    required this.level,
    required this.tag,
    required this.message,
    DateTime? timestamp,
    this.error,
    this.stackTrace,
    this.sourceModuleId,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 格式化为可读字符串
  String get formatted {
    final time = timestamp.toString().substring(0, 19);
    final levelStr = level.name.toUpperCase().padRight(5);
    final tagStr = '[$tag]';
    final sourceStr = sourceModuleId != null ? '($sourceModuleId)' : '';
    final errorStr = error != null ? '\n  └─ Error: $error' : '';
    final stackStr = stackTrace != null ? '\n  └─ StackTrace: $stackTrace' : '';

    return '$time $levelStr $tagStr $sourceStr $message$errorStr$stackStr';
  }

  /// 格式化为 JSON
  Map<String, dynamic> toJson() => {
    'level': level.name,
    'tag': tag,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    if (error != null) 'error': error.toString(),
    if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    if (sourceModuleId != null) 'sourceModuleId': sourceModuleId,
    if (metadata != null) 'metadata': metadata,
  };

  /// 从 JSON 创建
  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      level: LogLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => LogLevel.info,
      ),
      tag: json['tag'] as String? ?? '',
      message: json['message'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String)
          : null,
      error: json['error'] as Object?,
      stackTrace: json['stackTrace'] != null
          ? StackTrace.fromString(json['stackTrace'] as String)
          : null,
      sourceModuleId: json['sourceModuleId'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  LogEntry copyWith({
    LogLevel? level,
    String? tag,
    String? message,
    DateTime? timestamp,
    Object? error,
    StackTrace? stackTrace,
    String? sourceModuleId,
    Map<String, dynamic>? metadata,
    bool clearError = false,
    bool clearStackTrace = false,
    bool clearMetadata = false,
  }) {
    return LogEntry(
      level: level ?? this.level,
      tag: tag ?? this.tag,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      error: clearError ? null : (error ?? this.error),
      stackTrace: clearStackTrace ? null : (stackTrace ?? this.stackTrace),
      sourceModuleId: sourceModuleId ?? this.sourceModuleId,
      metadata: clearMetadata ? null : (metadata ?? this.metadata),
    );
  }

  @override
  String toString() => formatted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogEntry &&
          runtimeType == other.runtimeType &&
          level == other.level &&
          tag == other.tag &&
          message == other.message &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(level, tag, message, timestamp);
}

/// 日志级别
enum LogLevel {
  /// 详细调试信息（仅在开发环境输出）
  debug,

  /// 一般信息
  info,

  /// 警告
  warning,

  /// 错误
  error,

  /// 严重错误（可能导致应用功能异常）
  fatal,
}

/// 过滤日志的查询条件
class LogQuery {
  /// 日志级别过滤（不传则不过滤）
  final Set<LogLevel>? levels;

  /// 标签过滤（不传则不过滤）
  final Set<String>? tags;

  /// 来源模块过滤（不传则不过滤）
  final Set<String>? sourceModuleIds;

  /// 起始时间（不传则不过滤）
  final DateTime? from;

  /// 结束时间（不传则不过滤）
  final DateTime? to;

  /// 关键词搜索（在消息中搜索）
  final String? keyword;

  /// 是否只查询错误日志（含 error 或 stackTrace）
  final bool? hasError;

  /// 最大返回条数（0 表示不限制）
  final int limit;

  /// 是否按时间倒序排列
  final bool descending;

  const LogQuery({
    this.levels,
    this.tags,
    this.sourceModuleIds,
    this.from,
    this.to,
    this.keyword,
    this.hasError,
    this.limit = 0,
    this.descending = true,
  });

  /// 判断指定条目是否匹配当前查询条件
  bool matches(LogEntry entry) {
    if (levels != null && !levels!.contains(entry.level)) return false;
    if (tags != null && !tags!.contains(entry.tag)) return false;
    if (sourceModuleIds != null &&
        !sourceModuleIds!.contains(entry.sourceModuleId)) {
      return false;
    }
    if (from != null && entry.timestamp.isBefore(from!)) return false;
    if (to != null && entry.timestamp.isAfter(to!)) return false;
    if (keyword != null &&
        !entry.message.toLowerCase().contains(keyword!.toLowerCase())) {
      return false;
    }
    if (hasError == true && entry.error == null) return false;
    return true;
  }
}
