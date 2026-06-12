import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/module/module_manager.dart';

import '../music_subsonic_module.dart';
import '../subsonic_source.dart';

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

/// 已配置的 Subsonic 账号来源列表 Notifier
class SubsonicAccountsNotifier extends Notifier<List<SubsonicSource>> {
  @override
  List<SubsonicSource> build() {
    final module = ref.read(musicSubsonicModuleProvider);
    return module?.sources ?? [];
  }

  /// 添加账号
  ///
  /// 连接成功后刷新列表并持久化。
  Future<SubsonicSource> addAccount(SubsonicAccountConfig config) async {
    final module = ref.read(musicSubsonicModuleProvider);
    if (module == null) {
      throw StateError('MusicSubsonicModule 未注册');
    }
    final source = await module.addAccount(
      serverUrl: config.serverUrl,
      username: config.username,
      password: config.password,
      displayName: config.displayName,
    );
    state = module.sources;
    return source;
  }

  /// 移除账号
  Future<void> removeAccount(String sourceId) async {
    final module = ref.read(musicSubsonicModuleProvider);
    if (module == null) return;
    await module.removeAccount(sourceId);
    state = module.sources;
  }
}

/// 已配置的 Subsonic 账号来源列表
final subsonicAccountsProvider =
    NotifierProvider<SubsonicAccountsNotifier, List<SubsonicSource>>(
      SubsonicAccountsNotifier.new,
    );
