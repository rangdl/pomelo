import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pomelo/core/models/metadata/metadata.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/ui/music/widgets/playable_track_tile.dart';

/// 曲目列表组件
///
/// 基于 [PlayableTrackTile] 构建，整张卡片可点击播放，
/// 右侧不再显示单独的播放按钮（仅保留来源名和「更多操作」按钮）。
///
/// 默认 `shrinkWrap: true` + `NeverScrollableScrollPhysics()`，适合嵌入父滚动视图。
/// 当作为独立滚动区域使用时（如桌面端右侧固定高度区域），传入 [physics]
/// （如 `AlwaysScrollableScrollPhysics()`）即可启用正常滚动行为。
class TrackList extends ConsumerWidget {
  final List<Track> tracks;

  /// 是否在每行末尾显示「更多操作」按钮（下一首播放、添加到播放列表等）
  final bool showMoreActions;

  /// 当 showMoreActions=true 且该回调非空时，菜单显示「从列表移除」
  /// 透传给 TrackMoreActionsButton，主要用于播放队列页
  final void Function(Track)? onRemoveFromQueue;

  /// 滚动物理行为。
  /// - 默认（null）：`NeverScrollableScrollPhysics` + `shrinkWrap: true`
  ///   适合嵌入父滚动视图。
  /// - 传入非 null（如 `AlwaysScrollableScrollPhysics()`）：使用正常滚动，
  ///   `shrinkWrap: false`，适合作为独立滚动区域。
  final ScrollPhysics? physics;

  const TrackList({
    super.key,
    required this.tracks,
    this.showMoreActions = false,
    this.onRemoveFromQueue,
    this.physics,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStandalone = physics != null;
    // 断点只在父级算一次后下发，避免每个列表项各自订阅 MediaQuery
    final isMobile = Rx.isMobile(context);
    return ListView.builder(
      shrinkWrap: !isStandalone,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      padding: isStandalone ? const EdgeInsets.symmetric(horizontal: 8) : null,
      itemCount: tracks.length,
      // 曲目项无需保活，关闭后滚出视口即可回收 Element
      addAutomaticKeepAlives: false,
      itemBuilder: (context, index) {
        final track = tracks[index];
        return PlayableTrackTile(
          track: track,
          showMoreActions: showMoreActions,
          onRemoveFromQueue: onRemoveFromQueue,
          playlist: tracks,
          playlistIndex: index,
          isMobile: isMobile,
        );
      },
    );
  }
}
