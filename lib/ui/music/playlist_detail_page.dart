/// 歌单详情页面
///
/// 展示歌单信息（封面、名称、创建者）及其中的歌曲列表。
library;

import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/modules/music/model/models.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/ui/music/song_list.dart';
import 'package:pomelo/ui/music/widgets/cover_placeholder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 歌单详情 Provider
///
/// 根据 (sourceId, playlistId) 获取歌单歌曲列表。
final playlistSongsProvider =
    FutureProvider.family<List<Song>, ({String sourceId, String playlistId})>(
  (ref, params) async {
    await ref.watch(musicReadyProvider.future);
    final module = ref.watch(musicModuleProvider);
    final service = module?.service(params.sourceId);
    if (service == null) return [];
    return service.getPlaylistSongs(params.playlistId);
  },
);

/// 歌单详情页面
@RoutePage()
class PlaylistDetailPage extends HookConsumerWidget {
  final String playlistId;
  final String sourceId;
  final String playlistName;
  final String? coverUrl;
  final String creator;

  const PlaylistDetailPage({
    super.key,
    required this.playlistId,
    required this.sourceId,
    required this.playlistName,
    this.coverUrl,
    this.creator = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(
      playlistSongsProvider((sourceId: sourceId, playlistId: playlistId)),
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            GhostButton(
              onPressed: () => context.router.maybePop(),
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
        data: (songs) {
          // 歌单头部信息
          final header = _PlaylistHeader(
            name: playlistName,
            coverUrl: coverUrl,
            creator: creator,
            songCount: songs.length,
          );
          // 歌曲列表内容
          final songListContent = songs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Text(
                      '暂无歌曲',
                      style: TextStyle(color: colorScheme.mutedForeground),
                    ),
                  ),
                )
              : SongList(songs: songs);

          return Rx.layout(
            context,
            // 移动端：纵向布局（封面信息在上，歌曲列表在下）
            mobile: () => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                header,
                const Gap(16),
                songListContent,
              ],
            ),
            // 桌面端（tablet 及以上）：左侧封面信息，右侧歌曲列表
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
              Icon(Icons.error_outline, size: 48, color: colorScheme.destructive),
              const SizedBox(height: 12),
              Text('加载失败: $err'),
              const SizedBox(height: 12),
              GhostButton(
                onPressed: () {
                  ref.invalidate(
                    playlistSongsProvider(
                      (sourceId: sourceId, playlistId: playlistId),
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

/// 歌单头部信息组件
class _PlaylistHeader extends StatelessWidget {
  final String name;
  final String? coverUrl;
  final String creator;
  final int songCount;

  const _PlaylistHeader({
    required this.name,
    this.coverUrl,
    required this.creator,
    required this.songCount,
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
            // 封面图
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: coverUrl != null && coverUrl!.isNotEmpty
                  ? Image.network(
                      coverUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => CoverPlaceholder(
                        colorScheme: colorScheme,
                        width: 100,
                        height: 100,
                      ),
                    )
                  : CoverPlaceholder(
                      colorScheme: colorScheme,
                      width: 100,
                      height: 100,
                    ),
            ),
            const SizedBox(width: 16),
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
                  const SizedBox(height: 8),
                  if (creator.isNotEmpty)
                    Text(
                      creator,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '$songCount 首歌曲',
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

