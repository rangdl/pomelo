import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../providers/app_providers.dart';

/// 全屏播放页（liquid_glass 风格）：封面做背景，控制层为玻璃浮层。
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

    return GlassPage(
      // 封面做背景；无封面时用渐变
      background: _Background(artwork: artwork),
      statusBarStyle: GlassStatusBarStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('正在播放'),
          actions: [
            GlassIconButton(
              size: 40,
              iconSize: 20,
              icon: const Icon(Icons.queue_music),
              onPressed: () => _showQueue(queue, queueIndex),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const Spacer(),
                // 主控制玻璃面板
                GlassContainer(
                  shape: const LiquidRoundedSuperellipse(borderRadius: 28),
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
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item['artist'] ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
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
                          GlassIconButton(
                            size: 44,
                            iconSize: 20,
                            icon: Icon(switch (mode) {
                              PlayMode.listLoop => Icons.repeat,
                              PlayMode.singleLoop => Icons.repeat_one,
                              PlayMode.sequential => Icons.trending_flat,
                            }),
                            onPressed: () =>
                                ref.read(playModeProvider.notifier).cycle(),
                          ),
                          GlassIconButton(
                            size: 50,
                            iconSize: 26,
                            icon: const Icon(Icons.skip_previous),
                            onPressed: () =>
                                ref.read(playerActionsProvider).skip(next: false),
                          ),
                          StreamBuilder<bool>(
                            stream: player.playingStream,
                            initialData: player.playing,
                            builder: (context, snap) {
                              final playing = snap.data ?? false;
                              return GlassIconButton(
                                size: 68,
                                iconSize: 34,
                                icon: Icon(
                                  playing ? Icons.pause : Icons.play_arrow,
                                ),
                                onPressed: () =>
                                    playing ? player.pause() : player.play(),
                              );
                            },
                          ),
                          GlassIconButton(
                            size: 50,
                            iconSize: 26,
                            icon: const Icon(Icons.skip_next),
                            onPressed: () =>
                                ref.read(playerActionsProvider).skip(next: true),
                          ),
                          GlassIconButton(
                            size: 44,
                            iconSize: 20,
                            icon: const Icon(Icons.queue_music),
                            onPressed: () => _showQueue(queue, queueIndex),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQueue(List<Map<String, dynamic>> queue, int currentIndex) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final items = ref.watch(playQueueProvider);
          final index = ref.read(playQueueProvider.notifier).index;
          return GlassContainer(
            shape: const LiquidRoundedSuperellipse(borderRadius: 24),
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 24),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.5,
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
                    ),
            ),
          );
        },
      ),
    );
  }
}

/// 背景：有封面用模糊封面，否则用品牌色渐变。
class _Background extends StatelessWidget {
  const _Background({required this.artwork});

  final String artwork;

  @override
  Widget build(BuildContext context) {
    final gradient = DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A2318), Color(0xFFFF7A45), Color(0xFF2A1A12)],
        ),
      ),
      child: const SizedBox.expand(),
    );
    if (artwork.isEmpty) return gradient;
    return Stack(
      fit: StackFit.expand,
      children: [
        gradient,
        Image.network(
          artwork,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => const SizedBox.shrink(),
        ),
        // 压暗，保证玻璃上的文字可读
        const DecoratedBox(
          decoration: BoxDecoration(color: Color(0x66000000)),
          child: SizedBox.expand(),
        ),
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
            final value = dragValue ?? position.inMilliseconds.toDouble().clamp(0, max);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassSlider(
                  value: value,
                  max: max,
                  onChanged: total <= 0
                      ? null
                      : (v) => onDrag(v),
                  onChangeEnd: total <= 0
                      ? null
                      : (v) {
                          onSeek(Duration(milliseconds: v.round()));
                          onDrag(null);
                        },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _fmt(dragValue == null
                            ? position
                            : Duration(milliseconds: dragValue!.round())),
                        style: const TextStyle(fontSize: 11),
                      ),
                      Text(
                        _fmt(duration),
                        style: const TextStyle(fontSize: 11),
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
