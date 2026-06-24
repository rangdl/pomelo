import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/routers/app_router.gr.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/modules/music/model/playlist.dart';
import 'package:pomelo/ui/music/providers/music_ui_providers.dart';
import 'package:pomelo/ui/music/widgets/app_chip.dart';
import 'package:pomelo/ui/music/widgets/cover_placeholder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 歌单版块组件
///
/// 展示歌单分类导航和对应分类下的歌单列表。
/// 分类分两级：父分类（如"风格""排行榜"）和子分类（如"流行""网络热歌"）。
/// 仅当有子分类时显示子分类导航行。
class PlaylistSection extends HookConsumerWidget {
  const PlaylistSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(playlistCategoriesProvider);
    final selectedParentId = ref.watch(selectedPlaylistParentProvider);
    final selectedChildId = ref.watch(selectedPlaylistCategoryProvider);
    final playlistsAsync = ref.watch(playlistsByCategoryProvider);
    final sortOrdersAsync = ref.watch(playlistSortOrdersProvider);
    final selectedSortId = ref.watch(selectedPlaylistSortProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return categoriesAsync.when(
      data: (allCategories) {
        if (allCategories.isEmpty) return const SizedBox.shrink();

        final parentCategories =
            allCategories.where((c) => c.parentId == null).toList();
        if (parentCategories.isEmpty) return const SizedBox.shrink();

        // 默认选中第一个父分类
        final activeParentId = selectedParentId ?? parentCategories.first.id;

        // 当前选中父分类下的子分类
        final childCategories = allCategories
            .where((c) => c.parentId == activeParentId)
            .toList();

        // 默认选中第一个子分类
        final effectiveChildId = selectedChildId ??
            (childCategories.isNotEmpty ? childCategories.first.id : null);
        useEffect(() {
          if (selectedChildId == null && childCategories.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(selectedPlaylistCategoryProvider.notifier)
                  .select(childCategories.first.id);
            });
          }
          return null;
        }, [activeParentId, selectedChildId, childCategories.length]);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 12),
              child: Text(
                '歌单推荐',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.foreground,
                ),
              ),
            ),
            // 父分类标签行（点击仅切换子分类，不触发歌单查询）
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: parentCategories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = parentCategories[index];
                  final isSelected = cat.id == activeParentId;
                  return AppChip(
                    label: cat.name,
                    isSelected: isSelected,
                    onTap: () {
                      // 切换父分类：更新父分类选中态，清空子分类选中（不触发查询）
                      ref
                          .read(selectedPlaylistParentProvider.notifier)
                          .select(cat.id);
                      ref
                          .read(selectedPlaylistCategoryProvider.notifier)
                          .select(null);
                    },
                    fill: true,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    borderRadius: 18,
                    fontSize: 13,
                  );
                },
              ),
            ),
            // 子分类标签行（点击触发歌单查询）
            if (childCategories.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 30,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: childCategories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final cat = childCategories[index];
                    final isSelected = cat.id == effectiveChildId;
                    return AppChip(
                      label: cat.name,
                      isSelected: isSelected,
                      onTap: () {
                        // 点击子分类：触发歌单查询
                        ref
                            .read(selectedPlaylistCategoryProvider.notifier)
                            .select(cat.id);
                      },
                      fill: false,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      borderRadius: 14,
                      fontSize: 12,
                    );
                  },
                ),
              ),
            ],
            // 排序方式选择行
            sortOrdersAsync.when(
              data: (sortOrders) {
                if (sortOrders.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    height: 28,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: sortOrders.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 4),
                      itemBuilder: (context, index) {
                        final sort = sortOrders[index];
                        final isSelected = sort.id == (selectedSortId ?? sortOrders.first.id);
                        return AppChip(
                          label: sort.name,
                          isSelected: isSelected,
                          onTap: () {
                            ref
                                .read(selectedPlaylistSortProvider.notifier)
                                .select(sort.id);
                          },
                          fill: false,
                          selectedColor:
                              Theme.of(context).colorScheme.secondary,
                          icon: Icons.sort,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          borderRadius: 14,
                          fontSize: 12,
                        );
                      },
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            // 歌单网格（仅当选中子分类时显示）
            if (effectiveChildId != null)
              playlistsAsync.when(
                data: (data) {
                  if (data.items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          '暂无歌单',
                          style: TextStyle(color: colorScheme.mutedForeground),
                        ),
                      ),
                    );
                  }
                  return _PlaylistGrid(playlists: data.items);
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      '加载失败: $err',
                      style: TextStyle(color: colorScheme.mutedForeground),
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    '请选择一个子分类',
                    style: TextStyle(color: colorScheme.mutedForeground),
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

/// 歌单网格（响应式列数布局）
class _PlaylistGrid extends StatelessWidget {
  final List<Playlist> playlists;

  const _PlaylistGrid({required this.playlists});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 响应式列数，对齐项目 Rx 断点：
        // < 600px (mobile): 2 列
        // 600~1024px (tablet): 3 列
        // 1024~1440px (desktop): 4 列
        // >= 1440px (tv): 5 列
        final width = constraints.maxWidth;
        final crossAxisCount;
        if (width < ResponsiveBreakpoints.mobile) {
          crossAxisCount = 2;
        } else if (width < ResponsiveBreakpoints.tablet) {
          crossAxisCount = 3;
        } else if (width < ResponsiveBreakpoints.desktop) {
          crossAxisCount = 4;
        } else {
          crossAxisCount = 5;
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            return _PlaylistCard(playlist: playlists[index]);
          },
        );
      },
    );
  }
}

/// 单个歌单卡片
class _PlaylistCard extends StatelessWidget {
  final Playlist playlist;

  const _PlaylistCard({required this.playlist});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        context.pushRoute(PlaylistDetailRoute(
          playlistId: (playlist.meta?['id'] as String?) ?? playlist.id,
          sourceId: playlist.source.id,
          playlistName: playlist.name,
          coverUrl: playlist.coverUrl,
          creator: playlist.creator,
        ));
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                  child: playlist.coverUrl != null &&
                          playlist.coverUrl!.isNotEmpty
                      ? Image.network(
                          playlist.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => CoverPlaceholder(
                            colorScheme: colorScheme,
                          ),
                        )
                      : CoverPlaceholder(colorScheme: colorScheme),
                ),
              ),
            ),
            // 歌单名称
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
              child: Text(
                playlist.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: colorScheme.foreground),
              ),
            ),
            // 创建者
            if (playlist.creator.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Text(
                  playlist.creator,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.mutedForeground,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
