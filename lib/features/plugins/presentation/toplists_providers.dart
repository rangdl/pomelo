import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/plugin_record.dart';
import 'plugin_providers.dart';

/// 一个榜单分组（插件返回的榜单列表按 title 分块）。
class TopListGroup {
  const TopListGroup(this.title, this.items);

  final String title;
  final List<Map<String, dynamic>> items;
}

/// 当前可浏览榜单的插件。
///
/// 优先跟随首页已选择的搜索插件；它不支持榜单时回退到第一个支持的插件。
/// 这样在首页切换插件后，榜单/发现区会随选择一起刷新。
final toplistPluginProvider = Provider<PluginRecord?>((ref) {
  final list = (ref.watch(pluginListProvider).value ?? const [])
      .where((p) => p.enabled && p.supportedMethods.contains('getTopLists'))
      .toList();
  if (list.isEmpty) return null;
  final selectedId = ref.watch(selectedSearchPluginProvider);
  // 未选插件时默认第一个；选了就严格跟随（不支持榜单则留空，避免展示别的插件内容）。
  if (selectedId == null) return list.first;
  return list.where((p) => p.id == selectedId).firstOrNull;
});

/// 某插件的榜单列表（分组）。异步加载并缓存。
final topListGroupsProvider = FutureProvider.family<List<TopListGroup>, String>(
  (ref, pluginId) async {
    final list = ref.watch(pluginListProvider).value ?? const [];
    final plugin = list.where((p) => p.id == pluginId).firstOrNull;
    if (plugin == null) return const [];
    final rt = await ref.watch(pluginRuntimeProvider(plugin.id).future);
    final raw = await rt.getTopLists();
    return raw.map((g) {
      final items =
          (g['data'] as List?)
              ?.whereType<Map>()
              .map((e) => e.cast<String, dynamic>())
              .toList() ??
          const <Map<String, dynamic>>[];
      return TopListGroup('${g['title'] ?? '榜单'}', items);
    }).toList();
  },
);
