import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/models/metadata/music_server.dart';
import 'package:pomelo/modules/music_local/local_music_providers.dart';
import 'package:pomelo/modules/music_lx_server/providers/lx_server_providers.dart';
import 'package:pomelo/modules/music_subsonic/providers/subsonic_providers.dart';
import 'package:pomelo/provider/music/music_server_config_provider.dart';

/// 所有已注册的音乐服务列表
///
/// 聚合 local/lx/lx_server/subsonic 四个来源的 MusicServer 实例。
/// 当任意来源的 UserPreference 配置变化时，对应 Provider 自动重建，
/// 本 Provider 随之刷新。
final musicServersProvider = FutureProvider<List<MusicServer>>((ref) async {
  final local = await ref.watch(localMusicServerProvider.future);
  // final lx = await ref.watch(lxMusicServerProvider.future);
  final lxServer = await ref.watch(lxServerMusicServerProvider.future);
  final subsonic = await ref.watch(subsonicServersProvider.future);

  return [
    local,
    // ?lx,
    ?lxServer,
    ...subsonic,
  ];
});

/// 根据 sourceId 获取特定 MusicServer
///
/// 通过监听 [musicServerConfigsProvider] 确保配置变化时 Provider 自动重建。
/// 两阶段查找：先按 sourceId 精确匹配，再按 libraryId 匹配。
final musicServerByProvider = FutureProvider.family<MusicServer?, String>((
  ref,
  sourceId,
) async {
  // 监听配置变化，确保 config 变更时 Provider 自动重建
  await ref.watch(musicServerConfigsProvider.future);
  final servers = await ref.watch(musicServersProvider.future);
  return servers.firstWhereOrNull((s) => s.sourceId == sourceId) ??
      servers.firstWhereOrNull((s) => s.libraries.any((v) => v.id == sourceId));
});

/// 按分类分组的所有 MusicServer
final musicServersByCategoryProvider =
    FutureProvider<Map<String, List<MusicServer>>>((ref) async {
      final servers = await ref.watch(musicServersProvider.future);
      final byCategory = <String, List<MusicServer>>{};
      for (final s in servers) {
        byCategory.putIfAbsent(s.categoryId, () => []).add(s);
      }
      return byCategory;
    });

/// 所有已注册的分类列表
final musicCategoriesProvider =
    FutureProvider<List<({String id, String name})>>((ref) async {
      final servers = await ref.watch(musicServersProvider.future);
      final categories = <String, ({String id, String name})>{};
      for (final s in servers) {
        categories.putIfAbsent(
          s.categoryId,
          () => (id: s.categoryId, name: s.categoryName),
        );
      }
      return categories.values.toList();
    });
