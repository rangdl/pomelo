import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../provider/audio_player/audio_player.dart';

import '../../models/metadata/metadata.dart';
import '../../utils/platform.dart';
import '..//audio_services/windows_audio_service.dart';
import '../audio_player/audio_player.dart';
import '../audio_services/mobile_audio_service.dart';

class AudioServices with WidgetsBindingObserver {
  final MobileAudioService? mobile;
  final WindowsAudioService? smtc;

  AudioServices(this.mobile, this.smtc) {
    WidgetsBinding.instance.addObserver(this);
  }

  static Future<AudioServices> create(
    Ref ref,
    AudioPlayerNotifier playback,
  ) async {
    final mobile = kIsMobile || kIsMacOS || kIsLinux
        ? await AudioService.init(
            builder: () => MobileAudioService(playback),
            config: const AudioServiceConfig(
              androidNotificationChannelId: 'oss.rang.pomelo',
              androidNotificationChannelName: 'Pomelo',
              androidNotificationOngoing: false,
              androidStopForegroundOnPause: false,
              androidNotificationChannelDescription: "Pomelo Media Controls",
            ),
          )
        : null;
    final smtc = kIsWindows ? WindowsAudioService(ref, playback) : null;

    return AudioServices(mobile, smtc);
  }

  Future<void> addTrack(SpotubeTrackObject track) async {
    await smtc?.addTrack(track);
    mobile?.addItem(
      MediaItem(
        id: track.id,
        album: track.album.name,
        title: track.name,
        artist: track.artists.asString(),
        duration: Duration(milliseconds: track.durationMs),
        artUri: (track.album.images).asUri(
          placeholder: ImagePlaceholder.albumArt,
        ),
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
        audioPlayer.pause();
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
