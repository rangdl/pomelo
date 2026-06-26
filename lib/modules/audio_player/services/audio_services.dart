import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:pomelo/modules/audio_player/providers/audio_player.dart';
import 'package:pomelo/modules/music/model/track.dart' show Track;
import 'mobile_audio_service.dart';
import 'windows_audio_service.dart';

class AudioServices with WidgetsBindingObserver {
  final MobileAudioService? mobile;
  final WindowsAudioService? smtc;
  final AudioPlayerNotifier _playback;

  AudioServices(this.mobile, this.smtc, this._playback) {
    WidgetsBinding.instance.addObserver(this);
  }

  static Future<AudioServices> create(
    Ref ref,
    AudioPlayerNotifier playback,
  ) async {
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    final isMacOS = !kIsWeb && Platform.isMacOS;
    final isLinux = !kIsWeb && Platform.isLinux;
    final isWindows = !kIsWeb && Platform.isWindows;

    final mobile = isMobile || isMacOS || isLinux
        ? await AudioService.init(
            builder: () => MobileAudioService(playback),
            config: AudioServiceConfig(
              androidNotificationChannelId: switch (isLinux) {
                (true) => "pomelo",
                (_) => "oss.krtirtho.pomelo",
              },
              androidNotificationChannelName: 'Pomelo',
              androidNotificationOngoing: false,
              androidStopForegroundOnPause: false,
              androidNotificationChannelDescription: "Pomelo Media Controls",
            ),
          )
        : null;
    final smtc = isWindows ? WindowsAudioService(ref, playback) : null;

    return AudioServices(mobile, smtc, playback);
  }

  Future<void> addTrack(Track track) async {
    await smtc?.addTrack(track);
    mobile?.addItem(
      MediaItem(
        id: track.id,
        album: track.album ?? 'Unknown',
        title: track.title,
        artist: track.artist,
        duration: Duration(seconds: track.duration),
        artUri: track.coverArt == null ? null : Uri.tryParse(track.coverArt!),
        playable: true,
      ),
    );
  }

  void activateSession() {
    mobile?.session?.setActive(true);
  }

  void deactivateSession() {
    mobile?.session?.setActive(false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        deactivateSession();
        _playback.audioPlayer.pause();
        break;
      default:
        break;
    }
  }

  void dispose() {
    smtc?.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
