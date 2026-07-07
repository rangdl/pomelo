/// 音源设置页面
///
/// 集中管理音源相关设置：
/// - 本地音源全局开关（配合各 lx_server 的 `useLocalAudioSource` 开关使用）
/// - Lx 音源脚本管理（脚本内容持久化到 drift 表，不依赖文件系统）
/// - 各 Lx Server 配置的「使用本地音源」开关
///
/// 移动端作为全屏页面打开，桌面端作为对话框打开。
library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/models/lx_source_script.dart';
import 'package:pomelo/core/models/music_server_config.dart';
import 'package:pomelo/core/preferences/user_preference_provider.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/core/toast.dart';
import 'package:pomelo/modules/music_lx/providers/lx_source_scripts_provider.dart';
import 'package:pomelo/provider/music/music_server_config_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'dart:io';

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

/// Lx 音源脚本管理区块
///
/// 脚本内容直接持久化到 drift 表（[LxSourceScriptTable]），
/// 添加时解析脚本头部元信息并加载验证以获取注册的库与音质列表。
class LxSourcePluginSection extends HookConsumerWidget {
  const LxSourcePluginSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final colorScheme = Theme.of(context).colorScheme;
    final scriptsAsync = ref.watch(lxSourceScriptsProvider);

    Future<void> addScript() async {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: '选择 JS 音源脚本文件',
        type: FileType.custom,
        allowedExtensions: ['js'],
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;
      final pickedFile = result.files.first;
      if (pickedFile.path == null) return;

      isLoading.value = true;
      try {
        final content = await File(pickedFile.path!).readAsString();
        final libs = await ref
            .read(lxSourceScriptsNotifierProvider.notifier)
            .addScript(content);
        if (!context.mounted) return;
        if (libs == null) {
          AppToast().error('脚本加载失败，未注册任何库');
        } else if (libs.isEmpty) {
          AppToast().warning('脚本已保存，但未注册任何库');
        } else {
          AppToast().success(
            '音源脚本已添加，注册库: ${libs.map((l) => l.id).join(", ")}',
          );
        }
      } catch (e) {
        if (context.mounted) AppToast().error('添加失败: $e');
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> removeScript(String id) async {
      try {
        await ref.read(lxSourceScriptsNotifierProvider.notifier).removeScript(id);
        if (context.mounted) AppToast().success('音源脚本已移除');
      } catch (e) {
        if (context.mounted) AppToast().error('移除失败: $e');
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
                    '音源脚本',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    'Lx 音源插件脚本，提供音乐播放链接查询，支持多份添加',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            PrimaryButton(
              size: ButtonSize.small,
              enabled: !isLoading.value,
              onPressed: addScript,
              child: isLoading.value
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16),
                        Gap(4),
                        Text('添加'),
                      ],
                    ),
            ),
          ],
        ),
        const Gap(8),

        // 脚本列表或空状态
        scriptsAsync.when(
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (e, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  '加载失败: $e',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.mutedForeground,
                  ),
                ),
              ),
            ),
          ),
          data: (scripts) {
            if (scripts.isEmpty) {
              return Card(
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
                          '尚未添加音源脚本',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '已添加 (${scripts.length})',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.mutedForeground,
                  ),
                ),
                const Gap(4),
                Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < scripts.length; i++) ...[
                        _LxScriptTile(
                          script: scripts[i],
                          colorScheme: colorScheme,
                          onRemove: () => removeScript(scripts[i].id),
                        ),
                        if (i < scripts.length - 1) const Divider(height: 1),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// 单条 Lx 音源脚本列表项
class _LxScriptTile extends StatelessWidget {
  final LxSourceScript script;
  final ColorScheme colorScheme;
  final VoidCallback onRemove;

  const _LxScriptTile({
    required this.script,
    required this.colorScheme,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // 库与音质列表摘要
    final libsSummary = script.libraries.isEmpty
        ? '未注册库'
        : script.libraries.map((l) => '${l.id}(${l.qualitys.length})').join(' · ');

    return ListTile(
      leading: Icon(
        Icons.description,
        size: 20,
        color: colorScheme.primary,
      ),
      title: Text(
        script.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              if (script.author != null && script.author!.isNotEmpty)
                script.author,
              if (script.version != null && script.version!.isNotEmpty)
                'v${script.version}',
            ].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.mutedForeground,
            ),
          ),
          const Gap(2),
          Text(
            libsSummary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
      trailing: IconButton.text(
        icon: const Icon(Icons.close, size: 18),
        onPressed: onRemove,
      ),
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
