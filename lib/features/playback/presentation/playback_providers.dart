import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/audio_player_service.dart';
import '../domain/play_mode.dart';
import '../domain/play_queue.dart';

// ---------------------------------------------------------------------------
// 当前播放
// ---------------------------------------------------------------------------

class NowPlaying extends Notifier<Map<String, dynamic>?> {
  @override
  Map<String, dynamic>? build() => null;

  void set(Map<String, dynamic>? item) => state = item;
}

final nowPlayingProvider = NotifierProvider<NowPlaying, Map<String, dynamic>?>(
  NowPlaying.new,
);

// ---------------------------------------------------------------------------
// 队列与播放模式
// ---------------------------------------------------------------------------

final playQueueProvider =
    NotifierProvider<PlayQueue, List<Map<String, dynamic>>>(PlayQueue.new);

class PlayModeNotifier extends Notifier<PlayMode> {
  @override
  PlayMode build() => PlayMode.listLoop;

  void cycle() {
    state = PlayMode.values[(state.index + 1) % PlayMode.values.length];
  }
}

final playModeProvider = NotifierProvider<PlayModeNotifier, PlayMode>(
  PlayModeNotifier.new,
);

// ---------------------------------------------------------------------------
// 播放器
// ---------------------------------------------------------------------------

/// 播放器服务（应用生命周期内单例）。
final audioPlayerProvider = Provider<AudioPlayerService>((ref) {
  final player = AudioPlayerService();
  ref.onDispose(player.dispose);
  return player;
});
