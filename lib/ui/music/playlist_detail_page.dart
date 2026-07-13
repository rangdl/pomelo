/// 歌单详情页面
///
/// 展示歌单信息（封面、名称、创建者）及其中的歌曲列表。
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

/// 歌单详情 Provider
///
/// 根据 (sourceId, playlistId) 获取歌单歌曲列表。
final playlistTracksProvider =
    FutureProvider.family<List<Track>, ({String sourceId, String playlistId})>((
      ref,
      params,
    ) async {
      await ref.watch(musicServersProvider.future);
      final service = await ref.watch(
        musicServerByProvider(params.sourceId).future,
      );
      if (service == null) return [];
      return service.getPlaylistTracks(params.playlistId);
    });

/// 歌单详情页面
@RoutePage()
class PlaylistDetailPage extends HookConsumerWidget {
  final String playlistId;
  final String sourceId;
  final String playlistName;
  final String? coverUrl;
  final String creator;

  /// 关闭回调。
  ///
  /// 当此页面以非路由方式（如嵌入到首页 Tab 内容区）渲染时，
  /// 通过该回调通知宿主关闭。若为 null，则使用 `context.router.maybePop()`。
  final VoidCallback? onClose;

  const PlaylistDetailPage({
    super.key,
    required this.playlistId,
    required this.sourceId,
    required this.playlistName,
    this.coverUrl,
    this.creator = '',
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(
      playlistTracksProvider((sourceId: sourceId, playlistId: playlistId)),
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
            playlistName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Divider(),
      ],
      child: songsAsync.when(
        data: (tracks) {
          // 歌单头部信息
          final header = _PlaylistHeader(
            name: playlistName,
            coverUrl: coverUrl,
            creator: creator,
            songCount: tracks.length,
            tracks: tracks,
          );
          // 歌曲列表内容
          // 移动端：默认（嵌入父 ListView 滚动）
          // 桌面端：传入 physics 使其作为独立滚动区域
          final songListContent = tracks.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Text(
                      '暂无歌曲',
                      style: TextStyle(color: colorScheme.mutedForeground),
                    ),
                  ),
                )
              : TrackList(
                  tracks: tracks,
                  showMoreActions: true,
                  physics: isMobile
                      ? null
                      : const AlwaysScrollableScrollPhysics(),
                );

          return Rx.layout(
            context,
            // 移动端：纵向布局（封面信息在上，歌曲列表在下）
            mobile: () => ListView(
              padding: const EdgeInsets.all(12),
              children: [header, const Gap(12), songListContent],
            ),
            // 桌面端（tablet 及以上）：左侧封面信息，右侧歌曲列表
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
                Expanded(child: songListContent),
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
                    playlistTracksProvider((
                      sourceId: sourceId,
                      playlistId: playlistId,
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

/// 歌单头部信息组件
class _PlaylistHeader extends StatelessWidget {
  final String name;
  final String? coverUrl;
  final String creator;
  final int songCount;
  final List<Track> tracks;

  const _PlaylistHeader({
    required this.name,
    this.coverUrl,
    required this.creator,
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
            // 歌单信息
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
                  if (creator.isNotEmpty)
                    Text(
                      creator,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                  const Gap(4),
                  Text(
                    '$songCount 首歌曲',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                  const Gap(10),
                  PlayAllButton(tracks: tracks),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
