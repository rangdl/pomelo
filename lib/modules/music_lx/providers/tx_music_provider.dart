import '../model/lx_music_provider.dart';

/// 腾讯音乐（tx）提供者
///
/// TODO: 实现具体的方法
class TxMusicProvider extends LxMusicProvider {
  TxMusicProvider({required super.jsEngine});

  @override
  String get sourceId => 'tx';

  @override
  String get sourceName => '腾讯音乐';
}
