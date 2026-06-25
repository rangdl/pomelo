import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/module/module_manager.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';

import '../music_subsonic_module.dart';
import '../repository/subsonic_music_service.dart';

/// 持有 MusicSubsonicModule 实例的 Provider
final musicSubsonicModuleProvider = Provider<MusicSubsonicModule?>((ref) {
  final mm = ModuleManager();
  return mm.find<MusicSubsonicModule>('music_subsonic');
});

/// Subsonic 账号配置信息
typedef SubsonicAccountConfig = ({
  String serverUrl,
  String username,
  String password,
  String? displayName,
});

/// 已配置的 Subsonic 账号服务列表 Notifier
class SubsonicAccountsNotifier extends Notifier<List<SubsonicMusicService>> {
  @override
  List<SubsonicMusicService> build() {
    final module = ref.read(musicSubsonicModuleProvider);
    return module?.services ?? [];
  }

  /// 添加账号
  ///
  /// 连接成功后刷新列表并持久化。
  Future<SubsonicMusicService> addAccount(SubsonicAccountConfig config) async {
    final module = ref.read(musicSubsonicModuleProvider);
    if (module == null) {
      throw StateError('MusicSubsonicModule 未注册');
    }
    final service = await module.addAccount(
      serverUrl: config.serverUrl,
      username: config.username,
      password: config.password,
      displayName: config.displayName,
    );
    state = module.services;
    // 主动失效上游 Provider，使首页切换按钮和平台列表刷新
    ref.invalidate(musicServicesProvider);
    return service;
  }

  /// 移除账号
  Future<void> removeAccount(String sourceId) async {
    final module = ref.read(musicSubsonicModuleProvider);
    if (module == null) return;
    await module.removeAccount(sourceId);
    state = module.services;
    // 主动失效上游 Provider，使首页切换按钮和平台列表刷新
    ref.invalidate(musicServicesProvider);
  }
}

/// 已配置的 Subsonic 账号服务列表
final subsonicAccountsProvider =
    NotifierProvider<SubsonicAccountsNotifier, List<SubsonicMusicService>>(
      SubsonicAccountsNotifier.new,
    );
