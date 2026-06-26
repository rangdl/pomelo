import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/ui/music/providers/music_ui_providers.dart';
import 'package:pomelo/ui/music/widgets/app_chip.dart';
import 'package:pomelo/ui/music/widgets/play_pause_button.dart';
import 'package:pomelo/ui/music/widgets/song_tile.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 排行榜版块组件
///
/// 展示排行榜标签导航和对应排行榜下的歌曲列表。
/// 默认选中第一个排行榜。
class LeaderboardSection extends HookConsumerWidget {
  const LeaderboardSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardsAsync = ref.watch(leaderboardsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final selectedId = ref.watch(selectedLeaderboardProvider);

    return leaderboardsAsync.when(
      data: (leaderboards) {
        if (leaderboards.isEmpty) return const SizedBox.shrink();

        // 如果没有选中或选中的不在列表中，默认选中第一个
        final effectiveId = (selectedId == null ||
                !leaderboards.any((l) => l.id == selectedId))
            ? leaderboards.first.id
            : selectedId;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 12),
              child: Text(
                '排行榜',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.foreground,
                ),
              ),
            ),
            // 排行榜标签行（横向滚动）
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: leaderboards.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final lb = leaderboards[index];
                  final isSelected = lb.id == effectiveId;
                  return AppChip(
                    label: lb.name,
                    isSelected: isSelected,
                    onTap: () => ref
                        .read(selectedLeaderboardProvider.notifier)
                        .select(lb.id),
                    fill: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    borderRadius: 18,
                    fontSize: 13,
                  );
                },
              ),
            ),
            // 展开的排行榜歌曲列表
            const SizedBox(height: 12),
            _LeaderboardSongs(leaderboardId: effectiveId),
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

/// 排行榜歌曲列表
class _LeaderboardSongs extends ConsumerWidget {
  final String leaderboardId;

  const _LeaderboardSongs({required this.leaderboardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(leaderboardSongsProvider(leaderboardId));
    final colorScheme = Theme.of(context).colorScheme;

    return songsAsync.when(
      data: (songs) {
        if (songs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                '暂无歌曲',
                style: TextStyle(color: colorScheme.mutedForeground),
              ),
            ),
          );
        }

        // 显示前 20 首
        final displaySongs = songs.take(20).toList();
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displaySongs.length,
          itemBuilder: (context, index) {
            final song = displaySongs[index];
            return SongTile(
              song: song,
              index: index + 1,
              trailing: PlayPauseButton(song: song),
            );
          },
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            '加载失败: $err',
            style: TextStyle(color: colorScheme.mutedForeground),
          ),
        ),
      ),
    );
  }
}
