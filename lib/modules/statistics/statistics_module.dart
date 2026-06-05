import 'package:pomelo/core/mars.dart';
import 'repository/statistics_repository.dart';
import 'service/statistics_service.dart';

/// Statistics 模块定义
///
/// 遵循 M.A.R.S. 架构：
/// - Model: statistics_entry.dart
/// - Action: (模块初始化/就绪/销毁)
/// - Repository: StatisticsRepository
/// - Service/State: StatisticsService / Riverpod Provider
class StatisticsModule extends Module {
  StatisticsModule() : _repository = StatisticsRepository();

  final StatisticsRepository _repository;
  late final StatisticsService _service;

  @override
  String get id => 'statistics';

  @override
  String get displayName => '统计';

  @override
  bool get lazy => true;

  @override
  Future<void> onInit() async {
    await _repository.onInit();
    _service = StatisticsService(_repository);
    await _service.onInit();
  }

  @override
  Future<void> onDispose() async {
    await _repository.onDispose();
    await _service.onDispose();
  }

  /// 获取仓储实例（供外部使用）
  StatisticsRepository get repository => _repository;
}
