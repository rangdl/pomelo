import 'package:pomelo/core/mars.dart';
import 'package:pomelo/modules/music/music_module.dart';
import 'package:pomelo/modules/music_lx/model/lx_music_provider.dart';
import 'package:pomelo/modules/music_lx/providers/providers.dart';

/// Lx 音乐模块
///
/// 提供 tx/kg/wy/kw/mg 五个音乐平台的 [MusicProvider] 实现。
/// 初始化完成后通过 [MusicModule.register] 注册自身为数据提供者。
class LxMusicModule extends Module {
  late final TxMusicProvider _txMusicProvider;
  late final KgMusicProvider _kgMusicProvider;
  late final WyMusicProvider _wyMusicProvider;
  late final KwMusicProvider _kwMusicProvider;
  late final MgMusicProvider _mgMusicProvider;

  @override
  String get id => 'music_lx';

  @override
  String get displayName => 'Lx 音乐平台';

  @override
  bool get lazy => true;

  @override
  List<String> get dependencies => ['music'];

  /// 获取指定平台的提供者
  LxMusicProvider? provider(String platformId) {
    return switch (platformId) {
      'tx' => _txMusicProvider,
      'kg' => _kgMusicProvider,
      'wy' => _wyMusicProvider,
      'kw' => _kwMusicProvider,
      'mg' => _mgMusicProvider,
      _ => null,
    };
  }

  @override
  Future<void> onInit() async {
    _txMusicProvider = TxMusicProvider();
    _kgMusicProvider = KgMusicProvider();
    _wyMusicProvider = WyMusicProvider();
    _kwMusicProvider = KwMusicProvider();
    _mgMusicProvider = MgMusicProvider();
  }

  @override
  Future<void> onReady() async {
    final musicModule = ModuleManager().find<MusicModule>('music');
    if (musicModule == null) return;
    musicModule.register(_txMusicProvider);
    musicModule.register(_kgMusicProvider);
    musicModule.register(_wyMusicProvider);
    musicModule.register(_kwMusicProvider);
    musicModule.register(_mgMusicProvider);
  }

  @override
  Future<void> onDispose() async {
    // 不需要额外清理
  }
}
