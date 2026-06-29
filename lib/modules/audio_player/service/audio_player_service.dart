// ignore_for_file: public_member_api_docs, sort_constructors_first
/// 音频播放器服务层
///
/// 封装播放器核心业务逻辑，提供便捷的播放控制 API。
/// 其他模块可通过此服务控制播放、管理队列。
library;

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit/media_kit.dart' hide Track;

import 'package:pomelo/core/core.dart';
import 'package:pomelo/core/log.dart';
import 'package:pomelo/modules/audio_player/model/media.dart';
import 'package:pomelo/modules/audio_player/model/custom_player.dart';
import 'package:pomelo/modules/audio_player/model/playback_state.dart';
import 'package:pomelo/modules/audio_player/repository/audio_player_repository.dart';
import 'package:pomelo/core/models/metadata/track.dart' show Track;

/// 音频播放器服务
///
/// 负责播放控制、队列管理等核心业务逻辑。
/// 实际的媒体播放能力由 [AudioPlayerInterface] 提供。
class AudioPlayerService extends AudioPlayerInterface
    with AudioPlayerServiceStreams {
  final AudioPlayerRepository repository;

  AudioPlayerService(this.repository);

  Future<void> pause() async {
    await _mkPlayer.pause();
  }

  Future<void> resume() async {
    await _mkPlayer.play();
  }

  Future<void> stop() async {
    await _mkPlayer.stop();
  }

  Future<void> seek(Duration position) async {
    await _mkPlayer.seek(position);
  }

  /// Volume is between 0 and 1
  Future<void> setVolume(double volume) async {
    assert(volume >= 0 && volume <= 1);
    await _mkPlayer.setVolume(volume * 100);
  }

  Future<void> setSpeed(double speed) async {
    await _mkPlayer.setRate(speed);
  }

  Future<void> setAudioDevice(mk.AudioDevice device) async {
    await _mkPlayer.setAudioDevice(device);
  }

  Future<void> dispose() async {
    await _mkPlayer.dispose();
  }

  // Playlist related

  Future<void> openPlaylist(
    List<mk.Media> tracks, {
    bool autoPlay = true,
    int initialIndex = 0,
  }) async {
    assert(tracks.isNotEmpty);
    assert(initialIndex <= tracks.length - 1);
    await _mkPlayer.open(
      mk.Playlist(tracks, index: initialIndex),
      play: autoPlay,
    );
  }

  List<String> get sources {
    return _mkPlayer.state.playlist.medias.map((e) => e.uri).toList();
  }

  String? get currentSource {
    if (_mkPlayer.state.playlist.index == -1) return null;
    return _mkPlayer.state.playlist.medias
        .elementAtOrNull(_mkPlayer.state.playlist.index)
        ?.uri;
  }

  String? get nextSource {
    if (loopMode == PlaylistMode.loop &&
        _mkPlayer.state.playlist.index ==
            _mkPlayer.state.playlist.medias.length - 1) {
      return sources.first;
    }

    return _mkPlayer.state.playlist.medias
        .elementAtOrNull(_mkPlayer.state.playlist.index + 1)
        ?.uri;
  }

  String? get previousSource {
    if (loopMode == PlaylistMode.loop && _mkPlayer.state.playlist.index == 0) {
      return sources.last;
    }

    return _mkPlayer.state.playlist.medias
        .elementAtOrNull(_mkPlayer.state.playlist.index - 1)
        ?.uri;
  }

  int get currentIndex => _mkPlayer.state.playlist.index;

  Future<void> skipToNext() async {
    await _mkPlayer.next();
  }

  Future<void> skipToPrevious() async {
    await _mkPlayer.previous();
  }

  Future<void> jumpTo(int index) async {
    await _mkPlayer.jump(index);
  }

  Future<void> addTrack(mk.Media media) async {
    await _mkPlayer.add(media);
  }

  Future<void> addTrackAt(mk.Media media, int index) async {
    await _mkPlayer.insert(index, media);
  }

  Future<void> removeTrack(int index) async {
    await _mkPlayer.remove(index);
  }

  Future<void> moveTrack(int from, int to) async {
    await _mkPlayer.move(from, to);
  }

  Future<void> clearPlaylist() async {
    _mkPlayer.stop();
  }

  Future<void> setShuffle(bool shuffle) async {
    await _mkPlayer.setShuffle(shuffle);
  }

  Future<void> setLoopMode(PlaylistMode loop) async {
    await _mkPlayer.setPlaylistMode(loop);
  }

  Future<void> setAudioNormalization(bool normalize) async {
    await _mkPlayer.setAudioNormalization(normalize);
  }

  Future<void> setDemuxerBufferSize(int sizeInBytes) async {
    await _mkPlayer.setDemuxerBufferSize(sizeInBytes);
  }
}

class AudioPlayerInterface extends Service {
  @override
  String get id => 'audio_player_service';

  final CustomPlayer _mkPlayer;

  AudioPlayerInterface()
    : _mkPlayer = CustomPlayer(
        configuration: const mk.PlayerConfiguration(
          title: "Pomelo",
          logLevel: kDebugMode ? mk.MPVLogLevel.info : mk.MPVLogLevel.error,
          async: true,
        ),
      ) {
    _mkPlayer.stream.error.listen((event) {
      // AppLogger.reportError(event, StackTrace.current);
      log.error('AudioPlayer', event.toString());
    });
  }

  /// Whether the current platform supports the audioplayers plugin
  static const bool _mkSupportedPlatform = true;

  bool get mkSupportedPlatform => _mkSupportedPlatform;

  Duration get duration {
    return _mkPlayer.state.duration;
  }

  Playlist get playlist {
    return _mkPlayer.state.playlist;
  }

  Duration get position {
    return _mkPlayer.state.position;
  }

  Duration get bufferedPosition {
    return _mkPlayer.state.buffer;
  }

  Future<mk.AudioDevice> get selectedDevice async {
    return _mkPlayer.state.audioDevice;
  }

  Future<List<mk.AudioDevice>> get devices async {
    return _mkPlayer.state.audioDevices;
  }

  bool get hasSource {
    return _mkPlayer.state.playlist.medias.isNotEmpty;
  }

  // states
  bool get isPlaying {
    return _mkPlayer.state.playing;
  }

  bool get isPaused {
    return !_mkPlayer.state.playing;
  }

  bool get isStopped {
    return !hasSource;
  }

  Future<bool> get isCompleted async {
    return _mkPlayer.state.completed;
  }

  bool get isShuffled {
    return _mkPlayer.shuffled;
  }

  PlaylistMode get loopMode {
    return _mkPlayer.state.playlistMode;
  }

  /// Returns the current volume of the player, between 0 and 1
  double get volume {
    return _mkPlayer.state.volume / 100;
  }

  bool get isBuffering {
    return _mkPlayer.state.buffering;
  }

  @override
  Future<void> onInit() async {
    await super.onInit();
  }

  @override
  Future<void> onDispose() async {
    await _mkPlayer.dispose();
    await super.onDispose();
  }
}

mixin AudioPlayerServiceStreams on AudioPlayerInterface {
  // stream getters
  Stream<Duration> get durationStream {
    // if (mkSupportedPlatform) {
    return _mkPlayer.stream.duration;
    // } else {
    //   return _justAudio!.durationStream
    //       .where((event) => event != null)
    //       .map((event) => event!)
    //       ;
    // }
  }

  Stream<Duration> get positionStream {
    // if (mkSupportedPlatform) {
    return _mkPlayer.stream.position;
    // } else {
    //   return _justAudio!.positionStream;
    // }
  }

  Stream<Duration> get bufferedPositionStream {
    // if (mkSupportedPlatform) {
    // audioplayers doesn't have the capability to get buffered position
    return _mkPlayer.stream.buffer;
    // } else {
    //   return _justAudio!.bufferedPositionStream;
    // }
  }

  Stream<void> get completedStream {
    // if (mkSupportedPlatform) {
    return _mkPlayer.stream.completed;
    // } else {
    //   return _justAudio!.playerStateStream
    //       .where(
    //           (event) => event.processingState == ja.ProcessingState.completed)
    //       ;
    // }
  }

  /// Stream that emits when the player is almost (%) complete
  Stream<int> percentCompletedStream(double percent) {
    return positionStream
        .asyncMap(
          (position) async => duration == Duration.zero
              ? 0
              : (position.inSeconds / duration.inSeconds * 100).toInt(),
        )
        .where((event) => event >= percent);
  }

  Stream<bool> get playingStream {
    // if (mkSupportedPlatform) {
    return _mkPlayer.stream.playing;
    // } else {
    //   return _justAudio!.playingStream;
    // }
  }

  Stream<bool> get shuffledStream {
    // if (mkSupportedPlatform) {
    return _mkPlayer.shuffleStream;
    // } else {
    //   return _justAudio!.shuffleModeEnabledStream;
    // }
  }

  Stream<PlaylistMode> get loopModeStream {
    // if (mkSupportedPlatform) {
    return _mkPlayer.stream.playlistMode;
    // } else {
    //   return _justAudio!.loopModeStream
    //       .map(PlaylistMode.fromLoopMode)
    //       ;
    // }
  }

  Stream<double> get volumeStream {
    // if (mkSupportedPlatform) {
    return _mkPlayer.stream.volume.map((event) => event / 100);
    // } else {
    //   return _justAudio!.volumeStream;
    // }
  }

  Stream<bool> get bufferingStream {
    // if (mkSupportedPlatform) {
    return Stream.value(false);
    // } else {
    //   return _justAudio!.playerStateStream
    //       .map(
    //         (event) =>
    //             event.processingState == ja.ProcessingState.buffering ||
    //             event.processingState == ja.ProcessingState.loading,
    //       )
    //       ;
    // }
  }

  Stream<AudioPlaybackState> get playerStateStream {
    // if (mkSupportedPlatform) {
    return _mkPlayer.playerStateStream;
    // } else {
    //   return _justAudio!.playerStateStream
    //       .map(AudioPlaybackState.fromJaPlayerState)
    //       ;
    // }
  }

  Stream<int> get currentIndexChangedStream {
    // if (mkSupportedPlatform) {
    return _mkPlayer.indexChangeStream;
    // } else {
    //   return _justAudio!.sequenceStateStream
    //       .map((event) => event?.currentIndex ?? -1)
    //       ;
    // }
  }

  Stream<String> get activeSourceChangedStream {
    // if (mkSupportedPlatform) {
    return _mkPlayer.indexChangeStream
        .map((event) {
          return _mkPlayer.state.playlist.medias.elementAtOrNull(event)?.uri;
        })
        .where((event) => event != null)
        .cast<String>();
    // } else {
    //   return _justAudio!.sequenceStateStream
    //       .map((event) {
    //         return (event?.currentSource as ja.UriAudioSource?)?.uri.toString();
    //       })
    //       .where((event) => event != null)
    //       .cast<String>();
    // }
  }

  Stream<List<mk.AudioDevice>> get devicesStream =>
      _mkPlayer.stream.audioDevices.asBroadcastStream();

  Stream<mk.AudioDevice> get selectedDeviceStream =>
      _mkPlayer.stream.audioDevice.asBroadcastStream();

  Stream<String> get errorStream => _mkPlayer.stream.error;

  Stream<mk.Playlist> get playlistStream => _mkPlayer.stream.playlist;
}

extension AsMediaListTrack on Iterable<Track> {
  List<PomeloMedia> asMediaList() {
    return map((track) => PomeloMedia(track)).toList();
  }
}
