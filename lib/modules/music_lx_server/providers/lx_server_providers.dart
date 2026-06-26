import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/module/module_manager.dart';
import 'package:pomelo/core/storage/settings.dart';
import 'package:pomelo/core/storage/storage_keys.dart';

import '../model/lx_server_quality.dart';
import '../music_lx_server_module.dart';
import '../repository/lx_server_music_service.dart';

/// 持有 MusicLxServerModule 实例的 Provider
final musicLxServerModuleProvider = Provider<MusicLxServerModule?>((ref) {
  final mm = ModuleManager();
  return mm.find<MusicLxServerModule>('music_lx_server');
});

/// Lx Server 连接配置
typedef LxServerConfig = ({
  String serverUrl,
  String username,
  String password,
});

/// Lx Server 连接状态 Notifier
class LxServerConnectionNotifier
    extends Notifier<LxServerMusicService?> {
  @override
  LxServerMusicService? build() {
    final module = ref.read(musicLxServerModuleProvider);
    return module?.service;
  }

  /// 连接到 lx-server
  ///
  /// 登录成功后刷新状态。
  Future<LxServerMusicService> connect(LxServerConfig config) async {
    final module = ref.read(musicLxServerModuleProvider);
    if (module == null) {
      throw StateError('MusicLxServerModule 未注册');
    }
    final service = await module.connect(
      serverUrl: config.serverUrl,
      username: config.username,
      password: config.password,
    );
    state = service;
    return service;
  }

  /// 断开连接
  Future<void> disconnect() async {
    final module = ref.read(musicLxServerModuleProvider);
    if (module == null) return;
    await module.disconnect();
    state = null;
  }
}

/// Lx Server 连接状态
final lxServerConnectionProvider =
    NotifierProvider<LxServerConnectionNotifier, LxServerMusicService?>(
  LxServerConnectionNotifier.new,
);

/// 用户选择的 lx_server 音质偏好
///
/// 持久化到 [StorageKeys.musicLxServerQuality]。
/// 应用到 [LxServerMusicService.getMusicUrl] 时若该音质不可用则按优先级降级。
final selectedLxServerQualityProvider =
    NotifierProvider<SelectedLxServerQualityNotifier, LxServerQuality>(
  SelectedLxServerQualityNotifier.new,
);

class SelectedLxServerQualityNotifier extends Notifier<LxServerQuality> {
  @override
  LxServerQuality build() {
    final stored = Settings.get(StorageKeys.musicLxServerQuality);
    return LxServerQuality.fromIdOrDefault(stored);
  }

  Future<void> set(LxServerQuality quality) async {
    state = quality;
    await Settings.set(StorageKeys.musicLxServerQuality, quality.id);
  }
}
