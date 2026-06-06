import '../model/lx_music_provider.dart';

/// 酷狗音乐（kg）提供者
///
/// TODO: 实现具体的方法
class KgMusicProvider extends LxMusicProvider {
  @override
  String get sourceId => 'kg';

  @override
  String get sourceName => '酷狗音乐';
}
