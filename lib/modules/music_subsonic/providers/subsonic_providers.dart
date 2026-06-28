import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/log.dart';
import 'package:pomelo/core/preferences/user_preference.dart';
import 'package:pomelo/core/preferences/user_preference_provider.dart';

import '../repository/subsonic_client.dart';
import '../repository/subsonic_music_server.dart';

/// Subsonic 账号配置（兼容旧 UI 调用，保留为 record 类型别名）
typedef SubsonicAccountRecord = ({
  String serverUrl,
  String username,
  String password,
  String? displayName,
});

/// 去除 serverUrl 末尾的多余斜杠
String _cleanUrl(String url) => url.replaceAll(RegExp(r'/+$'), '');

/// 所有已配置的 Subsonic 服务列表
///
/// 依赖 [UserPreference.subsonicAccounts]：账号列表变化时自动重建。
/// 每个账号创建独立的 [SubsonicClient] + [SubsonicMusicServer]，
/// 连接失败的账号会被跳过。
final subsonicServersProvider =
    FutureProvider<List<SubsonicMusicServer>>((ref) async {
      final accounts = ref.watch(
        userPreferenceProvider.select((p) => p.subsonicAccounts),
      );
      final clients = <SubsonicClient>[];
      final servers = <SubsonicMusicServer>[];

      for (final account in accounts) {
        final cleanUrl = _cleanUrl(account.serverUrl);
        final client = SubsonicClient(
          serverUrl: cleanUrl,
          username: account.username,
          password: account.password,
        );

        try {
          await client.ping();
        } catch (e) {
          log.error(
            'MusicSubsonic',
            '账号 ${account.username}@$cleanUrl 连接失败: $e',
            error: e,
          );
          client.dispose();
          continue;
        }

        final server = SubsonicMusicServer(
          client: client,
          serverUrl: cleanUrl,
          username: account.username,
          displayName: account.displayName,
        );
        clients.add(client);
        servers.add(server);
        log.info('MusicSubsonic', '已连接 ${server.sourceName}');
      }

      ref.onDispose(() {
        for (final client in clients) {
          client.dispose();
        }
      });

      return servers;
    });

/// 已配置的 Subsonic 账号服务列表 Notifier
///
/// 本 Notifier 仅负责增删账号操作，实际的服务实例由
/// [subsonicServersProvider] 基于 [UserPreference.subsonicAccounts] 创建。
class SubsonicAccountsNotifier extends Notifier<List<SubsonicMusicServer>> {
  @override
  List<SubsonicMusicServer> build() {
    return ref.watch(subsonicServersProvider).value ?? [];
  }

  /// 添加账号
  ///
  /// 先用临时 client 验证连接（ping），成功后写入 [UserPreference.subsonicAccounts]，
  /// 由 [subsonicServersProvider] 自动创建服务实例。
  /// 连接失败抛出异常。
  Future<SubsonicMusicServer> addAccount(SubsonicAccountRecord config) async {
    final cleanUrl = _cleanUrl(config.serverUrl);
    final client = SubsonicClient(
      serverUrl: cleanUrl,
      username: config.username,
      password: config.password,
    );
    try {
      await client.ping();
    } catch (e) {
      client.dispose();
      rethrow;
    }
    client.dispose();

    final currentAccounts = ref.read(userPreferenceProvider).subsonicAccounts;
    final newAccount = SubsonicAccountConfig(
      serverUrl: cleanUrl,
      username: config.username,
      password: config.password,
      displayName: config.displayName,
    );
    await ref.read(userPreferenceProvider.notifier).setSubsonicAccounts([
      ...currentAccounts,
      newAccount,
    ]);

    final servers = await ref.read(subsonicServersProvider.future);
    final sourceId = 'subsonic-${cleanUrl.hashCode.abs()}-${config.username}';
    SubsonicMusicServer? server;
    for (final s in servers) {
      if (s.sourceId == sourceId) {
        server = s;
        break;
      }
    }
    if (server == null) {
      throw StateError('连接成功但 Provider 创建服务失败');
    }
    return server;
  }

  /// 移除账号
  ///
  /// 根据 sourceId 从 [UserPreference.subsonicAccounts] 中移除对应账号，
  /// 由 [subsonicServersProvider] 自动重建服务列表。
  Future<void> removeAccount(String sourceId) async {
    final currentAccounts = ref.read(userPreferenceProvider).subsonicAccounts;
    final newAccounts =
        currentAccounts.where((a) {
          final cleanUrl = _cleanUrl(a.serverUrl);
          final id = 'subsonic-${cleanUrl.hashCode.abs()}-${a.username}';
          return id != sourceId;
        }).toList();
    await ref
        .read(userPreferenceProvider.notifier)
        .setSubsonicAccounts(newAccounts);
  }
}

/// 已配置的 Subsonic 账号服务列表
final subsonicAccountsProvider =
    NotifierProvider<SubsonicAccountsNotifier, List<SubsonicMusicServer>>(
      SubsonicAccountsNotifier.new,
    );
