import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smtc_windows/smtc_windows.dart';

import 'package:pomelo/modules/audio_player/model/playback_state.dart';
import 'package:pomelo/modules/audio_player/providers/audio_player.dart';
import 'package:pomelo/modules/audio_player/service/audio_player_service.dart';
import 'package:pomelo/modules/music/model/track.dart' show Track;

class WindowsAudioService {
  final SMTCWindows smtc;
  final Ref ref;
  final AudioPlayerNotifier audioPlayerNotifier;

  AudioPlayerService get audioPlayer => audioPlayerNotifier.audioPlayer;

  final subscriptions = <StreamSubscription>[];

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
  }

  void dispose() {
    smtc.disableSmtc();
    smtc.dispose();
    for (var element in subscriptions) {
      element.cancel();
    }
  }
}