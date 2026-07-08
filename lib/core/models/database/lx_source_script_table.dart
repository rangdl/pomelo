import 'package:drift/drift.dart';

/// Lx 音源脚本表
///
/// 存储用户添加的 Lx 音源插件脚本内容（不依赖文件系统）。
/// 每行对应一份音源插件脚本，包含：
/// - 解析自脚本头部注释的元信息（name/description/author/homepage/version）
/// - 完整脚本内容（[script]）
/// - 加载后注册的库与音质列表（[librariesJson]）
///
/// 库信息 JSON 结构：
/// ```json
/// [
///   {"id":"kw","name":"kw","qualitys":["128k","320k","flac"]},
///   {"id":"kg","name":"kg","qualitys":["128k","320k","flac"]}
/// ]
/// ```
@DataClassName('LxSourceScriptEntity')
class LxSourceScriptTable extends Table {
  /// 脚本唯一标识（基于脚本内容 hash 生成）
  TextColumn get id => text()();

  /// 脚本名称（解析自 @name）
  TextColumn get name => text()();

  /// 描述（解析自 @description，可空）
  TextColumn get description => text().nullable()();

  /// 作者（解析自 @author，可空）
  TextColumn get author => text().nullable()();

  /// 主页（解析自 @homepage，可空）
  TextColumn get homepage => text().nullable()();

  /// 版本（解析自 @version，可空）
  TextColumn get version => text().nullable()();

  /// 完整脚本内容
  TextColumn get script => text()();

  /// 注册的库与音质列表 JSON 字符串
  TextColumn get librariesJson =>
      text().withDefault(const Constant('[]'))();

  /// 添加时间
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// 是否启用
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
