import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/modules/music/model/models.dart';
import 'package:pomelo/ui/music/providers/music_ui_providers.dart';
import 'package:pomelo/ui/music/widgets/play_pause_button.dart';
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

    return leaderboardsAsync.when(
      data: (leaderboards) {
        if (leaderboards.isEmpty) return const SizedBox.shrink();

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
                  return _LeaderboardTab(
                    leaderboard: leaderboards[index],
                    isFirst: index == 0,
                  );
                },
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

/// 单个排行榜标签（点击后展开歌曲列表）
class _LeaderboardTab extends HookConsumerWidget {
  final Leaderboard leaderboard;
  final bool isFirst;

  const _LeaderboardTab({
    required this.leaderboard,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = useState(isFirst);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => isExpanded.value = !isExpanded.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isExpanded.value ? colorScheme.primary : colorScheme.muted,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  leaderboard.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isExpanded.value ? FontWeight.w600 : FontWeight.normal,
                    color: isExpanded.value
                        ? colorScheme.primaryForeground
                        : colorScheme.mutedForeground,
                  ),
                ),
                if (isExpanded.value) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: colorScheme.primaryForeground,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (isExpanded.value) ...[
          const SizedBox(height: 12),
          _LeaderboardSongs(leaderboardId: leaderboard.id),
        ],
      ],
    );
  }
}

/// 排行榜歌曲列表
class _LeaderboardSongs extends HookConsumerWidget {
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
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Card(
                child: ListTile(
                  leading: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: index < 3 ? FontWeight.bold : null,
                        color: index < 3
                            ? colorScheme.primary
                            : colorScheme.mutedForeground,
                      ),
                    ),
                  ),
                  title: Text(
                    song.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${song.artist}  ·  ${song.formattedDuration}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: PlayPauseButton(song: song),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
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
