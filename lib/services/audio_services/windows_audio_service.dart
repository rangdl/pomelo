import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/models/metadata/metadata.dart';
import 'package:pomelo/provider/audio_player/audio_player.dart';
import 'package:pomelo/services/audio_player/audio_player.dart';
import 'package:pomelo/services/audio_player/playback_state.dart';
import 'package:smtc_windows/smtc_windows.dart';

class WindowsAudioService {
  final SMTCWindows smtc;
  final Ref ref;
  final AudioPlayerNotifier audioPlayerNotifier;

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

  Future<void> addTrack(SpotubeTrackObject track) async {
    if (!smtc.enabled) {
      await smtc.enableSmtc();
    }
    var thumbnail = (track.album.images).asUrlString(
      placeholder: ImagePlaceholder.albumArt,
    );
    // smtc_windows 不能读取assets目录内的图片,本机的图片好像也不行
    // https://github.com/KRTirtho/smtc_windows/pull/10/changes#diff-536025102b3795f79ed1d2d8fa9103cb1cccd44c5800e3499fc2b84b8d808e9e
    // 这个允许传递byte数组
    if (thumbnail.isNotEmpty && thumbnail.startsWith('assets/')) {
      // thumbnail =
      //     'D:/WorkSpace/personal/flutter/test/pomelo/assets/images/album-placeholder.png';
      thumbnail =
          'https://files.seeusercontent.com/2026/04/08/Tr4a/20260408153051-353.png';
    }
    await smtc.updateMetadata(
      MusicMetadata(
        title: track.name,
        albumArtist: track.artists.firstOrNull?.name ?? "Unknown",
        artist: track.artists.asString(),
        album: track.album.name,
        thumbnail: thumbnail,
      ),
    );
  }

  // Future<Uint8List> loadAssetAsBytes(String assetPath) async {
  //   // 加载资源为 ByteData
  //   final ByteData byteData = await rootBundle.load(assetPath);
  //   // 转换为 Uint8List
  //   final Uint8List bytes = byteData.buffer.asUint8List();
  //   return bytes;
  // }

  void dispose() {
    smtc.disableSmtc();
    smtc.dispose();
    for (var element in subscriptions) {
      element.cancel();
    }
  }
}
