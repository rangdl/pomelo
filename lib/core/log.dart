/// 日志便捷访问器
///
/// 提供全局 `log` 对象，方便在任何地方记录日志而无需持有 LogService 引用。
///
/// 职责：
/// 1. 控制台输出（开发环境所有级别，发布环境仅 error/fatal）
/// 2. 委托给 LogService 进行持久化存储（若已注册）
///
/// 用法：`log.info('Tag', 'message')`
// ignore_for_file: avoid_print

library;

import 'package:flutter/foundation.dart';
import 'package:pomelo/core/mars.dart';

import '../modules/log/log_module.dart';
import '../modules/log/model/log_entry.dart';
import '../modules/log/service/log_service.dart';

/// 全局日志访问器实例
final Logger log = Logger._();

/// 统一日志访问器
///
/// 控制台输出在入口处完成，确保即使 LogService 未注册也能看到日志。
/// LogService 仅负责持久化（内存 + 文件存储）。
class Logger {
  Logger._();

  LogService? get _service =>
      ModuleManager().find<LogModule>('log')?.service;

  /// 记录调试日志
  void debug(String tag, String message) {
    _console(LogLevel.debug, tag, message);
    _service?.debug(tag, message);
  }

  /// 记录信息日志
  void info(String tag, String message) {
    _console(LogLevel.info, tag, message);
    _service?.info(tag, message);
  }

  /// 记录警告日志
  void warning(
    String tag,
    String message, {
    Object? error,
  }) {
    _console(LogLevel.warning, tag, message, error: error);
    _service?.warning(tag, message, error: error);
  }

  /// 记录错误日志
  void error(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _console(LogLevel.error, tag, message, error: error, stackTrace: stackTrace);
    _service?.error(tag, message, error: error, stackTrace: stackTrace);
  }

  /// 记录严重错误日志
  void fatal(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _console(LogLevel.fatal, tag, message, error: error, stackTrace: stackTrace);
    _service?.fatal(tag, message, error: error, stackTrace: stackTrace);
  }

  /// 控制台输出
  ///
  /// 策略：
  /// - 开发环境（kDebugMode）：所有级别同步打印
  /// - 发布环境：仅 error / fatal 级别输出
  void _console(
    LogLevel level,
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode && level != LogLevel.error && level != LogLevel.fatal) {
      return;
    }

    final time = DateTime.now().toString().substring(0, 19);
    final levelStr = level.name.toUpperCase().padRight(5);
    final errorStr = error != null ? ' | $error' : '';
    final stackStr = stackTrace != null ? '\n$stackTrace' : '';
    print('[Pomelo] $time $levelStr [$tag] $message$errorStr$stackStr');
  }
}
