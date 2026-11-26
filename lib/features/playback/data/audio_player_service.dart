import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

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
  }

  final Player _player;

  // 供 UI 直接消费的细粒度流（与 audio_service 的 playbackState 并行存在）。
  Stream<Duration> get positionStream => _player.stream.position;
  Stream<Duration> get durationStream => _player.stream.duration;
  Stream<bool> get playingStream => _player.stream.playing;
  Stream<bool> get bufferingStream => _player.stream.buffering;
  Stream<bool> get completedStream => _player.stream.completed;
  Stream<String> get errorStream => _player.stream.error;
  Stream<double> get volumeStream => _player.stream.volume;

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

  @override
  Future<void> play() async {
    _userPaused = false;
    await _player.play();
  }

  @override
  Future<void> pause() async {
    _userPaused = true;
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    // 停止后引擎里不再有可用媒体，清掉标记，下次播放会重新解析。
    _loadedId = null;
    _userPaused = false;
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
