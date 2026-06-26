/// 日志服务层
///
/// 封装日志核心业务逻辑，提供便捷的日志记录 API。
/// 其他模块可通过此服务记录日志。
library;

import 'package:pomelo/core/mars.dart';

import 'log_entry.dart';
import 'log_repository.dart';

class LogService extends Service {
  @override
  String get id => 'log_service';

  final LogRepository repository;

  /// 日志回调监听器（可用于实时输出日志到控制台或外部）
  final List<void Function(LogEntry entry)> _listeners = [];

  LogService(this.repository);

  /// 记录调试日志
  void debug(
    String tag,
    String message, {
    String? sourceModuleId,
    Map<String, dynamic>? metadata,
  }) {
    _record(
      LogLevel.debug,
      tag,
      message,
      sourceModuleId: sourceModuleId,
      metadata: metadata,
    );
  }

  /// 记录信息日志
  void info(
    String tag,
    String message, {
    String? sourceModuleId,
    Map<String, dynamic>? metadata,
  }) {
    _record(
      LogLevel.info,
      tag,
      message,
      sourceModuleId: sourceModuleId,
      metadata: metadata,
    );
  }

  /// 记录警告日志
  void warning(
    String tag,
    String message, {
    String? sourceModuleId,
    Object? error,
    Map<String, dynamic>? metadata,
  }) {
    _record(
      LogLevel.warning,
      tag,
      message,
      sourceModuleId: sourceModuleId,
      error: error,
      metadata: metadata,
    );
  }

  /// 记录错误日志
  void error(
    String tag,
    String message, {
    String? sourceModuleId,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    _record(
      LogLevel.error,
      tag,
      message,
      sourceModuleId: sourceModuleId,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    );
  }

  /// 记录严重错误日志
  void fatal(
    String tag,
    String message, {
    String? sourceModuleId,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    _record(
      LogLevel.fatal,
      tag,
      message,
      sourceModuleId: sourceModuleId,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    );
  }

  /// 获取当前文件存储的最低日志级别
  LogLevel get storageLevel => repository.storageLevel;

  /// 设置文件存储的最低日志级别
  ///
  /// 低于此级别的日志仅存内存，不写入文件。
  Future<void> setStorageLevel(LogLevel level) =>
      repository.setStorageLevel(level);

  /// 日志文件路径
  String? get logFilePath => repository.logFilePath;

  /// 导出日志文件内容
  Future<String> exportFileContent() => repository.exportFileContent();

  /// 统一的日志记录内部方法
  ///
  /// 仅负责持久化（内存 + 文件）和监听器通知。
  /// 控制台输出由 [Logger] 入口类处理，避免重复打印。
  void _record(
    LogLevel level,
    String tag,
    String message, {
    String? sourceModuleId,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    final entry = LogEntry(
      level: level,
      tag: tag,
      message: message,
      sourceModuleId: sourceModuleId,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    );

    // 保存到仓储
    repository.save(entry);

    // 通知监听器（用于 UI 实时展示等）
    for (final listener in _listeners) {
      listener(entry);
    }
  }

  /// 添加日志监听器
  void addListener(void Function(LogEntry entry) listener) {
    _listeners.add(listener);
  }

  /// 移除日志监听器
  void removeListener(void Function(LogEntry entry) listener) {
    _listeners.remove(listener);
  }

  /// 按条件查询日志
  Future<List<LogEntry>> query(LogQuery query) => repository.query(query);

  /// 获取日志级别统计
  Future<Map<LogLevel, int>> getLevelStats() => repository.getLevelStats();

  /// 获取所有标签
  Future<Set<String>> getTags() => repository.getTags();

  /// 清理日志
  Future<int> cleanOlderThan(Duration duration) =>
      repository.cleanOlderThan(duration);

  Future<int> cleanByLevel(LogLevel level) => repository.cleanByLevel(level);

  /// 清理所有日志
  Future<void> cleanAll() => repository.deleteAll();

  /// 当前日志数量
  int get count => repository.count;

  @override
  Future<void> onInit() async {
    await super.onInit();
  }

  @override
  Future<void> onDispose() async {
    await super.onDispose();
    _listeners.clear();
  }
}
