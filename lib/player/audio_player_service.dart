import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

/// 基于 media_kit 的播放器封装。
///
/// 只做“给一个 URL + headers → 播放”这一件事；解析逻辑在运行时层。
class AudioPlayerService {
  AudioPlayerService() : _player = Player();

  final Player _player;

  Stream<Duration> get positionStream => _player.stream.position;
  Stream<Duration> get durationStream => _player.stream.duration;
  Stream<bool> get playingStream => _player.stream.playing;
  Stream<bool> get completedStream => _player.stream.completed;
  Stream<String> get errorStream => _player.stream.error;

  Duration get position => _player.state.position;
  Duration get duration => _player.state.duration;
  bool get playing => _player.state.playing;

  /// 播放网络地址。[headers] 会原样带给底层（用于 Referer/UA 防盗链）。
  Future<void> open(String url, {Map<String, String>? headers}) async {
    try {
      await _player.open(
        Media(url, httpHeaders: headers),
        play: true,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('media_kit open 失败: $e');
      rethrow;
    }
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  Future<void> seek(Duration position) => _player.seek(position);
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  Future<void> dispose() => _player.dispose();
}
