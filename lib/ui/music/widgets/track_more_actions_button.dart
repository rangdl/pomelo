import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/models/metadata/track.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/core/toast.dart';
import 'package:pomelo/provider/audio_player/audio_player.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 统一响应式打开「曲目更多操作」菜单。
///
/// 移动端：openSheet 从底部滑出
/// 桌面端：showDropdown 在指定位置弹出下拉菜单
///
/// 提供 [onRemoveFromQueue] 时显示「从列表移除」菜单项。
/// 传入 [position]（鼠标全局坐标）时，桌面端下拉菜单会在该位置弹出。
void showTrackMoreActions(
  BuildContext context,
  WidgetRef ref,
  Track track, {
  VoidCallback? onRemoveFromQueue,
  Offset? position,
}) {
  Rx.action(
    context,
    mobile: () => openSheet(
      context: context,
      position: OverlayPosition.bottom,
      draggable: true,
      builder: (_) => TrackMoreActionsContent(
        track: track,
        onRemoveFromQueue: onRemoveFromQueue,
      ),
    ),
    tablet: () => showDropdown(
      context: context,
      position: position,
      builder: (_) => DropdownMenu(
        children: buildTrackMoreMenuItems(context, ref, track, onRemoveFromQueue),
      ),
    ),
  );
}

/// 构造桌面端下拉的菜单项列表
List<MenuItem> buildTrackMoreMenuItems(
  BuildContext context,
  WidgetRef ref,
  Track track,
  VoidCallback? onRemoveFromQueue,
) {
  final notifier = ref.read(audioPlayerProvider.notifier);
  return [
    MenuButton(
      leading: const Icon(Icons.queue_music, size: 18),
      child: const Text('下一首播放'),
      onPressed: (_) {
        notifier.addTracksAtFirst([track]);
        context.toast.success('已添加到下一首');
      },
    ),
    MenuButton(
      leading: const Icon(Icons.playlist_add, size: 18),
      child: const Text('添加到播放列表'),
      onPressed: (_) {
        notifier.addTracks([track]);
        context.toast.success('已添加到播放列表');
      },
    ),
    if (onRemoveFromQueue != null)
      MenuButton(
        leading: Icon(
          Icons.delete_outline,
          size: 18,
          color: Theme.of(context).colorScheme.destructive,
        ),
        child: Text(
          '从列表移除',
          style: TextStyle(color: Theme.of(context).colorScheme.destructive),
        ),
        onPressed: (_) {
          onRemoveFromQueue.call();
          context.toast.success('已从列表移除');
        },
      ),
  ];
}

/// 曲目「更多操作」按钮
///
/// 点击后按响应式分流弹出菜单（实际调用 [showTrackMoreActions]）。
class TrackMoreActionsButton extends HookConsumerWidget {
  final Track track;

  /// 提供该回调时显示「从列表移除」（仅用于播放队列页）
  final VoidCallback? onRemoveFromQueue;

  const TrackMoreActionsButton({
    required this.track,
    super.key,
    this.onRemoveFromQueue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton.text(
      icon: const Icon(Icons.more_vert, size: 18),
      onPressed: () => showTrackMoreActions(
        context,
        ref,
        track,
        onRemoveFromQueue: onRemoveFromQueue,
      ),
    );
  }
}

/// 曲目更多操作菜单共享内容
///
/// 移动端用 Column + ListTile 嵌入 openSheet。
/// 桌面端直接用 DropdownMenu + MenuItem（不走此组件）。
class TrackMoreActionsContent extends HookConsumerWidget {
  final Track track;
  final VoidCallback? onRemoveFromQueue;

  const TrackMoreActionsContent({
    required this.track,
    super.key,
    this.onRemoveFromQueue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(audioPlayerProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部曲目信息条
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        track.artist ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.queue_music, size: 20),
            title: const Text('下一首播放'),
            onTap: () {
              notifier.addTracksAtFirst([track]);
              closeOverlay(context);
              context.toast.success('已添加到下一首');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.playlist_add, size: 20),
            title: const Text('添加到播放列表'),
            onTap: () {
              notifier.addTracks([track]);
              closeOverlay(context);
              context.toast.success('已添加到播放列表');
            },
          ),
          if (onRemoveFromQueue != null) ...[
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                size: 20,
                color: colorScheme.destructive,
              ),
              title: Text(
                '从列表移除',
                style: TextStyle(color: colorScheme.destructive),
              ),
              onTap: () {
                onRemoveFromQueue!.call();
                closeOverlay(context);
                context.toast.success('已从列表移除');
              },
            ),
          ],
        ],
      ),
    );
  }
}
