import 'package:pomelo/core/mars.dart';
import '../model/statistics_entry.dart';

/// Statistics 模块 - 仓储层
class StatisticsRepository extends InMemoryRepository<StatisticsEntry> {
  StatisticsRepository()
    : super(id: 'statistics_repository', idSelector: (item) => item.id);

  @override
  Future<void> onInit() async {
    await saveAll([
      const StatisticsEntry(id: '1', label: '项目数', value: 12, unit: '个'),
      const StatisticsEntry(id: '2', label: '完成率', value: 75, unit: '%'),
    ]);
  }
}
