import 'package:drift/drift.dart';

/// 播放器状态表（单行，id 固定为 0）
///
/// 持久化当前播放器的整体状态。
@DataClassName('PlayerStateEntity')
class PlayerStateTable extends Table {
  /// 固定为 0，确保单行
  IntColumn get id => integer().withDefault(const Constant(0))();

  /// 是否正在播放
  BoolColumn get playing => boolean().withDefault(const Constant(false))();

  /// 循环模式：'none' | 'loop' | 'loopOne'
  TextColumn get loopMode => text().withDefault(const Constant('none'))();

  /// 是否随机播放
  BoolColumn get shuffled => boolean().withDefault(const Constant(false))();

  /// 当前曲目索引
  IntColumn get currentIndex => integer().withDefault(const Constant(0))();

  /// 收藏集合 ID 列表（JSON 数组字符串）
  TextColumn get collections =>
      text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// 播放列表曲目表
///
/// 存储当前播放队列中的曲目，按 [orderIndex] 排序。
@DataClassName('PlayerTrackEntity')
class PlayerTrackTable extends Table {
  /// 自增主键
  IntColumn get id => integer().autoIncrement()();

  /// 在播放列表中的顺序
  IntColumn get orderIndex => integer()();

  /// 曲目 ID（用于快速查找）
  TextColumn get trackId => text()();

  /// 完整曲目 JSON
  TextColumn get trackJson => text()();
}

/// 播放记录表
///
/// 每个曲目一行，记录播放次数和最后播放时间。
/// 使用 upsert 语义：曲目已存在时递增 [playCount] 并更新 [playedAt]。
@DataClassName('PlayHistoryEntity')
class PlayHistoryTable extends Table {
  /// 自增主键
  IntColumn get id => integer().autoIncrement()();

  /// 曲目 ID
  TextColumn get trackId => text()();

  /// 完整曲目 JSON（用于恢复完整信息）
  TextColumn get trackJson => text()();

  /// 来源 ID
  TextColumn get sourceId => text()();

  /// 来源名称
  TextColumn get sourceName => text().withDefault(const Constant(''))();

  /// 曲目标题
  TextColumn get title => text()();

  /// 艺术家
  TextColumn get artist => text().nullable()();

  /// 封面
  TextColumn get coverArt => text().nullable()();

  /// 时长（秒）
  IntColumn get duration => integer().withDefault(const Constant(0))();

  /// 播放时间（最后一次播放）
  DateTimeColumn get playedAt => dateTime().withDefault(currentDateAndTime)();

  /// 播放次数
  IntColumn get playCount => integer().withDefault(const Constant(1))();
}

/// 已解析音源曲目持久化表
///
/// 缓存曲目在各音质下的播放链接和本地缓存文件路径，
/// 下次播放时优先使用本地缓存文件，次选缓存的播放链接，
/// 全部未命中或失效时重新获取并更新记录。
@DataClassName('SourcedTrackEntity')
class SourcedTrackTable extends Table {
  /// 曲目 ID（主键）
  TextColumn get trackId => text()();

  /// 来源服务 ID
  TextColumn get sourceId => text()();

  /// 库 ID（可空）
  TextColumn get libraryId => text().nullable()();

  /// 可用音质列表（JSON 数组字符串，如 `["flac","320k","128k"]`）
  TextColumn get qualities => text().withDefault(const Constant('[]'))();

  /// 音质 → 播放链接映射（JSON 对象，如 `{"flac":"https://...","320k":"https://..."}`)
  TextColumn get urlMap => text().withDefault(const Constant('{}'))();

  /// 音质 → 本地缓存文件路径映射（JSON 对象）
  TextColumn get cachePathMap => text().withDefault(const Constant('{}'))();

  /// 最后更新时间
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {trackId};
}
