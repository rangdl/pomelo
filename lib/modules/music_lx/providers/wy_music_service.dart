import '../model/lx_music_service.dart';

/// 网易云音乐（wy）服务
///
/// TODO: 实现具体的方法
class WyMusicService extends LxMusicService {
  WyMusicService({required super.jsEngine});

  @override
  String get sourceId => 'wy';

  @override
  String get sourceName => '网易云音乐';
}
