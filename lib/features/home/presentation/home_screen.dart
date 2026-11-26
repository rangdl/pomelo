import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/layout/window_class.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../../plugins/presentation/plugin_providers.dart';
import '../../plugins/presentation/toplists_providers.dart';

/// 首页内容(外壳 [AdaptiveAppShell] 提供标题栏与自适应导航)。
///
/// 搜索已拆分为独立页面,这里只保留发现区:歌单 / 榜单快捷入口 + 榜单封面网格。
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plugins = ref.watch(pluginListProvider);
    return plugins.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(
        icon: Icons.error_outline_rounded,
        title: '加载插件失败',
        message: '$e',
        actions: [
          FilledButton.tonalIcon(
            onPressed: () => ref.invalidate(pluginListProvider),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('重试'),
          ),
        ],
      ),
      data: (list) => list.isEmpty
          ? EmptyState(
              icon: Icons.extension_off_rounded,
              title: '还没有安装插件',
              message: '到设置页安装插件后即可搜索和播放音乐。',
              actions: [
                FilledButton.tonalIcon(
                  onPressed: () => context.push('/plugins'),
                  icon: const Icon(Icons.extension_rounded),
                  label: const Text('安装插件'),
                ),
              ],
            )
          // 迷你播放胶囊由外壳统一以浮层形式显示，首页只放内容。
          : const _DiscoverView(),
    );
  }
}

/// 发现区:快捷入口 + 按分组展示榜单封面网格,点封面直达该榜单歌曲页。
class _DiscoverView extends ConsumerWidget {
  const _DiscoverView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plugin = ref.watch(toplistPluginProvider);
    if (plugin == null) {
      return const EmptyState(
        icon: Icons.leaderboard_rounded,
        title: '当前插件没有榜单',
        message: '在标题栏左侧切换音源,或安装支持榜单的插件。',
      );
    }

    final groups = ref.watch(topListGroupsProvider(plugin.id));
    return WindowClassBuilder(
      builder: (context, windowClass) => ListView(
        padding: AppSpacing.pagePadding,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () => context.push('/sheets'),
                  icon: const Icon(Icons.queue_music_rounded, size: 18),
                  label: const Text('推荐歌单'),
                ),
                const SizedBox(width: AppSpacing.xs),
                TextButton.icon(
                  onPressed: () => context.push('/toplists'),
                  icon: const Icon(Icons.leaderboard_rounded, size: 18),
                  label: const Text('全部榜单'),
                ),
              ],
            ),
          ),
          groups.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => EmptyState(
              icon: Icons.error_outline_rounded,
              title: '榜单加载失败',
              message: '$e',
              actions: [
                FilledButton.tonalIcon(
                  onPressed: () =>
                      ref.invalidate(topListGroupsProvider(plugin.id)),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('重试'),
                ),
              ],
            ),
            data: (list) {
              if (list.isEmpty) {
                return const EmptyState(
                  icon: Icons.leaderboard_outlined,
                  title: '暂无榜单',
                  message: '该插件暂时没有返回榜单数据。',
                );
              }
              return Column(
                children: [
                  for (final group in list) ...[
                    SectionHeader(group.title),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: mediaGridDelegate(windowClass),
                      itemCount: group.items.length,
                      itemBuilder: (context, i) {
                        final item = group.items[i];
                        final desc = '${item['description'] ?? ''}';
                        final cover = trackArtwork(item);
                        return PosterCard(
                          title: '${item['title'] ?? '榜单'}',
                          subtitle: desc.isEmpty ? null : desc,
                          coverUrl: cover.isEmpty ? null : cover,
                          onTap: () => context.push('/toplists', extra: item),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
