/// 投屏按钮组件
///
/// 根据当前投屏状态显示不同图标/颜色：
/// - disconnected：默认 cast 图标
/// - discovering / connecting：连接中态（高亮）
/// - connected：投屏中态（主色高亮）
///
/// 点击响应式弹出设备选择面板：
/// - 桌面端：[showDropdown] + [DropdownMenu]（设备列表 + 刷新 + 断开）
/// - 移动端：[openSheet] 从底部弹出（[ListTile] 列表）
///
/// 投屏中时长按可快速断开（通过包裹的 [GestureDetector]）。
library;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/core/toast.dart';
import 'package:pomelo/provider/cast/cast_provider.dart';
import 'package:pomelo/services/cast/dlna_device.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class CastButton extends HookConsumerWidget {
  const CastButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final castState = ref.watch(castProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final icon = switch (castState.connectionState) {
      CastConnectionState.disconnected => Icons.cast,
      CastConnectionState.discovering => Icons.cast_outlined,
      CastConnectionState.connecting => Icons.cast_connected,
      CastConnectionState.connected => Icons.cast_connected,
    };
    // 投屏中用主色高亮
    final color = castState.isCasting ? colorScheme.primary : null;

    return GestureDetector(
      onLongPress: castState.isCasting
          ? () {
              ref.read(castProvider.notifier).disconnect();
              context.toast.success('已断开投屏');
            }
          : null,
      child: IconButton.text(
        icon: Icon(icon, size: 22, color: color),
        onPressed: () => _openDevicePicker(context, ref),
      ),
    );
  }

  /// 响应式打开设备选择面板
  ///
  /// 打开时自动触发一次设备发现（用 microtask 延迟到面板渲染后，
  /// 避免在 build 阶段修改 provider 状态）。
  void _openDevicePicker(BuildContext context, WidgetRef ref) {
    Future.microtask(() {
      if (!context.mounted) return;
      ref.read(castProvider.notifier).discover();
    });

    Rx.action(
      context,
      mobile: () => openSheet(
        context: context,
        position: OverlayPosition.bottom,
        draggable: true,
        builder: (_) => const _CastDeviceSheetContent(),
      ),
      tablet: () => showDropdown(
        context: context,
        anchorAlignment: Alignment.bottomRight,
        alignment: Alignment.topRight,
        builder: (_) => const _CastDeviceDropdown(),
      ),
    );
  }
}

/// 桌面端投屏下拉菜单
class _CastDeviceDropdown extends HookConsumerWidget {
  const _CastDeviceDropdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final castState = ref.watch(castProvider);
    final useRustyDlna = ref.watch(castBackendProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final children = <MenuItem>[
      const MenuLabel(child: Text('投屏到设备')),
      MenuButton(
        leading: Icon(
          useRustyDlna ? Icons.memory : Icons.dns,
          size: 18,
          color: useRustyDlna ? colorScheme.primary : null,
        ),
        trailing: useRustyDlna
            ? Icon(Icons.check, size: 14, color: colorScheme.primary)
            : null,
        onPressed: (_) {
          ref.read(castBackendProvider.notifier).toggle();
          context.toast.info(
            useRustyDlna ? '已切换到 dlna_dart' : '已切换到 rusty_dlna',
          );
          Future.microtask(() {
            ref.read(castProvider.notifier).discover();
          });
        },
        child: Text(useRustyDlna ? 'Rust 引擎 (rusty_dlna)' : 'Dart 引擎 (dlna_dart)'),
      ),
      const MenuDivider(),
    ];

    if (castState.connectionState == CastConnectionState.discovering) {
      children.add(const MenuLabel(child: Text('搜索中...')));
    }

    if (castState.discoveredDevices.isEmpty &&
        castState.connectionState != CastConnectionState.discovering) {
      children.add(const MenuLabel(child: Text('未发现可用设备')));
    }

    for (final device in castState.discoveredDevices) {
      final isCurrent = castState.currentDevice?.id == device.id;
      children.add(
        MenuButton(
          leading: Icon(
            device.isPlayable ? Icons.speaker : Icons.volume_off,
            size: 18,
            color: device.isPlayable ? null : colorScheme.mutedForeground,
          ),
          trailing: isCurrent ? const Icon(Icons.check, size: 16) : null,
          onPressed: device.isPlayable
              ? (_) {
                  ref.read(castProvider.notifier).connect(device);
                  closeOverlay(context);
                }
              : null,
          child: Text(
            device.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    children.add(const MenuDivider());
    children.add(
      MenuButton(
        leading: const Icon(Icons.refresh, size: 18),
        child: const Text('刷新设备'),
        onPressed: (_) {
          ref.read(castProvider.notifier).discover();
        },
      ),
    );

    if (castState.isCasting) {
      children.add(
        MenuButton(
          leading: Icon(
            Icons.link_off,
            size: 18,
            color: colorScheme.destructive,
          ),
          child: Text('断开投屏', style: TextStyle(color: colorScheme.destructive)),
          onPressed: (_) {
            ref.read(castProvider.notifier).disconnect();
            closeOverlay(context);
          },
        ),
      );
    }

    return DropdownMenu(children: children);
  }
}

/// 移动端投屏底部 Sheet 内容
class _CastDeviceSheetContent extends HookConsumerWidget {
  const _CastDeviceSheetContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final castState = ref.watch(castProvider);
    final useRustyDlna = ref.watch(castBackendProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final widgets = <Widget>[];

    // 引擎切换按钮
    widgets.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GhostButton(
          leading: Icon(
            useRustyDlna ? Icons.memory : Icons.dns,
            size: 16,
            color: useRustyDlna ? colorScheme.primary : null,
          ),
          child: Text(
            useRustyDlna ? 'Rust 引擎 (rusty_dlna)' : 'Dart 引擎 (dlna_dart)',
            style: const TextStyle(fontSize: 12),
          ),
          onPressed: () {
            ref.read(castBackendProvider.notifier).toggle();
            context.toast.info(
              useRustyDlna ? '已切换到 dlna_dart' : '已切换到 rusty_dlna',
            );
            Future.microtask(() {
              ref.read(castProvider.notifier).discover();
            });
          },
        ),
      ),
    );

    // 标题
    widgets.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const Text(
                '投屏到设备',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (castState.connectionState == CastConnectionState.discovering)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    widgets.add(const Divider(height: 1));

    // 状态提示
    if (castState.discoveredDevices.isEmpty &&
        castState.connectionState != CastConnectionState.discovering) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Center(
            child: Text(
              '未发现可用设备',
              style: TextStyle(color: colorScheme.mutedForeground),
            ),
          ),
        ),
      );
    }

    // 设备列表（包在 Card 内）
    if (castState.discoveredDevices.isNotEmpty) {
      widgets.add(
        Card(
          child: Column(
            children: [
              for (int i = 0; i < castState.discoveredDevices.length; i++) ...[
                _buildDeviceTile(
                  context,
                  ref,
                  castState.discoveredDevices[i],
                  castState.currentDevice?.id ==
                      castState.discoveredDevices[i].id,
                ),
                if (i < castState.discoveredDevices.length - 1)
                  const Divider(height: 1),
              ],
            ],
          ),
        ),
      );
    }

    widgets.add(const Gap(8));

    // 刷新按钮
    widgets.add(
      Card(
        child: ListTile(
          leading: const Icon(Icons.refresh, size: 20),
          title: const Text('刷新设备'),
          onTap: () {
            ref.read(castProvider.notifier).discover();
          },
        ),
      ),
    );

    // 断开投屏按钮
    if (castState.isCasting) {
      widgets.add(const Gap(8));
      widgets.add(
        Card(
          child: ListTile(
            leading: Icon(
              Icons.link_off,
              size: 20,
              color: colorScheme.destructive,
            ),
            title: Text(
              '断开投屏',
              style: TextStyle(color: colorScheme.destructive),
            ),
            onTap: () {
              closeOverlay(context);
              ref.read(castProvider.notifier).disconnect();
            },
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(mainAxisSize: MainAxisSize.min, children: widgets),
    );
  }

  Widget _buildDeviceTile(
    BuildContext context,
    WidgetRef ref,
    DlnaDevice device,
    bool isCurrent,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(
        device.isPlayable ? Icons.speaker : Icons.volume_off,
        size: 20,
        color: device.isPlayable ? null : colorScheme.mutedForeground,
      ),
      title: Text(
        device.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: isCurrent ? FontWeight.w600 : null,
          color: isCurrent ? colorScheme.primary : null,
        ),
      ),
      subtitle: device.modelName != null ? Text(device.modelName!) : null,
      trailing: isCurrent
          ? Icon(Icons.check, size: 18, color: colorScheme.primary)
          : (device.isPlayable ? null : const Icon(Icons.lock, size: 16)),
      onTap: device.isPlayable
          ? () {
              closeOverlay(context);
              ref.read(castProvider.notifier).connect(device);
            }
          : null,
    );
  }
}
