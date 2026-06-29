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
/// - 播放记录
@DriftDatabase(tables: [
  PlayerStateTable,
  PlayerTrackTable,
  PlayHistoryTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  /// 用于测试的构造函数
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

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

  /// 添加播放记录
  Future<void> addPlayHistory(PlayHistoryTableCompanion companion) {
    return into(playHistoryTable).insert(companion);
  }

  /// 获取播放记录（按时间倒序）
  Future<List<PlayHistoryEntity>> getPlayHistory({int limit = 100}) {
    return (select(playHistoryTable)
          ..orderBy([(t) => OrderingTerm.desc(t.playedAt)])
          ..limit(limit))
        .get();
  }

  /// 获取最近播放的曲目（去重，按最后播放时间倒序）
  Future<List<PlayHistoryEntity>> getRecentPlayed({int limit = 50}) async {
    // 取全部记录后在 Dart 中去重，避免复杂 SQL
    final all = await (select(playHistoryTable)
          ..orderBy([(t) => OrderingTerm.desc(t.playedAt)]))
        .get();
    final seen = <String>{};
    final result = <PlayHistoryEntity>[];
    for (final entity in all) {
      if (seen.add(entity.trackId)) {
        result.add(entity);
        if (result.length >= limit) break;
      }
    }
    return result;
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
