import '../model/lx_music_service.dart';

/// 腾讯音乐（tx）服务
///
/// TODO: 实现具体的方法
class TxMusicService extends LxMusicService {
  TxMusicService({required super.jsEngine});

  @override
  String get sourceId => 'tx';

  @override
  String get sourceName => '腾讯音乐';
}
