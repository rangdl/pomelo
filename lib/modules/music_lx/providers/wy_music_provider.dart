import '../model/lx_music_provider.dart';

/// 网易云音乐（wy）提供者
///
/// TODO: 实现具体的方法
class WyMusicProvider extends LxMusicProvider {
  WyMusicProvider({required super.jsEngine});

  @override
  String get sourceId => 'wy';

  @override
  String get sourceName => '网易云音乐';
}
