import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/settings/lock_screen_lyric.dart';
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
// 取链阶段 / 乐观播放态
// ---------------------------------------------------------------------------

/// 当前播放所处的阶段，用于在播放控件上展示取链进度。
enum PlaybackStage {
  /// 空闲：没有进行中的取链流程。
  idle,

  /// 正在向来源插件获取播放链接。
  resolving,

  /// 来源插件取链失败，正在尝试其它插件兜底。
  fallback,

  /// 取链失败（含兜底），本次播放已放弃。
  failed,
}

extension PlaybackStageLabel on PlaybackStage {
  /// 展示在播放控件上的文案；[idle] 为空，表示不占用该行。
  String get label => switch (this) {
    PlaybackStage.idle => '',
    PlaybackStage.resolving => '获取播放链接…',
    PlaybackStage.fallback => '走兜底流程…',
    PlaybackStage.failed => '获取播放链接失败',
  };
}

class PlaybackStageNotifier extends Notifier<PlaybackStage> {
  Timer? _resetTimer;

  @override
  PlaybackStage build() {
    ref.onDispose(() => _resetTimer?.cancel());
    return PlaybackStage.idle;
  }

  void set(PlaybackStage stage) {
    _resetTimer?.cancel();
    state = stage;
    // 失败文案展示几秒后自动复位，避免长期占着播放控件的信息位。
    if (stage == PlaybackStage.failed) {
      _resetTimer = Timer(const Duration(seconds: 4), () {
        if (ref.mounted && state == PlaybackStage.failed) {
          state = PlaybackStage.idle;
        }
      });
    }
  }

  void reset() {
    _resetTimer?.cancel();
    state = PlaybackStage.idle;
  }
}

final playbackStageProvider =
    NotifierProvider<PlaybackStageNotifier, PlaybackStage>(
      PlaybackStageNotifier.new,
    );

/// 点击播放/暂停时先给出的乐观意图（null 表示以播放器真实状态为准）。
///
/// 取链需要时间，图标若等真实播放状态更新才切换会显得「不跟手」：点击瞬间
/// 先按用户意图显示，等播放器状态追上（或已停止）后自动交还给真实状态。
class PlaybackIntentNotifier extends Notifier<bool?> {
  StreamSubscription<bool>? _sub;

  @override
  bool? build() {
    final player = ref.read(audioPlayerProvider);
    _sub = player.playingStream.listen((actual) {
      final intent = state;
      if (intent == null) return;
      // 真实状态已追上意图，交还控制权。
      if (actual == intent) {
        state = null;
        return;
      }
      // 切歌途中会短暂出现 playing=false，此时引擎里仍是旧曲，不能误清；
      // 只有引擎里已无加载媒体（stop）才把乐观态交还。
      if (!actual && player.loadedId == null) state = null;
    });
    ref.onDispose(() => _sub?.cancel());
    return null;
  }

  void setOptimistic(bool playing) => state = playing;

  void clear() => state = null;
}

final playbackIntentProvider = NotifierProvider<PlaybackIntentNotifier, bool?>(
  PlaybackIntentNotifier.new,
);

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

/// 控制中心 / 锁屏歌词联动：按设置把当前歌词行写入媒体卡的标题或歌手位。
///
/// 仅 iOS 有实际效果；其它平台即使开启也不调用底层，避免无谓开销。
final lockScreenLyricSyncProvider = Provider<void>((ref) {
  if (!Platform.isIOS) return;

  final player = ref.read(audioPlayerProvider);
  List<LyricLine> lines = const [];
  int lastActive = -1;
  StreamSubscription<Duration>? sub;

  void push(Duration pos) {
    final mode = ref.read(lockScreenLyricModeProvider);
    if (mode == LockScreenLyricMode.off) {
      player.applyLockScreenLyric(mode, null);
      return;
    }
    if (lines.isEmpty) {
      player.applyLockScreenLyric(mode, null);
      return;
    }
    final active = LrcParser.activeIndex(lines, pos);
    if (active == lastActive) return;
    lastActive = active;
    final text = active >= 0 && active < lines.length
        ? lines[active].text
        : null;
    player.applyLockScreenLyric(mode, text);
  }

  void resubscribe() {
    sub?.cancel();
    lastActive = -1;
    sub = player.positionStream.listen(push);
  }

  // 模式变化或切歌：重新评估歌词来源。
  ref.listen(lockScreenLyricModeProvider, (_, _) {
    // 关闭时立即还原原始文本。
    if (ref.read(lockScreenLyricModeProvider) == LockScreenLyricMode.off) {
      player.applyLockScreenLyric(LockScreenLyricMode.off, null);
    }
    push(player.position);
  });

  ref.listen(lyricLinesProvider, (_, next) {
    lines = next.value ?? const [];
    lastActive = -1;
    push(player.position);
  });

  ref.listen(nowPlayingProvider, (_, _) {
    lines = ref.read(lyricLinesProvider).value ?? const [];
    lastActive = -1;
    resubscribe();
    push(Duration.zero);
  });

  lines = ref.read(lyricLinesProvider).value ?? const [];
  resubscribe();

  ref.onDispose(() {
    sub?.cancel();
  });
});

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
