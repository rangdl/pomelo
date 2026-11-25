import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/player_actions.dart';
import '../domain/play_mode.dart';
import 'playback_providers.dart';

/// 全屏播放页:封面做背景,控制层为半透明深色面板。
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
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

    final artwork = '${item['artwork'] ?? ''}';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('正在播放'),
        actions: [
          IconButton(
            tooltip: '播放队列',
            icon: const Icon(Icons.queue_music_rounded),
            onPressed: () => _showQueue(queue, queueIndex),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _PlayerBackground(artwork: artwork),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Spacer(),
                  // 主控制面板:深色半透明,两种主题下都浮在封面上
                  Material(
                    color: const Color(0xB3000000),
                    borderRadius: BorderRadius.circular(28),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${item['title'] ?? '未知歌曲'}',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item['artist'] ?? ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _ProgressBar(
                            playerPosition: player.positionStream,
                            playerDuration: player.durationStream,
                            onSeek: (d) => player.seek(d),
                            dragValue: _dragValue,
                            onDrag: (v) => setState(() => _dragValue = v),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                iconSize: 28,
                                color: Colors.white,
                                onPressed: () =>
                                    ref.read(playModeProvider.notifier).cycle(),
                                icon: Icon(switch (mode) {
                                  PlayMode.listLoop => Icons.repeat_rounded,
                                  PlayMode.singleLoop => Icons.repeat_one_rounded,
                                  PlayMode.sequential => Icons.trending_flat_rounded,
                                }),
                              ),
                              IconButton(
                                iconSize: 34,
                                color: Colors.white,
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
                                    iconSize: 44,
                                    color: Colors.white,
                                    onPressed: () => playing
                                        ? player.pause()
                                        : player.play(),
                                    icon: Icon(
                                      playing
                                          ? Icons.pause_circle_filled_rounded
                                          : Icons.play_circle_fill_rounded,
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                iconSize: 34,
                                color: Colors.white,
                                onPressed: () =>
                                    ref.read(playerActionsProvider).skip(next: true),
                                icon: const Icon(Icons.skip_next_rounded),
                              ),
                              IconButton(
                                iconSize: 28,
                                color: Colors.white,
                                onPressed: () => _showQueue(queue, queueIndex),
                                icon: const Icon(Icons.queue_music_rounded),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQueue(List<Map<String, dynamic>> queue, int currentIndex) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => LayoutBuilder(
        builder: (ctx, constraints) => Consumer(
          builder: (ctx, ref, _) {
            final items = ref.watch(playQueueProvider);
            final index = ref.read(playQueueProvider.notifier).index;
            // 约束驱动:弹层自身已限制最大高度,不再读裸屏幕尺寸。
            return SizedBox(
              height: math.min(560.0, constraints.maxHeight),
              child: items.isEmpty
                ? const Center(child: Text('队列为空'))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (ctx, i) {
                      final it = items[i];
                      final current = i == index;
                      return ListTile(
                        selected: current,
                        leading: current
                            ? const Icon(Icons.volume_up_rounded)
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
                  ),
            );
          },
        ),
      ),
    );
  }
}

/// 封面背景:品牌色渐变打底,可选叠加封面图并压暗。
class _PlayerBackground extends StatelessWidget {
  const _PlayerBackground({required this.artwork});

  final String artwork;

  @override
  Widget build(BuildContext context) {
    if (artwork.isEmpty) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3A2318), Color(0xFFFF7A45), Color(0xFF2A1A12)],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          artwork,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => const SizedBox.shrink(),
        ),
        // 压暗,保证面板上的文字可读
        const ColoredBox(color: Color(0x66000000)),
      ],
    );
  }
}

/// 进度条 + 时间标签。
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.playerPosition,
    required this.playerDuration,
    required this.onSeek,
    required this.dragValue,
    required this.onDrag,
  });

  final Stream<Duration> playerPosition;
  final Stream<Duration> playerDuration;
  final void Function(Duration) onSeek;
  final double? dragValue;
  final void Function(double?) onDrag;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: playerPosition,
      builder: (context, posSnap) {
        return StreamBuilder<Duration>(
          stream: playerDuration,
          builder: (context, durSnap) {
            final position = posSnap.data ?? Duration.zero;
            final duration = durSnap.data ?? Duration.zero;
            final total = duration.inMilliseconds.toDouble();
            final max = total <= 0 ? 1.0 : total;
            final value =
                dragValue ?? position.inMilliseconds.toDouble().clamp(0, max);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbColor: Colors.white,
                    activeTrackColor: Colors.white70,
                    inactiveTrackColor: Colors.white24,
                    overlayColor: Colors.white24,
                  ),
                  child: Slider(
                    value: value,
                    max: max,
                    onChanged: total <= 0 ? null : (v) => onDrag(v),
                    onChangeEnd: total <= 0
                        ? null
                        : (v) {
                            onSeek(Duration(milliseconds: v.round()));
                            onDrag(null);
                          },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _fmt(
                          dragValue == null
                              ? position
                              : Duration(milliseconds: dragValue!.round()),
                        ),
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                      Text(
                        _fmt(duration),
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
