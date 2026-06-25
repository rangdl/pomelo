import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/modules/audio_player/module_providers.dart';
import 'package:pomelo/modules/music/model/song.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 歌曲「更多操作」按钮
///
/// 点击后按响应式分流弹出菜单：
/// - 移动端：openSheet 从底部滑出
/// - 桌面端：showDropdown 在按钮旁弹出
///
/// 菜单项：下一首播放、添加到播放列表、（可选）从列表移除。
class SongMoreActionsButton extends HookConsumerWidget {
  final Song song;

  /// 提供该回调时显示「从列表移除」（仅用于播放队列页）
  final VoidCallback? onRemoveFromQueue;

  const SongMoreActionsButton({
    required this.song,
    super.key,
    this.onRemoveFromQueue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton.text(
      icon: const Icon(Icons.more_vert, size: 18),
      onPressed: () => _openActions(context, ref),
    );
  }

  void _openActions(BuildContext context, WidgetRef ref) {
    void close() => Navigator.of(context, rootNavigator: true).pop();
    Rx.action(
      context,
      mobile: () => openSheet(
        context: context,
        position: OverlayPosition.bottom,
        draggable: true,
        builder: (_) => SongMoreActionsContent(
          song: song,
          onRemoveFromQueue: onRemoveFromQueue,
          onClose: close,
        ),
      ),
      tablet: () => showDropdown(
        context: context,
        builder: (_) => DropdownMenu(
          children: _buildMenuItems(context, ref, close),
        ),
      ),
    );
  }

  List<MenuItem> _buildMenuItems(
    BuildContext context,
    WidgetRef ref,
    VoidCallback onClose,
  ) {
    final notifier = ref.read(audioPlayerProvider.notifier);
    return [
      MenuButton(
        leading: const Icon(Icons.queue_music, size: 18),
        child: const Text('下一首播放'),
        onPressed: (_) {
          notifier.addTracksAtFirst([song]);
          onClose();
          Rx.toast.success('已添加到下一首');
        },
      ),
      MenuButton(
        leading: const Icon(Icons.playlist_add, size: 18),
        child: const Text('添加到播放列表'),
        onPressed: (_) {
          notifier.addTracks([song]);
          onClose();
          Rx.toast.success('已添加到播放列表');
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
            style: TextStyle(
              color: Theme.of(context).colorScheme.destructive,
            ),
          ),
          onPressed: (_) {
            onRemoveFromQueue!.call();
            onClose();
            Rx.toast.success('已从列表移除');
          },
        ),
    ];
  }
}

/// 歌曲更多操作菜单共享内容
///
/// 移动端用 Column + ListTile 嵌入 openSheet。
/// 桌面端直接用 DropdownMenu + MenuItem（不走此组件）。
class SongMoreActionsContent extends HookConsumerWidget {
  final Song song;
  final VoidCallback? onRemoveFromQueue;
  final VoidCallback? onClose;

  const SongMoreActionsContent({
    required this.song,
    super.key,
    this.onRemoveFromQueue,
    this.onClose,
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
          // 顶部歌曲信息条
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
                        song.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        song.artist,
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
              notifier.addTracksAtFirst([song]);
              onClose?.call();
              Rx.toast.success('已添加到下一首');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.playlist_add, size: 20),
            title: const Text('添加到播放列表'),
            onTap: () {
              notifier.addTracks([song]);
              onClose?.call();
              Rx.toast.success('已添加到播放列表');
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
                onClose?.call();
                Rx.toast.success('已从列表移除');
              },
            ),
          ],
        ],
      ),
    );
  }
}
