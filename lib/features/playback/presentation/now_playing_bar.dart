import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../application/player_actions.dart';
import '../data/lrc_parser.dart';
import 'playback_providers.dart';
import 'player_sheet.dart';

/// 浮在内容之上的迷你播放胶囊。
///
/// 与底部导航栏一致：玻璃材质、按内容宽度自适应（超宽窗口限宽并居中），
/// 直接叠在页面内容上层，不占布局高度。没有正在播放的曲目时不显示。
class FloatingNowPlaying extends ConsumerWidget {
  const FloatingNowPlaying({super.key, this.aboveNavigation = false});

  /// 是否与底部导航胶囊叠放在一起。为 false 时（没有底部导航的页面，
  /// 如详情页）自己负责底部安全区与 6 的留白，与导航胶囊的底部边距一致。
  final bool aboveNavigation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(nowPlayingProvider) == null) {
      return const SizedBox.shrink();
    }
    if (aboveNavigation) {
      // 作为底部浮层的一部分（叠在底部导航之上），底部安全区由导航栏负责，
      // 这里只留与导航之间的小间距。
      return Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 8),
        // heightFactor: 1 —— 只占胶囊自身高度，不铺满下层导致挡住内容点击。
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: const NowPlayingBar(),
          ),
        ),
      );
    }
    // 独立浮层：底部边距与底部导航胶囊一致（安全区 + 6）。
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 6),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: const NowPlayingBar(),
          ),
        ),
      ),
    );
  }
}

/// 底部迷你播放条:点击进入全屏播放页。
class NowPlayingBar extends ConsumerWidget {
  const NowPlayingBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(nowPlayingProvider);
    if (item == null) return const SizedBox.shrink();
    final player = ref.watch(audioPlayerProvider);
    final scheme = Theme.of(context).colorScheme;
    final artwork = trackArtwork(item);
    final title = '${item['title'] ?? '未知歌曲'}';
    final artist = '${item['artist'] ?? ''}'.trim();
    final label = artist.isEmpty ? title : '$title - $artist';
    final stage = ref.watch(playbackStageProvider);
    // 点击后立即按用户意图显示，等播放器真实状态追上再交还。
    final intent = ref.watch(playbackIntentProvider);

    return GlassContainer(
      shape: const LiquidRoundedSuperellipse(borderRadius: AppRadius.glass),
      padding: EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.glass),
          onTap: () => showPlayerSheet(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.glass),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 顶部细进度条：只做进度提示，不改变胶囊的圆角与内边距。
                _MiniProgressBar(
                  positionStream: player.positionStream,
                  durationStream: player.effectiveDurationStream,
                  fallbackDuration: player.effectiveDuration,
                  color: scheme.primary,
                  backgroundColor: scheme.onSurface.withValues(alpha: 0.10),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: AppRadius.badgeBorder,
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: CoverImage(
                            url: artwork,
                            decodeWidth: 36,
                            iconSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 歌名 - 歌手放一行，超长时自动滚动。
                            MarqueeText(
                              label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: AppText.rowTitle,
                              ),
                            ),
                            // 原歌手位置：取链/兜底进行中显示进度；
                            // 播放中且有歌词时，单行向上滑动展示当前歌词。
                            _MiniSubtitleLine(
                              stage: stage,
                              positionStream: player.positionStream,
                              playingStream: player.playingStream,
                              color: scheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
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
                          final playing = intent ?? (snap.data ?? false);
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 迷你播放条顶部进度指示（2px，纯展示，不可拖动）。
class _MiniProgressBar extends StatelessWidget {
  const _MiniProgressBar({
    required this.positionStream,
    required this.durationStream,
    required this.color,
    required this.backgroundColor,
    this.fallbackDuration = Duration.zero,
  });

  final Stream<Duration> positionStream;
  final Stream<Duration> durationStream;
  final Color color;
  final Color backgroundColor;

  /// 流尚未发射时的兜底时长（来自媒体元信息）。
  final Duration fallbackDuration;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: positionStream,
      builder: (context, posSnap) {
        return StreamBuilder<Duration>(
          stream: durationStream,
          builder: (context, durSnap) {
            var duration = durSnap.data ?? Duration.zero;
            if (duration <= Duration.zero) duration = fallbackDuration;
            final total = duration.inMilliseconds;
            final current = (posSnap.data ?? Duration.zero).inMilliseconds;
            final value = total <= 0 ? 0.0 : (current / total).clamp(0.0, 1.0);
            return LinearProgressIndicator(
              value: value,
              minHeight: 2,
              color: color,
              backgroundColor: backgroundColor,
            );
          },
        );
      },
    );
  }
}

/// 迷你胶囊的副标题行：取链/兜底进行中显示进度文案；播放中且有歌词时，
/// 单行展示当前歌词，切换行时像播放页那样向上滑动过渡。
class _MiniSubtitleLine extends ConsumerWidget {
  const _MiniSubtitleLine({
    required this.stage,
    required this.positionStream,
    required this.playingStream,
    required this.color,
  });

  final PlaybackStage stage;
  final Stream<Duration> positionStream;
  final Stream<bool> playingStream;
  final Color color;

  static const TextStyle _style = TextStyle(fontSize: AppText.rowSubtitle);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy =
        stage == PlaybackStage.resolving || stage == PlaybackStage.fallback;
    // 取链/兜底进行中：优先显示进度文案。
    if (busy) {
      return Text(
        stage.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _style.copyWith(color: color),
      );
    }
    final lines = ref.watch(lyricLinesProvider).value ?? const <LyricLine>[];
    if (lines.isEmpty) {
      // 无歌词：非播放态时保持空行（与原占位一致）。
      return Text(
        stage.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _style.copyWith(color: color),
      );
    }
    return StreamBuilder<bool>(
      stream: playingStream,
      initialData: true,
      builder: (context, playSnap) {
        final playing = playSnap.data ?? false;
        return StreamBuilder<Duration>(
          stream: positionStream,
          builder: (context, posSnap) {
            final pos = posSnap.data ?? Duration.zero;
            final active = LrcParser.activeIndex(lines, pos);
            final text = playing && active >= 0 && active < lines.length
                ? lines[active].text.trim()
                : '';
            return _RollingLyricLine(
              text: text,
              style: _style.copyWith(color: color),
            );
          },
        );
      },
    );
  }
}

/// 单行歌词的「向上滚动」过渡：新行自下而上滑入，旧行继续向上滑出，
/// 与播放页歌词区整首歌上移的方向一致。
class _RollingLyricLine extends StatefulWidget {
  const _RollingLyricLine({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  State<_RollingLyricLine> createState() => _RollingLyricLineState();
}

class _RollingLyricLineState extends State<_RollingLyricLine>
    with SingleTickerProviderStateMixin {
  static const double _height = 16;
  static const Duration _duration = Duration(milliseconds: 300);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  String _previous = '';
  late String _current = widget.text;

  @override
  void initState() {
    super.initState();
    // 首次出现即为静止文本，不做入场滑动。
    if (_current.isNotEmpty) _controller.value = 1;
  }

  @override
  void didUpdateWidget(_RollingLyricLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text == _current) return;
    // 暂停/恢复对应空文本，此时只做淡出/淡入（旧行为），
    // 真正换行时才是「旧行上滑出、新行下侧滑入」。
    _previous = _current;
    _current = widget.text;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _line(String text, Key key) {
    return Text(
      text,
      key: key,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: widget.style,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      width: double.infinity,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _curve,
          builder: (context, _) {
            final t = _curve.value;
            final hasOld = _previous.isNotEmpty && t < 1;
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // 旧行：从原位继续向上滑出。
                if (hasOld)
                  Positioned.fill(
                    child: FractionalTranslation(
                      translation: Offset(0, -t),
                      child: FadeTransition(
                        // 旧行淡出（同一 Curve 反向使用即可）。
                        opacity: Tween<double>(
                          begin: 1,
                          end: 0,
                        ).animate(_curve),
                        child: _line(_previous, const ValueKey('prev')),
                      ),
                    ),
                  ),
                // 新行：从下方滑入到原位。
                if (_current.isNotEmpty)
                  Positioned.fill(
                    child: FractionalTranslation(
                      translation: Offset(0, 1 - t),
                      child: FadeTransition(
                        opacity: _curve,
                        child: _line(_current, const ValueKey('cur')),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
