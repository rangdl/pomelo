
/// 播放设置页面
///
/// 集中管理播放相关设置（音质偏好等）。
/// 移动端作为全屏页面打开，桌面端作为对话框打开。
library;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/modules/music_lx_server/model/lx_server_quality.dart';
import 'package:pomelo/modules/music_lx_server/providers/lx_server_providers.dart';

/// 播放设置页面
class PlaybackSettingsPage extends ConsumerWidget {
  const PlaybackSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedQuality = ref.watch(selectedLxServerQualityProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            GhostButton(
              density: ButtonDensity.icon,
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ],
          title: const Text('播放设置'),
        ),
      ],
      child: CenteredListView(
        maxWidth: 640,
        children: [
          Text(
            '音质',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.mutedForeground,
            ),
          ),
          const Gap(8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.graphic_eq, size: 20),
                  title: const Text('音质偏好'),
                  subtitle: Text(
                    '当前：${selectedQuality.label}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                  trailing: Select<LxServerQuality>(
                    value: selectedQuality,
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(selectedLxServerQualityProvider.notifier)
                            .set(value);
                      }
                    },
                    popup: SelectPopup(
                      items: SelectItemList(
                        children: LxServerQuality.values
                            .map((q) => SelectItemButton(
                                  value: q,
                                  child: Text(q.label),
                                ))
                            .toList(),
                      ),
                    ).call,
                    itemBuilder: (context, value) => Text(
                      value.label,
                      style: TextStyle(color: colorScheme.mutedForeground),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: colorScheme.mutedForeground,
                      ),
                      const Gap(6),
                      Expanded(
                        child: Text(
                          '仅对 lx_server 音源生效，不支持所选音质时自动降级',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 打开播放设置 — 响应式
///
/// 移动端：全屏页面
/// 桌面端：对话框
void openPlaybackSettings(BuildContext context) {
  Rx.action(
    context,
    mobile: () => Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PlaybackSettingsPage()),
    ),
    tablet: () => showDialog(
      context: context,
      builder: (_) => const _PlaybackSettingsDialog(),
    ),
  );
}

/// 桌面端播放设置对话框
class _PlaybackSettingsDialog extends ConsumerWidget {
  const _PlaybackSettingsDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedQuality = ref.watch(selectedLxServerQualityProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('播放设置'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '音质',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.mutedForeground,
              ),
            ),
            const Gap(8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.graphic_eq, size: 20),
                    title: const Text('音质偏好'),
                    subtitle: Text(
                      '当前：${selectedQuality.label}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                    trailing: Select<LxServerQuality>(
                      value: selectedQuality,
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(selectedLxServerQualityProvider.notifier)
                              .set(value);
                        }
                      },
                      popup: SelectPopup(
                        items: SelectItemList(
                          children: LxServerQuality.values
                              .map((q) => SelectItemButton(
                                    value: q,
                                    child: Text(q.label),
                                  ))
                              .toList(),
                        ),
                      ).call,
                      itemBuilder: (context, value) => Text(
                        value.label,
                        style: TextStyle(color: colorScheme.mutedForeground),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: colorScheme.mutedForeground,
                        ),
                        const Gap(6),
                        Expanded(
                          child: Text(
                            '仅对 lx_server 音源生效，不支持所选音质时自动降级',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.mutedForeground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        PrimaryButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('完成'),
        ),
      ],
    );
  }
}
