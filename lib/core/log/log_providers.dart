/// 日志核心组件 - Riverpod Providers
///
/// 提供日志模块的响应式状态管理。
library;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/log.dart';
import 'package:pomelo/core/models/database/database_provider.dart';

import 'log_entry.dart';
import 'log_module.dart';
import 'log_service.dart';

/// LogModule 实例 Provider
///
/// 内部完成 LogModule 的创建与 onInit 初始化，并注入全局 [setLogService]。
/// main.dart 通过 `container.read(logModuleProvider.future)` 触发初始化。
final logModuleProvider = FutureProvider<LogModule>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final module = LogModule(db: db);
  await module.onInit();
  setLogService(module.service);
  ref.onDispose(() {
    module.onDispose();
    setLogService(null);
  });
  return module;
});

/// 日志模块的 Service Provider
///
/// 同步派生自 [logModuleProvider]。main.dart 在 runApp 前已 await
/// `logModuleProvider.future`，故 UI 访问时必定为 data 状态。
final logServiceProvider = Provider<LogService>((ref) {
  return ref.watch(logModuleProvider).requireValue.service;
});

/// 日志查询 Provider（支持参数化查询）
final logQueryProvider = FutureProvider.family<List<LogEntry>, LogQuery>((
  ref,
  query,
) async {
  final service = ref.watch(logServiceProvider);
  return service.query(query);
});

/// 所有可用的日志标签
final logTagsProvider = FutureProvider<Set<String>>((ref) async {
  final service = ref.watch(logServiceProvider);
  return service.getTags();
});

/// 日志级别统计
final logLevelStatsProvider = FutureProvider<Map<LogLevel, int>>((ref) async {
  final service = ref.watch(logServiceProvider);
  return service.getLevelStats();
});

/// 最新日志（实时最近 100 条）
final latestLogsProvider = FutureProvider<List<LogEntry>>((ref) async {
  final service = ref.watch(logServiceProvider);
  return service.query(const LogQuery(limit: 100));
});

/// 文件存储的最低日志级别
class LogStorageLevelNotifier extends Notifier<LogLevel> {
  @override
  LogLevel build() => ref.read(logServiceProvider).storageLevel;

  Future<void> setLevel(LogLevel level) async {
    await ref.read(logServiceProvider).setStorageLevel(level);
    state = level;
  }
}

final logStorageLevelProvider =
    NotifierProvider<LogStorageLevelNotifier, LogLevel>(
  LogStorageLevelNotifier.new,
);

/// 日志文件路径
final logFilePathProvider = Provider<String?>((ref) {
  return ref.watch(logServiceProvider).logFilePath;
});
