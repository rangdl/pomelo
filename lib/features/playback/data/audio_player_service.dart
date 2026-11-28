import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

import '../../../shared/settings/lock_screen_lyric.dart';

/// 基于 media_kit + audio_service 的播放器封装。
///
/// 同时承担两个角色：
///   - 对 UI：暴露位置/时长/播放态/错误等流与基础控制；
///   - 对系统：作为 [AudioHandler] 提供通知栏 / 锁屏 / 蓝牙耳机
///     的媒体控制（播放、暂停、上一首、下一首、进度拖动）。
///
/// 解码引擎仍是 media_kit 的 libmpv；audio_service 只负责把控制下沉到前台
/// Service 与 MediaSession，让切后台 / 锁屏后音乐继续播放并可被系统控制。
class AudioPlayerService extends BaseAudioHandler with SeekHandler {
  AudioPlayerService() : _player = Player() {
    _wireStreams();
    _setupAudioSession();
  }

  final Player _player;

  /// 音频会话：负责申请/释放音频焦点，并把 AudioAttributes 标记为音乐类型。
  ///
  /// 华为等 OEM 的「控制中心媒体卡」会据此判断是否为正在播放的音乐 App；
  /// 不申请焦点时 content type 会是 UNKNOWN，卡片可能只显示「未在播放」。
  AudioSession? _session;
  StreamSubscription<AudioInterruptionEvent>? _interruptSub;
  StreamSubscription<void>? _noisySub;

  Future<void> _setupAudioSession() async {
    try {
      final session = await AudioSession.instance;
      // 声明为音乐播放：content type = music，usage = media。
      await session.configure(const AudioSessionConfiguration.music());
      _session = session;

      // 来电/其它 App 抢占焦点时暂停；短暂打断（如导航播报）结束后恢复。
      _interruptSub = session.interruptionEventStream.listen((event) {
        if (!event.begin) {
          // 打断结束且是被系统暂停（非用户操作）时恢复播放。
          if (!_userPaused &&
              event.type == AudioInterruptionType.pause &&
              !_player.state.playing) {
            _player.play();
          }
          return;
        }
        if (event.type == AudioInterruptionType.duck) {
          _player.setVolume(_player.state.volume * 0.3);
        } else {
          // pause / unknown：直接暂停，避免和其它音频混播。
          if (_player.state.playing) _player.pause();
        }
      });

      // 拔耳机等 becoming noisy 事件：暂停。
      _noisySub = session.becomingNoisyEventStream.listen((_) {
        if (_player.state.playing) _player.pause();
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[pomelo] audio session 初始化失败: $e');
    }
  }

  /// 申请音频焦点（播放前调用）。
  Future<void> _requestFocus() async {
    try {
      await _session?.setActive(true);
    } catch (e) {
      if (kDebugMode) debugPrint('[pomelo] 申请音频焦点失败: $e');
    }
  }

  /// 释放音频焦点（暂停/停止后调用）。
  Future<void> _abandonFocus() async {
    try {
      await _session?.setActive(false);
    } catch (e) {
      if (kDebugMode) debugPrint('[pomelo] 释放音频焦点失败: $e');
    }
  }

  // 供 UI 直接消费的细粒度流（与 audio_service 的 playbackState 并行存在）。
  Stream<Duration> get positionStream => _player.stream.position;
  Stream<Duration> get durationStream => _player.stream.duration;
  Stream<bool> get playingStream => _player.stream.playing;
  Stream<bool> get bufferingStream => _player.stream.buffering;
  Stream<bool> get completedStream => _player.stream.completed;
  Stream<String> get errorStream => _player.stream.error;
  Stream<double> get volumeStream => _player.stream.volume;

  /// 有效时长：优先用引擎（mpv）解析出的真实时长；拿不到时（部分网络流
  /// 解析不出容器时长，会一直是 0）退回媒体元信息里带的时长，保证进度条
  /// 可拖动、总时长有显示。
  ///
  /// 注意：部分流 mpv 不再发射 duration 事件，UI 侧应把 [effectiveDuration]
  /// 作为 StreamBuilder 的 initialData，否则兜底值不会被渲染。
  Stream<Duration> get effectiveDurationStream {
    return _player.stream.duration.map(
      (d) => d > Duration.zero ? d : (mediaItem.value?.duration ?? d),
    );
  }

  Duration get effectiveDuration {
    final d = _player.state.duration;
    if (d > Duration.zero) return d;
    return mediaItem.value?.duration ?? Duration.zero;
  }

  Duration get position => _player.state.position;
  Duration get duration => _player.state.duration;
  bool get playing => _player.state.playing;
  double get volume => _player.state.volume;

  dynamic _completedSub;
  dynamic _errorSub;
  final List<StreamSubscription> _subs = [];

  /// 当前曲目在队列中的位置（由上层通过 [updateQueueIndex] 同步）。
  int _queueIndex = 0;

  /// 播放出错回调（上层据此提示 / 自动跳歌）。
  void Function(String message)? onPlaybackError;

  /// 播放完成回调（上层据此按播放模式自动切歌）。
  void Function()? onPlaybackCompleted;

  void _wireStreams() {
    // 位置 / 时长 / 缓冲 -> 广播给系统（通知栏进度条）
    _subs.add(_player.stream.position.listen((_) => _broadcastState()));
    _subs.add(_player.stream.duration.listen((_) => _broadcastState()));
    _subs.add(_player.stream.buffer.listen((_) => _broadcastState()));
    _subs.add(_player.stream.buffering.listen((_) => _broadcastState()));
    _subs.add(_player.stream.playing.listen((_) => _broadcastState()));

    _completedSub = _player.stream.completed.listen((done) {
      if (!done) return;
      _broadcastState();
      onPlaybackCompleted?.call();
    });
    _errorSub = _player.stream.error.listen((message) {
      if (message.isEmpty) return;
      onPlaybackError?.call(message);
    });
  }

  void _broadcastState() {
    final hasItem = mediaItem.value != null;
    final state = _player.state;
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (state.playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0, 1, 2],
        // 暂停不等于空闲：只有「没有曲目」才是 idle，暂停仍是 ready，
        // 否则系统的播放/暂停状态会来回跳变。
        processingState: !hasItem
            ? AudioProcessingState.idle
            : state.completed
            ? AudioProcessingState.completed
            : state.buffering
            ? AudioProcessingState.buffering
            : AudioProcessingState.ready,
        playing: state.playing,
        updatePosition: state.position,
        // 缓冲进度用 mpv 自报的缓冲位置，不再拿总时长冒充。
        bufferedPosition: state.buffer > state.position
            ? state.buffer
            : state.position,
        speed: state.rate,
        queueIndex: _queueIndex,
      ),
    );
  }

  /// 收到播放完成事件（用于自动下一首）。保留旧接口以兼容调用点。
  void onCompleted(void Function() callback) => onPlaybackCompleted = callback;

  /// 收到播放错误事件（用于提示用户并自动跳过无法播放的曲目）。
  void onError(void Function(String message) callback) =>
      onPlaybackError = callback;

  /// 上限：目前直接用原始 String 流，保留给上层按需去抖。

  /// 播放网络地址。[headers] 会原样带给底层（Referer/UA 防盗链）。
  ///
  /// [meta] 非空时同步更新通知栏的 MediaItem 信息。
  Future<void> open(
    String url, {
    Map<String, String>? headers,
    MediaMeta? meta,
  }) async {
    if (meta != null) {
      // 记住原始元信息：控制中心歌词联动时需要还原「歌名 - 歌手」文本。
      _baseMeta = meta;
      _lockScreenLyric = null;
      mediaItem.add(
        MediaItem(
          id: meta.id,
          title: meta.title,
          artist: meta.artist,
          album: meta.album,
          artUri: meta.artUri,
          duration: meta.duration,
        ),
      );
      _broadcastState();
    }
    try {
      _userPaused = false;
      // 播放前申请音频焦点（同时把 AudioAttributes 落成 music）。
      await _requestFocus();
      await _player.open(Media(url, httpHeaders: headers), play: true);
      // 打开成功后才标记「已加载」，避免失败时被误判为可直接续播。
      _loadedId = meta?.id;
    } catch (e) {
      _loadedId = null;
      if (kDebugMode) debugPrint('media_kit open 失败: $e');
      rethrow;
    }
  }

  /// 当前已实际加载到引擎的曲目 id（用于判断能否直接 play/pause）。
  String? _loadedId;
  String? get loadedId => _loadedId;

  /// 引擎里是否已加载了 [id] 这一首（决定「播放」是续播还是重新解析）。
  ///
  /// 不再用「时长 > 0」判断：网络流刚打开时时长可能还是 0，会被误判为未加载
  /// 而触发整首重新解析。
  bool hasLoaded(String? id) => id != null && id.isNotEmpty && id == _loadedId;

  /// 是否由用户主动暂停（用于区分「用户暂停」与「播放卡死」）。
  bool _userPaused = false;
  bool get userPaused => _userPaused;

  /// 更新队列位置（通知栏「上一首/下一首」高亮用）。
  void updateQueueIndex(int index) {
    _queueIndex = index;
    _broadcastState();
  }

  /// 当前曲目的原始元信息（控制中心歌词联动时用于还原文本）。
  MediaMeta? _baseMeta;

  /// 最近一次写入控制中心的歌词行（用于去重，避免重复 add 造成抖动）。
  String? _lockScreenLyric;

  /// 控制中心 / 锁屏媒体卡的歌词联动。
  ///
  /// [mode] 为 off 时恢复原始「歌名 / 歌手」；[title] 把歌词放歌名位置、
  /// 歌手位置显示「歌名 - 歌手」；[artist] 反之。歌词行未变化时不更新。
  /// 仅 iOS 有实际效果（Android 通知栏布局由系统决定）。
  void applyLockScreenLyric(LockScreenLyricMode mode, String? lyric) {
    final base = _baseMeta;
    if (base == null) return;
    final artistLabel = base.artist.isEmpty
        ? base.title
        : '${base.title} - ${base.artist}';

    final String title;
    final String artist;
    final String? newLyric;
    switch (mode) {
      case LockScreenLyricMode.off:
        title = base.title;
        artist = base.artist;
        newLyric = null;
      case LockScreenLyricMode.title:
        title = (lyric == null || lyric.trim().isEmpty)
            ? base.title
            : lyric.trim();
        artist = artistLabel;
        newLyric = title;
      case LockScreenLyricMode.artist:
        title = artistLabel;
        artist = (lyric == null || lyric.trim().isEmpty)
            ? base.artist
            : lyric.trim();
        newLyric = artist;
    }
    // 歌词与模式都没变化时跳过，避免高频位置回调反复重建 MediaItem。
    if (newLyric == _lockScreenLyric &&
        mediaItem.value?.title == title &&
        mediaItem.value?.artist == artist) {
      return;
    }
    _lockScreenLyric = newLyric;
    final current = mediaItem.value;
    if (current == null) return;
    mediaItem.add(
      current.copyWith(title: title, artist: artist, album: base.album),
    );
  }

  @override
  Future<void> play() async {
    _userPaused = false;
    await _requestFocus();
    await _player.play();
  }

  @override
  Future<void> pause() async {
    _userPaused = true;
    await _player.pause();
    await _abandonFocus();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    // 停止后引擎里不再有可用媒体，清掉标记，下次播放会重新解析。
    _loadedId = null;
    _userPaused = false;
    await _abandonFocus();
    mediaItem.add(null);
    await super.stop();
    _broadcastState();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    _onSkip?.call(true);
  }

  @override
  Future<void> skipToPrevious() async {
    _onSkip?.call(false);
  }

  /// 系统「上一首/下一首」回调，由上层接到队列切歌逻辑。
  void Function(bool next)? _onSkip;
  set skipCallback(void Function(bool next) cb) => _onSkip = cb;

  Future<void> setVolume(double volume) => _player.setVolume(volume);

  /// 静音/取消静音（记住上一次的可听音量）。
  Future<void> toggleMute() async {
    final current = _player.state.volume;
    if (current > 0) {
      _lastAudibleVolume = current;
      await _player.setVolume(0);
    } else {
      await _player.setVolume(
        _lastAudibleVolume > 0 ? _lastAudibleVolume : 100,
      );
    }
  }

  double _lastAudibleVolume = 100;

  bool get muted => _player.state.volume <= 0;

  /// 播放速度（1.0 为原速）；同步到通知栏的 playbackState。
  @override
  Future<void> setSpeed(double speed) async {
    final clamped = speed.clamp(0.5, 2.0);
    await _player.setRate(clamped);
    playbackState.add(playbackState.value.copyWith(speed: clamped));
  }

  double get speed => _player.state.rate;

  Future<void> dispose() async {
    await _completedSub?.cancel();
    await _errorSub?.cancel();
    await _interruptSub?.cancel();
    await _noisySub?.cancel();
    await _abandonFocus();
    for (final s in _subs) {
      await s.cancel();
    }
    await _player.dispose();
  }
}

/// 轻量元信息，避免播放层依赖 UI 数据结构。
class MediaMeta {
  const MediaMeta({
    required this.id,
    required this.title,
    this.artist = '',
    this.album = '',
    this.artUri,
    this.duration,
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final Uri? artUri;
  final Duration? duration;
}
