import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pomelo/modules/music/model/models.dart';
import 'package:pomelo/ui/music/widgets/play_pause_button.dart';
import 'package:pomelo/ui/music/widgets/song_more_actions_button.dart';
import 'package:pomelo/ui/music/widgets/song_tile.dart';

/// 歌曲列表组件
class SongList extends HookConsumerWidget {
  final List<Song> songs;

  /// 是否在每行末尾显示「更多操作」按钮（下一首播放、添加到播放列表等）
  final bool showMoreActions;

  /// 当 showMoreActions=true 且该回调非空时，菜单显示「从列表移除」
  /// 透传给 SongMoreActionsButton，主要用于播放队列页
  final void Function(Song)? onRemoveFromQueue;

  const SongList({
    super.key,
    required this.songs,
    this.showMoreActions = false,
    this.onRemoveFromQueue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return SongTile(
          song: song,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(song.source.name).muted,
              PlayPauseButton(song: song),
              if (showMoreActions)
                SongMoreActionsButton(
                  song: song,
                  onRemoveFromQueue: onRemoveFromQueue == null
                      ? null
                      : () => onRemoveFromQueue!(song),
                ),
            ],
          ),
        );
      },
    );
  }
}
