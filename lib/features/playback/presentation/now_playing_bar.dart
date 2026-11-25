import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/player_actions.dart';
import 'playback_providers.dart';

/// 底部迷你播放条:点击进入全屏播放页。
class NowPlayingBar extends ConsumerWidget {
  const NowPlayingBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(nowPlayingProvider);
    if (item == null) return const SizedBox.shrink();
    final player = ref.watch(audioPlayerProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/player'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.music_note_rounded, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${item['title'] ?? '未知歌曲'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${item['artist'] ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                StreamBuilder<Duration>(
                  stream: player.positionStream,
                  builder: (context, snap) => Text(
                    _fmt(snap.data ?? Duration.zero),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                  onPressed: () =>
                      ref.read(playerActionsProvider).skip(next: false),
                  icon: const Icon(Icons.skip_previous_rounded),
                ),
                StreamBuilder<bool>(
                  stream: player.playingStream,
                  initialData: player.playing,
                  builder: (context, snap) {
                    final playing = snap.data ?? false;
                    return IconButton(
                      iconSize: 24,
                      visualDensity: VisualDensity.compact,
                      onPressed: () =>
                          ref.read(playerActionsProvider).togglePlay(),
                      icon: Icon(
                        playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                    );
                  },
                ),
                IconButton(
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                  onPressed: () =>
                      ref.read(playerActionsProvider).skip(next: true),
                  icon: const Icon(Icons.skip_next_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
