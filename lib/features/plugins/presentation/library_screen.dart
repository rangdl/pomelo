import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/layout/window_class.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../../playback/application/player_actions.dart';
import '../../playback/presentation/player_sheet.dart';
import 'library_providers.dart';

/// 我的：收藏与播放历史。
///
/// 外壳 [AdaptiveAppShell] 已提供 AppBar（标题「我的」），此页不再自套
/// Scaffold 的 AppBar，只放 TabBar + 内容。
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: TabBar(
                  tabs: [
                    Tab(text: '收藏'),
                    Tab(text: '最近播放'),
                  ],
                ),
              ),
              IconButton(
                tooltip: '清空历史',
                icon: const Icon(Icons.delete_sweep_rounded),
                onPressed: () async {
                  await ref.read(historyProvider.notifier).clear();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已清空播放历史')),
                    );
                  }
                },
              ),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _SongList(tab: _ListTab.favorites),
                _SongList(tab: _ListTab.history),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _ListTab { favorites, history }

class _SongList extends ConsumerWidget {
  const _SongList({required this.tab});

  final _ListTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = tab == _ListTab.favorites
        ? ref.watch(favoritesProvider)
        : ref.watch(historyProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
      data: (items) {
        if (items.isEmpty) {
          return EmptyState(
            icon: tab == _ListTab.favorites
                ? Icons.favorite_border_rounded
                : Icons.history_rounded,
            title: tab == _ListTab.favorites ? '还没有收藏' : '还没有播放记录',
            message: tab == _ListTab.favorites
                ? '在播放页点 ♥ 收藏喜欢的歌。'
                : '播放过的歌曲会出现在这里。',
          );
        }
        return CenteredMaxWidth(
          child: ListView(
            padding: AppSpacing.pagePadding,
            children: [
              GroupCard(
                children: [
                  for (final (i, item) in items.indexed)
                    SettingsItem(
                      icon: tab == _ListTab.favorites
                          ? Icons.favorite_rounded
                          : Icons.history_rounded,
                      title: '${item['title'] ?? '未知'}',
                      subtitle: '${item['artist'] ?? ''}',
                      onTap: () async {
                        try {
                          await ref
                              .read(playerActionsProvider)
                              .playFromList(items, i);
                          if (context.mounted) showPlayerSheet(context);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('播放失败: $e')),
                            );
                          }
                        }
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
