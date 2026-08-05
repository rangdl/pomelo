/// 播放设置页面
///
/// 集中管理播放相关设置（音质偏好、缓存管理）。
/// 移动端作为全屏页面打开，桌面端作为对话框打开。
library;

import 'package:file_picker/file_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/preferences/user_preference_provider.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/core/storage/music_cache_dir.dart';
import 'package:pomelo/core/toast.dart';
import 'package:pomelo/core/models/lx_server_quality.dart';
import 'package:pomelo/modules/music_lx_server/providers/lx_server_providers.dart';

/// 缓存大小（字节）Provider，autoDispose 便于手动刷新
final cacheSizeProvider = FutureProvider.autoDispose<int>((ref) async {
  return MusicCacheDir.getCacheSize();
});

/// 字节数格式化为人类可读字符串（如 "1.23 GB"、"456.7 MB"）
String formatBytes(int bytes) {
  if (bytes <= 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var size = bytes.toDouble();
  var unitIndex = 0;
  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024;
    unitIndex++;
  }
  return unitIndex <= 1
      ? '${size.toStringAsFixed(0)} ${units[unitIndex]}'
      : '${size.toStringAsFixed(2)} ${units[unitIndex]}';
}

/// 播放行为设置区块（页面和对话框共享）
class PlaybackBehaviorSection extends ConsumerWidget {
  const PlaybackBehaviorSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overwrite = ref.watch(
      userPreferenceProvider.select((p) => p.overwritePlaylistOnPlay),
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '播放行为',
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
                leading: const Icon(Icons.playlist_play, size: 20),
                title: const Text('点击播放时覆盖播放列表'),
                subtitle: Text(
                  overwrite ? '当前：覆盖播放列表' : '当前：添加到播放列表末尾',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.mutedForeground,
                  ),
                ),
                trailing: Switch(
                  value: overwrite,
                  onChanged: (v) => ref
                      .read(userPreferenceProvider.notifier)
                      .setOverwritePlaylistOnPlay(v),
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
                        '关闭时点击歌曲卡片会将歌曲添加到当前播放列表；'
                        '开启时点击歌曲卡片会覆盖当前播放列表',
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
    );
  }
}

/// 投屏设置区块（页面和对话框共享）
class CastSettingsSection extends ConsumerWidget {
  const CastSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final castLocalProxy = ref.watch(
      userPreferenceProvider.select((p) => p.castLocalProxy),
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '投屏',
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
                leading: const Icon(Icons.cast_connected, size: 20),
                title: const Text('启用本地代理'),
                subtitle: Text(
                  castLocalProxy ? '当前：所有曲目经本地服务投送' : '当前：在线音源直投原始 URL',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.mutedForeground,
                  ),
                ),
                trailing: Switch(
                  value: castLocalProxy,
                  onChanged: (v) => ref
                      .read(userPreferenceProvider.notifier)
                      .setCastLocalProxy(v),
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
                        '开启时所有曲目（含在线音源）通过本地 HTTP 服务器投送，'
                        '便于统一缓存与控制；关闭时在线音源直接投送原始 URL，'
                        '本地文件仍需通过本地服务器代理',
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
    );
  }
}

/// 缓存设置区块（页面和对话框共享）
class CacheSettingsSection extends HookConsumerWidget {
  const CacheSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheDirectory = ref.watch(
      userPreferenceProvider.select((p) => p.cacheDirectory),
    );
    final cacheSizeLimitGB = ref.watch(
      userPreferenceProvider.select((p) => p.cacheSizeLimitGB),
    );
    final cacheSizeAsync = ref.watch(cacheSizeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    Future<void> pickCacheDirectory() async {
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '选择缓存目录',
      );
      if (result == null) return;
      await ref.read(userPreferenceProvider.notifier).setCacheDirectory(result);
      ref.invalidate(cacheSizeProvider);
      AppToast().success('缓存目录已更新');
    }

    Future<void> openCacheDirectory() async {
      final ok = await MusicCacheDir.openDirectory();
      if (!ok) AppToast().error('无法打开缓存目录');
    }

    Future<void> clearCache() async {
      // 先弹出确认对话框
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('清除缓存'),
          content: const SizedBox(
            width: 340,
            child: Text('确定要清除所有音频缓存文件吗？此操作不可撤销。'),
          ),
          actions: [
            GhostButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            PrimaryButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('确定'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await MusicCacheDir.clear();
      ref.invalidate(cacheSizeProvider);
      AppToast().success('缓存已清除');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '缓存',
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
                leading: const Icon(Icons.storage, size: 20),
                title: const Text('缓存目录'),
                subtitle: Text(
                  cacheDirectory ?? '系统默认',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton.text(
                      icon: const Icon(Icons.folder_open, size: 18),
                      onPressed: pickCacheDirectory,
                    ),
                    if (cacheDirectory != null)
                      IconButton.text(
                        icon: const Icon(Icons.restore, size: 18),
                        onPressed: () {
                          ref
                              .read(userPreferenceProvider.notifier)
                              .setCacheDirectory(null);
                          ref.invalidate(cacheSizeProvider);
                        },
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.open_in_new, size: 20),
                title: const Text('打开缓存目录'),
                onTap: openCacheDirectory,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.data_usage, size: 20),
                title: const Text('缓存大小'),
                subtitle: Text(
                  cacheSizeAsync.when(
                    loading: () => '计算中…',
                    error: (_, _) => '无法获取',
                    data: (bytes) =>
                        '${formatBytes(bytes)} / $cacheSizeLimitGB GB',
                  ),
                ),
                trailing: IconButton.text(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: () => ref.invalidate(cacheSizeProvider),
                ),
              ),
              const Divider(height: 1),
              // 缓存上限 — 分段进度条
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cloud_upload_outlined, size: 20),
                        const Gap(8),
                        const Text('缓存上限'),
                        const Spacer(),
                        Text(
                          '$cacheSizeLimitGB GB',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        for (int i = 1; i <= 5; i++) ...[
                          Expanded(
                            child: GestureDetector(
                              onTap: () => ref
                                  .read(userPreferenceProvider.notifier)
                                  .setCacheSizeLimitGB(i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                height: 28,
                                decoration: BoxDecoration(
                                  color: i <= cacheSizeLimitGB
                                      ? colorScheme.primary
                                      : colorScheme.muted,
                                  borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(i == 1 ? 6 : 0),
                                    right: Radius.circular(i == 5 ? 6 : 0),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '$i',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: i <= cacheSizeLimitGB
                                          ? colorScheme.primaryForeground
                                          : colorScheme.mutedForeground,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (i < 5) const SizedBox(width: 3),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.cleaning_services_outlined, size: 20),
                title: const Text('清除缓存'),
                onTap: clearCache,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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
        padding: const EdgeInsets.all(16),
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
          const Gap(24),
          const PlaybackBehaviorSection(),
          const Gap(24),
          const CastSettingsSection(),
          const Gap(24),
          const CacheSettingsSection(),
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
        width: 460,
        child: SingleChildScrollView(
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
              const Gap(20),
              const PlaybackBehaviorSection(),
              const Gap(20),
              const CastSettingsSection(),
              const Gap(20),
              const CacheSettingsSection(),
            ],
          ),
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
