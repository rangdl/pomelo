import 'package:drift/drift.dart';

/// 本地音乐库 - 曲目表
///
/// 存储完整的 Track 映射，作为本地音乐库的统一数据源：
/// - 本地扫描的曲目（sourceId='local'，path 非空）
/// - 在线缓存的曲目（sourceId 为各音乐源 id，src 非空，path 可能为缓存文件路径）
///
/// 关键查询字段（title/artist/album/sourceId 等）单独建列以支持索引与过滤，
/// 完整数据存入 [trackJson] 用于零丢失恢复。
@DataClassName('LocalTrackEntity')
class LocalTrackTable extends Table {
  /// 曲目 ID（主键，与 Track.id 一致）
  TextColumn get id => text()();

  /// 标题
  TextColumn get title => text()();

  /// 艺术家（可空）
  TextColumn get artist => text().nullable()();

  /// 专辑名（可空）
  TextColumn get album => text().nullable()();

  /// 专辑 ID（可空）
  TextColumn get albumId => text().nullable()();

  /// 艺术家 ID（可空）
  TextColumn get artistId => text().nullable()();

  /// 封面地址（URL 或本地文件路径，可空）
  TextColumn get coverArt => text().nullable()();

  /// 时长（秒）
  IntColumn get duration => integer().withDefault(const Constant(0))();

  /// 本地文件路径（本地扫描曲目必填，在线缓存曲目可为空）
  TextColumn get path => text().nullable()();

  /// 在线播放地址（可空）
  TextColumn get src => text().nullable()();

  /// 来源 ID（如 'local'、'lx-server-xxx'、'subsonic-xxx'）
  TextColumn get sourceId => text()();

  /// 库 ID（可空）
  TextColumn get libraryId => text().nullable()();

  /// 是否为本地曲目（path != null）
  BoolColumn get isLocal =>
      boolean().withDefault(const Constant(false))();

  /// 完整 Track JSON（用于零丢失恢复）
  TextColumn get trackJson => text()();

  /// 最后更新时间
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// 本地音乐库 - 专辑表
@DataClassName('LocalAlbumEntity')
class LocalAlbumTable extends Table {
  /// 专辑 ID（主键）
  TextColumn get id => text()();

  /// 专辑名称
  TextColumn get name => text()();

  /// 艺术家（可空）
  TextColumn get artist => text().nullable()();

  /// 艺术家 ID（可空）
  TextColumn get artistId => text().nullable()();

  /// 封面地址（可空）
  TextColumn get coverArt => text().nullable()();

  /// 发行年份（可空）
  IntColumn get year => integer().nullable()();

  /// 歌曲数量
  IntColumn get songCount => integer().withDefault(const Constant(0))();

  /// 来源 ID
  TextColumn get sourceId => text()();

  /// 完整 Album JSON
  TextColumn get albumJson => text()();

  /// 最后更新时间
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// 本地音乐库 - 艺术家表
@DataClassName('LocalArtistEntity')
class LocalArtistTable extends Table {
  /// 艺术家 ID（主键）
  TextColumn get id => text()();

  /// 艺术家名称
  TextColumn get name => text()();

  /// 封面地址（可空）
  TextColumn get coverArt => text().nullable()();

  /// 艺术家图片 URL（可空）
  TextColumn get artistImageUrl => text().nullable()();

  /// 专辑数量
  IntColumn get albumCount => integer().withDefault(const Constant(0))();

  /// 来源 ID
  TextColumn get sourceId => text()();

  /// 完整 Artist JSON
  TextColumn get artistJson => text()();

  /// 最后更新时间
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// 本地音乐库 - 歌单表
@DataClassName('LocalPlaylistEntity')
class LocalPlaylistTable extends Table {
  /// 歌单 ID（主键）
  TextColumn get id => text()();

  /// 歌单名称
  TextColumn get name => text()();

  /// 创建者/拥有者（可空）
  TextColumn get owner => text().nullable()();

  /// 封面地址（可空）
  TextColumn get coverArt => text().nullable()();

  /// 歌曲数量
  IntColumn get songCount => integer().withDefault(const Constant(0))();

  /// 来源 ID
  TextColumn get sourceId => text()();

  /// 完整 Playlist JSON
  TextColumn get playlistJson => text()();

  /// 最后更新时间
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
