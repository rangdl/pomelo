import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../shared/storage/json_file_store.dart';
import '../domain/play_mode.dart';

/// 播放状态的本地快照：上次的播放队列、当前曲目、播放模式。
///
/// 只做「恢复上下文」，不做「自动开声」：重启 App 后恢复队列与高亮的当前曲，
/// 但需要用户点一下才播放，避免一打开就外放。
class PlaybackSnapshot {
  const PlaybackSnapshot({
    required this.queue,
    required this.index,
    required this.mode,
  });

  final List<Map<String, dynamic>> queue;
  final int index;
  final PlayMode mode;

  Map<String, dynamic> toJson() => {
    'queue': queue,
    'index': index,
    'mode': mode.name,
  };

  static PlaybackSnapshot? fromJson(Map<String, dynamic> json) {
    final rawQueue = json['queue'];
    if (rawQueue is! List) return null;
    final queue = rawQueue
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
    if (queue.isEmpty) return null;
    final index = (json['index'] is int)
        ? json['index'] as int
        : int.tryParse('${json['index'] ?? 0}') ?? 0;
    final modeName = json['mode'] as String?;
    final mode = PlayMode.values.firstWhere(
      (m) => m.name == modeName,
      orElse: () => PlayMode.listLoop,
    );
    return PlaybackSnapshot(
      queue: queue,
      index: index.clamp(0, queue.length - 1),
      mode: mode,
    );
  }
}

const _playbackStateFileName = 'playback_state.json';

Future<JsonFileStore> _stateStore() async {
  final directory = await getApplicationSupportDirectory();
  return JsonFileStore(
    File('${directory.path}${Platform.pathSeparator}$_playbackStateFileName'),
  );
}

/// 读取上次的播放快照；不存在或损坏时返回 null。
Future<PlaybackSnapshot?> loadPlaybackSnapshot() async {
  final raw = await (await _stateStore()).read();
  if (raw is! Map) return null;
  return PlaybackSnapshot.fromJson(Map<String, dynamic>.from(raw));
}

/// 保存播放快照（失败静默，不影响本次会话）。
Future<void> savePlaybackSnapshot(PlaybackSnapshot snapshot) async {
  await (await _stateStore()).write(snapshot.toJson());
}
