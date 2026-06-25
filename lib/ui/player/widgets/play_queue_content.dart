import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart' hide Track;
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/modules/audio_player/module_providers.dart';
import 'package:pomelo/modules/audio_player/providers/audio_player.dart';
import 'package:pomelo/modules/music/model/song.dart';
import 'package:pomelo/ui/music/widgets/play_pause_button.dart';
import 'package:pomelo/ui/music/widgets/song_more_actions_button.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 播放队列内容组件
///
/// 监听 [audioPlayerProvider] 渲染当前播放队列，列出所有曲目，
/// 当前曲目高亮，点击项调用 [AudioPlayerNotifier.jumpToTrack] 跳转。
///
/// 该组件同时供移动端全屏页 [PlayQueuePage] 与桌面端 openSheet 复用。
class PlayQueueContent extends HookConsumerWidget {
  const PlayQueueContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioPlayerProvider);
    final notifier = ref.read(audioPlayerProvider.notifier);
    final audioPlayer = ref.watch(audioPlayerServiceProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final tracks = state.tracks;
    final activeTrack = state.activeTrack;

    if (tracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.queue_music, size: 48, color: colorScheme.mutedForeground),
            const Gap(12),
            Text(
              '播放队列为空',
              style: TextStyle(color: colorScheme.mutedForeground),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _QueueHeader(
          songCount: tracks.length,
          loopMode: state.loopMode,
          shuffled: state.shuffled,
          onToggleShuffle: () => audioPlayer.setShuffle(!state.shuffled),
          onCycleLoop: () {
            final next = switch (state.loopMode) {
              PlaylistMode.none => PlaylistMode.loop,
              PlaylistMode.loop => PlaylistMode.single,
              PlaylistMode.single => PlaylistMode.none,
            };
            audioPlayer.setLoopMode(next);
          },
          onClear: () {
            notifier.stop();
            Rx.toast.success('已清空播放队列');
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final song = tracks[index];
              final isActive = activeTrack?.id == song.id;
              return Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                child: Card(
                  child: ListTile(
                    leading: SizedBox(
                      width: 28,
                      child: isActive
                          ? Icon(
                              Icons.equalizer,
                              color: colorScheme.primary,
                              size: 20,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.mutedForeground,
                              ),
                            ),
                    ),
                    title: Text(
                      song.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isActive ? colorScheme.primary : null,
                        fontWeight: isActive ? FontWeight.w600 : null,
                      ),
                    ),
                    subtitle: Text(
                      '${song.artist}  ·  ${song.formattedDuration}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PlayPauseButton(song: song),
                        SongMoreActionsButton(
                          song: song,
                          onRemoveFromQueue: () =>
                              notifier.removeTrack(song.id),
                        ),
                      ],
                    ),
                    onTap: () => notifier.jumpToTrack(song),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 队列顶部工具栏
class _QueueHeader extends StatelessWidget {
  final int songCount;
  final PlaylistMode loopMode;
  final bool shuffled;
  final VoidCallback onToggleShuffle;
  final VoidCallback onCycleLoop;
  final VoidCallback onClear;

  const _QueueHeader({
    required this.songCount,
    required this.loopMode,
    required this.shuffled,
    required this.onToggleShuffle,
    required this.onCycleLoop,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '播放队列 · $songCount 首',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.mutedForeground,
              ),
            ),
          ),
          IconButton.ghost(
            icon: Icon(
              Icons.shuffle,
              size: 18,
              color: shuffled ? colorScheme.primary : null,
            ),
            onPressed: onToggleShuffle,
          ),
          IconButton.ghost(
            icon: Icon(
              loopMode == PlaylistMode.loop
                  ? Icons.repeat
                  : loopMode == PlaylistMode.single
                  ? Icons.repeat_one
                  : Icons.repeat,
              size: 18,
              color: loopMode != PlaylistMode.none
                  ? colorScheme.primary
                  : null,
            ),
            onPressed: onCycleLoop,
          ),
          IconButton.ghost(
            icon: Icon(
              Icons.delete_sweep_outlined,
              size: 18,
              color: colorScheme.destructive,
            ),
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}
