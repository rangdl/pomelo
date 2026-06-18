/// 日志模块 - Riverpod Providers
///
/// 提供日志模块的响应式状态管理。
library;

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/log_entry.dart';
import '../service/log_service.dart';

/// 日志模块的 Service Provider
final logServiceProvider = Provider<LogService>((ref) {
  throw UnimplementedError(
    'LogService must be provided via overrides in main.dart',
  );
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
