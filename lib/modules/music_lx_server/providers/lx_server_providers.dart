import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/services/logger/logger.dart';
import 'package:pomelo/core/models/lx_server_quality.dart';
import 'package:pomelo/core/models/music_server_config.dart';
import 'package:pomelo/core/preferences/user_preference_provider.dart';
import 'package:pomelo/provider/music/music_server_config_provider.dart';
import 'package:pomelo/modules/music_lx/providers/lx_providers.dart';

import '../repository/lx_server_client.dart';
import '../repository/lx_server_music_server.dart';

/// 去除 serverUrl 末尾的多余斜杠
String _cleanUrl(String url) => url.replaceAll(RegExp(r'/+$'), '');

/// Lx Server 音乐服务实例
///
/// 从 [musicServerConfigsProvider] 读取 LxServerConfig，
/// 配置变化时自动重建。配置为 null 或连接失败时返回 null。
///
/// 同时监听全局 [UserPreference.localAudioSourceEnabled] 开关与
/// [lxSourceEngineProvider]（本地音源脚本引擎），
/// 当全局开关与 LxServerConfig.useLocalAudioSource 均开启时，
/// 启用本地音源优先策略（详见 [LxServerMusicServer.getMusicUrl]）。
/// 脚本列表变化时自动重建以加载最新的本地音源引擎。
final lxServerMusicServerProvider = FutureProvider<LxServerMusicServer?>((
  ref,
) async {
  final configs = await ref.watch(musicServerConfigsProvider.future);
  final config = configs.whereType<LxServerConfig>().firstOrNull;
  if (config == null) return null;

  // 监听全局本地音源开关，变化时自动重建服务
  final globalLocalAudioEnabled = ref.watch(
    userPreferenceProvider.select((p) => p.localAudioSourceEnabled),
  );

  // 监听本地音源脚本引擎，脚本变化时自动重建
  final sourceEngine = await ref.watch(lxSourceEngineProvider.future);

  final cleanUrl = _cleanUrl(config.serverUrl);
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
    AppLogger.reportError(
      e,
      null,
      '[LxServer] 连接 ${config.username}@$cleanUrl 失败: $e',
    );
    client.dispose();
    return null;
  }

  final server = LxServerMusicServer(
    client: client,
    sourceId: config.id,
    sourceName: config.name,
    allowSourceSwitching: config.allowSourceSwitching,
    useLocalAudioSource:
        globalLocalAudioEnabled && config.useLocalAudioSource,
    sourceEngine: sourceEngine,
  );

  ref.onDispose(() => client.dispose());
  AppLogger.log.i('[LxServer] 已连接 ${config.username}@$cleanUrl');
  return server;
});

/// Lx Server 连接配置（兼容旧 UI 调用，保留为 record 类型别名）
typedef LxServerConnectionConfig = ({
  String serverUrl,
  String username,
  String password,
  String name,
  bool proxyPlayback,
  bool allowSourceSwitching,
  bool useLocalAudioSource,
});

/// Lx Server 连接状态 Notifier
///
/// 本 Notifier 仅负责连接/断开操作，实际的服务实例由
/// [lxServerMusicServerProvider] 基于 [musicServerConfigsProvider] 创建。
class LxServerConnectionNotifier extends Notifier<LxServerMusicServer?> {
  @override
  LxServerMusicServer? build() {
    return ref.watch(lxServerMusicServerProvider).value;
  }

  /// 连接到 lx-server
  ///
  /// 先用临时 client 验证登录，成功后写入 LxServerConfig 到配置表，
  /// 由 [lxServerMusicServerProvider] 自动创建服务实例。
  Future<LxServerMusicServer> connect(LxServerConnectionConfig config) async {
    final cleanUrl = _cleanUrl(config.serverUrl);
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

    final configId = 'lx-server-${cleanUrl.hashCode.abs()}';
    await ref
        .read(musicServerConfigsNotifierProvider.notifier)
        .upsert(
          LxServerConfig(
            id: configId,
            name: config.name,
            serverUrl: cleanUrl,
            username: config.username,
            password: config.password,
            token: token,
            proxyPlayback: config.proxyPlayback,
            allowSourceSwitching: config.allowSourceSwitching,
            useLocalAudioSource: config.useLocalAudioSource,
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
  /// 删除 LxServerConfig，由 [lxServerMusicServerProvider] 自动重建为 null。
  Future<void> disconnect() async {
    final configs = ref.read(musicServerConfigsProvider).value ?? const [];
    final config = configs.whereType<LxServerConfig>().firstOrNull;
    if (config != null) {
      await ref
          .read(musicServerConfigsNotifierProvider.notifier)
          .remove(config.id);
    }
  }
}

/// Lx Server 连接状态
final lxServerConnectionProvider =
    NotifierProvider<LxServerConnectionNotifier, LxServerMusicServer?>(
      LxServerConnectionNotifier.new,
    );

/// 用户选择的音质偏好（全局，持久化到 UserPreference）
///
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
