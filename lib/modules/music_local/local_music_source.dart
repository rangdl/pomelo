import 'package:pomelo/modules/music/model/models.dart';
import 'repository/local_music_service.dart';

/// 本地音乐来源
///
/// 将 [LocalMusicService] 包装为 [MusicSource]，
/// 注册为一个来源实例，提供 1 个 [MusicService]。
/// 目录管理能力委托给内部的 [LocalMusicService]。
class LocalMusicSource extends MusicSource {
  final LocalMusicService _service;

  LocalMusicSource({LocalMusicService? service})
      : _service = service ?? LocalMusicService();

  @override
  String get id => 'local';

  @override
  String get name => '本地音乐';

  @override
  MusicSourceType get type => MusicSourceType.local;

  @override
  List<MusicService> get services => [_service];

  /// 内部的本地音乐服务实例
  LocalMusicService get service => _service;

  @override
  Future<void> init() async {
    // LocalMusicService 无需额外初始化，目录扫描由外部调用
  }

  @override
  Future<void> dispose() async {
    _service.clear();
  }
}
