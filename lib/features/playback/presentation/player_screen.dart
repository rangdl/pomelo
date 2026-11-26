import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/settings/theme_mode.dart';
import '../../../shared/ui/duration_fmt.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../../plugins/presentation/library_providers.dart';
import '../application/player_actions.dart';
import '../data/audio_player_service.dart';
import '../data/lrc_parser.dart';
import '../data/media_proxy_server.dart';
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

    final artwork = trackArtwork(item);
    final title = '${item['title'] ?? '未知歌曲'}';
    final artist = '${item['artist'] ?? ''}';
    final quality = ref.watch(audioQualityProvider).label;

    return Scaffold(
      backgroundColor: Colors.black,
      // 全屏铺满，不再做顶部圆角（避免顶部左右两个角被裁出缺口）。
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 背景:封面的模糊暗化版,营造沉浸感(不抢前景)。
          _BlurredBackdrop(artwork: artwork),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 矮窗口(如桌面小窗)下把空间让给歌词,避免封面把歌词挤没。
                final short = constraints.maxHeight < 620;
                final coverFlex = short ? 4 : 6;
                final lyricFlex = short ? 3 : 2;
                return Column(
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
                    // 上部:封面主图(调大)。切歌时交叉淡入淡出过渡。
                    Expanded(
                      flex: coverFlex,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xxl,
                          0,
                          AppSpacing.xxl,
                          AppSpacing.sm,
                        ),
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _CoverArt(
                                key: ValueKey(artwork),
                                artwork: artwork,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 中部:歌词滚动区(当前行居中,整首随播放平滑上移)。
                    Expanded(
                      flex: lyricFlex,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: _LyricScrollView(
                          positionStream: player.positionStream,
                          onSeek: (d) => player.seek(d),
                        ),
                      ),
                    ),
                    // 下部:歌名-歌手 / 收藏·队列 / 进度 / 控制(整体上移)。
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        0,
                        AppSpacing.xl,
                        AppSpacing.xl,
                      ),
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
                );
              },
            ),
          ),
        ],
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
              // 切歌时歌名/歌手交叉淡入淡出。
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                // 默认 Stack 居中对齐会把整块文字推到中间,这里改为左对齐。
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  alignment: Alignment.centerLeft,
                  children: [...previousChildren, ?currentChild],
                ),
                child: SizedBox(
                  key: ValueKey('$title-$artist'),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: AppText.displayTitle,
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
                            fontSize: AppText.rowTitle,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
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
                  // 播放/暂停切换时缩放过渡,替代生硬跳变。
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      playing
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      key: ValueKey(playing),
                    ),
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
    // 弹层背景走主题(跟随亮/暗模式),不写死深色。
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Row(
            children: [
              // 点击喇叭图标静音 / 取消静音。
              StreamBuilder<double>(
                stream: volumeStream,
                initialData: player.volume,
                builder: (context, snap) {
                  final vol = (snap.data ?? 100.0).clamp(0.0, 100.0);
                  return IconButton(
                    tooltip: vol <= 0 ? '取消静音' : '静音',
                    onPressed: player.toggleMute,
                    icon: Icon(
                      vol <= 0
                          ? Icons.volume_off_rounded
                          : vol < 50
                          ? Icons.volume_down_rounded
                          : Icons.volume_up_rounded,
                    ),
                  );
                },
              ),
              Expanded(
                child: StreamBuilder<double>(
                  stream: volumeStream,
                  initialData: player.volume,
                  builder: (context, snap) {
                    final vol = (snap.data ?? 100.0)
                        .clamp(0.0, 100.0)
                        .toDouble();
                    return Slider(
                      value: vol,
                      max: 100,
                      onChanged: (v) => player.setVolume(v),
                    );
                  },
                ),
              ),
              const Icon(Icons.volume_up_rounded),
            ],
          ),
        ),
      ),
    );
  }

  void _showQueue(List<Map<String, dynamic>> queue, int currentIndex) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
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
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: Row(
                            children: [
                              Text(
                                '共 ${items.length} 首',
                                style: Theme.of(ctx).textTheme.bodySmall,
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () {
                                  ref.read(playQueueProvider.notifier).clear();
                                  ref.read(audioPlayerProvider).stop();
                                  Navigator.pop(ctx);
                                },
                                icon: const Icon(
                                  Icons.delete_sweep_rounded,
                                  size: 18,
                                ),
                                label: const Text('清空'),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ReorderableListView.builder(
                            itemCount: items.length,
                            // 列表头的 to 已是「移除后」的位置。
                            onReorderItem: (from, to) {
                              final queue = ref.read(
                                playQueueProvider.notifier,
                              );
                              queue.move(from, to);
                              ref
                                  .read(audioPlayerProvider)
                                  .updateQueueIndex(queue.index);
                            },
                            itemBuilder: (ctx, i) {
                              final it = items[i];
                              final current = i == index;
                              return ListTile(
                                key: ValueKey(
                                  '${it['_pluginId'] ?? ''}'
                                  ':${it['id'] ?? it['title'] ?? ''}:$i',
                                ),
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
                                  ref
                                      .read(playQueueProvider.notifier)
                                      .jumpTo(i);
                                  ref.read(playerActionsProvider).safePlay(it);
                                },
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: '从队列移除',
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        final wasCurrent = i == index;
                                        final newIndex = ref
                                            .read(playQueueProvider.notifier)
                                            .removeAt(i);
                                        final updated = ref.read(
                                          playQueueProvider,
                                        );
                                        if (updated.isEmpty) {
                                          Navigator.pop(ctx);
                                          ref.read(audioPlayerProvider).stop();
                                          return;
                                        }
                                        if (wasCurrent) {
                                          Navigator.pop(ctx);
                                          ref
                                              .read(playerActionsProvider)
                                              .safePlay(updated[newIndex]);
                                        }
                                      },
                                    ),
                                    // 桌面端用鼠标也能直接拖动排序。
                                    ReorderableDragStartListener(
                                      index: i,
                                      child: const Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Icon(
                                          Icons.drag_handle_rounded,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}

/// 封面主图:圆角 + 阴影,空封面时用主题色渐变占位。
class _CoverArt extends StatelessWidget {
  const _CoverArt({super.key, required this.artwork});

  final String artwork;

  @override
  Widget build(BuildContext context) {
    final radius = AppRadius.floatingBorder;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(
            color: AppOverlay.coverShadow,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: !isRemoteHttpUrl(artwork)
            ? const _CoverPlaceholder()
            : Image.network(
                cachedArtworkUrl(artwork),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) =>
                    const _CoverPlaceholder(),
              ),
      ),
    );
  }
}

/// 封面占位:主题色渐变(跟随设置里的主题色,不再写死品牌色)。
class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withValues(alpha: 0.25),
            scheme.primary,
            scheme.primary.withValues(alpha: 0.15),
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.music_note_rounded, color: Colors.white24, size: 64),
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
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (!isRemoteHttpUrl(artwork))
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [scheme.primary.withValues(alpha: 0.2), Colors.black],
              ),
            ),
          )
        else
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Image.network(
              cachedArtworkUrl(artwork),
              fit: BoxFit.cover,
              // 背景被 40px 模糊，没必要按原图解码。
              cacheWidth: 240,
              errorBuilder: (context, error, stack) =>
                  const ColoredBox(color: Colors.black),
            ),
          ),
        const ColoredBox(color: AppOverlay.scrim),
      ],
    );
  }
}

/// 歌词滚动视图:整首歌词连续滚动,当前行始终停在中间并放大高亮。
class _LyricScrollView extends ConsumerStatefulWidget {
  const _LyricScrollView({required this.positionStream, required this.onSeek});

  final Stream<Duration> positionStream;

  /// 点击某行歌词时跳转到该行时间点（桌面端无手势拖动也能定位）。
  final void Function(Duration) onSeek;

  @override
  ConsumerState<_LyricScrollView> createState() => _LyricScrollViewState();
}

class _LyricScrollViewState extends ConsumerState<_LyricScrollView> {
  static const double _lineHeight = 34;

  final ScrollController _controller = ScrollController();
  int _lastActive = -1;

  /// 用户手动拖动歌词后暂停自动滚动的时间点(4 秒后恢复)。
  DateTime? _autoPauseUntil;

  bool get _autoPaused =>
      _autoPauseUntil != null && DateTime.now().isBefore(_autoPauseUntil!);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 用户拖动时暂停自动回中,避免和手指抢滚动。
  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _autoPauseUntil = DateTime.now().add(const Duration(seconds: 4));
    }
    return false;
  }

  /// 让第 [active] 行停在视口中间（列表上下留白 = 半个视口）。
  void _scrollToActive(int active) {
    if (active == _lastActive) return;
    _lastActive = active;
    if (_autoPaused) return;
    // 等本次布局完成后再滚动，否则拿不到正确的滚动范围。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      final target = (active * _lineHeight).clamp(
        0.0,
        _controller.position.maxScrollExtent,
      );
      _controller.animateTo(
        target,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
      error: (e, s) => const Center(
        child: Text('歌词加载失败', style: TextStyle(color: Colors.white38)),
      ),
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
            _scrollToActive(active);
            return LayoutBuilder(
              builder: (context, constraints) {
                final pad = math.max(
                  0.0,
                  (constraints.maxHeight - _lineHeight) / 2,
                );
                return NotificationListener<ScrollNotification>(
                  onNotification: _onScroll,
                  child: ListView.builder(
                    controller: _controller,
                    // 允许手动回看;用户拖动后 4 秒内不自动回中。
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: pad),
                    itemExtent: _lineHeight,
                    itemCount: lines.length,
                    itemBuilder: (context, i) {
                      final isActive = i == active;
                      return Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          style: TextStyle(
                            fontSize: isActive ? 20 : 15,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isActive ? Colors.white : Colors.white54,
                          ),
                          child: InkWell(
                            // 点击歌词跳转到对应时间。
                            onTap: () => widget.onSeek(lines[i].time),
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              child: Text(
                                lines[i].text.isEmpty ? '♪' : lines[i].text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
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
      },
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
    final isFav =
        favorites.value != null &&
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
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
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
                        formatDuration(current),
                        style: const TextStyle(
                          fontSize: AppText.compact,
                          color: Colors.white70,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          centerText ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: AppText.compact,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                      Text(
                        formatDuration(duration),
                        style: const TextStyle(
                          fontSize: AppText.compact,
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
}
