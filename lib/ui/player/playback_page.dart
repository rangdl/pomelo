import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart' hide Track;
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/modules/audio_player/module_providers.dart';
import 'package:pomelo/modules/audio_player/service/audio_player_service.dart';
import 'package:pomelo/modules/music/model/track.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../music/widgets/cover_image.dart';
import 'duration_format.dart';
import 'lyric_parser.dart';
import 'lyric_view.dart';
import 'widgets/bottom_sheet.dart';
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
    final audioPlayer = ref.watch(audioPlayerServiceProvider);
    final state = ref.watch(audioPlayerProvider);
    final track = state.activeTrack;

    // 实时播放进度
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

    // 歌词获取与解析
    final lyricAsync = track == null
        ? const AsyncValue<String?>.data(null)
        : ref.watch(lyricProvider(track));
    final lyricText = lyricAsync.value;
    final lyricLines = useMemoized(
      () => lyricText != null ? LyricParser.parse(lyricText) : <LyricLine>[],
      [lyricText],
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
                position: position,
                duration: duration,
                audioPlayer: audioPlayer,
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
                position: position,
                duration: duration,
                audioPlayer: audioPlayer,
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
        builder: (_) => const SizedBox(
          width: 360,
          child: PlayQueueContent(),
        ),
      ),
    );
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
class _PlaybackBody extends StatelessWidget {
  final Track track;
  final bool isPlaying;
  final PlaylistMode loopMode;
  final bool shuffled;
  final Duration position;
  final Duration duration;
  final AudioPlayerService audioPlayer;
  final List<LyricLine> lyricLines;
  final void Function(Duration)? onSeek;
  final _PlaybackStyle style;
  final _PlaybackLayout layout;

  const _PlaybackBody({
    required this.track,
    required this.isPlaying,
    required this.loopMode,
    required this.shuffled,
    required this.position,
    required this.duration,
    required this.audioPlayer,
    required this.lyricLines,
    required this.onSeek,
    required this.style,
    required this.layout,
  });

  @override
  Widget build(BuildContext context) {
    final coverUrl = track.coverArt;
    final albumName = track.album;

    return SafeArea(
      child: switch (layout) {
        _PlaybackLayout.vertical => _buildVertical(context, coverUrl, albumName),
        _PlaybackLayout.horizontal => _buildHorizontal(context, coverUrl, albumName),
      },
    );
  }

  // ===== 布局组装 =====

  Widget _buildVertical(BuildContext context, String? coverUrl, String? albumName) {
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
          _buildSeekBar(context),
          const Gap(16),
          _buildMainControls(context),
          const Gap(20),
          _buildSecondaryControls(context),
          const Gap(24),
        ],
      ),
    );
  }

  Widget _buildHorizontal(BuildContext context, String? coverUrl, String? albumName) {
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
                    _buildSeekBar(context),
                    const Gap(24),
                    _buildMainControls(context),
                    const Gap(20),
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

  Widget _buildSeekBar(BuildContext context) {
    final totalMs = duration.inMilliseconds.toDouble();
    final posMs = position.inMilliseconds.toDouble().clamp(0.0, totalMs);
    final muted = Theme.of(context).colorScheme.mutedForeground;

    return Column(
      children: [
        Slider(
          value: SliderValue.single(totalMs > 0 ? posMs / totalMs : 0),
          onChanged: totalMs > 0
              ? (v) => audioPlayer.seek(
                  Duration(milliseconds: (v.value * totalMs).toInt()),
                )
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDuration(position),
                style: TextStyle(fontSize: 12, color: muted),
              ),
              Text(
                formatDuration(duration),
                style: TextStyle(fontSize: 12, color: muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainControls(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 36,
              color: colorScheme.primaryForeground,
            ),
            onPressed: () {
              isPlaying ? audioPlayer.pause() : audioPlayer.resume();
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
            color: loopMode != PlaylistMode.none
                ? colorScheme.primary
                : null,
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
