/// 歌手详情页面
///
/// 展示歌手信息（封面、名称、专辑数量）及其专辑列表。
library;

import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/core/models/metadata/metadata.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/ui/music/widgets/cover_image.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 歌手专辑列表 Provider
///
/// 根据 (sourceId, artistId) 获取歌手的专辑列表。
final artistAlbumsProvider =
    FutureProvider.family<List<Album>, ({String sourceId, String artistId})>(
  (ref, params) async {
    await ref.watch(musicServersProvider.future);
    final service =
        await ref.watch(musicServerByProvider(params.sourceId).future);
    if (service == null) return [];
    try {
      return await service.getArtistAlbums(params.artistId);
    } catch (_) {
      return [];
    }
  },
);

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
    final albumsAsync = ref.watch(
      artistAlbumsProvider((sourceId: sourceId, artistId: artistId)),
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            GhostButton(
              onPressed: onClose ?? () => context.router.maybePop(),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ],
          title: Text(
            artistName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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

          // 专辑列表内容
          final albumsContent = albums.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Text(
                      '暂无专辑',
                      style: TextStyle(color: colorScheme.mutedForeground),
                    ),
                  ),
                )
              : _ArtistAlbumsGrid(
                  albums: albums,
                  onOpenAlbum: onOpenAlbum,
                );

          return Rx.layout(
            context,
            // 移动端：纵向布局（歌手信息在上，专辑网格在下）
            mobile: () => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                header,
                const Gap(16),
                albumsContent,
              ],
            ),
            // 桌面端（tablet 及以上）：左侧歌手信息，右侧专辑网格
            tablet: () => Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 300,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [header],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: albumsContent),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.destructive),
              const Gap(12),
              Text('加载失败: $err'),
              const Gap(12),
              GhostButton(
                onPressed: () {
                  ref.invalidate(
                    artistAlbumsProvider(
                      (sourceId: sourceId, artistId: artistId),
                    ),
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
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 歌手封面（圆形）
            CoverImage(
              coverArt: coverUrl,
              colorScheme: colorScheme,
              size: 100,
              borderRadius: BorderRadius.circular(50),
            ),
            const Gap(16),
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
                  const Gap(8),
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

  const _ArtistAlbumsGrid({
    required this.albums,
    this.onOpenAlbum,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
          itemCount: albums.length,
          itemBuilder: (context, index) => _AlbumCard(
            album: albums[index],
            colorScheme: colorScheme,
            onTap: onOpenAlbum != null ? () => onOpenAlbum!(albums[index]) : null,
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
