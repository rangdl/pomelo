/// 音源设置页面
///
/// 集中管理音源相关设置：
/// - 本地音源全局开关（配合各 lx_server 的 `useLocalAudioSource` 开关使用）
/// - Lx 音源插件管理（从 Lx 插件管理对话框迁移而来）
/// - 各 Lx Server 配置的「使用本地音源」开关
///
/// 移动端作为全屏页面打开，桌面端作为对话框打开。
library;

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/models/music_server_config.dart';
import 'package:pomelo/core/preferences/user_preference_provider.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/core/toast.dart';
import 'package:pomelo/provider/music/music_server_config_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../platform/providers/lx_source_plugin_paths_provider.dart';

/// 本地音源全局开关区块
class LocalAudioSourceSection extends ConsumerWidget {
  const LocalAudioSourceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      userPreferenceProvider.select((p) => p.localAudioSourceEnabled),
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '本地音源',
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
                title: const Text('优先使用本地音源'),
                subtitle: Text(
                  enabled ? '当前：已启用' : '当前：已关闭',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.mutedForeground,
                  ),
                ),
                trailing: Switch(
                  value: enabled,
                  onChanged: (v) => ref
                      .read(userPreferenceProvider.notifier)
                      .setLocalAudioSourceEnabled(v),
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
                        '开启后，配合各 Lx Server 配置中的「使用本地音源」开关，'
                        '获取播放链接时优先从本地音乐库匹配，失败再回退到在线解析',
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

/// Lx 音源插件管理区块
class LxSourcePluginSection extends HookConsumerWidget {
  const LxSourcePluginSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final colorScheme = Theme.of(context).colorScheme;
    final plugins = ref.watch(lxSourcePluginPathsProvider);

    Future<List<String>> pickFiles({bool allowMultiple = false}) async {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: '选择 JS 插件文件',
        type: FileType.custom,
        allowedExtensions: ['js'],
        allowMultiple: allowMultiple,
      );

      if (result == null || result.files.isEmpty) return [];

      final appDir = await getApplicationSupportDirectory();
      final pluginsDir = Directory(p.join(appDir.path, 'lx_scripts'));
      if (!await pluginsDir.exists()) {
        await pluginsDir.create(recursive: true);
      }

      final paths = <String>[];
      for (final pickedFile in result.files) {
        if (pickedFile.path == null) continue;
        final destPath = p.join(pluginsDir.path, p.basename(pickedFile.path!));
        if (!await File(destPath).exists()) {
          await File(pickedFile.path!).copy(destPath);
        }
        paths.add(destPath);
      }
      return paths;
    }

    Future<void> replaceSourcePlugin(String oldPath) async {
      isLoading.value = true;
      try {
        final paths = await pickFiles();
        if (paths.isNotEmpty) {
          await ref
              .read(lxSourcePluginPathsProvider.notifier)
              .replacePlugin(oldPath, paths.first);
          if (context.mounted) AppToast().success('音源插件已替换');
        }
      } catch (e) {
        AppToast().error('替换失败: $e');
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> removeSourcePlugin(String path) async {
      try {
        await ref.read(lxSourcePluginPathsProvider.notifier).removePlugin(path);
        if (context.mounted) AppToast().success('音源插件已移除');
      } catch (e) {
        AppToast().error('移除失败: $e');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题 + 说明
        Row(
          children: [
            Icon(Icons.audiotrack, size: 24, color: colorScheme.primary),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '音源插件',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    'Lx 音源插件，提供音乐播放链接查询，支持多份上传',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Gap(8),

        // 插件列表或空状态
        if (plugins.isNotEmpty) ...[
          Text(
            '已添加 (${plugins.length})',
            style: TextStyle(fontSize: 12, color: colorScheme.mutedForeground),
          ),
          const Gap(4),
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < plugins.length; i++) ...[
                  ListTile(
                    leading: Icon(
                      Icons.description,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    title: Text(
                      p.basename(plugins[i]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      plugins[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton.text(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: isLoading.value
                              ? null
                              : () => replaceSourcePlugin(plugins[i]),
                        ),
                        IconButton.text(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => removeSourcePlugin(plugins[i]),
                        ),
                      ],
                    ),
                  ),
                  if (i < plugins.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
        ] else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 28,
                      color: colorScheme.mutedForeground,
                    ),
                    const Gap(6),
                    Text(
                      '尚未添加音源插件',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Lx Server 使用本地音源配置区块
///
/// 列出所有已配置的 Lx Server，每个独立切换是否使用本地音源。
class LxServerLocalSourceSection extends ConsumerWidget {
  const LxServerLocalSourceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs = ref.watch(musicServerConfigsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final lxServerConfigs = configs.value
            ?.whereType<LxServerConfig>()
            .toList() ??
        const <LxServerConfig>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lx Server 本地音源',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.mutedForeground,
          ),
        ),
        const Gap(8),
        if (lxServerConfigs.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_off_outlined,
                      size: 28,
                      color: colorScheme.mutedForeground,
                    ),
                    const Gap(6),
                    Text(
                      '尚未配置 Lx Server',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < lxServerConfigs.length; i++) ...[
                  ListTile(
                    leading: const Icon(Icons.dns, size: 20),
                    title: Text(lxServerConfigs[i].name),
                    subtitle: Text(
                      lxServerConfigs[i].serverUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                    trailing: Switch(
                      value: lxServerConfigs[i].useLocalAudioSource,
                      onChanged: (v) async {
                        await ref
                            .read(musicServerConfigsNotifierProvider.notifier)
                            .upsert(
                              lxServerConfigs[i].copyWith(
                                useLocalAudioSource: v,
                              ),
                            );
                      },
                    ),
                  ),
                  if (i < lxServerConfigs.length - 1)
                    const Divider(height: 1),
                ],
              ],
            ),
          ),
        const Gap(8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  '为每个 Lx Server 独立配置是否使用本地音源。'
                  '需同时在上方「本地音源」中启用全局开关才会生效',
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
    );
  }
}

/// 音源设置页面
class AudioSourceSettingsPage extends ConsumerWidget {
  const AudioSourceSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          title: const Text('音源设置'),
        ),
      ],
      child: CenteredListView(
        maxWidth: 640,
        padding: const EdgeInsets.all(16),
        children: [
          const LocalAudioSourceSection(),
          const Gap(24),
          const LxSourcePluginSection(),
          const Gap(24),
          const LxServerLocalSourceSection(),
        ],
      ),
    );
  }
}

/// 打开音源设置 — 响应式
///
/// 移动端：全屏页面
/// 桌面端：对话框
void openAudioSourceSettings(BuildContext context) {
  Rx.action(
    context,
    mobile: () => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AudioSourceSettingsPage(),
      ),
    ),
    tablet: () => showDialog(
      context: context,
      builder: (_) => const _AudioSourceSettingsDialog(),
    ),
  );
}

/// 桌面端音源设置对话框
class _AudioSourceSettingsDialog extends ConsumerWidget {
  const _AudioSourceSettingsDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('音源设置'),
      content: SizedBox(
        width: 480,
        height: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LocalAudioSourceSection(),
              const Gap(20),
              const LxSourcePluginSection(),
              const Gap(20),
              const LxServerLocalSourceSection(),
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
