import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:pomelo/modules/audio_player/providers/audio_player.dart';
import 'package:pomelo/core/models/metadata/track.dart' show Track;
import 'mobile_audio_service.dart';
import 'windows_audio_service.dart';

class AudioServices with WidgetsBindingObserver {
  final MobileAudioService? mobile;
  final WindowsAudioService? smtc;
  final AudioPlayerNotifier _playback;

  /// 当前曲目的原始 artist（用于清除歌词时恢复）
  String? _originalArtist;

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
              androidNotificationChannelName: '柚子音乐',
              androidNotificationOngoing: false,
              androidStopForegroundOnPause: false,
              androidNotificationChannelDescription: "柚子音乐媒体控制",
            ),
          )
        : null;
    final smtc = isWindows ? WindowsAudioService(ref, playback) : null;

    return AudioServices(mobile, smtc, playback);
  }

  Future<void> addTrack(Track track) async {
    _originalArtist = track.artist;
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

  /// 更新歌词到 artist 展示位置
  ///
  /// 将当前歌词行写入系统媒体控制的 artist 字段，
  /// 便于在各平台的音频控制位置（通知栏、锁屏、SMTC）展示歌词。
  /// 传入 null 时恢复原始 artist。
  Future<void> updateLyric(String? line) async {
    final artist = line ?? _originalArtist;

    // 移动端：更新 mediaItem 的 artist 字段
    final currentMediaItem = mobile?.mediaItem.value;
    if (currentMediaItem != null) {
      mobile?.mediaItem.add(currentMediaItem.copyWith(artist: artist));
    }

    // Windows 端：更新 SMTC 元数据的 artist 字段
    await smtc?.updateArtist(artist);
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
