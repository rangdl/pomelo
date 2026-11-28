import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../shared/layout/window_class.dart';
import '../../../shared/settings/cache_limit.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../../playback/data/media_proxy_server.dart';

/// 当前缓存占用（打开存储设置页时统计一次）。
final cacheUsageProvider = FutureProvider.autoDispose<MediaCacheUsage>((
  ref,
) async {
  final server = MediaProxyServer.instance;
  if (server == null) return MediaCacheUsage.empty;
  return server.usage();
});

/// 存储设置：缓存占用 / 上限 / 数据目录，以及各项缓存清理。
class StorageSettingsScreen extends ConsumerStatefulWidget {
  const StorageSettingsScreen({super.key});

  @override
  ConsumerState<StorageSettingsScreen> createState() =>
      _StorageSettingsScreenState();
}

class _StorageSettingsScreenState extends ConsumerState<StorageSettingsScreen> {
  /// 正在执行的清理动作(按行控制 loading,不整页闪)。
  final Set<String> _clearing = {};

  @override
  Widget build(BuildContext context) {
    final cacheLimit = ref.watch(cacheLimitProvider);
    final cacheUsage = ref.watch(cacheUsageProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('存储设置')),
      body: CenteredMaxWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            AppSpacing.floatingPlayerInset,
          ),
          children: [
            const SectionHeader('存储'),
            GroupCard(
              children: [
                SettingsItem(
                  icon: Icons.inventory_2_rounded,
                  title: '缓存占用',
                  subtitle: cacheUsage.when(
                    data: (usage) =>
                        '音频 ${_formatBytes(usage.audioBytes)} · '
                        '封面 ${_formatBytes(usage.coverBytes)}',
                    loading: () => '统计中…',
                    error: (_, _) => '统计失败',
                  ),
                ),
                SettingsItem(
                  icon: Icons.data_usage_rounded,
                  title: '缓存上限',
                  subtitle: cacheLimit.label,
                  onTap: () => _pickCacheLimit(cacheLimit),
                ),
                SettingsItem(
                  icon: Icons.folder_open_rounded,
                  title: '数据目录',
                  subtitle: '查看配置与缓存所在位置',
                  onTap: _showDataDir,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader('清理缓存'),
            GroupCard(
              children: [
                _clearItem(
                  key: 'audio',
                  icon: Icons.audio_file_rounded,
                  title: '清除音频缓存',
                  subtitle: '删除边播边存的歌曲文件',
                  label: '音频缓存',
                  action: () async {
                    await MediaProxyServer.instance?.clearAudioCache();
                  },
                ),
                _clearItem(
                  key: 'cover',
                  icon: Icons.image_rounded,
                  title: '清除封面缓存',
                  subtitle: '下次展示时重新下载',
                  label: '封面缓存',
                  action: () async {
                    await MediaProxyServer.instance?.clearCoverCache();
                  },
                ),
                _clearItem(
                  key: 'links',
                  icon: Icons.link_off_rounded,
                  title: '清除播放链接缓存',
                  subtitle: '下次播放时重新向音源取链',
                  label: '播放链接缓存',
                  action: () async {
                    await MediaLinkCache.instance?.clear();
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                '清理后无法恢复，下次使用时会重新下载或向音源取链。',
                style: TextStyle(
                  fontSize: AppText.rowSubtitle,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 清理行:破坏性操作不带箭头(不跳转),执行中显示行级转圈。
  Widget _clearItem({
    required String key,
    required IconData icon,
    required String title,
    required String subtitle,
    required String label,
    required Future<void> Function() action,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final busy = _clearing.contains(key);
    return SettingsItem(
      icon: icon,
      title: title,
      subtitle: subtitle,
      danger: true,
      showChevron: false,
      trailing: busy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.delete_outline_rounded, color: scheme.error),
      onTap: busy ? null : () => _clearCache(key, label, action),
    );
  }

  Future<void> _showDataDir() async {
    final dir = await getApplicationSupportDirectory();
    if (!mounted) return;
    await showAppModal<void>(
      context: context,
      title: '数据目录',
      body: (ctx) => SelectableText(dir.path),
      actions: (ctx) => [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: dir.path));
            if (ctx.mounted) Navigator.pop(ctx);
          },
          child: const Text('复制路径'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('关闭'),
        ),
      ],
    );
  }

  Future<void> _pickCacheLimit(CacheLimitOption current) async {
    final picked = await showSelectionSheet<CacheLimitOption>(
      context: context,
      title: '缓存上限',
      current: current,
      options: [
        for (final option in CacheLimitOption.values)
          SelectionOption(value: option, label: option.label),
      ],
    );
    if (picked != null) {
      await ref.read(cacheLimitProvider.notifier).set(picked);
      ref.invalidate(cacheUsageProvider);
    }
  }

  /// 清理缓存:先二次确认,再按行统计 loading。
  Future<void> _clearCache(
    String key,
    String label,
    Future<void> Function() action,
  ) async {
    if (_clearing.contains(key)) return;
    final confirmed = await showAppConfirm(
      context: context,
      title: '清除$label',
      message: '清除后无法恢复，下次使用时会重新下载或向音源取链。',
      confirmLabel: '清除',
      danger: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _clearing.add(key));
    try {
      await action();
      ref.invalidate(cacheUsageProvider);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('已清除$label')));
      }
    } catch (e) {
      // 清理是破坏性操作：失败要明确告知，而不是静默失败。
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('清除$label 失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _clearing.remove(key));
    }
  }

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB'];
    var value = bytes.toDouble();
    var unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    final text = unit == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(value >= 100 ? 0 : 1);
    return '$text ${units[unit]}';
  }
}
