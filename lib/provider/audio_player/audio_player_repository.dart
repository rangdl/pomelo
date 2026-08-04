/// 音频播放器仓储层
///
/// 负责播放状态的持久化存取（drift/SQLite）。
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart' hide Track;
import 'package:pomelo/core/models/database/app_database.dart';
import 'package:pomelo/provider/database/database_provider.dart';
import 'package:pomelo/core/models/metadata/track.dart';

import 'state.dart';

/// 音频播放器状态仓储
///
/// 负责 [AudioPlayerState] 的持久化存储与恢复，基于 drift 数据库。
class AudioPlayerRepository {
  final AppDatabase _db;

  AudioPlayerRepository(this._db);

  /// PlaylistMode 与字符串互转
  static PlaylistMode _parseLoopMode(String? value) {
    switch (value) {
      case 'loop':
        return PlaylistMode.loop;
      case 'single':
        return PlaylistMode.single;
      default:
        return PlaylistMode.none;
    }
  }

  static String _loopModeToString(PlaylistMode mode) {
    switch (mode) {
      case PlaylistMode.loop:
        return 'loop';
      case PlaylistMode.single:
        return 'single';
      case PlaylistMode.none:
        return 'none';
    }
  }

  /// 从数据库恢复播放器状态
  Future<AudioPlayerState?> restore() async {
    final stateEntity = await _db.getPlayerState();
    if (stateEntity == null) return null;

    final trackEntities = await _db.getPlayerTracks();
    final tracks = trackEntities
        .map(
          (e) =>
              Track.fromJson(jsonDecode(e.trackJson) as Map<String, dynamic>),
        )
        .toList();

    final collections = (jsonDecode(stateEntity.collections) as List<dynamic>)
        .cast<String>();

    return AudioPlayerState(
      playing: stateEntity.playing,
      loopMode: _parseLoopMode(stateEntity.loopMode),
      shuffled: stateEntity.shuffled,
      collections: collections,
      currentIndex: stateEntity.currentIndex,
      tracks: tracks,
    );
  }

  /// 保存播放器状态到数据库
  Future<void> persist(AudioPlayerState state) async {
    await persistState(state);
    await persistTracks(state.tracks);
  }

  /// 仅保存轻量播放状态（playing / loop / shuffle / currentIndex / collections）。
  ///
  /// 不涉及曲目表，开销很低，可在每次状态变更时立即调用，
  /// 避免每次都重写整张曲目表（见 [persistTracks]）。
  Future<void> persistState(AudioPlayerState state) async {
    await _db.upsertPlayerState(
      PlayerStateTableCompanion(
        playing: Value(state.playing),
        loopMode: Value(_loopModeToString(state.loopMode)),
        shuffled: Value(state.shuffled),
        currentIndex: Value(state.currentIndex),
        collections: Value(jsonEncode(state.collections)),
      ),
    );
  }

  /// 仅保存播放列表（曲目表整表替换）。
  ///
  /// 开销较高（千首队列 = 数千行写），调用方应自行做防抖合并，
  /// 例如 [AudioPlayerNotifier] 中的轨迹变更统一走防抖落库。
  Future<void> persistTracks(List<Track> tracks) async {
    final companions = tracks.asMap().entries.map((entry) {
      return PlayerTrackTableCompanion.insert(
        orderIndex: entry.key,
        trackId: entry.value.id,
        trackJson: jsonEncode(entry.value.toJson()),
      );
    }).toList();
    await _db.replacePlayerTracks(companions);
  }

  /// 清空持久化状态
  Future<void> clear() async {
    await _db.upsertPlayerState(
      const PlayerStateTableCompanion(
        playing: Value(false),
        loopMode: Value('none'),
        shuffled: Value(false),
        currentIndex: Value(0),
        collections: Value('[]'),
      ),
    );
    await _db.clearPlayerTracks();
  }
}

/// 音频播放器仓储 Provider
final audioPlayerRepositoryProvider = Provider<AudioPlayerRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AudioPlayerRepository(db);
});
