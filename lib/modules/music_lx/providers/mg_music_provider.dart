import '../model/lx_music_provider.dart';

/// 咪咕音乐（mg）提供者
///
/// TODO: 实现具体的方法
class MgMusicProvider extends LxMusicProvider {
  MgMusicProvider({required super.jsEngine});

  @override
  String get sourceId => 'mg';

  @override
  String get sourceName => '咪咕音乐';
}
