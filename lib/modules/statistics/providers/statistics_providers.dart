import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/statistics_repository.dart';

/// Statistics 模块 - 状态管理层 (Riverpod Provider)
final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  final repo = StatisticsRepository();
  repo.onInit();
  ref.onDispose(() => repo.onDispose());
  return repo;
});
