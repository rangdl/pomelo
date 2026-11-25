import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/plugin_record.dart';
import 'plugin_providers.dart';

/// 一个榜单分组（插件返回的榜单列表按 title 分块）。
class TopListGroup {
  const TopListGroup(this.title, this.items);

  final String title;
  final List<Map<String, dynamic>> items;
}

/// 当前可浏览榜单的插件（默认取第一个已启用、支持榜单的 MusicFree 插件）。
final toplistPluginProvider = Provider<PluginRecord?>((ref) {
  final list = ref.watch(pluginListProvider).value ?? const [];
  return list
      .where((p) =>
          p.isMusicFree &&
          p.enabled &&
          p.supportedMethods.contains('getTopLists'))
      .firstOrNull;
});

/// 某插件的榜单列表（分组）。异步加载并缓存。
final topListGroupsProvider =
    FutureProvider.family<List<TopListGroup>, String>((ref, pluginId) async {
  final list = ref.watch(pluginListProvider).value ?? const [];
  final plugin = list.where((p) => p.id == pluginId).firstOrNull;
  if (plugin == null) return const [];
  final rt = await ref.watch(musicFreeRuntimeProvider(plugin).future);
  final raw = await rt.getTopLists();
  return raw.map((g) {
    final items = (g['data'] as List?)
            ?.whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList() ??
        const <Map<String, dynamic>>[];
    return TopListGroup('${g['title'] ?? '榜单'}', items);
  }).toList();
});
