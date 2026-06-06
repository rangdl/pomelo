import 'package:pomelo/core/mars.dart';
import 'package:pomelo/modules/music/music_module.dart';
import 'repository/local_music_provider.dart';

/// 本地音乐模块
///
/// 实现 [MusicProvider] 接口，提供本地音乐数据。
/// 初始化完成后通过 [MusicModule.register] 注册自身为数据提供者。
class MusicLocalModule extends Module {
  late final LocalMusicProvider _provider;

  @override
  String get id => 'music_local';

  @override
  String get displayName => '本地音乐';

  @override
  bool get lazy => true;

  @override
  List<String> get dependencies => ['music'];

  /// 对外暴露提供者实例
  LocalMusicProvider get provider => _provider;

  @override
  Future<void> onInit() async {
    _provider = LocalMusicProvider();
  }

  @override
  Future<void> onReady() async {
    // 在 onReady 中将提供者注册到 MusicModule
    // 此时 MusicModule 已就绪，可以接收注册
    final musicModule = ModuleManager().find<MusicModule>('music');
    musicModule?.register(_provider);
  }

  @override
  Future<void> onDispose() async {
    // 不需要额外清理
  }
}
