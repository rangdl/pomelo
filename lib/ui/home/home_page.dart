import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/framework/pomelo_icons.dart';
import 'package:pomelo/core/routers/app_router.gr.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/core/models/metadata/metadata.dart';
import 'package:pomelo/ui/home/home_providers.dart';
import 'package:pomelo/ui/home/favorites_page.dart';
import 'package:pomelo/ui/music/album_detail_page.dart';
import 'package:pomelo/ui/music/artist_detail_page.dart';
import 'package:pomelo/ui/music/music_section.dart';
import 'package:pomelo/ui/music/playlist_detail_page.dart';
import 'package:pomelo/ui/music/providers/music_ui_providers.dart';
import 'package:pomelo/ui/music/widgets/app_chip.dart';
import 'package:pomelo/ui/music/widgets/cover_image.dart';
import 'package:pomelo/ui/music/widgets/play_all_button.dart';
import 'package:pomelo/ui/music/widgets/playable_track_tile.dart';
import 'package:pomelo/ui/root/root_providers.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Home 页面
///
/// 排行榜和歌单融合为一体，顶部 Tab 切换。
/// 桌面端：左侧分类导航 + 右侧内容
/// 移动端：顶部 Tab + 横向分类 chips + 内容
@RoutePage()
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 0 = 排行榜, 1 = 歌单
    final tabIndex = useState(0);
    // Home Tab 内联导航状态（默认列表/我的收藏/歌单详情）
    final homeNav = ref.watch(homeNavProvider);
    // 当前激活的 Tab 索引 — 用于判断 Home tab 是否处于前台
    final activeTabIndex = ref.watch(activeTabIndexProvider);
    // 移动端显示自带 AppBar（搜索/切换）；桌面端由 Root 标题栏统一承载
    final isMobile =
        MediaQuery.of(context).size.width < ResponsiveBreakpoints.mobile;

    // 同步内联导航状态到 Root 标题栏的返回按钮
    // 使用 Future.microtask 延迟到 build 后执行，避免在 build 期间修改 provider
    useEffect(() {
      final isHomeActive = activeTabIndex == 0;
      final hasInlineNav = homeNav is! HomeNavNormal;
      final shouldEnable = isHomeActive && hasInlineNav;
      Future.microtask(() {
        ref.read(rootCanPopProvider.notifier).set(shouldEnable);
        ref
            .read(rootPopCallbackProvider.notifier)
            .set(
              shouldEnable
                  ? () => ref.read(homeNavProvider.notifier).showNormal()
                  : null,
            );
      });
      return null;
    }, [activeTabIndex, homeNav]);

    // 内联视图：歌单详情
    if (homeNav is HomeNavPlaylist) {
      final p = homeNav.ref;
      return PlaylistDetailPage(
        playlistId: p.playlistId,
        sourceId: p.sourceId,
        playlistName: p.playlistName,
        coverUrl: p.coverUrl,
        creator: p.creator,
        onClose: () => ref.read(homeNavProvider.notifier).showNormal(),
      );
    }

    // 内联视图：歌手详情
    if (homeNav is HomeNavArtist) {
      final a = homeNav.ref;
      return ArtistDetailPage(
        artistId: a.artistId,
        sourceId: a.sourceId,
        artistName: a.artistName,
        coverUrl: a.coverUrl,
        albumCount: a.albumCount,
        onClose: () => ref.read(homeNavProvider.notifier).showNormal(),
        onOpenAlbum: (album) => ref
            .read(homeNavProvider.notifier)
            .showAlbum(
              AlbumRef(
                albumId: album.id,
                sourceId: a.sourceId,
                albumName: album.name,
                coverUrl: album.coverArt,
                artist: album.artist,
                year: album.year,
                songCount: album.songCount,
              ),
            ),
      );
    }

    // 内联视图：专辑详情
    if (homeNav is HomeNavAlbum) {
      final a = homeNav.ref;
      return AlbumDetailPage(
        albumId: a.albumId,
        sourceId: a.sourceId,
        albumName: a.albumName,
        coverUrl: a.coverUrl,
        artist: a.artist,
        year: a.year,
        songCount: a.songCount,
        onClose: () => ref.read(homeNavProvider.notifier).showNormal(),
      );
    }

    // 内联视图：我的收藏
    if (homeNav is HomeNavFavorites) {
      return FavoritesPage(
        onClose: () => ref.read(homeNavProvider.notifier).showNormal(),
      );
    }

    // 内联视图：默认列表
    if (homeNav is HomeNavDefaultList) {
      return _DefaultListView(
        onClose: () => ref.read(homeNavProvider.notifier).showNormal(),
      );
    }

    return Scaffold(
      headers: [
        // 移动端显示 AppBar；桌面端由 Root 标题栏统一承载搜索/切换
        if (isMobile)
          AppBar(
            leading: [const LibrarySwitchButton()],
            title: TextField(
              placeholder: const Text('搜索歌曲...'),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  context.pushRoute(MusicSearchRoute(keyword: value.trim()));
                }
              },
              features: [
                InputFeature.leading(const Icon(Icons.search, size: 18)),
              ],
            ),
            trailing: [const SourceSwitchButton()],
          ),
      ],
      child: Column(
        children: [
          // 移动端顶部快捷入口卡片
          if (isMobile) const _MobileQuickCard(),
          // 顶部 Tab 切换栏
          _HomeTabBar(tabIndex: tabIndex),
          const Divider(height: 1),
          // 内容区域
          Expanded(
            child: tabIndex.value == 0
                ? const _LeaderboardContent()
                : _PlaylistContent(
                    onOpenPlaylist: (p) =>
                        ref.read(homeNavProvider.notifier).showPlaylist(p),
                  ),
          ),
        ],
      ),
    );
  }
}

/// 顶部 Tab 切换栏
class _HomeTabBar extends ConsumerWidget {
  final ValueNotifier<int> tabIndex;

  const _HomeTabBar({required this.tabIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLeaderboard = tabIndex.value == 0;

    // 仅在排行榜 Tab 下获取曲目列表
    final tracks = isLeaderboard ? _watchLeaderboardTracks(ref) : <Track>[];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _TabItem(
            label: '排行榜',
            icon: Icons.leaderboard,
            isSelected: tabIndex.value == 0,
            colorScheme: colorScheme,
            onTap: () => tabIndex.value = 0,
          ),
          const Gap(8),
          _TabItem(
            label: '歌单',
            icon: Icons.queue_music,
            isSelected: tabIndex.value == 1,
            colorScheme: colorScheme,
            onTap: () => tabIndex.value = 1,
          ),
          const Spacer(),
          // 播放全部按钮 — 仅排行榜 Tab 下生效
          if (isLeaderboard) PlayAllButton(tracks: tracks),
        ],
      ),
    );
  }

  /// 获取当前选中排行榜的曲目列表
  List<Track> _watchLeaderboardTracks(WidgetRef ref) {
    final leaderboards = ref.watch(leaderboardsProvider).value ?? [];
    if (leaderboards.isEmpty) return [];

    final selectedId = ref.watch(selectedLeaderboardProvider);
    final effectiveId =
        (selectedId == null || !leaderboards.any((l) => l.id == selectedId))
        ? leaderboards.first.id
        : selectedId;

    return ref.watch(leaderboardTracksProvider(effectiveId)).value ?? [];
  }
}

/// Tab 项
class _TabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.muted.withAlpha(30),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? colorScheme.primaryForeground
                  : colorScheme.mutedForeground,
            ),
            const Gap(6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? colorScheme.primaryForeground
                    : colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================== 排行榜内容 ========================

/// 排行榜内容容器 — 响应式布局
class _LeaderboardContent extends HookConsumerWidget {
  const _LeaderboardContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardsAsync = ref.watch(leaderboardsProvider);
    final selectedId = ref.watch(selectedLeaderboardProvider);

    return leaderboardsAsync.when(
      data: (leaderboards) {
        if (leaderboards.isEmpty) {
          return _EmptyHint(text: '暂无排行榜');
        }

        final effectiveId =
            (selectedId == null || !leaderboards.any((l) => l.id == selectedId))
            ? leaderboards.first.id
            : selectedId;

        return Rx.layout(
          context,
          mobile: () => _LeaderboardMobile(
            leaderboards: leaderboards,
            selectedId: effectiveId,
          ),
          tablet: () => _LeaderboardDesktop(
            leaderboards: leaderboards,
            selectedId: effectiveId,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const _EmptyHint(text: '排行榜加载失败'),
    );
  }
}

/// 排行榜 — 移动端布局（横向 chips + 歌曲列表）
class _LeaderboardMobile extends ConsumerWidget {
  final List<Leaderboard> leaderboards;
  final String selectedId;

  const _LeaderboardMobile({
    required this.leaderboards,
    required this.selectedId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // 横向排行榜标签
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: leaderboards.length,
            separatorBuilder: (_, _) => const Gap(8),
            itemBuilder: (context, index) {
              final lb = leaderboards[index];
              final isSelected = lb.id == selectedId;
              return AppChip(
                label: lb.name,
                isSelected: isSelected,
                onTap: () => ref
                    .read(selectedLeaderboardProvider.notifier)
                    .select(lb.id),
                fill: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                borderRadius: 18,
                fontSize: 13,
              );
            },
          ),
        ),
        // 歌曲列表
        Expanded(child: _LeaderboardSongs(leaderboardId: selectedId)),
      ],
    );
  }
}

/// 排行榜 — 桌面端布局（左侧列表 + 右侧歌曲）
class _LeaderboardDesktop extends ConsumerWidget {
  final List<Leaderboard> leaderboards;
  final String selectedId;

  const _LeaderboardDesktop({
    required this.leaderboards,
    required this.selectedId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // 左侧排行榜列表
        SizedBox(
          width: 200,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: leaderboards.length,
            itemBuilder: (context, index) {
              final lb = leaderboards[index];
              final isSelected = lb.id == selectedId;
              return GestureDetector(
                onTap: () => ref
                    .read(selectedLeaderboardProvider.notifier)
                    .select(lb.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary.withAlpha(20)
                        : Colors.transparent,
                    border: Border(
                      left: BorderSide(
                        width: 3,
                        color: isSelected
                            ? colorScheme.primary
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  child: Text(
                    lb.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.foreground,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const VerticalDivider(width: 1),
        // 右侧歌曲列表
        Expanded(child: _LeaderboardSongs(leaderboardId: selectedId)),
      ],
    );
  }
}

/// 排行榜歌曲列表
class _LeaderboardSongs extends ConsumerWidget {
  final String leaderboardId;

  const _LeaderboardSongs({required this.leaderboardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(leaderboardTracksProvider(leaderboardId));
    final colorScheme = Theme.of(context).colorScheme;

    return songsAsync.when(
      data: (tracks) {
        if (tracks.isEmpty) {
          return Center(
            child: Text(
              '暂无歌曲',
              style: TextStyle(color: colorScheme.mutedForeground),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          itemCount: tracks.length,
          itemBuilder: (context, index) {
            final track = tracks[index];
            return PlayableTrackTile(
              track: track,
              index: index + 1,
              playlist: tracks,
              playlistIndex: index,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text(
          '加载失败: $err',
          style: TextStyle(color: colorScheme.mutedForeground),
        ),
      ),
    );
  }
}

// ======================== 歌单内容 ========================

/// 歌单内容容器 — 响应式布局
class _PlaylistContent extends HookConsumerWidget {
  final void Function(PlaylistRef) onOpenPlaylist;

  const _PlaylistContent({required this.onOpenPlaylist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(playlistCategoriesProvider);
    final selectedParentId = ref.watch(selectedPlaylistParentProvider);
    final selectedChildId = ref.watch(selectedPlaylistCategoryProvider);

    return categoriesAsync.when(
      data: (allCategories) {
        if (allCategories.isEmpty) return const _EmptyHint(text: '暂无歌单分类');

        final parentCategories = allCategories
            .where((c) => c.parentId == null)
            .toList();
        if (parentCategories.isEmpty) return const _EmptyHint(text: '暂无歌单分类');

        final activeParentId =
            (selectedParentId != null &&
                parentCategories.any((c) => c.id == selectedParentId))
            ? selectedParentId
            : parentCategories.first.id;
        final childCategories = allCategories
            .where((c) => c.parentId == activeParentId)
            .toList();
        final effectiveChildId =
            selectedChildId ??
            (childCategories.isNotEmpty ? childCategories.first.id : null);

        // 自动选中第一个子分类
        useEffect(() {
          // 检查当前选中的子分类是否属于当前一级分类
          final isChildInCurrentParent = childCategories.any(
            (c) => c.id == selectedChildId,
          );

          // 如果没有选中任何子分类，或者选中的子分类不属于当前一级分类
          if ((selectedChildId == null || !isChildInCurrentParent) &&
              childCategories.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(selectedPlaylistCategoryProvider.notifier)
                  .select(childCategories.first.id);
            });
          }
          return null;
        }, [activeParentId, selectedChildId, childCategories.length]);

        return Rx.layout(
          context,
          mobile: () => _PlaylistMobile(
            parentCategories: parentCategories,
            childCategories: childCategories,
            activeParentId: activeParentId,
            effectiveChildId: effectiveChildId,
            onOpenPlaylist: onOpenPlaylist,
          ),
          tablet: () => _PlaylistDesktop(
            allCategories: allCategories,
            parentCategories: parentCategories,
            activeParentId: activeParentId,
            effectiveChildId: effectiveChildId,
            onOpenPlaylist: onOpenPlaylist,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const _EmptyHint(text: '歌单分类加载失败'),
    );
  }
}

/// 歌单 — 移动端布局（横向 chips + 网格）
class _PlaylistMobile extends HookConsumerWidget {
  final List<PlaylistCategory> parentCategories;
  final List<PlaylistCategory> childCategories;
  final String activeParentId;
  final String? effectiveChildId;
  final void Function(PlaylistRef) onOpenPlaylist;

  const _PlaylistMobile({
    required this.parentCategories,
    required this.childCategories,
    required this.activeParentId,
    required this.effectiveChildId,
    required this.onOpenPlaylist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // 父分类横向 chips
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: parentCategories.length,
            separatorBuilder: (_, _) => const Gap(8),
            itemBuilder: (context, index) {
              final cat = parentCategories[index];
              final isSelected = cat.id == activeParentId;
              return AppChip(
                label: cat.name,
                isSelected: isSelected,
                onTap: () {
                  ref
                      .read(selectedPlaylistParentProvider.notifier)
                      .select(cat.id);
                  ref
                      .read(selectedPlaylistCategoryProvider.notifier)
                      .select(null);
                },
                fill: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                borderRadius: 18,
                fontSize: 13,
              );
            },
          ),
        ),
        // 子分类横向 chips
        if (childCategories.isNotEmpty)
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              itemCount: childCategories.length,
              separatorBuilder: (_, _) => const Gap(6),
              itemBuilder: (context, index) {
                final cat = childCategories[index];
                final isSelected = cat.id == effectiveChildId;
                return AppChip(
                  label: cat.name,
                  isSelected: isSelected,
                  onTap: () => ref
                      .read(selectedPlaylistCategoryProvider.notifier)
                      .select(cat.id),
                  fill: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  borderRadius: 14,
                  fontSize: 12,
                );
              },
            ),
          ),
        // 歌单网格
        Expanded(
          child: _PlaylistGridContent(
            childCategoryId: effectiveChildId,
            onOpenPlaylist: onOpenPlaylist,
          ),
        ),
      ],
    );
  }
}

/// 歌单 — 桌面端布局（左侧全部分类导航 + 右侧网格）
///
/// 左侧面板：一级分类作为标题，其下二级分类用 grid 布局排列。
/// 右侧：选中分类的歌单网格。
class _PlaylistDesktop extends HookConsumerWidget {
  final List<PlaylistCategory> allCategories;
  final List<PlaylistCategory> parentCategories;
  final String activeParentId;
  final String? effectiveChildId;
  final void Function(PlaylistRef) onOpenPlaylist;

  const _PlaylistDesktop({
    required this.allCategories,
    required this.parentCategories,
    required this.activeParentId,
    required this.effectiveChildId,
    required this.onOpenPlaylist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // 左侧分类面板（全部展示）
        SizedBox(
          width: 240,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: parentCategories.length,
            itemBuilder: (context, index) {
              final parent = parentCategories[index];
              final isParentActive = parent.id == activeParentId;
              final children = allCategories
                  .where((c) => c.parentId == parent.id)
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 一级分类标题
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      parent.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isParentActive
                            ? colorScheme.primary
                            : colorScheme.mutedForeground,
                      ),
                    ),
                  ),
                  // 二级分类 grid
                  if (children.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                        bottom: 8,
                      ),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: children.map((child) {
                          final isChildSelected = child.id == effectiveChildId;
                          return GestureDetector(
                            onTap: () {
                              ref
                                  .read(selectedPlaylistParentProvider.notifier)
                                  .select(parent.id);
                              ref
                                  .read(
                                    selectedPlaylistCategoryProvider.notifier,
                                  )
                                  .select(child.id);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isChildSelected
                                    ? colorScheme.primary
                                    : colorScheme.muted.withAlpha(30),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                child.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isChildSelected
                                      ? colorScheme.primaryForeground
                                      : colorScheme.foreground,
                                  fontWeight: isChildSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const VerticalDivider(width: 1),
        // 右侧歌单网格
        Expanded(
          child: _PlaylistGridContent(
            childCategoryId: effectiveChildId,
            onOpenPlaylist: onOpenPlaylist,
          ),
        ),
      ],
    );
  }
}

/// 歌单网格内容（含排序）
class _PlaylistGridContent extends HookConsumerWidget {
  final String? childCategoryId;
  final void Function(PlaylistRef) onOpenPlaylist;

  const _PlaylistGridContent({
    required this.childCategoryId,
    required this.onOpenPlaylist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsByCategoryProvider);
    final sortOrdersAsync = ref.watch(playlistSortOrdersProvider);
    final selectedSortId = ref.watch(selectedPlaylistSortProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (childCategoryId == null) {
      return Center(
        child: Text(
          '请选择一个子分类',
          style: TextStyle(color: colorScheme.mutedForeground),
        ),
      );
    }

    return Column(
      children: [
        // 排序方式
        sortOrdersAsync.when(
          data: (sortOrders) {
            if (sortOrders.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 3,
                ),
                itemCount: sortOrders.length,
                separatorBuilder: (_, _) => const Gap(6),
                itemBuilder: (context, index) {
                  final sort = sortOrders[index];
                  final isSelected =
                      sort.id == (selectedSortId ?? sortOrders.first.id);
                  return AppChip(
                    label: sort.name,
                    isSelected: isSelected,
                    onTap: () => ref
                        .read(selectedPlaylistSortProvider.notifier)
                        .select(sort.id),
                    fill: false,
                    selectedColor: colorScheme.secondary,
                    icon: Icons.sort,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    borderRadius: 14,
                    fontSize: 12,
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
        // 歌单网格
        Expanded(
          child: playlistsAsync.when(
            data: (data) {
              if (data.items.isEmpty) {
                return Center(
                  child: Text(
                    '暂无歌单',
                    style: TextStyle(color: colorScheme.mutedForeground),
                  ),
                );
              }
              return _PlaylistGrid(
                playlists: data.items,
                onOpenPlaylist: onOpenPlaylist,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Text(
                '加载失败: $err',
                style: TextStyle(color: colorScheme.mutedForeground),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 歌单网格（响应式列数）
class _PlaylistGrid extends StatelessWidget {
  final List<Playlist> playlists;
  final void Function(PlaylistRef) onOpenPlaylist;

  const _PlaylistGrid({required this.playlists, required this.onOpenPlaylist});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount;
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
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: playlists.length,
          itemBuilder: (context, index) => _PlaylistCard(
            playlist: playlists[index],
            onOpenPlaylist: onOpenPlaylist,
          ),
        );
      },
    );
  }
}

/// 单个歌单卡片
class _PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final void Function(PlaylistRef) onOpenPlaylist;

  const _PlaylistCard({required this.playlist, required this.onOpenPlaylist});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => onOpenPlaylist(
        PlaylistRef(
          playlistId: (playlist.meta?['id'] as String?) ?? playlist.id,
          sourceId: playlist.source?.id ?? '',
          playlistName: playlist.name,
          coverUrl: playlist.coverArt,
          creator: playlist.owner ?? '',
        ),
      ),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: CoverImage(
                  coverArt: playlist.coverArt,
                  colorScheme: colorScheme,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
              child: Text(
                playlist.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: colorScheme.foreground),
              ),
            ),
            if ((playlist.owner ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Text(
                  playlist.owner ?? '',
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

// ======================== 移动端快捷入口 ========================

/// 移动端首页顶部快捷入口卡片
///
/// 横向排列三个图标按钮：默认列表 / 我的收藏 / 我的歌单。
class _MobileQuickCard extends HookConsumerWidget {
  const _MobileQuickCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: _QuickItem(
                  icon: PomeloIcons.list,
                  label: '默认',
                  colorScheme: colorScheme,
                  onTap: () =>
                      ref.read(homeNavProvider.notifier).showDefaultList(),
                ),
              ),
              Expanded(
                child: _QuickItem(
                  icon: PomeloIcons.heart,
                  label: '收藏',
                  colorScheme: colorScheme,
                  onTap: () =>
                      ref.read(homeNavProvider.notifier).showFavorites(),
                ),
              ),
              Expanded(
                child: _QuickItem(
                  icon: PomeloIcons.playlist,
                  label: '歌单',
                  colorScheme: colorScheme,
                  onTap: () => _showUserPlaylistsSheet(context, ref),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 弹出底部 Sheet 展示用户歌单列表
  void _showUserPlaylistsSheet(BuildContext context, WidgetRef ref) {
    openSheet(
      context: context,
      position: OverlayPosition.bottom,
      draggable: true,
      builder: (context) => _UserPlaylistsSheet(
        onSelected: (playlistRef) {
          closeOverlay(context);
          ref.read(homeNavProvider.notifier).showPlaylist(playlistRef);
        },
      ),
    );
  }
}

// ======================== 快捷入口单项 ========================

/// 快捷入口单项
class _QuickItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _QuickItem({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: colorScheme.primary),
          const Gap(4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colorScheme.mutedForeground),
          ),
        ],
      ),
    );
  }
}

/// 用户歌单列表 Sheet（移动端）
class _UserPlaylistsSheet extends HookConsumerWidget {
  final void Function(PlaylistRef) onSelected;

  const _UserPlaylistsSheet({required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(userListsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('我的歌单'),
          trailing: [
            GhostButton(
              density: ButtonDensity.icon,
              onPressed: () => closeOverlay(context),
              child: const Icon(Icons.close, size: 20),
            ),
          ],
        ),
      ],
      child: listsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            '加载失败: $err',
            style: TextStyle(color: colorScheme.mutedForeground),
          ),
        ),
        data: (data) {
          final playlists = data.userPlaylists;
          if (playlists.isEmpty) {
            return Center(
              child: Text(
                '暂无歌单',
                style: TextStyle(color: colorScheme.mutedForeground),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: playlists.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = playlists[index];
              return Card(
                child: ListTile(
                  leading: CoverImage(
                    coverArt: p.coverArt,
                    colorScheme: colorScheme,
                    size: 48,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  title: Text(p.name),
                  subtitle: p.owner != null && p.owner!.isNotEmpty
                      ? Text(p.owner ?? '')
                      : null,
                  onTap: () => onSelected(
                    PlaylistRef(
                      playlistId: (p.meta?['id'] as String?) ?? p.id,
                      sourceId: p.source?.id ?? '',
                      playlistName: p.name,
                      coverUrl: p.coverArt,
                      creator: p.owner ?? '',
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ======================== 默认列表视图 ========================

/// 默认列表视图（内联渲染）
///
/// 展示 [userListsProvider] 的 defaultTracks。
class _DefaultListView extends HookConsumerWidget {
  final VoidCallback? onClose;

  const _DefaultListView({this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(userListsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile =
        MediaQuery.of(context).size.width < ResponsiveBreakpoints.mobile;

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            if (isMobile)
              GhostButton(
                onPressed:
                    onClose ??
                    () => ref.read(homeNavProvider.notifier).showNormal(),
                child: const Icon(Icons.arrow_back, size: 20),
              ),
          ],
          title: const Text('默认列表'),
        ),
        const Divider(),
      ],
      child: listsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            '加载失败: $err',
            style: TextStyle(color: colorScheme.mutedForeground),
          ),
        ),
        data: (data) {
          final tracks = data.defaultTracks;
          if (tracks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PomeloIcons.music,
                    size: 48,
                    color: colorScheme.mutedForeground,
                  ),
                  const Gap(12),
                  Text(
                    '暂无歌曲',
                    style: TextStyle(color: colorScheme.mutedForeground),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Text(
                      '共 ${tracks.length} 首',
                      style: TextStyle(color: colorScheme.mutedForeground),
                    ),
                    const Gap(12),
                    PlayAllButton(tracks: tracks),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    return PlayableTrackTile(
                      track: track,
                      index: index + 1,
                      playlist: tracks,
                      playlistIndex: index,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ======================== 通用组件 ========================

/// 空状态提示
class _EmptyHint extends StatelessWidget {
  final String text;

  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.mutedForeground),
      ),
    );
  }
}
