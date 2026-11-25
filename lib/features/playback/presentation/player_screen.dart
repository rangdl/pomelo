import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/settings/theme_mode.dart';
import '../../plugins/presentation/library_providers.dart';
import '../application/player_actions.dart';
import '../data/audio_player_service.dart';
import '../data/lrc_parser.dart';
import '../domain/play_mode.dart';
import 'playback_providers.dart';

/// 沉浸式全屏播放页:封面满屏为背景,底部信息与控制直接浮在封面上。
///
/// 布局参考主流音乐 App:顶部「下箭头」返回,中部大面积封面,底部依次是
/// 歌名-歌手 / 收藏·队列 / 进度条 / 时间·音质 / 传输控制。
/// 点中部封面区域可在「封面」与「歌词」之间切换。
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  double? _dragValue;
  bool _showLyrics = false;

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
      extendBody: true,
      extendBodyBehindAppBar: true,
      // 底部信息与控制放在 bottomNavigationBar：由 Scaffold 原生布局，位于
      // Stack 之外，避免与全屏封面层叠导致按钮 hit-test 失效；extendBody 让
      // 封面 body 延伸到其背后，视觉上仍满屏。
      bottomNavigationBar: _buildControls(
        context,
        item,
        player,
        mode,
        queue,
        queueIndex,
        title,
        artist,
        quality,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 封面背景(满屏) + 上下暗渐变保证可读。
          _PlayerBackground(artwork: artwork, dimmed: _showLyrics),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // 顶部:下箭头返回。
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: '收起',
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                // 中部:点击切换封面/歌词。
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _showLyrics = !_showLyrics),
                    child: _showLyrics
                        ? Padding(
                            // 底部留出控制区高度，避免歌词文字与控制区重叠。
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 220),
                            child: _LyricView(
                              positionStream: player.positionStream,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 底部控制区：歌名-歌手 + 收藏/歌词/队列 + 进度 + 传输控制。
  Widget _buildControls(
    BuildContext context,
    Map<String, dynamic> item,
    AudioPlayerService player,
    PlayMode mode,
    List<Map<String, dynamic>> queue,
    int queueIndex,
    String title,
    String artist,
    String quality,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Color(0xCC000000)],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 歌名-歌手 + 收藏/歌词/队列。
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
                    tooltip: _showLyrics ? '显示封面' : '显示歌词',
                    onPressed: () => setState(() => _showLyrics = !_showLyrics),
                    icon: Icon(
                      _showLyrics
                          ? Icons.music_note_rounded
                          : Icons.lyrics_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
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
              const SizedBox(height: 4),
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
                        onPressed: () =>
                            ref.read(playerActionsProvider).togglePlay(),
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
                    onPressed: () =>
                        ref.read(playerActionsProvider).skip(next: true),
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
          ),
        ),
      ),
    );
  }

  /// 音量通过底部弹层调节（参照图控制行右侧音量图标）。
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

/// 歌词视图:随播放进度自动高亮当前行并居中滚动。
class _LyricView extends ConsumerStatefulWidget {
  const _LyricView({required this.positionStream});

  final Stream<Duration> positionStream;

  @override
  ConsumerState<_LyricView> createState() => _LyricViewState();
}

class _LyricViewState extends ConsumerState<_LyricView> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncLyrics = ref.watch(lyricLinesProvider);
    return asyncLyrics.when(
      loading: () => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
        ),
      ),
      error: (err, stack) => const SizedBox.shrink(),
      data: (lines) {
        if (lines.isEmpty) {
          return const Center(
            child: Text('暂无歌词', style: TextStyle(color: Colors.white38)),
          );
        }
        return StreamBuilder<Duration>(
          stream: widget.positionStream,
          builder: (context, snap) {
            final pos = snap.data ?? Duration.zero;
            final active = LrcParser.activeIndex(lines, pos);
            const lineHeight = 38.0;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_scroll.hasClients) return;
              final target = (active * lineHeight) -
                  (_scroll.position.viewportDimension / 2) +
                  lineHeight / 2;
              _scroll.animateTo(
                target.clamp(
                  _scroll.position.minScrollExtent,
                  _scroll.position.maxScrollExtent,
                ),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
              );
            });
            return ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
                stops: [0.0, 0.15, 0.85, 1.0],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: ListView.builder(
                controller: _scroll,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 140),
                itemCount: lines.length,
                itemBuilder: (context, i) {
                  final isActive = i == active;
                  return SizedBox(
                    height: lineHeight,
                    child: Center(
                      child: Text(
                        lines[i].text.isEmpty ? '♪' : lines[i].text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isActive ? 19 : 16,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                          color: isActive ? Colors.white : Colors.white54,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

/// 封面背景:满屏封面 + 上下暗渐变(底部更暗,给信息区可读性)。
/// [dimmed] 为真(歌词态)时整体压暗更多。
class _PlayerBackground extends StatelessWidget {
  const _PlayerBackground({required this.artwork, this.dimmed = false});

  final String artwork;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final overlay = dimmed
        ? const [
            Color(0xCC000000),
            Color(0xF0000000),
            Color(0xCC000000),
          ]
        : const [
            Color(0x66000000),
            Color(0x22000000),
            Color(0xF20A0A0A),
          ];

    final gradient = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: overlay,
          stops: dimmed ? const [0.0, 0.5, 1.0] : const [0.0, 0.45, 1.0],
        ),
      ),
    );

    if (artwork.isEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3A2318), Color(0xFFFF7A45), Color(0xFF2A1A12)],
              ),
            ),
          ),
          gradient,
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          artwork,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => const ColoredBox(
            color: Color(0xFF241812),
          ),
        ),
        gradient,
      ],
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
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
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
