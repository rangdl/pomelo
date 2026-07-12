import 'package:drift/drift.dart';

/// Lx 音源插件使用记录表
///
/// 记录每个音源脚本对每个库的调用统计，用于展示成功率与耗时范围。
/// 每行对应一个 (scriptId, libraryId) 组合，upsert 语义累加统计。
///
/// 字段说明：
/// - [totalCount]：总调用次数（含失败）
/// - [successCount]：成功次数（返回非空 URL）
/// - [maxDurationMs] / [minDurationMs]：单次最高/最低耗时（毫秒）
@DataClassName('LxSourceUsageEntity')
class LxSourceUsageTable extends Table {
  /// 音源脚本 ID（关联 [LxSourceScriptTable.id]）
  TextColumn get scriptId => text()();

  /// 库 ID（如 kw、kg、tx 等）
  TextColumn get libraryId => text()();

  /// 总调用次数
  IntColumn get totalCount => integer().withDefault(const Constant(0))();

  /// 成功次数
  IntColumn get successCount => integer().withDefault(const Constant(0))();

  /// 最高耗时（毫秒）
  IntColumn get maxDurationMs => integer().withDefault(const Constant(0))();

  /// 最低耗时（毫秒）
  IntColumn get minDurationMs => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {scriptId, libraryId};
}
