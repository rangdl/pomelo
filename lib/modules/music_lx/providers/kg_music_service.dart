import '../model/lx_music_service.dart';

/// 酷狗音乐（kg）服务
///
/// TODO: 实现具体的方法
class KgMusicService extends LxMusicService {
  KgMusicService({required super.jsEngine});

  @override
  String get sourceId => 'kg';

  @override
  String get sourceName => '酷狗音乐';
}
