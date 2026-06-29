import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/log.dart';
import 'package:pomelo/core/preferences/user_preference.dart';
import 'package:pomelo/core/preferences/user_preference_provider.dart';

import '../model/lx_server_quality.dart';
import '../repository/lx_server_client.dart';
import '../repository/lx_server_music_server.dart';

/// Lx Server 音乐服务实例
///
/// 依赖 [UserPreference.lxServerConfig]：配置变化时自动重建。
/// 配置为 null 或连接失败时返回 null。
final lxServerMusicServerProvider =
    FutureProvider<LxServerMusicServer?>((ref) async {
      final config = ref.watch(
        userPreferenceProvider.select((p) => p.lxServerConfig),
      );
      if (config == null) return null;

      final cleanUrl = config.serverUrl.replaceAll(RegExp(r'/+$'), '');
      final client = LxServerClient(
        serverUrl: cleanUrl,
        username: config.username,
        password: config.password,
        token: config.token,
        proxyPlayback: config.proxyPlayback,
      );

      try {
        if (config.token != null && config.token!.isNotEmpty) {
          final valid = await client.verifyToken();
          if (!valid) {
            await client.login();
          }
        } else {
          await client.login();
        }
      } catch (e) {
        log.error('LxServer', '连接 ${config.username}@$cleanUrl 失败: $e', error: e);
        client.dispose();
        return null;
      }

      final sourceId = 'lx-server-${cleanUrl.hashCode.abs()}';
      final sourceName =
          (config.displayName != null && config.displayName!.isNotEmpty)
          ? config.displayName!
          : 'Lx Server';
      final server = LxServerMusicServer(
        client: client,
        sourceId: sourceId,
        sourceName: sourceName,
      );

      ref.onDispose(() => client.dispose());
      log.info('LxServer', '已连接 ${config.username}@$cleanUrl');
      return server;
    });

/// Lx Server 连接配置（兼容旧 UI 调用，保留为 record 类型别名）
typedef LxServerConnectionConfig = ({
  String serverUrl,
  String username,
  String password,
  String? displayName,
  bool proxyPlayback,
});

/// Lx Server 连接状态 Notifier
///
/// 本 Notifier 仅负责连接/断开操作，实际的服务实例由
/// [lxServerMusicServerProvider] 基于 [UserPreference.lxServerConfig] 创建。
class LxServerConnectionNotifier extends Notifier<LxServerMusicServer?> {
  @override
  LxServerMusicServer? build() {
    return ref.watch(lxServerMusicServerProvider).value;
  }

  /// 连接到 lx-server
  ///
  /// 先用临时 client 验证登录，成功后写入 [UserPreference.lxServerConfig]，
  /// 由 [lxServerMusicServerProvider] 自动创建服务实例。
  /// 连接失败抛出异常。
  Future<LxServerMusicServer> connect(LxServerConnectionConfig config) async {
    final cleanUrl = config.serverUrl.replaceAll(RegExp(r'/+$'), '');
    final client = LxServerClient(
      serverUrl: cleanUrl,
      username: config.username,
      password: config.password,
    );
    try {
      await client.login();
    } catch (e) {
      client.dispose();
      rethrow;
    }
    final token = client.token;
    client.dispose();

    await ref.read(userPreferenceProvider.notifier).setLxServerConfig(
      LxServerConfig(
        serverUrl: cleanUrl,
        username: config.username,
        password: config.password,
        displayName: config.displayName,
        token: token,
        proxyPlayback: config.proxyPlayback,
      ),
    );

    final server = await ref.read(lxServerMusicServerProvider.future);
    if (server == null) {
      throw StateError('连接成功但 Provider 创建服务失败');
    }
    return server;
  }

  /// 断开连接
  ///
  /// 清除 [UserPreference.lxServerConfig]，由 [lxServerMusicServerProvider]
  /// 自动重建为 null。
  Future<void> disconnect() async {
    await ref.read(userPreferenceProvider.notifier).setLxServerConfig(null);
  }
}

/// Lx Server 连接状态
final lxServerConnectionProvider =
    NotifierProvider<LxServerConnectionNotifier, LxServerMusicServer?>(
      LxServerConnectionNotifier.new,
    );

/// 用户选择的 lx_server 音质偏好
///
/// 持久化到 UserPreference。
/// 应用到 [LxServerMusicServer.getMusicUrl] 时若该音质不可用则按优先级降级。
final selectedLxServerQualityProvider =
    NotifierProvider<SelectedLxServerQualityNotifier, LxServerQuality>(
      SelectedLxServerQualityNotifier.new,
    );

class SelectedLxServerQualityNotifier extends Notifier<LxServerQuality> {
  @override
  LxServerQuality build() {
    return ref.watch(userPreferenceProvider.select((p) => p.lxServerQuality));
  }

  Future<void> set(LxServerQuality quality) async {
    state = quality;
    await ref.read(userPreferenceProvider.notifier).setLxServerQuality(quality);
  }
}
