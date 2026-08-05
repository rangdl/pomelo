import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pomelo/core/models/metadata/metadata.dart';
import 'package:pomelo/core/preferences/user_preference_provider.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/core/toast.dart';
import 'package:pomelo/provider/audio_player/audio_player.dart';
import 'package:pomelo/services/audio_player/audio_player.dart';
import 'package:pomelo/ui/music/widgets/track_more_actions_button.dart';
import 'package:pomelo/ui/music/widgets/track_tile.dart';

/// 可点击播放的曲目卡片
///
/// 包装 [TrackTile]，统一处理「整卡点击播放」行为：
/// - 点击当前活跃曲目：暂停/恢复
/// - 点击非活跃曲目：根据 [UserPreference.overwritePlaylistOnPlay] 开关
///   - false（默认）：添加到当前播放列表末尾并播放（不覆盖）
///   - true：覆盖当前播放列表
///     - 若提供 [playlist]：覆盖为该列表（完整排行榜/搜索结果/收藏等），
///       并跳转到 [playlistIndex] 播放
///     - 否则降级为仅覆盖为单曲
///
/// 响应式「更多操作」：
/// - 移动端：trailing 显示 TrackMoreActionsButton 图标按钮
/// - 桌面端：不显示按钮，整卡右键（onSecondaryTap）弹出下拉菜单
///
/// 如需自定义 onTap（如播放队列页跳转），请直接使用 [TrackTile]。
class PlayableTrackTile extends HookConsumerWidget {
  final Track track;

  /// 序号（1-based），传入后会在封面右上角叠加序号 badge
  final int? index;

  /// 是否启用「更多操作」（移动端显示按钮 / 桌面端右键菜单）
  final bool showMoreActions;

  /// 当 showMoreActions=true 且该回调非空时，菜单显示「从列表移除」
  final void Function(Track)? onRemoveFromQueue;

  /// 额外的 trailing Widget（放在来源名右侧、更多操作按钮左侧）
  final Widget? trailingExtra;

  /// 外层 Card 之下的额外间距
  final EdgeInsets padding;

  /// 是否显示封面图
  final bool showCover;

  /// 当前展示的曲目列表（用于 overwrite 开关开启时整体覆盖播放列表）。
  ///
  /// 不传则降级为单曲覆盖。建议由列表型页面（排行榜、搜索结果、收藏等）传入。
  final List<Track>? playlist;

  /// 当前曲目在 [playlist] 中的索引（0-based），用于覆盖后跳转播放。
  /// 不传时默认为 0。
  final int? playlistIndex;

  /// 是否移动端布局。由列表型父级统一算一次后下发，
  /// 避免每个列表项各自订阅 MediaQuery（长列表下 N 次依赖注册 + N 次 rebuild）。
  /// 不传则回退为自行通过 [Rx.isMobile] 计算。
  final bool? isMobile;

  const PlayableTrackTile({
    super.key,
    required this.track,
    this.index,
    this.showMoreActions = false,
    this.onRemoveFromQueue,
    this.trailingExtra,
    this.padding = const EdgeInsets.only(bottom: 4),
    this.showCover = true,
    this.playlist,
    this.playlistIndex,
    this.isMobile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = ref.watch(
      audioPlayerProvider.select((s) => s.activeTrack?.id == track.id),
    );
    final overwrite = ref.watch(
      userPreferenceProvider.select((p) => p.overwritePlaylistOnPlay),
    );
    final notifier = ref.read(audioPlayerProvider.notifier);
    // 优先使用父级下发的断点结果；未下发时才自行订阅 MediaQuery
    final isMobile = this.isMobile ?? Rx.isMobile(context);

    // 响应式更多操作：
    // - 移动端：trailing 中显示按钮
    // - 桌面端：不显示按钮，整卡右键触发
    final trailing = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (trailingExtra != null) trailingExtra!,
        Text(track.source.name).muted,
        if (showMoreActions && isMobile)
          TrackMoreActionsButton(
            track: track,
            onRemoveFromQueue: onRemoveFromQueue == null
                ? null
                : () => onRemoveFromQueue!(track),
          ),
      ],
    );

    final tile = TrackTile(
      track: track,
      index: index,
      isActive: isActive,
      trailing: trailing,
      padding: padding,
      showCover: showCover,
      onTap: () async {
        if (isActive) {
          ref.read(audioPlayerProvider).playing
              ? audioPlayer.pause()
              : audioPlayer.resume();
          return;
        }
        // 本地曲目：校验文件存在
        if (track.isLocal && track.path != null) {
          if (!await File(track.path!).exists()) {
            if (!context.mounted) return;
            context.toast.error('文件不存在：${track.path}');
            return;
          }
        }
        if (overwrite) {
          // 覆盖模式：优先使用当前展示列表整体覆盖，降级为单曲覆盖
          if (playlist != null && playlist!.isNotEmpty) {
            final safeIndex = (playlistIndex ?? 0).clamp(
              0,
              playlist!.length - 1,
            );
            notifier.load(playlist!, initialIndex: safeIndex, autoPlay: true);
          } else {
            notifier.load([track], autoPlay: true);
          }
        } else {
          notifier.playTrack(track);
        }
      },
    );

    // 桌面端启用更多操作时，包裹 GestureDetector 处理右键
    // 使用 onSecondaryTapDown 捕获鼠标位置，让菜单在鼠标处弹出
    if (showMoreActions && !isMobile) {
      return GestureDetector(
        onSecondaryTapDown: (details) => showTrackMoreActions(
          context,
          ref,
          track,
          position: details.globalPosition,
          onRemoveFromQueue: onRemoveFromQueue == null
              ? null
              : () => onRemoveFromQueue!(track),
        ),
        child: tile,
      );
    }
    return tile;
  }
}
