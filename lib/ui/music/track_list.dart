import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pomelo/core/models/metadata/metadata.dart';
import 'package:pomelo/ui/music/widgets/play_pause_button.dart';
import 'package:pomelo/ui/music/widgets/track_more_actions_button.dart';
import 'package:pomelo/ui/music/widgets/track_tile.dart';

/// 曲目列表组件
class TrackList extends HookConsumerWidget {
  final List<Track> tracks;

  /// 是否在每行末尾显示「更多操作」按钮（下一首播放、添加到播放列表等）
  final bool showMoreActions;

  /// 当 showMoreActions=true 且该回调非空时，菜单显示「从列表移除」
  /// 透传给 TrackMoreActionsButton，主要用于播放队列页
  final void Function(Track)? onRemoveFromQueue;

  const TrackList({
    super.key,
    required this.tracks,
    this.showMoreActions = false,
    this.onRemoveFromQueue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        return TrackTile(
          track: track,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(track.source?.name ?? '').muted,
              PlayPauseButton(track: track),
              if (showMoreActions)
                TrackMoreActionsButton(
                  track: track,
                  onRemoveFromQueue: onRemoveFromQueue == null
                      ? null
                      : () => onRemoveFromQueue!(track),
                ),
            ],
          ),
        );
      },
    );
  }
}
