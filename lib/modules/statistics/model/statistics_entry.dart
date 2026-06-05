/// 统计模块 - 数据模型
class StatisticsEntry {
  final String id;
  final String label;
  final double value;
  final String unit;

  const StatisticsEntry({
    required this.id,
    required this.label,
    required this.value,
    this.unit = '',
  });
}
