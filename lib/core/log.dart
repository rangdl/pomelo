/// 日志便捷访问器
///
/// 提供全局 `log` 对象，方便在任何地方记录日志而无需持有 LogService 引用。
/// 若 LogModule 已注册则委托给 LogService，否则回退到 `print`。
///
/// 用法：`log.info('Tag', 'message')`
// ignore_for_file: avoid_print

library;

import 'package:pomelo/core/mars.dart';

import '../modules/log/log_module.dart';
import '../modules/log/service/log_service.dart';

/// 全局日志访问器实例
final Logger log = Logger._();

/// 统一日志访问器
///
/// 封装了对 LogService 的委托逻辑：
/// - LogModule 已注册 → 调用 LogService 记录日志
/// - LogModule 未注册 → 回退到 print 输出
class Logger {
  Logger._();

  LogService? get _service =>
      ModuleManager().find<LogModule>('log')?.service;

  /// 记录调试日志
  void debug(String tag, String message) {
    final s = _service;
    if (s != null) {
      s.debug(tag, message);
    } else {
      print('[DBG][$tag] $message');
    }
  }

  /// 记录信息日志
  void info(String tag, String message) {
    final s = _service;
    if (s != null) {
      s.info(tag, message);
    } else {
      print('[INF][$tag] $message');
    }
  }

  /// 记录警告日志
  void warning(
    String tag,
    String message, {
    Object? error,
  }) {
    final s = _service;
    if (s != null) {
      s.warning(tag, message, error: error);
    } else {
      print('[WRN][$tag] $message${error != null ? ' ($error)' : ''}');
    }
  }

  /// 记录错误日志
  void error(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final s = _service;
    if (s != null) {
      s.error(tag, message, error: error, stackTrace: stackTrace);
    } else {
      print('[ERR][$tag] $message${error != null ? ' ($error)' : ''}');
    }
  }

  /// 记录严重错误日志
  void fatal(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final s = _service;
    if (s != null) {
      s.fatal(tag, message, error: error, stackTrace: stackTrace);
    } else {
      print('[FTL][$tag] $message${error != null ? ' ($error)' : ''}');
    }
  }
}
