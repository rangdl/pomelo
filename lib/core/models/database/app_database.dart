import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pomelo/core/helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'player_state_table.dart';

part 'app_database.g.dart';

/// 应用数据库
///
/// 基于 drift (SQLite) 的持久化数据库，负责：
/// - 播放器状态持久化（替代旧的 freezed + Hive 方案）
/// - 当前播放列表持久化
/// - 播放记录（含播放次数）
/// - 已解析音源曲目持久化（播放链接与缓存路径）
@DriftDatabase(tables: [
  PlayerStateTable,
  PlayerTrackTable,
  PlayHistoryTable,
  SourcedTrackTable,
  PreferenceTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  /// 用于测试的构造函数
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

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
