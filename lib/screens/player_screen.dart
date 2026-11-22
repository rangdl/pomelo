import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';

/// 全屏播放页：封面、进度、上一首/播放/下一首、播放模式、队列。
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  /// 拖动进度条时的临时值，松手后 seek
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final item = ref.watch(nowPlayingProvider);
    final player = ref.watch(audioPlayerProvider);
    final mode = ref.watch(playModeProvider);
    final queue = ref.watch(playQueueProvider);
    final queueIndex = ref.read(playQueueProvider.notifier).index;

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('正在播放')),
        body: const Center(child: Text('当前没有播放内容')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('正在播放'),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music),
            tooltip: '播放队列 (${queue.length})',
            onPressed: () => _showQueue(context, queue, queueIndex),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _Cover(artwork: '${item['artwork'] ?? ''}'),
              const SizedBox(height: 28),
              Text(
                '${item['title'] ?? '未知歌曲'}',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                '${item['artist'] ?? ''}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const Spacer(),
              StreamBuilder<Duration>(
                stream: player.positionStream,
                builder: (context, posSnap) {
                  return StreamBuilder<Duration>(
                    stream: player.durationStream,
                    builder: (context, durSnap) {
                      final position = posSnap.data ?? Duration.zero;
                      final duration = durSnap.data ?? Duration.zero;
                      final total = duration.inMilliseconds.toDouble();
                      final max = total <= 0 ? 1.0 : total;
                      final value = _dragValue ??
                          position.inMilliseconds.toDouble().clamp(0, max);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Slider(
                            value: value,
                            max: max,
                            onChanged: total <= 0
                                ? null
                                : (v) => setState(() => _dragValue = v),
                            onChangeEnd: total <= 0
                                ? null
                                : (v) async {
                                    await player
                                        .seek(Duration(milliseconds: v.round()));
                                    if (mounted) setState(() => _dragValue = null);
                                  },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_fmt(_dragValue == null
                                    ? position
                                    : Duration(
                                        milliseconds: _dragValue!.round()))),
                                Text(_fmt(duration)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    tooltip: mode.label,
                    iconSize: 28,
                    icon: Icon(switch (mode) {
                      PlayMode.listLoop => Icons.repeat,
                      PlayMode.singleLoop => Icons.repeat_one,
                      PlayMode.sequential => Icons.trending_flat,
                    }),
                    onPressed: () =>
                        ref.read(playModeProvider.notifier).cycle(),
                  ),
                  IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.skip_previous),
                    onPressed: () =>
                        ref.read(playerActionsProvider).skip(next: false),
                  ),
                  StreamBuilder<bool>(
                    stream: player.playingStream,
                    initialData: player.playing,
                    builder: (context, snap) {
                      final playing = snap.data ?? false;
                      return StreamBuilder<bool>(
                        stream: player.bufferingStream,
                        builder: (context, bufSnap) {
                          final buffering = bufSnap.data ?? false;
                          return IconButton.filled(
                            iconSize: 52,
                            padding: const EdgeInsets.all(12),
                            icon: buffering
                                ? const SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Icon(playing
                                    ? Icons.pause
                                    : Icons.play_arrow),
                            onPressed: () =>
                                playing ? player.pause() : player.play(),
                          );
                        },
                      );
                    },
                  ),
                  IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.skip_next),
                    onPressed: () =>
                        ref.read(playerActionsProvider).skip(next: true),
                  ),
                  IconButton(
                    tooltip: '队列',
                    iconSize: 28,
                    icon: const Icon(Icons.queue_music),
                    onPressed: () => _showQueue(context, queue, queueIndex),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _showQueue(
    BuildContext context,
    List<Map<String, dynamic>> queue,
    int currentIndex,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final items = ref.watch(playQueueProvider);
          final index = ref.read(playQueueProvider.notifier).index;
          if (items.isEmpty) {
            return const SizedBox(
              height: 160,
              child: Center(child: Text('队列为空')),
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final it = items[i];
              final current = i == index;
              return ListTile(
                selected: current,
                leading: current
                    ? const Icon(Icons.volume_up)
                    : Text('${i + 1}'),
                title: Text(
                  '${it['title'] ?? '未知'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${it['artist'] ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(playQueueProvider.notifier).jumpTo(i);
                  ref.read(playerActionsProvider).playItem(it);
                },
              );
            },
          );
        },
      ),
    );
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.artwork});

  final String artwork;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    if (artwork.isEmpty) {
      return Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          borderRadius: radius,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: const Icon(Icons.music_note, size: 96),
      );
    }
    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        artwork,
        width: 260,
        height: 260,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Container(
          width: 260,
          height: 260,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.music_note, size: 96),
        ),
      ),
    );
  }
}
