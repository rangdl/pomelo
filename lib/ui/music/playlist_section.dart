import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/routers/app_router.gr.dart';
import 'package:pomelo/modules/music/model/playlist.dart';
import 'package:pomelo/ui/music/providers/music_ui_providers.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 歌单版块组件
///
/// 展示歌单分类导航和对应分类下的歌单列表。
/// 分类分两级：父分类（如"风格""排行榜"）和子分类（如"流行""网络热歌"）。
/// 仅当有子分类时显示子分类导航行。
class PlaylistSection extends ConsumerWidget {
  const PlaylistSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(playlistCategoriesProvider);
    final selectedParentId = ref.watch(selectedPlaylistParentProvider);
    final selectedChildId = ref.watch(selectedPlaylistCategoryProvider);
    final playlistsAsync = ref.watch(playlistsByCategoryProvider);
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
                  return _CategoryChip(
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
                    final isSelected = cat.id == selectedChildId;
                    return _SubCategoryChip(
                      label: cat.name,
                      isSelected: isSelected,
                      onTap: () {
                        // 点击子分类：触发歌单查询
                        ref
                            .read(selectedPlaylistCategoryProvider.notifier)
                            .select(cat.id);
                      },
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
            // 歌单网格（仅当选中子分类时显示）
            if (selectedChildId != null)
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

/// 父分类标签（较大，高亮选中态）
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.muted,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? colorScheme.primaryForeground : colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }
}

/// 子分类标签（较小，点击后触发歌单查询）
class _SubCategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubCategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.15)
              : colorScheme.muted.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: colorScheme.primary.withValues(alpha: 0.5))
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? colorScheme.primary
                : colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }
}

/// 歌单网格（2列布局）
class _PlaylistGrid extends StatelessWidget {
  final List<Playlist> playlists;

  const _PlaylistGrid({required this.playlists});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 响应式：宽度足够时显示3列，否则2列
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
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
                          errorBuilder: (_, _, _) => _CoverPlaceholder(
                            colorScheme: colorScheme,
                          ),
                        )
                      : _CoverPlaceholder(colorScheme: colorScheme),
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

/// 封面占位图（无图片时展示）
class _CoverPlaceholder extends StatelessWidget {
  final ColorScheme colorScheme;

  const _CoverPlaceholder({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.muted,
      child: Center(
        child: Icon(
          Icons.queue_music,
          size: 36,
          color: colorScheme.mutedForeground,
        ),
      ),
    );
  }
}
