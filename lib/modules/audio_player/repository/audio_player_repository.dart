/// 音频播放器仓储层
///
/// 负责播放状态的持久化存取（本地存储）。
library;

import 'dart:convert';

import 'package:pomelo/core/mars.dart';
import '../model/state.dart';

/// 音频播放器状态仓储
///
/// 负责 [AudioPlayerState] 的持久化存储与恢复。
class AudioPlayerRepository extends Repository<AudioPlayerState> {
  @override
  String get id => 'audio_player_repository';

  /// 从本地存储恢复播放器状态
  Future<AudioPlayerState?> restore() async {
    final raw = Settings.get(StorageKeys.audioPlayerState);
    if (raw == null) return null;
    return AudioPlayerState.fromJson(jsonDecode(raw));
  }

  /// 保存播放器状态到本地存储
  Future<void> persist(AudioPlayerState state) async {
    Settings.set(StorageKeys.audioPlayerState, jsonEncode(state));
  }

  @override
  Future<List<AudioPlayerState>> fetchAll() async {
    final state = await restore();
    return state != null ? [state] : [];
  }

  @override
  Future<AudioPlayerState?> fetchById(String id) async {
    return restore();
  }

  @override
  Future<void> save(AudioPlayerState item) async {
    await persist(item);
  }

  @override
  Future<void> saveAll(List<AudioPlayerState> items) async {
    for (final item in items) {
      await persist(item);
    }
  }

  @override
  Future<void> delete(String id) async {
    Settings.remove(StorageKeys.audioPlayerState);
  }

  @override
  Future<void> deleteAll() async {
    Settings.remove(StorageKeys.audioPlayerState);
  }
}
