import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/player_actions.dart';
import '../data/audio_player_service.dart';
import '../data/lrc_parser.dart';
import '../data/playback_store.dart';
import '../domain/play_mode.dart';
import '../domain/play_queue.dart';

// ---------------------------------------------------------------------------
// 启动时注入的播放快照（无记录时为空壳）
// ---------------------------------------------------------------------------

/// 由 main() 启动时读取磁盘后注入；未 override 时返回 null。
final playbackSnapshotInitializerProvider = Provider<PlaybackSnapshot?>(
  (ref) => null,
);

// ---------------------------------------------------------------------------
// 当前播放
// ---------------------------------------------------------------------------

class NowPlaying extends Notifier<Map<String, dynamic>?> {
  @override
  Map<String, dynamic>? build() {
    // 恢复上次播放的当前曲目（仅用于展示，不自动开声）。
    final snap = ref.watch(playbackSnapshotInitializerProvider);
    if (snap != null && snap.queue.isNotEmpty) {
      return snap.queue[snap.index];
    }
    return null;
  }

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
  PlayMode build() =>
      ref.watch(playbackSnapshotInitializerProvider)?.mode ?? PlayMode.listLoop;

  void cycle() {
    state = PlayMode.values[(state.index + 1) % PlayMode.values.length];
  }

  void set(PlayMode mode) => state = mode;
}

final playModeProvider = NotifierProvider<PlayModeNotifier, PlayMode>(
  PlayModeNotifier.new,
);

// ---------------------------------------------------------------------------
// 播放器
// ---------------------------------------------------------------------------

/// 播放器服务（应用生命周期内单例）。
///
/// 真实实例由 `main()` 通过 `AudioService.init(...)` 创建后以 override 注入，
/// 这样才能把播放下沉到前台 Service（后台/锁屏可控）。未 override 时
/// （例如单元测试）会抛错，提示必须注入。
final audioPlayerProvider = Provider<AudioPlayerService>((ref) {
  throw UnimplementedError('audioPlayerProvider 需在 ProviderScope 中 override');
});

// ---------------------------------------------------------------------------
// 播放状态持久化
// ---------------------------------------------------------------------------

/// 睡眠定时器：到点自动暂停播放，并清空状态。
class SleepTimerNotifier extends Notifier<DateTime?> {
  Timer? _timer;

  @override
  DateTime? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  /// 从现在起 [duration] 后暂停。
  void start(Duration duration) {
    _timer?.cancel();
    state = DateTime.now().add(duration);
    _timer = Timer(duration, () {
      ref.read(audioPlayerProvider).pause();
      state = null;
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    state = null;
  }
}

final sleepTimerProvider = NotifierProvider<SleepTimerNotifier, DateTime?>(
  SleepTimerNotifier.new,
);

/// 监听队列 / 索引 / 当前曲 / 播放模式的变化，节流写盘到 playback_state.json。
///
/// 在 App 顶层 `ref.watch` 一次即可长期生效（keepAlive）。
/// 变化先累积 500ms 再写，避免拖动队列/连续切歌时频繁落盘；窗口关闭或应用
/// 退到后台时立即 flush，保证最后一次变更不丢。
final playbackPersistenceProvider = Provider<void>((ref) {
  Timer? timer;
  PlaybackSnapshot? pending;

  PlaybackSnapshot? currentSnapshot() {
    final queue = ref.read(playQueueProvider);
    if (queue.isEmpty) return null;
    return PlaybackSnapshot(
      queue: queue,
      index: ref.read(playQueueProvider.notifier).index,
      mode: ref.read(playModeProvider),
    );
  }

  void flush() {
    timer?.cancel();
    timer = null;
    final snapshot = pending;
    pending = null;
    if (snapshot != null) unawaited(savePlaybackSnapshot(snapshot));
  }

  void schedule() {
    final snapshot = currentSnapshot();
    if (snapshot == null) return;
    pending = snapshot;
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 500), flush);
  }

  ref.listen(playQueueProvider, (previous, next) => schedule());
  ref.listen(playModeProvider, (previous, next) => schedule());
  ref.listen(nowPlayingProvider, (previous, next) => schedule());

  final observer = _PlaybackLifecycleObserver(onFlush: flush);
  WidgetsBinding.instance.addObserver(observer);
  ref.onDispose(() {
    WidgetsBinding.instance.removeObserver(observer);
    flush();
  });
});

/// 应用生命周期观察者：退后台 / 被系统回收前把待写快照落盘。
class _PlaybackLifecycleObserver with WidgetsBindingObserver {
  _PlaybackLifecycleObserver({required this.onFlush});

  final VoidCallback onFlush;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      onFlush();
    }
  }
}

// ---------------------------------------------------------------------------
// 歌词
// ---------------------------------------------------------------------------

/// 当前曲目的解析后歌词（随 nowPlaying 变化自动重新拉取）。
final lyricLinesProvider = FutureProvider<List<LyricLine>>((ref) async {
  final item = ref.watch(nowPlayingProvider);
  if (item == null) return const [];
  final raw = await ref.read(playerActionsProvider).fetchLyric(item);
  if (raw == null || raw.trim().isEmpty) return const [];
  return LrcParser.parse(raw);
});
