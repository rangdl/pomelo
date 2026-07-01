import 'package:drift/drift.dart';

/// 音乐服务配置表
///
/// 统一存储所有音乐源（local/lx/lxServer/subsonic）的配置。
/// 每行一个配置，基类字段（id/name/type）映射到表列，
/// 子类额外字段以 JSON 字符串存储在 [configJson] 列。
@DataClassName('MusicServerConfigEntity')
class MusicServerConfigTable extends Table {
  /// 配置唯一标识（如 'local'、'lx'、'lx-server-xxx'、'subsonic-xxx'）
  TextColumn get id => text()();

  /// 显示名称
  TextColumn get name => text()();

  /// 来源类型（MusicSourceType.name）
  TextColumn get type => text()();

  /// 子类额外字段的 JSON 字符串
  TextColumn get configJson => text().withDefault(const Constant('{}'))();

  /// 是否启用
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
