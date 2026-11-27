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
  const FloatingNowPlaying({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(nowPlayingProvider) == null) {
      return const SizedBox.shrink();
    }
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 10),
        // heightFactor: 1 —— 只占胶囊自身高度，不铺满下层导致挡住内容点击。
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
                  durationStream: player.durationStream,
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
  });

  final Stream<Duration> positionStream;
  final Stream<Duration> durationStream;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: positionStream,
      builder: (context, posSnap) {
        return StreamBuilder<Duration>(
          stream: durationStream,
          builder: (context, durSnap) {
            final total = (durSnap.data ?? Duration.zero).inMilliseconds;
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
    final busy = stage == PlaybackStage.resolving ||
        stage == PlaybackStage.fallback;
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
            final text = active >= 0 && active < lines.length
                ? lines[active].text.trim()
                : '';
            // 暂停时淡出歌词（只留歌名），播放时淡入。
            return ClipRect(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  // 向上滑入 / 向上滑出，与播放页歌词方向一致。
                  final offset = Tween<Offset>(
                    begin: const Offset(0, 0.6),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: playing
                    ? Text(
                        text,
                        key: ValueKey<int>(active),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _style.copyWith(color: color),
                      )
                    : const SizedBox(
                        key: ValueKey('paused'),
                        width: double.infinity,
                        height: 14,
                      ),
              ),
            );
          },
        );
      },
    );
  }
}

