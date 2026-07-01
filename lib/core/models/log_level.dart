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
