import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smtc_windows/smtc_windows.dart';

import 'package:pomelo/services/audio_player/playback_state.dart';
import 'package:pomelo/provider/audio_player/audio_player.dart';
import 'package:pomelo/services/audio_player/audio_player.dart';
import 'package:pomelo/core/models/metadata/track.dart' show Track;

class WindowsAudioService {
  final SMTCWindows smtc;
  final Ref ref;
  final AudioPlayerNotifier audioPlayerNotifier;

  final subscriptions = <StreamSubscription>[];

  /// 标记 SMTC 是否已释放，避免 dispose 后调用 smtc 方法抛出
  /// DroppableDisposedException
  bool _disposed = false;

  WindowsAudioService(this.ref, this.audioPlayerNotifier)
    : smtc = SMTCWindows(enabled: false) {
    smtc.setPlaybackStatus(PlaybackStatus.stopped);
    final buttonStream = smtc.buttonPressStream.listen((event) {
      switch (event) {
        case PressedButton.play:
          audioPlayer.resume();
          break;
        case PressedButton.pause:
          audioPlayer.pause();
          break;
        case PressedButton.next:
          audioPlayer.skipToNext();
          break;
        case PressedButton.previous:
          audioPlayer.skipToPrevious();
          break;
        case PressedButton.stop:
          audioPlayerNotifier.stop();
          break;
        default:
          break;
      }
    });

    final playerStateStream = audioPlayer.playerStateStream.listen((
      state,
    ) async {
      switch (state) {
        case AudioPlaybackState.playing:
          await smtc.setPlaybackStatus(PlaybackStatus.playing);
          break;
        case AudioPlaybackState.paused:
          await smtc.setPlaybackStatus(PlaybackStatus.paused);
          break;
        case AudioPlaybackState.stopped:
          await smtc.setPlaybackStatus(PlaybackStatus.stopped);
          break;
        case AudioPlaybackState.completed:
          await smtc.setPlaybackStatus(PlaybackStatus.changing);
          break;
        default:
          break;
      }
    });

    final positionStream = audioPlayer.positionStream.listen((pos) async {
      await smtc.setPosition(pos);
    });

    final durationStream = audioPlayer.durationStream.listen((duration) async {
      await smtc.setEndTime(duration);
    });

    subscriptions.addAll([
      buttonStream,
      playerStateStream,
      positionStream,
      durationStream,
    ]);
  }

  Future<void> addTrack(Track track) async {
    if (_disposed) return;
    _currentTrack = track;
    try {
      if (!smtc.enabled) {
        await smtc.enableSmtc();
      }
      await smtc.updateMetadata(
        MusicMetadata(
          title: track.title,
          albumArtist: track.artist,
          artist: track.artist,
          album: track.album ?? 'Unknown',
          thumbnail: track.coverArt,
        ),
      );
    } catch (_) {
      // smtc 可能已释放或 flutter_rust_bridge 未初始化，忽略
    }
  }

  /// 当前曲目的元数据缓存（用于 updateArtist 时重建完整元数据）
  Track? _currentTrack;

  /// 更新 artist 字段（用于歌词展示）
  Future<void> updateArtist(String? artist) async {
    if (_disposed) return;
    final track = _currentTrack;
    if (track == null) return;
    try {
      await smtc.updateMetadata(
        MusicMetadata(
          title: track.title,
          albumArtist: track.artist,
          artist: artist,
          album: track.album ?? 'Unknown',
          thumbnail: track.coverArt,
        ),
      );
    } catch (_) {
      // smtc 可能已释放或 flutter_rust_bridge 未初始化，忽略
    }
  }

  void dispose() {
    _disposed = true;
    for (var element in subscriptions) {
      element.cancel();
    }
    try {
      smtc.disableSmtc();
      smtc.dispose();
    } catch (_) {
      // smtc 可能未正确初始化，忽略
    }
  }
}
