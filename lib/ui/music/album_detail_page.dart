/// 专辑详情页面
///
/// 展示专辑信息（封面、名称、艺术家、年份）及其曲目列表。
library;

import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/core/models/metadata/metadata.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/ui/music/track_list.dart';
import 'package:pomelo/ui/music/widgets/cover_image.dart';
import 'package:pomelo/ui/music/widgets/play_all_button.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 专辑详情 Provider
///
/// 根据 (sourceId, albumId) 获取专辑曲目列表。
final albumTracksProvider =
    FutureProvider.family<List<Track>, ({String sourceId, String albumId})>(
  (ref, params) async {
    final service =
        await ref.watch(musicServerProvider(params.sourceId).future);
    if (service == null) return [];
    try {
      final result = await service.getAlbumTracks(params.albumId);
      return result.items;
    } catch (_) {
      return [];
    }
  },
);

/// 专辑详情页面
@RoutePage()
class AlbumDetailPage extends HookConsumerWidget {
  final String albumId;
  final String sourceId;
  final String albumName;
  final String? coverUrl;
  final String? artist;
  final int? year;
  final int songCount;

  /// 关闭回调。
  ///
  /// 当此页面以非路由方式（如嵌入到首页 Tab 内容区）渲染时，
  /// 通过该回调通知宿主关闭。若为 null，则使用 `context.router.maybePop()`。
  final VoidCallback? onClose;

  const AlbumDetailPage({
    super.key,
    required this.albumId,
    required this.sourceId,
    required this.albumName,
    this.coverUrl,
    this.artist,
    this.year,
    this.songCount = 0,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(
      albumTracksProvider((sourceId: sourceId, albumId: albumId)),
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
          title: Text(
            albumName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Divider(),
      ],
      child: tracksAsync.when(
        data: (tracks) {
          // 专辑头部信息
          final header = _AlbumHeader(
            name: albumName,
            coverUrl: coverUrl,
            artist: artist,
            year: year,
            songCount: tracks.isNotEmpty ? tracks.length : songCount,
            tracks: tracks,
          );
          // 曲目列表内容
          final trackListContent = tracks.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Text(
                      '暂无曲目',
                      style: TextStyle(color: colorScheme.mutedForeground),
                    ),
                  ),
                )
              : TrackList(tracks: tracks, showMoreActions: true);

          return Rx.layout(
            context,
            // 移动端：纵向布局（封面信息在上，曲目列表在下）
            mobile: () => ListView(
              padding: const EdgeInsets.all(12),
              children: [
                header,
                const Gap(12),
                trackListContent,
              ],
            ),
            // 桌面端（tablet 及以上）：左侧封面信息，右侧曲目列表
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
                Expanded(child: trackListContent),
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
                    albumTracksProvider(
                      (sourceId: sourceId, albumId: albumId),
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

/// 专辑头部信息组件
class _AlbumHeader extends StatelessWidget {
  final String name;
  final String? coverUrl;
  final String? artist;
  final int? year;
  final int songCount;
  final List<Track> tracks;

  const _AlbumHeader({
    required this.name,
    this.coverUrl,
    this.artist,
    this.year,
    required this.songCount,
    required this.tracks,
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
            // 封面图
            CoverImage(
              coverArt: coverUrl,
              colorScheme: colorScheme,
              size: 80,
              borderRadius: BorderRadius.circular(8),
            ),
            const Gap(12),
            // 专辑信息
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
                  if (artist != null && artist!.isNotEmpty)
                    Text(
                      artist!,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                  const Gap(4),
                  Text(
                    [
                      if (year != null) '$year',
                      '$songCount 首曲目',
                    ].join(' · '),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                  const Gap(10),
                  if (tracks.isNotEmpty) PlayAllButton(tracks: tracks),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
