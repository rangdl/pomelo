import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/modules/audio_player/module_providers.dart';
import 'package:pomelo/modules/music/model/track.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../music/widgets/cover_placeholder.dart';
import 'lyric_parser.dart';
import 'lyric_view.dart';
import 'playback_page.dart';
import 'widgets/play_queue_content.dart';

/// 底部迷你播放器
///
/// 当有活跃曲目时显示在页面底部，提供快速播放控制。
/// 点击主体区域跳转到全屏播放页面。
///
/// 移动端：紧凑横向布局，底部细进度条。
/// 桌面端：稍宽，进度条内嵌。
class MiniPlayer extends HookConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayer = ref.watch(audioPlayerServiceProvider);
    final state = ref.watch(audioPlayerProvider);
    final track = state.activeTrack;

    // Hooks 必须无条件调用
    final position = useStream(
      audioPlayer.positionStream,
      initialData: audioPlayer.position,
    ).data ?? Duration.zero;
    final duration = useStream(
      audioPlayer.durationStream,
      initialData: audioPlayer.duration,
    ).data ?? Duration.zero;

    // 歌词获取与解析（track 为空时传入空 Track 占位避免条件 hook）
    final lyricAsync = track == null
        ? const AsyncValue<String?>.data(null)
        : ref.watch(lyricProvider(track));
    final lyricText = lyricAsync.value;
    final lyricLines = useMemoized(
      () => lyricText != null ? LyricParser.parse(lyricText) : <LyricLine>[],
      [lyricText],
    );
    final currentLyricIndex = LyricParser.findCurrentIndex(lyricLines, position);
    final currentLyric =
        currentLyricIndex >= 0 ? lyricLines[currentLyricIndex].text : null;

    if (track == null) return const SizedBox.shrink();

    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return GestureDetector(
      onTap: () => _navigateToPlayback(context),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.card,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.border,
              width: 1,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: _buildContent(
                context,
                ref,
                track,
                state.playing,
                audioPlayer,
                position,
                duration,
                isDesktop,
                currentLyric,
              ),
            ),
            // 底部细进度条
            _buildProgressBar(context, progress),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Track track,
    bool isPlaying,
    dynamic audioPlayer,
    Duration position,
    Duration duration,
    bool isDesktop,
    String? currentLyric,
  ) {
    return Row(
      children: [
        // 封面（右键/长按打开播放队列）
        GestureDetector(
          onSecondaryTap: () => _openPlayQueue(context),
          onLongPress: () => _openPlayQueue(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: _buildCover(context, track, isDesktop ? 48 : 40),
          ),
        ),
        const Gap(12),
        // 歌曲信息（含当前歌词行）
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                track.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  // 有当前歌词时优先展示歌词，否则回退到歌手名
                  (currentLyric != null && currentLyric.isNotEmpty)
                      ? currentLyric
                      : track.artist ?? '',
                  key: ValueKey(
                    (currentLyric != null && currentLyric.isNotEmpty)
                        ? 'lyric:$currentLyric'
                        : 'artist:${track.artist}',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: (currentLyric != null && currentLyric.isNotEmpty)
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        // 桌面端显示时间
        if (isDesktop) ...[
          Text(
            _formatDuration(position),
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
          ),
          const Gap(8),
        ],
        // 控制按钮
        _buildControls(context, audioPlayer, isPlaying, isDesktop),
        // 桌面端显示总时长
        if (isDesktop) ...[
          const Gap(8),
          Text(
            _formatDuration(duration),
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCover(BuildContext context, Track track, double size) {
    final coverUrl = track.coverArt;
    if (coverUrl != null && coverUrl.isNotEmpty) {
      return Image.network(
        coverUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => CoverPlaceholder(
          colorScheme: Theme.of(context).colorScheme,
          width: size,
          height: size,
        ),
      );
    }
    return CoverPlaceholder(
      colorScheme: Theme.of(context).colorScheme,
      width: size,
      height: size,
    );
  }

  Widget _buildControls(
    BuildContext context,
    dynamic audioPlayer,
    bool isPlaying,
    bool isDesktop,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.text(
          icon: const Icon(Icons.skip_previous, size: 22),
          onPressed: () => audioPlayer.skipToPrevious(),
        ),
        IconButton.text(
          icon: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 26,
          ),
          onPressed: () {
            isPlaying ? audioPlayer.pause() : audioPlayer.resume();
          },
        ),
        IconButton.text(
          icon: const Icon(Icons.skip_next, size: 22),
          onPressed: () => audioPlayer.skipToNext(),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, double progress) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 2,
      child: Stack(
        children: [
          Container(color: colorScheme.muted),
          FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(color: colorScheme.primary),
          ),
        ],
      ),
    );
  }

  /// 打开播放详情页 — 作为底部 Sheet 覆盖整个页面
  void _navigateToPlayback(BuildContext context) {
    openSheet(
      context: context,
      position: OverlayPosition.bottom,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height,
        child: const PlaybackPage(),
      ),
    );
  }

  /// 响应式打开播放队列
  ///
  /// 桌面端：右侧 Sheet（360px 宽）
  /// 移动端：底部 Sheet
  void _openPlayQueue(BuildContext context) {
    Rx.action(
      context,
      mobile: () => openSheet(
        context: context,
        position: OverlayPosition.bottom,
        draggable: true,
        builder: (_) => _PlayQueueSheet(onClose: () =>
            Navigator.of(context, rootNavigator: true).pop()),
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

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

/// 移动端播放队列底部 Sheet 内容
class _PlayQueueSheet extends StatelessWidget {
  final VoidCallback onClose;

  const _PlayQueueSheet({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton.text(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClose,
                ),
                const Gap(4),
                const Text(
                  '播放队列',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const Flexible(child: PlayQueueContent()),
        ],
      ),
    );
  }
}
