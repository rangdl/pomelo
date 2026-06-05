import 'package:pomelo/core/mars.dart';
import '../model/statistics_entry.dart';
import '../repository/statistics_repository.dart';

/// Statistics 模块 - 服务层
class StatisticsService extends Service {
  @override
  String get id => 'statistics_service';

  final StatisticsRepository repository;

  StatisticsService(this.repository);

  /// 获取所有统计数据
  List<StatisticsEntry> getAllEntries() => throw UnimplementedError('待实现');
}
