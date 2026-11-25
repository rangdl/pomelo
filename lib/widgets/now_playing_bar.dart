import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../providers/app_providers.dart';

/// 玻璃风格的底部播放条（liquid_glass_widgets demo）。
class NowPlayingBar extends ConsumerWidget {
  const NowPlayingBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(nowPlayingProvider);
    if (item == null) return const SizedBox.shrink();
    final player = ref.watch(audioPlayerProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: GlassContainer(
        shape: const LiquidRoundedSuperellipse(borderRadius: 22),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: InkWell(
          onTap: () => context.push('/player'),
          borderRadius: BorderRadius.circular(22),
          child: Row(
            children: [
              const Icon(Icons.music_note, size: 20),
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
              GlassIconButton(
                size: 36,
                iconSize: 18,
                icon: const Icon(Icons.skip_previous),
                onPressed: () =>
                    ref.read(playerActionsProvider).skip(next: false),
              ),
              const SizedBox(width: 4),
              StreamBuilder<bool>(
                stream: player.playingStream,
                initialData: player.playing,
                builder: (context, snap) {
                  final playing = snap.data ?? false;
                  return GlassIconButton(
                    size: 40,
                    iconSize: 22,
                    icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                    onPressed: () => playing ? player.pause() : player.play(),
                  );
                },
              ),
              const SizedBox(width: 4),
              GlassIconButton(
                size: 36,
                iconSize: 18,
                icon: const Icon(Icons.skip_next),
                onPressed: () =>
                    ref.read(playerActionsProvider).skip(next: true),
              ),
            ],
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
