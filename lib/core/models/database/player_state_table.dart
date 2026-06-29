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
/// 记录每次播放的曲目信息，按时间倒序查询。
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

  /// 播放时间
  DateTimeColumn get playedAt => dateTime().withDefault(currentDateAndTime)();
}
