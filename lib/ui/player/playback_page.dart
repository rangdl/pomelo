import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart' hide Track;
import 'package:pomelo/core/models/metadata/track.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/core/toast.dart';
import 'package:pomelo/provider/audio_player/audio_player.dart';
import 'package:pomelo/provider/cast/cast_provider.dart';
import 'package:pomelo/provider/lyric/lyric.dart';
import 'package:pomelo/provider/server/sourced_track.dart';
import 'package:pomelo/services/audio_player/audio_player.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../music/widgets/cover_image.dart';
import 'duration_format.dart';
import 'lyric_parser.dart';
import 'lyric_view.dart';
import 'widgets/bottom_sheet.dart';
import 'widgets/cast_button.dart';
import 'widgets/play_queue_content.dart';
import 'widgets/play_queue_sheet.dart';

/// 全屏播放页面
///
/// 展示当前播放曲目的完整信息和控制。
/// 移动端：竖向布局，封面居中。
/// 桌面端：横向布局，封面在左，信息和控制在右。
@RoutePage()
class PlaybackPage extends HookConsumerWidget {
  const PlaybackPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioPlayerProvider);
    final track = state.activeTrack;

    // 歌词获取与解析（track 为空时传入空 Track 占位避免条件 hook）
    final lyricLinesAsync = track == null
        ? const AsyncValue<List<LyricLine>>.data([])
        : ref.watch(lyricLinesProvider(track));
    // 仅依赖歌词异步结果，不随播放进度变化 → 本页 build 不会因进度流重建
    final lyricLines = useMemoized(
      () => lyricLinesAsync.value ?? <LyricLine>[],
      [lyricLinesAsync],
    );
    void onSeek(Duration d) => audioPlayer.seek(d);

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            IconButton.text(
              icon: const Icon(Icons.keyboard_arrow_down, size: 24),
              onPressed: () => closeOverlay(context),
            ),
          ],
          title: const Text('正在播放'),
          trailing: [
            const CastButton(),
            IconButton.text(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: () => _refreshStreamingUrl(context, ref, track),
            ),
            IconButton.text(
              icon: const Icon(Icons.queue_music, size: 22),
              onPressed: () => _openPlayQueue(context),
            ),
          ],
        ),
      ],
      child: track == null
          ? const Center(child: Text('暂无播放内容'))
          : Rx.layout(
              context,
              mobile: () => _PlaybackBody(
                track: track,
                isPlaying: state.playing,
                loopMode: state.loopMode,
                shuffled: state.shuffled,
                lyricLines: lyricLines,
                onSeek: onSeek,
                style: _mobileStyle,
                layout: _PlaybackLayout.vertical,
              ),
              // tablet 与 desktop 共用横向布局
              tablet: () => _PlaybackBody(
                track: track,
                isPlaying: state.playing,
                loopMode: state.loopMode,
                shuffled: state.shuffled,
                lyricLines: lyricLines,
                onSeek: onSeek,
                style: _desktopStyle,
                layout: _PlaybackLayout.horizontal,
              ),
            ),
    );
  }

  /// 响应式打开播放队列
  ///
  /// 移动端：底部 Sheet，支持下拉关闭
  /// 桌面端：右侧 Sheet（360px 宽）
  void _openPlayQueue(BuildContext context) {
    Rx.action(
      context,
      mobile: () => openBottomSheet(
        context: context,
        builder: (_) => const PlayQueueSheet(),
      ),
      tablet: () => openSheet(
        context: context,
        position: OverlayPosition.right,
        builder: (_) => const SizedBox(width: 360, child: PlayQueueContent()),
      ),
    );
  }

  /// 刷新当前曲目的播放链接
  ///
  /// 清空 SourcedTrack 中缓存的播放链接和本地缓存文件后重新获取。
  /// 仅对有音质类型（meta['types']）的在线曲目有效。
  Future<void> _refreshStreamingUrl(
    BuildContext context,
    WidgetRef ref,
    Track? track,
  ) async {
    if (track == null || track.isLocal) {
      context.toast.warning('当前曲目不支持刷新');
      return;
    }

    context.toast.info('正在刷新播放链接...');
    try {
      await ref.read(sourcedTrackProvider(track).notifier).forceRefresh();
      if (!context.mounted) return;
      context.toast.success('播放链接已刷新');
    } catch (e) {
      if (!context.mounted) return;
      context.toast.error('刷新失败: $e');
    }
  }
}

/// 播放页样式配置（差异化移动端与桌面端的字号/间距/圆角）
class _PlaybackStyle {
  final double coverRadius;
  final double titleFontSize;
  final int titleMaxLines;
  final TextAlign titleAlign;
  final double artistFontSize;
  final double albumFontSize;
  final double titleGap;
  final double mainControlGap;
  final double horizontalPadding;

  const _PlaybackStyle({
    required this.coverRadius,
    required this.titleFontSize,
    required this.titleMaxLines,
    required this.titleAlign,
    required this.artistFontSize,
    required this.albumFontSize,
    required this.titleGap,
    required this.mainControlGap,
    required this.horizontalPadding,
  });
}

const _mobileStyle = _PlaybackStyle(
  coverRadius: 12,
  titleFontSize: 22,
  titleMaxLines: 1,
  titleAlign: TextAlign.start,
  artistFontSize: 15,
  albumFontSize: 13,
  titleGap: 4,
  mainControlGap: 16,
  horizontalPadding: 24,
);

const _desktopStyle = _PlaybackStyle(
  coverRadius: 16,
  titleFontSize: 26,
  titleMaxLines: 2,
  titleAlign: TextAlign.center,
  artistFontSize: 16,
  albumFontSize: 14,
  titleGap: 6,
  mainControlGap: 20,
  horizontalPadding: 48,
);

/// 布局方向
enum _PlaybackLayout { vertical, horizontal }

/// 播放页主体（移动端竖向 / 桌面端横向共用同一组件，通过 [style] 与 [layout] 差异化）
///
/// 当 DLNA 投屏中（castState.isCasting）时，播放/暂停/上一首/下一首/seek
/// 自动转发到投屏设备，本地播放器保持暂停状态。
class _PlaybackBody extends HookConsumerWidget {
  final Track track;
  final bool isPlaying;
  final PlaylistMode loopMode;
  final bool shuffled;
  final List<LyricLine> lyricLines;
  final void Function(Duration)? onSeek;
  final _PlaybackStyle style;
  final _PlaybackLayout layout;

  const _PlaybackBody({
    required this.track,
    required this.isPlaying,
    required this.loopMode,
    required this.shuffled,
    required this.lyricLines,
    required this.onSeek,
    required this.style,
    required this.layout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 进度/时长流仅在 _PlaybackBody 子树内消费，不驱动外层 PlaybackPage 重建
    final position =
        useStream(
          audioPlayer.positionStream,
          initialData: audioPlayer.position,
        ).data ??
        Duration.zero;
    final duration =
        useStream(
          audioPlayer.durationStream,
          initialData: audioPlayer.duration,
        ).data ??
        Duration.zero;

    final coverUrl = track.coverArt;
    final albumName = track.album;

    return SafeArea(
      child: switch (layout) {
        _PlaybackLayout.vertical => _buildVertical(
          context,
          ref,
          coverUrl,
          albumName,
          position,
          duration,
        ),
        _PlaybackLayout.horizontal => _buildHorizontal(
          context,
          ref,
          coverUrl,
          albumName,
          position,
          duration,
        ),
      },
    );
  }

  // ===== 布局组装 =====

  Widget _buildVertical(
    BuildContext context,
    WidgetRef ref,
    String? coverUrl,
    String? albumName,
    Duration position,
    Duration duration,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: style.horizontalPadding),
      child: Column(
        children: [
          const Gap(16),
          Expanded(
            flex: 3,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: CoverImage(
                  coverArt: coverUrl,
                  colorScheme: Theme.of(context).colorScheme,
                  borderRadius: BorderRadius.circular(style.coverRadius),
                ),
              ),
            ),
          ),
          const Gap(16),
          _buildInfo(context, albumName),
          const Gap(8),
          Expanded(
            child: LyricView(
              lines: lyricLines,
              position: position,
              onSeek: onSeek,
            ),
          ),
          const Gap(8),
          _buildSeekBar(context, ref, position, duration),
          const Gap(16),
          _buildMainControls(context, ref),
          const Gap(8),
          _buildVolumeControl(context, ref),
          const Gap(12),
          _buildSecondaryControls(context),
          const Gap(24),
        ],
      ),
    );
  }

  Widget _buildHorizontal(
    BuildContext context,
    WidgetRef ref,
    String? coverUrl,
    String? albumName,
    Duration position,
    Duration duration,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: style.horizontalPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CoverImage(
                    coverArt: coverUrl,
                    colorScheme: Theme.of(context).colorScheme,
                    borderRadius: BorderRadius.circular(style.coverRadius),
                  ),
                ),
              ),
              const Gap(48),
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildInfo(context, albumName),
                    const Gap(16),
                    SizedBox(
                      height: 240,
                      child: LyricView(
                        lines: lyricLines,
                        position: position,
                        onSeek: onSeek,
                      ),
                    ),
                    const Gap(16),
                    _buildSeekBar(context, ref, position, duration),
                    const Gap(24),
                    _buildMainControls(context, ref),
                    const Gap(8),
                    _buildVolumeControl(context, ref),
                    const Gap(12),
                    _buildSecondaryControls(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== 共享子部件 =====

  Widget _buildInfo(BuildContext context, String? albumName) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          track.title,
          maxLines: style.titleMaxLines,
          overflow: TextOverflow.ellipsis,
          textAlign: style.titleAlign,
          style: TextStyle(
            fontSize: style.titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        Gap(style.titleGap),
        Text(
          track.artist ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: style.artistFontSize,
            color: colorScheme.mutedForeground,
          ),
        ),
        if (albumName != null && albumName.isNotEmpty) ...[
          const Gap(2),
          Text(
            albumName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: style.albumFontSize,
              color: colorScheme.mutedForeground,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSeekBar(
    BuildContext context,
    WidgetRef ref,
    Duration position,
    Duration duration,
  ) {
    final castState = ref.watch(castProvider);
    // 投屏中：使用投屏设备返回的进度；否则使用本地播放器进度
    final pos = castState.isCasting ? castState.position : position;
    final dur = castState.isCasting ? castState.duration : duration;
    final totalMs = dur.inMilliseconds.toDouble();
    final posMs = pos.inMilliseconds.toDouble().clamp(0.0, totalMs);
    final muted = Theme.of(context).colorScheme.mutedForeground;

    return Column(
      children: [
        Slider(
          value: SliderValue.single(totalMs > 0 ? posMs / totalMs : 0),
          onChanged: totalMs > 0
              ? (v) {
                  final target = Duration(
                    milliseconds: (v.value * totalMs).toInt(),
                  );
                  if (castState.isCasting) {
                    ref.read(castProvider.notifier).seek(target);
                  } else {
                    audioPlayer.seek(target);
                  }
                }
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDuration(pos),
                style: TextStyle(fontSize: 12, color: muted),
              ),
              Text(
                formatDuration(dur),
                style: TextStyle(fontSize: 12, color: muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainControls(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final castState = ref.watch(castProvider);

    // 投屏中：根据投屏设备的 transportState 决定图标；
    // 否则使用本地播放器的 isPlaying
    final castPlaying = castState.transportState == 'PLAYING';
    final showPlaying = castState.isCasting ? castPlaying : isPlaying;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.text(
          icon: const Icon(Icons.skip_previous, size: 36),
          onPressed: () => audioPlayer.skipToPrevious(),
        ),
        Gap(style.mainControlGap),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: IconButton.text(
            icon: Icon(
              showPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 36,
              color: colorScheme.primaryForeground,
            ),
            onPressed: () {
              if (castState.isCasting) {
                showPlaying
                    ? ref.read(castProvider.notifier).pause()
                    : ref.read(castProvider.notifier).resume();
              } else {
                isPlaying ? audioPlayer.pause() : audioPlayer.resume();
              }
            },
          ),
        ),
        Gap(style.mainControlGap),
        IconButton.text(
          icon: const Icon(Icons.skip_next, size: 36),
          onPressed: () => audioPlayer.skipToNext(),
        ),
      ],
    );
  }

  /// 音量控制：投屏中控制 DLNA 设备音量，否则控制本地播放器
  Widget _buildVolumeControl(BuildContext context, WidgetRef ref) {
    final castState = ref.watch(castProvider);
    final isCasting = castState.isCasting;
    // 本地音量记忆（0~1），避免无音量流时滑块跳变
    final localVolume = useState(audioPlayer.volume);
    final deviceVolume =
        castState.volume != null ? castState.volume! / 100 : localVolume.value;
    final displayVolume = isCasting ? deviceVolume : localVolume.value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton.ghost(
            icon: Icon(
              displayVolume <= 0.001
                  ? Icons.volume_off
                  : displayVolume < 0.5
                      ? Icons.volume_down
                      : Icons.volume_up,
              size: 18,
            ),
            onPressed: () {
              final target = displayVolume <= 0.001 ? 1.0 : 0.0;
              localVolume.value = target;
              if (isCasting) {
                ref
                    .read(castProvider.notifier)
                    .setVolume((target * 100).round());
              } else {
                audioPlayer.setVolume(target);
              }
            },
          ),
          Expanded(
            child: Slider(
              value: SliderValue.single(displayVolume.clamp(0.0, 1.0)),
              onChanged: (v) {
                final vol = v.value.clamp(0.0, 1.0);
                localVolume.value = vol;
                if (isCasting) {
                  ref
                      .read(castProvider.notifier)
                      .setVolume((vol * 100).round());
                } else {
                  audioPlayer.setVolume(vol);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryControls(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton.ghost(
          icon: Icon(
            Icons.shuffle,
            size: 20,
            color: shuffled ? colorScheme.primary : null,
          ),
          onPressed: () => audioPlayer.setShuffle(!shuffled),
        ),
        IconButton.ghost(
          icon: Icon(
            loopMode == PlaylistMode.loop
                ? Icons.repeat
                : loopMode == PlaylistMode.single
                ? Icons.repeat_one
                : Icons.repeat,
            size: 20,
            color: loopMode != PlaylistMode.none ? colorScheme.primary : null,
          ),
          onPressed: () {
            final next = switch (loopMode) {
              PlaylistMode.none => PlaylistMode.loop,
              PlaylistMode.loop => PlaylistMode.single,
              PlaylistMode.single => PlaylistMode.none,
            };
            audioPlayer.setLoopMode(next);
          },
        ),
      ],
    );
  }
}
