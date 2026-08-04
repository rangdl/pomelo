/// 歌手详情页面
///
/// 展示歌手信息（封面、名称、专辑数量）及其歌曲列表与专辑列表。
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/core/models/metadata/metadata.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/ui/music/track_list.dart';
import 'package:pomelo/ui/music/widgets/app_chip.dart';
import 'package:pomelo/ui/music/widgets/cover_image.dart';
import 'package:pomelo/ui/music/widgets/play_all_button.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 歌手专辑列表 Provider
///
/// 根据 (sourceId, artistId) 获取歌手的专辑列表。
final artistAlbumsProvider =
    FutureProvider.family<List<Album>, ({String sourceId, String artistId})>((
      ref,
      params,
    ) async {
      final service = await ref.watch(
        musicServerProvider(params.sourceId).future,
      );
      if (service == null) return [];
      try {
        return await service.getArtistAlbums(params.artistId);
      } catch (_) {
        return [];
      }
    });

/// 歌手歌曲列表 Provider
///
/// 根据 (sourceId, artistId, order) 获取歌手的歌曲列表。
/// [order] 排序方式：'hot'（热度）或 'time'（时间）。
final artistSongsProvider =
    FutureProvider.family<
      List<Track>,
      ({String sourceId, String artistId, String order})
    >((ref, params) async {
      final service = await ref.watch(
        musicServerProvider(params.sourceId).future,
      );
      if (service == null) return [];
      try {
        final result = await service.getArtistSongs(
          params.artistId,
          order: params.order,
        );
        return result.items;
      } catch (_) {
        return [];
      }
    });

/// 歌手详情页面
@RoutePage()
class ArtistDetailPage extends HookConsumerWidget {
  final String artistId;
  final String sourceId;
  final String artistName;
  final String? coverUrl;
  final int albumCount;

  /// 关闭回调。
  ///
  /// 当此页面以非路由方式（如嵌入到首页 Tab 内容区）渲染时，
  /// 通过该回调通知宿主关闭。若为 null，则使用 `context.router.maybePop()`。
  final VoidCallback? onClose;

  /// 打开专辑详情回调。
  ///
  /// 点击专辑卡片时触发。若为 null，则专辑卡片不可点击。
  final void Function(Album album)? onOpenAlbum;

  const ArtistDetailPage({
    super.key,
    required this.artistId,
    required this.sourceId,
    required this.artistName,
    this.coverUrl,
    this.albumCount = 0,
    this.onClose,
    this.onOpenAlbum,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tab 切换：0 = 歌曲，1 = 专辑
    final tabIndex = useState(0);
    // 歌曲排序方式：'hot' 或 'time'
    final songOrder = useState('hot');

    final albumsAsync = ref.watch(
      artistAlbumsProvider((sourceId: sourceId, artistId: artistId)),
    );
    final songsAsync = ref.watch(
      artistSongsProvider((
        sourceId: sourceId,
        artistId: artistId,
        order: songOrder.value,
      )),
    );
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
                onPressed: onClose ?? () => context.router.maybePop(),
                child: const Icon(Icons.arrow_back, size: 20),
              ),
          ],
          title: Text(artistName, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        const Divider(),
      ],
      child: albumsAsync.when(
        data: (albums) {
          // 歌手头部信息
          final header = _ArtistHeader(
            name: artistName,
            coverUrl: coverUrl,
            albumCount: albums.isNotEmpty ? albums.length : albumCount,
          );

          // Tab 切换行 + 排序切换
          final tabRow = _TabBar(
            tabIndex: tabIndex.value,
            onTabChanged: (i) => tabIndex.value = i,
            showSort: tabIndex.value == 0,
            songOrder: songOrder.value,
            onSortChanged: (o) => songOrder.value = o,
            colorScheme: colorScheme,
          );

          // 内容区
          final content = tabIndex.value == 0
              ? songsAsync.when(
                  data: (tracks) => _SongsContent(tracks: tracks),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _ErrorView(
                    message: '加载失败: $e',
                    onRetry: () => ref.invalidate(
                      artistSongsProvider((
                        sourceId: sourceId,
                        artistId: artistId,
                        order: songOrder.value,
                      )),
                    ),
                    colorScheme: colorScheme,
                  ),
                )
              : _AlbumsContent(
                  albums: albums,
                  onOpenAlbum: onOpenAlbum,
                  colorScheme: colorScheme,
                );

          return Rx.layout(
            context,
            // 移动端：纵向布局（歌手信息在上，Tab + 内容在下）
            mobile: () => Column(
              children: [
                Padding(padding: const EdgeInsets.all(12), child: header),
                tabRow,
                const Divider(height: 1),
                Expanded(child: content),
              ],
            ),
            // 桌面端（tablet 及以上）：左侧歌手信息，右侧 Tab + 内容
            tablet: () => Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 280,
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [header],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Column(
                    children: [
                      tabRow,
                      const Divider(height: 1),
                      Expanded(child: content),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: colorScheme.destructive,
              ),
              const Gap(12),
              Text('加载失败: $err'),
              const Gap(12),
              GhostButton(
                onPressed: () {
                  ref.invalidate(
                    artistAlbumsProvider((
                      sourceId: sourceId,
                      artistId: artistId,
                    )),
                  );
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tab 切换栏（歌曲 / 专辑）+ 排序切换
class _TabBar extends StatelessWidget {
  final int tabIndex;
  final ValueChanged<int> onTabChanged;
  final bool showSort;
  final String songOrder;
  final ValueChanged<String> onSortChanged;
  final ColorScheme colorScheme;

  const _TabBar({
    required this.tabIndex,
    required this.onTabChanged,
    required this.showSort,
    required this.songOrder,
    required this.onSortChanged,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          AppChip(
            label: '歌曲',
            isSelected: tabIndex == 0,
            onTap: () => onTabChanged(0),
            fill: true,
            borderRadius: 8,
            fontSize: 13,
          ),
          const Gap(8),
          AppChip(
            label: '专辑',
            isSelected: tabIndex == 1,
            onTap: () => onTabChanged(1),
            fill: true,
            borderRadius: 8,
            fontSize: 13,
          ),
          const Spacer(),
          if (showSort)
            Row(
              children: [
                AppChip(
                  label: '热度',
                  isSelected: songOrder == 'hot',
                  onTap: () => onSortChanged('hot'),
                  fill: false,
                  borderRadius: 14,
                  fontSize: 12,
                ),
                const Gap(6),
                AppChip(
                  label: '时间',
                  isSelected: songOrder == 'time',
                  onTap: () => onSortChanged('time'),
                  fill: false,
                  borderRadius: 14,
                  fontSize: 12,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// 歌曲列表内容
class _SongsContent extends StatelessWidget {
  final List<Track> tracks;

  const _SongsContent({required this.tracks});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (tracks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text(
            '暂无歌曲',
            style: TextStyle(color: colorScheme.mutedForeground),
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        if (tracks.isNotEmpty) PlayAllButton(tracks: tracks),
        const Gap(10),
        TrackList(tracks: tracks, showMoreActions: true),
      ],
    );
  }
}

/// 专辑列表内容
class _AlbumsContent extends StatelessWidget {
  final List<Album> albums;
  final void Function(Album album)? onOpenAlbum;
  final ColorScheme colorScheme;

  const _AlbumsContent({
    required this.albums,
    this.onOpenAlbum,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    if (albums.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text(
            '暂无专辑',
            style: TextStyle(color: colorScheme.mutedForeground),
          ),
        ),
      );
    }
    return _ArtistAlbumsGrid(albums: albums, onOpenAlbum: onOpenAlbum);
  }
}

/// 错误视图
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final ColorScheme colorScheme;

  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: colorScheme.destructive),
          const Gap(12),
          Text(message),
          const Gap(12),
          GhostButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}

/// 歌手头部信息组件
class _ArtistHeader extends StatelessWidget {
  final String name;
  final String? coverUrl;
  final int albumCount;

  const _ArtistHeader({
    required this.name,
    this.coverUrl,
    required this.albumCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 歌手封面（圆形）
            CoverImage(
              coverArt: coverUrl,
              colorScheme: colorScheme,
              size: 80,
              borderRadius: BorderRadius.circular(40),
            ),
            const Gap(12),
            // 歌手信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.foreground,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(6),
                  Text(
                    '$albumCount 张专辑',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 歌手专辑网格组件
class _ArtistAlbumsGrid extends StatelessWidget {
  final List<Album> albums;
  final void Function(Album album)? onOpenAlbum;

  const _ArtistAlbumsGrid({required this.albums, this.onOpenAlbum});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = Rx.gridColumns(constraints.maxWidth, base: 3);
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: albums.length,
          itemBuilder: (context, index) => _AlbumCard(
            album: albums[index],
            colorScheme: colorScheme,
            onTap: onOpenAlbum != null
                ? () => onOpenAlbum!(albums[index])
                : null,
          ),
        );
      },
    );
  }
}

/// 专辑卡片（用于歌手详情页的专辑网格）
class _AlbumCard extends StatelessWidget {
  final Album album;
  final ColorScheme colorScheme;
  final VoidCallback? onTap;

  const _AlbumCard({
    required this.album,
    required this.colorScheme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            if (album.artist != null && album.artist!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Text(
                  album.artist!,
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
