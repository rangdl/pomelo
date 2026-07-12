/// 音源设置页面
///
/// 集中管理音源相关设置：
/// - 本地音源全局开关 + 本地音源脚本管理（脚本内容持久化到 drift 表，不依赖文件系统）
/// - 各 Lx Server 配置的「使用本地音源」开关
/// - 脚本拖拽排序（左侧拖拽按钮）
/// - 每个库的成功率展示与调用统计详情
///
/// 移动端作为全屏页面打开，桌面端作为对话框打开。
library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' show ReorderableListView, ReorderableDragStartListener;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/models/database/app_database.dart';
import 'package:pomelo/core/models/lx_source_script.dart';
import 'package:pomelo/core/models/music_server_config.dart';
import 'package:pomelo/core/preferences/user_preference_provider.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/core/toast.dart';
import 'package:pomelo/modules/music_lx/providers/lx_source_scripts_provider.dart';
import 'package:pomelo/provider/music/music_server_config_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'dart:io';

/// 本地音源区块
///
/// 包含全局开关与本地音源脚本管理：
/// - 全局开关：配合各 Lx Server 的 `useLocalAudioSource` 开关使用
/// - 脚本管理：添加/移除本地音源脚本，脚本内容持久化到 drift 表
///
/// 添加脚本时解析脚本头部元信息并加载验证以获取注册的库与音质列表。
class LocalAudioSourceSection extends HookConsumerWidget {
  const LocalAudioSourceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      userPreferenceProvider.select((p) => p.localAudioSourceEnabled),
    );
    final colorScheme = Theme.of(context).colorScheme;
    final isLoading = useState(false);
    final scriptsAsync = ref.watch(lxSourceScriptsProvider);
    final usagesAsync = ref.watch(lxSourceUsagesProvider);

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
        // 标题 + 添加按钮
        Row(
          children: [
            Icon(Icons.graphic_eq, size: 24, color: colorScheme.primary),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '本地音源',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    '通过本地音源脚本获取播放链接，优先于在线解析',
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

        // 全局开关
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.toggle_on, size: 20),
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
                        '获取播放链接时优先通过本地音源脚本解析，失败再回退到在线解析',
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
            final usages = usagesAsync.value ?? const <LxSourceUsageEntity>[];
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
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: scripts.length,
                    onReorder: (oldIndex, newIndex) async {
                      // ReorderableListView 的 newIndex 在 oldIndex 之后时需要 -1
                      if (newIndex > oldIndex) newIndex -= 1;
                      final ordered = [...scripts];
                      final moved = ordered.removeAt(oldIndex);
                      ordered.insert(newIndex, moved);
                      await ref
                          .read(lxSourceScriptsNotifierProvider.notifier)
                          .reorderScripts(ordered.map((s) => s.id).toList());
                    },
                    itemBuilder: (context, index) {
                      final script = scripts[index];
                      final scriptUsages = usages
                          .where((u) => u.scriptId == script.id)
                          .toList();
                      return Padding(
                        key: ValueKey(script.id),
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: _LxScriptTile(
                          script: script,
                          index: index,
                          usages: scriptUsages,
                          colorScheme: colorScheme,
                          onRemove: () => removeScript(script.id),
                          onTap: () => _showScriptDetail(context, script),
                        ),
                      );
                    },
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

/// 计算指定库的成功率百分比
///
/// 无记录返回 100，否则返回 successCount / totalCount * 100 取整。
int _successRate(LxSourceUsageEntity? usage) {
  if (usage == null || usage.totalCount == 0) return 100;
  return (usage.successCount * 100 / usage.totalCount).round();
}

/// 单条 Lx 音源脚本列表项
class _LxScriptTile extends StatelessWidget {
  final LxSourceScript script;
  final int index;
  final List<LxSourceUsageEntity> usages;
  final ColorScheme colorScheme;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _LxScriptTile({
    required this.script,
    required this.index,
    required this.usages,
    required this.colorScheme,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 每个库的成功率摘要
    final libsSummary = script.libraries.isEmpty
        ? '未注册库'
        : script.libraries.map((lib) {
            final usage = usages.firstWhere(
              (u) => u.libraryId == lib.id,
              orElse: () => LxSourceUsageEntity(
                scriptId: script.id,
                libraryId: lib.id,
                totalCount: 0,
                successCount: 0,
                maxDurationMs: 0,
                minDurationMs: 0,
              ),
            );
            final rate = _successRate(usage);
            return '${lib.id} $rate%';
          }).join(' · ');

    return ListTile(
      leading: ReorderableDragStartListener(
        index: index,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            Icons.drag_indicator,
            size: 20,
            color: colorScheme.mutedForeground,
          ),
        ),
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
      onTap: onTap,
    );
  }
}

/// 展示音源脚本详情弹窗
void _showScriptDetail(
  BuildContext context,
  LxSourceScript script,
) {
  showDialog(
    context: context,
    builder: (_) => _ScriptDetailDialog(script: script),
  );
}

/// 音源脚本详情对话框
///
/// 展示脚本信息、库列表、音质列表与调用统计（成功率、调用次数、最高/最低耗时）。
/// 在内部通过 ref.watch 实时获取使用记录，避免依赖外部传入的静态快照导致 Dialog 不刷新。
class _ScriptDetailDialog extends ConsumerWidget {
  final LxSourceScript script;

  const _ScriptDetailDialog({required this.script});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    // 弹窗内部自己 watch provider，保证数据是最新的（Dialog 是独立 Route，不会随外部 rebuild）
    final usagesAsync = ref.watch(lxSourceUsagesProvider);
    final allUsages = usagesAsync.valueOrNull ?? const <LxSourceUsageEntity>[];
    final usages =
        allUsages.where((u) => u.scriptId == script.id).toList();

    final metaInfo = [
      if (script.author != null && script.author!.isNotEmpty)
        ('作者', script.author!),
      if (script.version != null && script.version!.isNotEmpty)
        ('版本', script.version!),
      if (script.description != null && script.description!.isNotEmpty)
        ('描述', script.description!),
      if (script.homepage != null && script.homepage!.isNotEmpty)
        ('主页', script.homepage!),
    ];

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.description, size: 20, color: colorScheme.primary),
          const Gap(8),
          Expanded(
            child: Text(
              script.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 脚本元信息
              if (metaInfo.isNotEmpty) ...[
                Text(
                  '脚本信息',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.mutedForeground,
                  ),
                ),
                const Gap(6),
                ...metaInfo.map(
                  (info) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 48,
                          child: Text(
                            info.$1,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.mutedForeground,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            info.$2,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(12),
              ],
              // 库列表与统计
              Text(
                '库与调用统计',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.mutedForeground,
                ),
              ),
              const Gap(6),
              if (script.libraries.isEmpty)
                Text(
                  '未注册库',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.mutedForeground,
                  ),
                )
              else
                ...script.libraries.map((lib) {
                  final usage = usages.firstWhere(
                    (u) => u.libraryId == lib.id,
                    orElse: () => LxSourceUsageEntity(
                      scriptId: script.id,
                      libraryId: lib.id,
                      totalCount: 0,
                      successCount: 0,
                      maxDurationMs: 0,
                      minDurationMs: 0,
                    ),
                  );
                  final rate = _successRate(usage);
                  final rateColor = rate >= 80
                      ? const Color(0xFF22C55E)
                      : rate >= 50
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFFEF4444);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                lib.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Gap(8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: rateColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '$rate%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: rateColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Gap(4),
                          Wrap(
                            spacing: 4,
                            runSpacing: 2,
                            children: lib.qualitys
                                .map(
                                  (q) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.muted
                                          .withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      q,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: colorScheme.mutedForeground,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          if (usage.totalCount > 0) ...[
                            const Gap(6),
                            Text(
                              '调用 ${usage.totalCount} 次 · 成功 ${usage.successCount} 次',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.mutedForeground,
                              ),
                            ),
                            const Gap(2),
                            Text(
                              '最高 ${usage.maxDurationMs}ms · 最低 ${usage.minDurationMs}ms',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.mutedForeground,
                              ),
                            ),
                          ] else
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '暂无调用记录',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.mutedForeground,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
      actions: [
        PrimaryButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
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
                  '需同时在上方「本地音源」中启用全局开关并添加音源脚本才会生效',
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
        width: 600,
        height: 620,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LocalAudioSourceSection(),
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
