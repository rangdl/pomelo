import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart' hide Track;

import 'package:pomelo/services/audio_player/playback_state.dart';
import 'package:pomelo/provider/audio_player/state.dart';
import 'package:pomelo/provider/audio_player/audio_player.dart';
import 'package:pomelo/provider/cast/cast_provider.dart';
import 'package:pomelo/services/audio_player/audio_player.dart';

class MobileAudioService extends BaseAudioHandler {
  AudioSession? session;
  final Ref ref;
  final AudioPlayerNotifier audioPlayerNotifier;

  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
  AudioPlayerState get playlist => audioPlayerNotifier.state;

  /// 投屏状态（已连接且有设备时 isCasting 为 true）
  CastState get _cast => ref.read(castProvider);

  /// 投屏控制器（用于把系统媒体控制转发到 DLNA 设备）
  CastNotifier get _castNotifier => ref.read(castProvider.notifier);

  MobileAudioService(this.ref, this.audioPlayerNotifier) {
    AudioSession.instance.then((s) {
      session = s;
      session?.configure(const AudioSessionConfiguration.music());

      bool wasPausedByBeginEvent = false;

      s.interruptionEventStream.listen((event) async {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              await audioPlayer.setVolume(0.5);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              {
                wasPausedByBeginEvent = audioPlayer.isPlaying;
                await audioPlayer.pause();
                break;
              }
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              await audioPlayer.setVolume(1.0);
              break;
            case AudioInterruptionType.pause when wasPausedByBeginEvent:
            case AudioInterruptionType.unknown when wasPausedByBeginEvent:
              await audioPlayer.resume();
              wasPausedByBeginEvent = false;
              break;
            default:
              break;
          }
        }
      });

      s.becomingNoisyEventStream.listen((_) {
        audioPlayer.pause();
      });
    });
    audioPlayer.playerStateStream.listen((state) async {
      if (state == AudioPlaybackState.playing) {
        await session?.setActive(true);
      }
      playbackState.add(await _transformEvent());
    });

    audioPlayer.positionStream.listen((pos) async {
      playbackState.add(await _transformEvent());
    });
    audioPlayer.bufferedPositionStream.listen((pos) async {
      playbackState.add(await _transformEvent());
    });

    // 投屏中：锁屏/系统媒体控制的状态需随 DLNA 设备的进度与播放状态刷新，
    // 否则投屏后锁屏进度不动、且一直显示「暂停」。
    ref.listen<CastState>(castProvider, (_, __) {
      if (_cast.isCasting) _emitPlaybackState();
    });
  }

  void addItem(MediaItem item) {
    session?.setActive(true);
    mediaItem.add(item);
  }

  @override
  Future<void> play() async {
    // 投屏中：控制 DLNA 设备而非本地播放器
    if (_cast.isCasting) {
      await _castNotifier.resume();
    } else {
      await audioPlayer.resume();
    }
  }

  @override
  Future<void> pause() async {
    if (_cast.isCasting) {
      await _castNotifier.pause();
    } else {
      await audioPlayer.pause();
    }
  }

  @override
  Future<void> seek(Duration position) async {
    if (_cast.isCasting) {
      await _castNotifier.seek(position);
    } else {
      await audioPlayer.seek(position);
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    await super.setShuffleMode(shuffleMode);

    audioPlayer.setShuffle(shuffleMode == AudioServiceShuffleMode.all);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    super.setRepeatMode(repeatMode);
    audioPlayer.setLoopMode(switch (repeatMode) {
      AudioServiceRepeatMode.all ||
      AudioServiceRepeatMode.group => PlaylistMode.loop,
      AudioServiceRepeatMode.one => PlaylistMode.single,
      _ => PlaylistMode.none,
    });
  }

  @override
  Future<void> stop() async {
    await audioPlayerNotifier.stop();
  }

  @override
  Future<void> skipToNext() async {
    // 投屏中：仅切本地队列索引（触发 cast 自动重投新曲），
    // 并维持本地暂停以免本地与设备同时出声。
    if (_cast.isCasting) {
      await audioPlayer.skipToNext();
      if (_cast.isCasting) await audioPlayer.pause();
    } else {
      await audioPlayer.skipToNext();
    }
    await super.skipToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    if (_cast.isCasting) {
      await audioPlayer.skipToPrevious();
      if (_cast.isCasting) await audioPlayer.pause();
    } else {
      await audioPlayer.skipToPrevious();
    }
    await super.skipToPrevious();
  }

  @override
  Future<void> onTaskRemoved() async {
    await audioPlayer.pause();
    if (!kIsWeb && Platform.isAndroid) exit(0);
  }

  /// 重新计算并推送锁屏/系统媒体控制状态
  ///
  /// 投屏中改用 DLNA 设备的 [isPlaying]/[position]，使锁屏显示正确的
  /// 播放/暂停按钮与进度，而非被暂停的本地播放器状态。
  Future<void> _emitPlaybackState() async {
    try {
      playbackState.add(await _transformEvent());
    } catch (_) {
      // 状态推送失败不应影响播放
    }
  }

  Future<PlaybackState> _transformEvent() async {
    try {
      // 投屏中：以 DLNA 设备状态为准
      final casting = _cast.isCasting;
      final playing = casting ? _cast.isPlaying : audioPlayer.isPlaying;
      final position = casting ? _cast.position : audioPlayer.position;
      final buffered = casting ? _cast.duration : audioPlayer.bufferedPosition;
      final buffering = casting ? false : audioPlayer.isBuffering;

      return PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: {MediaAction.seek},
        androidCompactActionIndices: const [0, 1, 2],
        playing: playing,
        updatePosition: position,
        bufferedPosition: buffered,
        shuffleMode: audioPlayer.isShuffled == true
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        repeatMode: switch (audioPlayer.loopMode) {
          PlaylistMode.loop => AudioServiceRepeatMode.all,
          PlaylistMode.single => AudioServiceRepeatMode.one,
          _ => AudioServiceRepeatMode.none,
        },
        processingState: buffering
            ? AudioProcessingState.loading
            : AudioProcessingState.ready,
      );
    } catch (e) {
      rethrow;
    }
  }
}
