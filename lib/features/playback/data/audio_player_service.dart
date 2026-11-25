import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

/// 基于 media_kit 的播放器封装。
///
/// 只负责「URL + headers → 播放」与基础控制；队列与解析在更上层。
class AudioPlayerService {
  AudioPlayerService() : _player = Player();

  final Player _player;

  Stream<Duration> get positionStream => _player.stream.position;
  Stream<Duration> get durationStream => _player.stream.duration;
  Stream<bool> get playingStream => _player.stream.playing;
  Stream<bool> get bufferingStream => _player.stream.buffering;
  Stream<bool> get completedStream => _player.stream.completed;
  Stream<String> get errorStream => _player.stream.error;

  Duration get position => _player.state.position;
  Duration get duration => _player.state.duration;
  bool get playing => _player.state.playing;
  double get volume => _player.state.volume;

  /// 收到播放完成事件（用于自动下一首）。
  void onCompleted(void Function() callback) {
    _completedSub?.cancel();
    _completedSub = _player.stream.completed.listen((done) {
      if (done) callback();
    });
  }

  dynamic _completedSub;

  /// 播放网络地址。[headers] 会原样带给底层（Referer/UA 防盗链）。
  Future<void> open(String url, {Map<String, String>? headers}) async {
    try {
      await _player.open(Media(url, httpHeaders: headers), play: true);
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

  Future<void> dispose() async {
    await _completedSub?.cancel();
    await _player.dispose();
  }
}
