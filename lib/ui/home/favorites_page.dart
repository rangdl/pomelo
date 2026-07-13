/// 我的收藏页面
///
/// 顶部使用 歌曲/歌手/专辑 三个 Tab 切换：
/// - 歌曲：使用 [userListsProvider] 的 loveTracks
/// - 歌手：使用 [favoriteArtistsProvider]
/// - 专辑：使用 [favoriteAlbumsProvider]
library;

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/framework/pomelo_icons.dart';
import 'package:pomelo/core/models/metadata/metadata.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/ui/home/home_providers.dart';
import 'package:pomelo/ui/music/providers/music_ui_providers.dart';
import 'package:pomelo/ui/music/widgets/cover_image.dart';
import 'package:pomelo/ui/music/widgets/play_all_button.dart';
import 'package:pomelo/ui/music/widgets/playable_track_tile.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 我的收藏页面（内联渲染）
///
/// 通过 [onClose] 回调关闭返回默认视图，与 Home Tab 内联导航协议一致。
class FavoritesPage extends HookConsumerWidget {
  /// 关闭回调（返回默认视图）
  final VoidCallback? onClose;

  const FavoritesPage({super.key, this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = useState(0);
    final colorScheme = Theme.of(context).colorScheme;
    // 桌面端由 Root 标题栏承载返回按钮，内联页面不再显示
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
          title: const Text('我的收藏'),
        ),
        const Divider(),
      ],
      child: Column(
        children: [
          // 顶部 Tab 切换
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _FavoritesTabItem(
                  label: '歌曲',
                  icon: PomeloIcons.music,
                  isSelected: tabIndex.value == 0,
                  colorScheme: colorScheme,
                  onTap: () => tabIndex.value = 0,
                ),
                const Gap(8),
                _FavoritesTabItem(
                  label: '歌手',
                  icon: PomeloIcons.artist,
                  isSelected: tabIndex.value == 1,
                  colorScheme: colorScheme,
                  onTap: () => tabIndex.value = 1,
                ),
                const Gap(8),
                _FavoritesTabItem(
                  label: '专辑',
                  icon: PomeloIcons.album,
                  isSelected: tabIndex.value == 2,
                  colorScheme: colorScheme,
                  onTap: () => tabIndex.value = 2,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: tabIndex.value == 0
                ? const _FavoriteSongsTab()
                : tabIndex.value == 1
                ? const _FavoriteArtistsTab()
                : const _FavoriteAlbumsTab(),
          ),
        ],
      ),
    );
  }
}

/// Tab 项
class _FavoritesTabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _FavoritesTabItem({
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

/// 收藏歌曲 Tab
class _FavoriteSongsTab extends HookConsumerWidget {
  const _FavoriteSongsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(userListsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return listsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text(
          '加载失败: $err',
          style: TextStyle(color: colorScheme.mutedForeground),
        ),
      ),
      data: (data) {
        final tracks = data.loveTracks;
        if (tracks.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PomeloIcons.heart,
                  size: 48,
                  color: colorScheme.mutedForeground,
                ),
                const Gap(12),
                Text(
                  '暂无收藏歌曲',
                  style: TextStyle(color: colorScheme.mutedForeground),
                ),
              ],
            ),
          );
        }

        return Rx.layout(
          context,
          mobile: () => ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: PlayAllButton(tracks: tracks),
                ),
              ),
              ...tracks.asMap().entries.map(
                (e) => PlayableTrackTile(
                  track: e.value,
                  index: e.key + 1,
                  playlist: tracks,
                  playlistIndex: e.key,
                ),
              ),
            ],
          ),
          tablet: () => Column(
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
          ),
        );
      },
    );
  }
}

/// 收藏歌手 Tab
class _FavoriteArtistsTab extends HookConsumerWidget {
  const _FavoriteArtistsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistsAsync = ref.watch(favoriteArtistsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return artistsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text(
          '加载失败: $err',
          style: TextStyle(color: colorScheme.mutedForeground),
        ),
      ),
      data: (artists) {
        if (artists.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PomeloIcons.artist,
                  size: 48,
                  color: colorScheme.mutedForeground,
                ),
                const Gap(12),
                Text(
                  '暂无收藏歌手',
                  style: TextStyle(color: colorScheme.mutedForeground),
                ),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            int crossAxisCount;
            if (width < ResponsiveBreakpoints.mobile) {
              crossAxisCount = 3;
            } else if (width < ResponsiveBreakpoints.tablet) {
              crossAxisCount = 4;
            } else if (width < ResponsiveBreakpoints.desktop) {
              crossAxisCount = 5;
            } else {
              crossAxisCount = 6;
            }
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: artists.length,
              itemBuilder: (context, index) =>
                  _ArtistCard(artist: artists[index]),
            );
          },
        );
      },
    );
  }
}

/// 歌手卡片
class _ArtistCard extends ConsumerWidget {
  final Artist artist;

  const _ArtistCard({required this.artist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => ref
          .read(homeNavProvider.notifier)
          .showArtist(
            ArtistRef(
              artistId: artist.id,
              sourceId: artist.source?.id ?? '',
              artistName: artist.name,
              coverUrl: artist.coverArt ?? artist.artistImageUrl,
              albumCount: artist.albumCount,
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
                  coverArt: artist.coverArt ?? artist.artistImageUrl,
                  colorScheme: colorScheme,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Text(
                artist.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: colorScheme.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 收藏专辑 Tab
class _FavoriteAlbumsTab extends HookConsumerWidget {
  const _FavoriteAlbumsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsAsync = ref.watch(favoriteAlbumsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return albumsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text(
          '加载失败: $err',
          style: TextStyle(color: colorScheme.mutedForeground),
        ),
      ),
      data: (albums) {
        if (albums.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PomeloIcons.album,
                  size: 48,
                  color: colorScheme.mutedForeground,
                ),
                const Gap(12),
                Text(
                  '暂无收藏专辑',
                  style: TextStyle(color: colorScheme.mutedForeground),
                ),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            int crossAxisCount;
            if (width < ResponsiveBreakpoints.mobile) {
              crossAxisCount = 3;
            } else if (width < ResponsiveBreakpoints.tablet) {
              crossAxisCount = 4;
            } else if (width < ResponsiveBreakpoints.desktop) {
              crossAxisCount = 5;
            } else {
              crossAxisCount = 6;
            }
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: albums.length,
              itemBuilder: (context, index) => _AlbumCard(album: albums[index]),
            );
          },
        );
      },
    );
  }
}

/// 专辑卡片
class _AlbumCard extends ConsumerWidget {
  final Album album;

  const _AlbumCard({required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => ref
          .read(homeNavProvider.notifier)
          .showAlbum(
            AlbumRef(
              albumId: album.id,
              sourceId: album.source?.id ?? '',
              albumName: album.name,
              coverUrl: album.coverArt,
              artist: album.artist,
              year: album.year,
              songCount: album.songCount,
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
                  coverArt: album.coverArt,
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
                album.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: colorScheme.foreground),
              ),
            ),
            if ((album.artist ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Text(
                  album.artist ?? '',
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
