import '../model/lx_music_service.dart';

/// 酷我音乐（kw）服务
///
/// TODO: 实现具体的方法
class KwMusicService extends LxMusicService {
  KwMusicService({required super.jsEngine});

  @override
  String get sourceId => 'kw';

  @override
  String get sourceName => '酷我音乐';
}
