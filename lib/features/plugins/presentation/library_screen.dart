import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/layout/window_class.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/top_toast.dart';
import '../../../shared/widgets/widgets.dart';
import '../../playback/application/player_actions.dart';
import '../../playback/presentation/player_sheet.dart';
import 'library_providers.dart';
import 'track_more.dart';
import '../../../shared/settings/open_player_on_play.dart';

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
      // Builder 提供 DefaultTabController 之下的 context，
      // 否则在 build 里直接 DefaultTabController.of(context) 会找不到控制器。
      child: Builder(
        builder: (context) => Column(
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
                // 「清空」只对当前 tab 有意义:收藏页清收藏,历史页清历史。
                // 收进更多菜单并二次确认,避免误触清空全部数据。
                AnimatedBuilder(
                  animation: DefaultTabController.of(context),
                  builder: (context, _) {
                    final onHistory =
                        DefaultTabController.of(context).index == 1;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: PopupMenuButton<String>(
                        tooltip: '更多',
                        icon: const Icon(Icons.more_horiz_rounded),
                        position: PopupMenuPosition.under,
                        onSelected: (_) async {
                          final confirmed = await showAppConfirm(
                            context: context,
                            title: onHistory ? '清空播放历史' : '清空收藏',
                            message: onHistory
                                ? '将移除全部播放记录，此操作无法撤销。'
                                : '将移除全部收藏，此操作无法撤销。',
                            confirmLabel: '清空',
                            danger: true,
                          );
                          if (!confirmed) return;
                          if (onHistory) {
                            await ref.read(historyProvider.notifier).clear();
                          } else {
                            await ref.read(favoritesProvider.notifier).clear();
                          }
                          if (context.mounted) {
                            TopToast.show(onHistory ? '已清空播放历史' : '已清空收藏');
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'clear',
                            child: Text(onHistory ? '清空播放历史' : '清空收藏'),
                          ),
                        ],
                      ),
                    );
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
      error: (e, _) => EmptyState(
        icon: Icons.error_outline_rounded,
        title: '加载失败',
        message: '$e',
        actions: [
          FilledButton.tonalIcon(
            onPressed: () {
              if (tab == _ListTab.favorites) {
                ref.invalidate(favoritesProvider);
              } else {
                ref.invalidate(historyProvider);
              }
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('重试'),
          ),
        ],
      ),
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
                dividerIndent: AppSpacing.dividerIndentTrack,
                children: [
                  for (final (i, item) in items.indexed)
                    TrackTile(
                      item: item,
                      trailing: TrackMoreButton(item: item),
                      onTap: () async {
                        try {
                          await ref
                              .read(playerActionsProvider)
                              .playFromList(items, i);
                          if (context.mounted &&
                              ref.read(openPlayerOnPlayProvider)) {
                            showPlayerSheet(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            TopToast.error('播放失败: $e');
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
