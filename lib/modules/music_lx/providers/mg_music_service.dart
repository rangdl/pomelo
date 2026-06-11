import '../model/lx_music_service.dart';

/// 咪咕音乐（mg）服务
///
/// TODO: 实现具体的方法
class MgMusicService extends LxMusicService {
  MgMusicService({required super.jsEngine});

  @override
  String get sourceId => 'mg';

  @override
  String get sourceName => '咪咕音乐';
}
