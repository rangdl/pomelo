import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/services/logger/logger.dart';
import 'package:pomelo/core/models/music_server_config.dart';
import 'package:pomelo/provider/music/music_server_config_provider.dart';

import '../repository/subsonic_client.dart';
import '../repository/subsonic_music_server.dart';

/// Subsonic 账号配置（兼容旧 UI 调用，保留为 record 类型别名）
typedef SubsonicAccountRecord = ({
  String serverUrl,
  String username,
  String password,
  String? token,
  String? salt,
  String name,
  String? version,
  String? pathPrefix,
});

/// 去除 serverUrl 末尾的多余斜杠
String _cleanUrl(String url) => url.replaceAll(RegExp(r'/+$'), '');

/// 按 configId 懒创建单个 SubsonicMusicServer
///
/// 从 [musicServerConfigsProvider] 读取指定 id 的 SubsonicConfig，
/// 创建独立的 [SubsonicClient] + [SubsonicMusicServer]。
/// 连接失败时返回 null。
final subsonicServerProvider =
    FutureProvider.family<SubsonicMusicServer?, String>((ref, configId) async {
      final configs = await ref.watch(musicServerConfigsProvider.future);
      final config = configs
          .whereType<SubsonicConfig>()
          .where((c) => c.id == configId)
          .firstOrNull;
      if (config == null) return null;

      final cleanUrl = _cleanUrl(config.serverUrl);
      final client = SubsonicClient(
        serverUrl: cleanUrl,
        username: config.username,
        password: config.password,
        token: config.token,
        salt: config.salt,
        version: config.version,
        pathPrefix: config.pathPrefix,
      );

      try {
        await client.ping();
      } catch (e) {
        AppLogger.reportError(
          e,
          null,
          '[MusicSubsonic] 账号 ${config.username}@$cleanUrl 连接失败: $e',
        );
        client.dispose();
        return null;
      }

      final server = SubsonicMusicServer(
        client: client,
        serverUrl: cleanUrl,
        username: config.username,
        displayName: config.name,
      );
      ref.onDispose(() => client.dispose());
      AppLogger.log.i('[MusicSubsonic] 已连接 ${server.sourceName}');
      return server;
    });

/// 所有已配置的 Subsonic 服务列表
///
/// 聚合所有 SubsonicConfig 对应的 [subsonicServerProvider] 实例。
/// 配置变化时自动重建。
final subsonicServersProvider = FutureProvider<List<SubsonicMusicServer>>((
  ref,
) async {
  final configs = await ref.watch(musicServerConfigsProvider.future);
  final subsonicConfigs = configs.whereType<SubsonicConfig>().toList();
  final servers = <SubsonicMusicServer>[];
  for (final config in subsonicConfigs) {
    final server = await ref.watch(subsonicServerProvider(config.id).future);
    if (server != null) servers.add(server);
  }
  return servers;
});

/// 已配置的 Subsonic 账号服务列表 Notifier
///
/// 本 Notifier 仅负责增删账号操作，实际的服务实例由
/// [subsonicServersProvider] 基于 [musicServerConfigsProvider] 创建。
class SubsonicAccountsNotifier extends Notifier<List<SubsonicMusicServer>> {
  @override
  List<SubsonicMusicServer> build() {
    return ref.watch(subsonicServersProvider).value ?? [];
  }

  /// 添加账号
  ///
  /// 先用临时 client 验证连接（ping），成功后写入 SubsonicConfig 到配置表，
  /// 由 [subsonicServersProvider] 自动创建服务实例。
  Future<SubsonicMusicServer> addAccount(SubsonicAccountRecord config) async {
    final cleanUrl = _cleanUrl(config.serverUrl);
    final client = SubsonicClient(
      serverUrl: cleanUrl,
      username: config.username,
      password: config.password,
      token: config.token,
      salt: config.salt,
      version: config.version,
      pathPrefix: config.pathPrefix,
    );
    try {
      await client.ping();
    } catch (e) {
      client.dispose();
      rethrow;
    }
    client.dispose();

    final configId = 'subsonic-${cleanUrl.hashCode.abs()}-${config.username}';
    await ref
        .read(musicServerConfigsNotifierProvider.notifier)
        .upsert(
          SubsonicConfig(
            id: configId,
            name: config.name,
            serverUrl: cleanUrl,
            username: config.username,
            password: config.password,
            token: config.token,
            salt: config.salt,
            version: config.version,
            pathPrefix: config.pathPrefix,
          ),
        );

    final server = await ref.read(subsonicServerProvider(configId).future);
    if (server == null) {
      throw StateError('连接成功但 Provider 创建服务失败');
    }
    return server;
  }

  /// 移除账号
  ///
  /// 根据 sourceId 删除对应 SubsonicConfig，
  /// 由 [subsonicServersProvider] 自动重建服务列表。
  Future<void> removeAccount(String sourceId) async {
    await ref
        .read(musicServerConfigsNotifierProvider.notifier)
        .remove(sourceId);
  }

  /// 更新账号
  ///
  /// 先用临时 client 验证新配置的连接，成功后更新 SubsonicConfig。
  Future<void> updateAccount(
    String sourceId,
    SubsonicAccountRecord config,
  ) async {
    final cleanUrl = _cleanUrl(config.serverUrl);
    final client = SubsonicClient(
      serverUrl: cleanUrl,
      username: config.username,
      password: config.password,
      token: config.token,
      salt: config.salt,
      version: config.version,
      pathPrefix: config.pathPrefix,
    );
    try {
      await client.ping();
    } catch (e) {
      client.dispose();
      rethrow;
    }
    client.dispose();

    await ref
        .read(musicServerConfigsNotifierProvider.notifier)
        .upsert(
          SubsonicConfig(
            id: sourceId,
            name: config.name,
            serverUrl: cleanUrl,
            username: config.username,
            password: config.password,
            token: config.token,
            salt: config.salt,
            version: config.version,
            pathPrefix: config.pathPrefix,
          ),
        );
  }

  /// 根据 sourceId 获取账号配置
  SubsonicConfig? getAccount(String sourceId) {
    final configs = ref.read(musicServerConfigsProvider).value ?? const [];
    for (final c in configs.whereType<SubsonicConfig>()) {
      if (c.id == sourceId) return c;
    }
    return null;
  }
}

/// 已配置的 Subsonic 账号服务列表
final subsonicAccountsProvider =
    NotifierProvider<SubsonicAccountsNotifier, List<SubsonicMusicServer>>(
      SubsonicAccountsNotifier.new,
    );
