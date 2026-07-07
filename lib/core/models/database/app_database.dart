import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pomelo/core/helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'local_library_table.dart';
import 'lx_source_script_table.dart';
import 'music_server_config_table.dart';
import 'player_state_table.dart';

part 'app_database.g.dart';

/// 应用数据库
///
/// 基于 drift (SQLite) 的持久化数据库，负责：
/// - 播放器状态持久化（替代旧的 freezed + Hive 方案）
/// - 当前播放列表持久化
/// - 播放记录（含播放次数）
/// - 已解析音源曲目持久化（播放链接与缓存路径）
/// - 音乐服务配置（统一管理所有音乐源配置）
/// - 本地音乐库（完整 Track/Album/Artist/Playlist 映射，作为本地音乐数据源）
@DriftDatabase(tables: [
  PlayerStateTable,
  PlayerTrackTable,
  PlayHistoryTable,
  SourcedTrackTable,
  PreferenceTable,
  MusicServerConfigTable,
  LocalTrackTable,
  LocalAlbumTable,
  LocalArtistTable,
  LocalPlaylistTable,
  LxSourceScriptTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  /// 用于测试的构造函数
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2: 新增 SourcedTrackTable + PlayHistoryTable.playCount 列
            await m.createTable(sourcedTrackTable);
            await m.addColumn(playHistoryTable, playHistoryTable.playCount);
          }
          if (from < 3) {
            // v3: 新增 PreferenceTable（迁移自 hive_ce 存储）
            await m.createTable(preferenceTable);
          }
          if (from < 4) {
            // v4: 新增 MusicServerConfigTable（统一音乐源配置存储）
            await m.createTable(musicServerConfigTable);
          }
          if (from < 5) {
            // v5: 新增本地音乐库 4 张表（Track/Album/Artist/Playlist 完整映射）
            await m.createTable(localTrackTable);
            await m.createTable(localAlbumTable);
            await m.createTable(localArtistTable);
            await m.createTable(localPlaylistTable);
          }
          if (from < 6) {
            // v6: 新增 LxSourceScriptTable（音源脚本内容存储，替代文件存储）
            await m.createTable(lxSourceScriptTable);
          }
        },
      );

  // ========== 播放器状态 ==========

  /// 获取播放器状态（单行，id=0）
  Future<PlayerStateEntity?> getPlayerState() async {
    final result = await (select(playerStateTable)
          ..where((t) => t.id.equals(0)))
        .get();
    return result.isEmpty ? null : result.first;
  }

  /// 保存播放器状态（upsert）
  Future<void> upsertPlayerState(PlayerStateTableCompanion companion) async {
    await into(playerStateTable).insertOnConflictUpdate(
      PlayerStateTableCompanion.insert(
        id: const Value(0),
        playing: companion.playing,
        loopMode: companion.loopMode,
        shuffled: companion.shuffled,
        currentIndex: companion.currentIndex,
        collections: companion.collections,
      ),
    );
  }

  // ========== 播放列表曲目 ==========

  /// 获取播放列表所有曲目（按 orderIndex 排序）
  Future<List<PlayerTrackEntity>> getPlayerTracks() {
    return (select(playerTrackTable)
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
  }

  /// 替换整个播放列表
  Future<void> replacePlayerTracks(
      List<PlayerTrackTableCompanion> companions) async {
    await batch((batch) {
      batch.deleteAll(playerTrackTable);
      batch.insertAll(playerTrackTable, companions);
    });
  }

  /// 清空播放列表
  Future<void> clearPlayerTracks() {
    return playerTrackTable.deleteAll();
  }

  // ========== 播放记录 ==========

  /// 添加播放记录（upsert：曲目已存在时递增 playCount 并更新信息）
  Future<void> addPlayHistory(PlayHistoryTableCompanion companion) async {
    final trackId = companion.trackId.value;
    final existing = await (select(playHistoryTable)
          ..where((t) => t.trackId.equals(trackId)))
        .getSingleOrNull();
    if (existing != null) {
      await (update(playHistoryTable)
            ..where((t) => t.trackId.equals(trackId)))
          .write(PlayHistoryTableCompanion(
        trackJson: companion.trackJson,
        sourceId: companion.sourceId,
        sourceName: companion.sourceName,
        title: companion.title,
        artist: companion.artist,
        coverArt: companion.coverArt,
        duration: companion.duration,
        playedAt: companion.playedAt,
        playCount: Value(existing.playCount + 1),
      ));
    } else {
      await into(playHistoryTable).insert(companion);
    }
  }

  /// 获取播放记录（按时间倒序）
  Future<List<PlayHistoryEntity>> getPlayHistory({int limit = 100}) {
    return (select(playHistoryTable)
          ..orderBy([(t) => OrderingTerm.desc(t.playedAt)])
          ..limit(limit))
        .get();
  }

  /// 获取最近播放的曲目（按最后播放时间倒序）
  ///
  /// v2 起每个曲目仅一行（upsert 语义），无需去重。
  Future<List<PlayHistoryEntity>> getRecentPlayed({int limit = 50}) {
    return (select(playHistoryTable)
          ..orderBy([(t) => OrderingTerm.desc(t.playedAt)])
          ..limit(limit))
        .get();
  }

  /// 清空播放记录
  Future<void> clearPlayHistory() {
    return playHistoryTable.deleteAll();
  }

  /// 删除指定曲目的播放记录
  Future<void> deletePlayHistoryByTrackId(String trackId) {
    return (delete(playHistoryTable)
          ..where((t) => t.trackId.equals(trackId)))
        .go();
  }

  // ========== 已解析音源曲目持久化 ==========

  /// 获取指定曲目的持久化记录
  Future<SourcedTrackEntity?> getSourcedTrack(String trackId) {
    return (select(sourcedTrackTable)
          ..where((t) => t.trackId.equals(trackId)))
        .getSingleOrNull();
  }

  /// 插入或更新已解析音源曲目记录（upsert）
  Future<void> upsertSourcedTrack(SourcedTrackTableCompanion companion) async {
    await into(sourcedTrackTable).insertOnConflictUpdate(companion);
  }

  /// 删除指定曲目的持久化记录
  Future<void> deleteSourcedTrack(String trackId) {
    return (delete(sourcedTrackTable)
          ..where((t) => t.trackId.equals(trackId)))
        .go();
  }

  // ========== 用户偏好设置 ==========

  /// 获取用户偏好设置 JSON 字符串（单行，id=0）
  Future<String?> getPreference() async {
    final result = await (select(preferenceTable)
          ..where((t) => t.id.equals(0)))
        .get();
    return result.isEmpty ? null : result.first.value;
  }

  /// 保存用户偏好设置（upsert，单行 id=0）
  Future<void> upsertPreference(String json) async {
    await into(preferenceTable).insertOnConflictUpdate(
      PreferenceTableCompanion.insert(
        id: const Value(0),
        value: json,
      ),
    );
  }

  // ========== 音乐服务配置 ==========

  /// 获取所有音乐服务配置
  Future<List<MusicServerConfigEntity>> getAllMusicServerConfigs() {
    return (select(musicServerConfigTable)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  /// 插入或更新音乐服务配置（upsert）
  Future<void> upsertMusicServerConfig(
      MusicServerConfigTableCompanion companion) async {
    await into(musicServerConfigTable).insertOnConflictUpdate(companion);
  }

  /// 删除指定 id 的音乐服务配置
  Future<void> deleteMusicServerConfig(String id) {
    return (delete(musicServerConfigTable)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  // ========== Lx 音源脚本 ==========

  /// 获取所有 Lx 音源脚本（按添加时间正序）
  Future<List<LxSourceScriptEntity>> getAllLxSourceScripts() {
    return (select(lxSourceScriptTable)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// 插入或更新 Lx 音源脚本（upsert）
  Future<void> upsertLxSourceScript(
      LxSourceScriptTableCompanion companion) async {
    await into(lxSourceScriptTable).insertOnConflictUpdate(companion);
  }

  /// 删除指定 id 的 Lx 音源脚本
  Future<void> deleteLxSourceScript(String id) {
    return (delete(lxSourceScriptTable)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  // ========== 本地音乐库 - 曲目 ==========

  /// 插入或更新本地曲目（upsert）
  Future<void> upsertLocalTrack(LocalTrackTableCompanion companion) async {
    await into(localTrackTable).insertOnConflictUpdate(companion);
  }

  /// 批量插入本地曲目（upsert）
  Future<void> upsertLocalTracks(
      List<LocalTrackTableCompanion> companions) async {
    await batch((batch) {
      for (final c in companions) {
        batch.insert(localTrackTable, c,
            mode: InsertMode.insertOrReplace);
      }
    });
  }

  /// 获取指定 id 的本地曲目
  Future<LocalTrackEntity?> getLocalTrack(String id) {
    return (select(localTrackTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// 获取所有本地曲目
  Future<List<LocalTrackEntity>> getAllLocalTracks() {
    return (select(localTrackTable)
          ..orderBy([(t) => OrderingTerm.asc(t.title)]))
        .get();
  }

  /// 按来源获取本地曲目
  Future<List<LocalTrackEntity>> getLocalTracksBySource(String sourceId) {
    return (select(localTrackTable)
          ..where((t) => t.sourceId.equals(sourceId))
          ..orderBy([(t) => OrderingTerm.asc(t.title)]))
        .get();
  }

  /// 按库 ID 获取本地曲目
  Future<List<LocalTrackEntity>> getLocalTracksByLibrary(String libraryId) {
    return (select(localTrackTable)
          ..where((t) => t.libraryId.equals(libraryId))
          ..orderBy([(t) => OrderingTerm.asc(t.title)]))
        .get();
  }

  /// 按专辑 ID 获取本地曲目
  Future<List<LocalTrackEntity>> getLocalTracksByAlbum(String albumId) {
    return (select(localTrackTable)
          ..where((t) => t.albumId.equals(albumId))
          ..orderBy([(t) => OrderingTerm.asc(t.title)]))
        .get();
  }

  /// 按艺术家 ID 获取本地曲目
  Future<List<LocalTrackEntity>> getLocalTracksByArtist(String artistId) {
    return (select(localTrackTable)
          ..where((t) => t.artistId.equals(artistId))
          ..orderBy([(t) => OrderingTerm.asc(t.title)]))
        .get();
  }

  /// 删除指定 id 的本地曲目
  Future<void> deleteLocalTrack(String id) {
    return (delete(localTrackTable)..where((t) => t.id.equals(id))).go();
  }

  /// 删除指定来源的所有本地曲目
  Future<void> deleteLocalTracksBySource(String sourceId) {
    return (delete(localTrackTable)
          ..where((t) => t.sourceId.equals(sourceId)))
        .go();
  }

  // ========== 本地音乐库 - 专辑 ==========

  /// 插入或更新本地专辑（upsert）
  Future<void> upsertLocalAlbum(LocalAlbumTableCompanion companion) async {
    await into(localAlbumTable).insertOnConflictUpdate(companion);
  }

  /// 获取指定 id 的本地专辑
  Future<LocalAlbumEntity?> getLocalAlbum(String id) {
    return (select(localAlbumTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// 获取所有本地专辑
  Future<List<LocalAlbumEntity>> getAllLocalAlbums() {
    return (select(localAlbumTable)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// 按来源获取本地专辑
  Future<List<LocalAlbumEntity>> getLocalAlbumsBySource(String sourceId) {
    return (select(localAlbumTable)
          ..where((t) => t.sourceId.equals(sourceId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// 按艺术家获取本地专辑
  Future<List<LocalAlbumEntity>> getLocalAlbumsByArtist(String artistId) {
    return (select(localAlbumTable)
          ..where((t) => t.artistId.equals(artistId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// 删除指定 id 的本地专辑
  Future<void> deleteLocalAlbum(String id) {
    return (delete(localAlbumTable)..where((t) => t.id.equals(id))).go();
  }

  // ========== 本地音乐库 - 艺术家 ==========

  /// 插入或更新本地艺术家（upsert）
  Future<void> upsertLocalArtist(LocalArtistTableCompanion companion) async {
    await into(localArtistTable).insertOnConflictUpdate(companion);
  }

  /// 获取指定 id 的本地艺术家
  Future<LocalArtistEntity?> getLocalArtist(String id) {
    return (select(localArtistTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// 获取所有本地艺术家
  Future<List<LocalArtistEntity>> getAllLocalArtists() {
    return (select(localArtistTable)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// 按来源获取本地艺术家
  Future<List<LocalArtistEntity>> getLocalArtistsBySource(String sourceId) {
    return (select(localArtistTable)
          ..where((t) => t.sourceId.equals(sourceId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// 删除指定 id 的本地艺术家
  Future<void> deleteLocalArtist(String id) {
    return (delete(localArtistTable)..where((t) => t.id.equals(id))).go();
  }

  // ========== 本地音乐库 - 歌单 ==========

  /// 插入或更新本地歌单（upsert）
  Future<void> upsertLocalPlaylist(
      LocalPlaylistTableCompanion companion) async {
    await into(localPlaylistTable).insertOnConflictUpdate(companion);
  }

  /// 获取指定 id 的本地歌单
  Future<LocalPlaylistEntity?> getLocalPlaylist(String id) {
    return (select(localPlaylistTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// 获取所有本地歌单
  Future<List<LocalPlaylistEntity>> getAllLocalPlaylists() {
    return (select(localPlaylistTable)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// 按来源获取本地歌单
  Future<List<LocalPlaylistEntity>> getLocalPlaylistsBySource(
      String sourceId) {
    return (select(localPlaylistTable)
          ..where((t) => t.sourceId.equals(sourceId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// 删除指定 id 的本地歌单
  Future<void> deleteLocalPlaylist(String id) {
    return (delete(localPlaylistTable)..where((t) => t.id.equals(id))).go();
  }
}

/// 跨平台打开数据库连接
LazyDatabase _open() {
  return LazyDatabase(() async {
    // 确保平台初始化
    if (Helper.isDesktop) {
      // 桌面端使用 sqflite_common_ffi
      ffi.sqfliteFfiInit();
      final dbDir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbDir.path, 'pomelo', 'app.db'));
      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }
      return NativeDatabase.createInBackground(
        file,
        setup: (db) {
          // 优化 SQLite 性能
          db.execute('PRAGMA journal_mode = WAL;');
          db.execute('PRAGMA foreign_keys = ON;');
        },
      );
    } else {
      // 移动端使用 sqlite3_flutter_libs
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'pomelo', 'app.db'));
      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }
      // 确保 sqlite3 动态库已加载
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      return NativeDatabase.createInBackground(
        file,
        setup: (db) {
          db.execute('PRAGMA journal_mode = WAL;');
          db.execute('PRAGMA foreign_keys = ON;');
        },
      );
    }
  });
}
