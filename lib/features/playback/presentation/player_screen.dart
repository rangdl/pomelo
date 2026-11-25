import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/settings/theme_mode.dart';
import '../../../shared/ui/tokens.dart';
import '../../plugins/presentation/library_providers.dart';
import '../application/player_actions.dart';
import '../data/audio_player_service.dart';
import '../data/lrc_parser.dart';
import '../domain/play_mode.dart';
import 'playback_providers.dart';

/// 沉浸式全屏播放页。
///
/// 竖向三段式:上部封面(适度大小、不铺满),中部歌词(约三行,当前行大、
/// 上下行小),下部歌名-进度-控制。背景是封面的模糊暗化版,保证整体沉浸感。
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
    final title = '${item['title'] ?? '未知歌曲'}';
    final artist = '${item['artist'] ?? ''}';
    final quality = ref.watch(audioQualityProvider).label;

    return Scaffold(
      backgroundColor: Colors.black,
      body: ClipRRect(
        // 顶部圆角:贴合从底部弹出的 sheet 观感。
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 背景:封面的模糊暗化版,营造沉浸感(不抢前景)。
            _BlurredBackdrop(artwork: artwork),
            SafeArea(
              child: Column(
                children: [
                  // 顶部:下箭头收起(sheet 也可下滑关闭)。缩小顶部留白。
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: '收起',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  // 上部:封面主图(调大)。
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 8),
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: _CoverArt(artwork: artwork),
                        ),
                      ),
                    ),
                  ),
                  // 中部:歌词三行(当前行大、上下行小,间距紧凑)。
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _LyricThreeLines(
                        positionStream: player.positionStream,
                      ),
                    ),
                  ),
                  // 下部:歌名-歌手 / 收藏·队列 / 进度 / 控制(整体上移)。
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: _buildControls(
                      item,
                      player,
                      mode,
                      queue,
                      queueIndex,
                      title,
                      artist,
                      quality,
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

  /// 底部信息与控制区。
  Widget _buildControls(
    Map<String, dynamic> item,
    AudioPlayerService player,
    PlayMode mode,
    List<Map<String, dynamic>> queue,
    int queueIndex,
    String title,
    String artist,
    String quality,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 歌名-歌手 + 收藏/队列。
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if (artist.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _FavoriteButton(item: item),
            IconButton(
              tooltip: '播放队列',
              onPressed: () => _showQueue(queue, queueIndex),
              icon: const Icon(
                Icons.queue_music_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        // 进度条。
        _ProgressBar(
          playerPosition: player.positionStream,
          playerDuration: player.durationStream,
          onSeek: (d) => player.seek(d),
          dragValue: _dragValue,
          onDrag: (v) => setState(() => _dragValue = v),
          centerText: '原文件 · $quality',
        ),
        const SizedBox(height: 2),
        // 传输控制行。
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              iconSize: 24,
              color: Colors.white70,
              onPressed: () => ref.read(playModeProvider.notifier).cycle(),
              icon: Icon(switch (mode) {
                PlayMode.listLoop => Icons.repeat_rounded,
                PlayMode.singleLoop => Icons.repeat_one_rounded,
                PlayMode.sequential => Icons.trending_flat_rounded,
              }),
            ),
            IconButton(
              iconSize: 38,
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
                  iconSize: 60,
                  color: Colors.white,
                  onPressed: () => ref.read(playerActionsProvider).togglePlay(),
                  icon: Icon(
                    playing
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                  ),
                );
              },
            ),
            IconButton(
              iconSize: 38,
              color: Colors.white,
              onPressed: () => ref.read(playerActionsProvider).skip(next: true),
              icon: const Icon(Icons.skip_next_rounded),
            ),
            IconButton(
              iconSize: 24,
              color: Colors.white70,
              onPressed: () => _showVolume(player.volumeStream, player),
              icon: const Icon(Icons.volume_up_rounded),
            ),
          ],
        ),
      ],
    );
  }

  /// 音量底部弹层。
  void _showVolume(Stream<double> volumeStream, AudioPlayerService player) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Row(
            children: [
              const Icon(Icons.volume_down_rounded, color: Colors.white70),
              Expanded(
                child: StreamBuilder<double>(
                  stream: volumeStream,
                  initialData: player.volume,
                  builder: (context, snap) {
                    final vol =
                        (snap.data ?? 100.0).clamp(0.0, 100.0).toDouble();
                    return Slider(
                      value: vol,
                      max: 100,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white24,
                      onChanged: (v) => player.setVolume(v),
                    );
                  },
                ),
              ),
              const Icon(Icons.volume_up_rounded, color: Colors.white70),
            ],
          ),
        ),
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
                          trailing: IconButton(
                            tooltip: '从队列移除',
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () {
                              final wasCurrent = i == index;
                              final newIndex = ref
                                  .read(playQueueProvider.notifier)
                                  .removeAt(i);
                              final updated = ref.read(playQueueProvider);
                              if (updated.isEmpty) {
                                Navigator.pop(ctx);
                                ref.read(audioPlayerProvider).stop();
                                return;
                              }
                              if (wasCurrent) {
                                Navigator.pop(ctx);
                                ref
                                    .read(playerActionsProvider)
                                    .playItem(updated[newIndex]);
                              }
                            },
                          ),
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

/// 封面主图:圆角 + 阴影,空封面时用品牌渐变占位。
class _CoverArt extends StatelessWidget {
  const _CoverArt({required this.artwork});

  final String artwork;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(16));
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: artwork.isEmpty
            ? const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF3A2318),
                      Color(0xFFFF7A45),
                      Color(0xFF2A1A12),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.music_note_rounded,
                    color: Colors.white24,
                    size: 64,
                  ),
                ),
              )
            : Image.network(
                artwork,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF3A2318),
                        Color(0xFFFF7A45),
                        Color(0xFF2A1A12),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.music_note_rounded,
                      color: Colors.white24,
                      size: 64,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

/// 背景:封面放大 + 强模糊 + 暗化。
class _BlurredBackdrop extends StatelessWidget {
  const _BlurredBackdrop({required this.artwork});

  final String artwork;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (artwork.isEmpty)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2A1A12), Color(0xFF0A0A0A)],
              ),
            ),
          )
        else
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Image.network(
              artwork,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  const ColoredBox(color: Color(0xFF1A1310)),
            ),
          ),
        const ColoredBox(color: Color(0xB3000000)),
      ],
    );
  }
}

/// 歌词三行视图:当前行大且高亮,上下相邻行缩小、变淡。
class _LyricThreeLines extends ConsumerWidget {
  const _LyricThreeLines({required this.positionStream});

  final Stream<Duration> positionStream;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLyrics = ref.watch(lyricLinesProvider);
    return asyncLyrics.when(
      loading: () => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white38,
          ),
        ),
      ),
      error: (e, s) => const SizedBox.shrink(),
      data: (lines) {
        if (lines.isEmpty) {
          return const Center(
            child: Text('暂无歌词', style: TextStyle(color: Colors.white38)),
          );
        }
        return StreamBuilder<Duration>(
          stream: positionStream,
          builder: (context, snap) {
            final pos = snap.data ?? Duration.zero;
            final active = LrcParser.activeIndex(lines, pos);
            String textAt(int i) =>
                (i >= 0 && i < lines.length) ? lines[i].text : '';
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _lyricLine(textAt(active - 1), false, 15),
                const SizedBox(height: 2),
                _lyricLine(textAt(active), true, 20),
                const SizedBox(height: 2),
                _lyricLine(textAt(active + 1), false, 15),
              ],
            );
          },
        );
      },
    );
  }

  Widget _lyricLine(String text, bool active, double size) {
    return SizedBox(
      height: 24,
      child: Center(
        child: Text(
          text.isEmpty ? '♪' : text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: active ? Colors.white : Colors.white38,
          ),
        ),
      ),
    );
  }
}

/// 收藏按钮：切换当前曲目的收藏状态，实心/空心红心反馈。
class _FavoriteButton extends ConsumerWidget {
  const _FavoriteButton({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isFav = favorites.value != null &&
        ref.read(favoritesProvider.notifier).contains(item);
    return IconButton(
      tooltip: isFav ? '取消收藏' : '收藏',
      icon: Icon(
        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: isFav ? Colors.redAccent : Colors.white,
        size: 26,
      ),
      onPressed: () async {
        final nowFav = await ref.read(favoritesProvider.notifier).toggle(item);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(nowFav ? '已收藏' : '已取消收藏'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
    );
  }
}

/// 进度条 + 时间标签 + 中间说明文案(如音质/格式)。
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.playerPosition,
    required this.playerDuration,
    required this.onSeek,
    required this.dragValue,
    required this.onDrag,
    this.centerText,
  });

  final Stream<Duration> playerPosition;
  final Stream<Duration> playerDuration;
  final void Function(Duration) onSeek;
  final double? dragValue;
  final void Function(double?) onDrag;
  final String? centerText;

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
            final current = dragValue == null
                ? position
                : Duration(milliseconds: dragValue!.round());
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 14),
                    thumbColor: Colors.white,
                    activeTrackColor: Colors.white,
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
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Row(
                    children: [
                      Text(
                        _fmt(current),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          centerText ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white38,
                          ),
                        ),
                      ),
                      Text(
                        _fmt(duration),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
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
