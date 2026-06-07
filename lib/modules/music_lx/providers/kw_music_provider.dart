import '../model/lx_music_provider.dart';

/// 酷我音乐（kw）提供者
///
/// TODO: 实现具体的方法
class KwMusicProvider extends LxMusicProvider {
  KwMusicProvider({required super.jsEngine});

  @override
  String get sourceId => 'kw';

  @override
  String get sourceName => '酷我音乐';
}
