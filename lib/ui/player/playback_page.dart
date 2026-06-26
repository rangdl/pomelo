import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart' hide Track;
import 'package:pomelo/core/routers/app_router.gr.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/modules/audio_player/module_providers.dart';
import 'package:pomelo/modules/music/model/track.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../music/widgets/cover_placeholder.dart';
import 'lyric_parser.dart';
import 'lyric_view.dart';
import 'widgets/play_queue_content.dart';

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
              onPressed: () => Navigator.of(context).pop(),
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
              mobile: () => _MobileLayout(
                track: track,
                isPlaying: state.playing,
                loopMode: state.loopMode,
                shuffled: state.shuffled,
                position: position,
                duration: duration,
                audioPlayer: audioPlayer,
                lyricLines: lyricLines,
                onSeek: onSeek,
              ),
              tablet: () => _DesktopLayout(
                track: track,
                isPlaying: state.playing,
                loopMode: state.loopMode,
                shuffled: state.shuffled,
                position: position,
                duration: duration,
                audioPlayer: audioPlayer,
                lyricLines: lyricLines,
                onSeek: onSeek,
              ),
              desktop: () => _DesktopLayout(
                track: track,
                isPlaying: state.playing,
                loopMode: state.loopMode,
                shuffled: state.shuffled,
                position: position,
                duration: duration,
                audioPlayer: audioPlayer,
                lyricLines: lyricLines,
                onSeek: onSeek,
              ),
            ),
    );
  }

  /// 响应式打开播放队列
  ///
  /// 移动端：pushRoute 进入全屏页
  /// 桌面端：openSheet 从右侧滑出 360px 宽面板
  void _openPlayQueue(BuildContext context) {
    Rx.action(
      context,
      mobile: () => context.pushRoute(const PlayQueueRoute()),
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

/// 移动端布局 — 竖向排列
class _MobileLayout extends StatelessWidget {
  final Track track;
  final bool isPlaying;
  final PlaylistMode loopMode;
  final bool shuffled;
  final Duration position;
  final Duration duration;
  final dynamic audioPlayer;
  final List<LyricLine> lyricLines;
  final void Function(Duration)? onSeek;

  const _MobileLayout({
    required this.track,
    required this.isPlaying,
    required this.loopMode,
    required this.shuffled,
    required this.position,
    required this.duration,
    required this.audioPlayer,
    required this.lyricLines,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final coverUrl = track.coverArt;
    final albumName = track.album;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Gap(16),
            // 封面
            Expanded(
              flex: 3,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildCover(context, coverUrl),
                  ),
                ),
              ),
            ),
            const Gap(16),
            // 歌曲信息
            _buildInfo(context, albumName),
            const Gap(8),
            // 歌词滚动
            Expanded(
              child: LyricView(
                lines: lyricLines,
                position: position,
                onSeek: onSeek,
              ),
            ),
            const Gap(8),
            // 进度条
            _buildSeekBar(context),
            const Gap(16),
            // 主控制
            _buildMainControls(context),
            const Gap(20),
            // 副控制
            _buildSecondaryControls(context),
            const Gap(24),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context, String? coverUrl) {
    if (coverUrl != null && coverUrl.isNotEmpty) {
      return Image.network(
        coverUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            CoverPlaceholder(colorScheme: Theme.of(context).colorScheme),
      );
    }
    return CoverPlaceholder(colorScheme: Theme.of(context).colorScheme);
  }

  Widget _buildInfo(BuildContext context, String? albumName) {
    return Column(
      children: [
        Text(
          track.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const Gap(4),
        Text(
          track.artist ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).colorScheme.mutedForeground,
          ),
        ),
        if (albumName != null && albumName.isNotEmpty) ...[
          const Gap(2),
          Text(
            albumName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSeekBar(BuildContext context) {
    final totalMs = duration.inMilliseconds.toDouble();
    final posMs = position.inMilliseconds.toDouble().clamp(0.0, totalMs);

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
                _formatDuration(position),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.mutedForeground,
                ),
              ),
              Text(
                _formatDuration(duration),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.mutedForeground,
                ),
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
        const Gap(16),
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
        const Gap(16),
        IconButton.text(
          icon: const Icon(Icons.skip_next, size: 36),
          onPressed: () => audioPlayer.skipToNext(),
        ),
      ],
    );
  }

  Widget _buildSecondaryControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton.ghost(
          icon: Icon(
            Icons.shuffle,
            size: 20,
            color: shuffled ? Theme.of(context).colorScheme.primary : null,
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
                ? Theme.of(context).colorScheme.primary
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

/// 桌面端布局 — 横向排列
class _DesktopLayout extends StatelessWidget {
  final Track track;
  final bool isPlaying;
  final PlaylistMode loopMode;
  final bool shuffled;
  final Duration position;
  final Duration duration;
  final dynamic audioPlayer;
  final List<LyricLine> lyricLines;
  final void Function(Duration)? onSeek;

  const _DesktopLayout({
    required this.track,
    required this.isPlaying,
    required this.loopMode,
    required this.shuffled,
    required this.position,
    required this.duration,
    required this.audioPlayer,
    required this.lyricLines,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final coverUrl = track.coverArt;
    final albumName = track.album;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 左侧：封面
                Expanded(
                  flex: 4,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildCover(context, coverUrl),
                    ),
                  ),
                ),
                const Gap(48),
                // 右侧：信息和控制
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
      ),
    );
  }

  Widget _buildCover(BuildContext context, String? coverUrl) {
    if (coverUrl != null && coverUrl.isNotEmpty) {
      return Image.network(
        coverUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            CoverPlaceholder(colorScheme: Theme.of(context).colorScheme),
      );
    }
    return CoverPlaceholder(colorScheme: Theme.of(context).colorScheme);
  }

  Widget _buildInfo(BuildContext context, String? albumName) {
    return Column(
      children: [
        Text(
          track.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const Gap(6),
        Text(
          track.artist ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.mutedForeground,
          ),
        ),
        if (albumName != null && albumName.isNotEmpty) ...[
          const Gap(2),
          Text(
            albumName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSeekBar(BuildContext context) {
    final totalMs = duration.inMilliseconds.toDouble();
    final posMs = position.inMilliseconds.toDouble().clamp(0.0, totalMs);

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
                _formatDuration(position),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.mutedForeground,
                ),
              ),
              Text(
                _formatDuration(duration),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.mutedForeground,
                ),
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
        const Gap(20),
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
        const Gap(20),
        IconButton.text(
          icon: const Icon(Icons.skip_next, size: 36),
          onPressed: () => audioPlayer.skipToNext(),
        ),
      ],
    );
  }

  Widget _buildSecondaryControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton.ghost(
          icon: Icon(
            Icons.shuffle,
            size: 20,
            color: shuffled ? Theme.of(context).colorScheme.primary : null,
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
                ? Theme.of(context).colorScheme.primary
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

String _formatDuration(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds.remainder(60);
  return '$m:${s.toString().padLeft(2, '0')}';
}
