import 'package:pomelo/core/mars.dart';
import '../model/song.dart';
import '../repository/music_repository.dart';

/// Music SDK 业务服务
///
/// 音乐播放最底层服务，封装通用的音乐播放核心能力。
/// 不依赖任何特定的音乐平台，由上层模块提供数据。
class MusicSdkService extends Service {
  final MusicSdkRepository repository;

  MusicSdkService({required this.repository});

  @override
  String get id => 'music_service';

  /// 当前播放队列
  List<Song> _queue = [];

  /// 当前播放索引
  int _currentIndex = 0;

  /// 当前播放队列（只读）
  List<Song> get queue => List.unmodifiable(_queue);

  /// 当前播放的歌曲
  Song? get currentSong => _queue.isNotEmpty && _currentIndex < _queue.length
      ? _queue[_currentIndex]
      : null;

  /// 设置播放队列
  void setQueue(List<Song> songs, {int startIndex = 0}) {
    _queue = List.from(songs);
    _currentIndex = startIndex.clamp(0, _queue.length - 1);
  }

  /// 下一首
  Song? next() {
    if (_queue.isEmpty) return null;
    _currentIndex = (_currentIndex + 1) % _queue.length;
    return _queue[_currentIndex];
  }

  /// 上一首
  Song? previous() {
    if (_queue.isEmpty) return null;
    _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
    return _queue[_currentIndex];
  }

  /// 跳转到指定索引
  Song? jumpTo(int index) {
    if (index < 0 || index >= _queue.length) return null;
    _currentIndex = index;
    return _queue[_currentIndex];
  }

  @override
  Future<void> onInit() async {
    await super.onInit();
    // 服务初始化逻辑
  }

  @override
  Future<void> onDispose() async {
    await super.onDispose();
    _queue = [];
    _currentIndex = 0;
  }
}
