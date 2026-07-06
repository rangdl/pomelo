import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../providers/lx_metadata_plugin_paths_provider.dart';

/// Lx 插件管理内容组件（桌面端对话框和移动端页面共享）
///
/// 仅展示元数据插件管理；音源插件已迁移至「音源设置」页面。
class _LxPluginContent extends HookConsumerWidget {
  const _LxPluginContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);

    // ========== 文件选择 ==========

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

    // ========== 元数据插件操作 ==========

    Future<void> addMetadataPlugin() async {
      isLoading.value = true;
      try {
        final paths = await pickFiles();
        if (paths.isNotEmpty) {
          await ref
              .read(lxMetadataPluginPathsProvider.notifier)
              .addPlugin(paths.first);
          if (context.mounted) AppToast().success('元数据插件已添加');
        }
      } catch (e) {
        AppToast().error('添加失败: $e');
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> replaceMetadataPlugin() async {
      isLoading.value = true;
      try {
        final paths = await pickFiles();
        if (paths.isNotEmpty) {
          await ref
              .read(lxMetadataPluginPathsProvider.notifier)
              .replacePlugin(paths.first);
          if (context.mounted) AppToast().success('元数据插件已替换');
        }
      } catch (e) {
        AppToast().error('替换失败: $e');
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> removeMetadataPlugin(String path) async {
      try {
        await ref
            .read(lxMetadataPluginPathsProvider.notifier)
            .removePlugin(path);
        if (context.mounted) AppToast().success('元数据插件已移除');
      } catch (e) {
        AppToast().error('移除失败: $e');
      }
    }

    final colorScheme = Theme.of(context).colorScheme;
    final plugins = ref.watch(lxMetadataPluginPathsProvider);
    final hasPlugin = plugins.isNotEmpty;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // 标题 + 说明
        Row(
          children: [
            Icon(Icons.library_music, size: 24, color: colorScheme.primary),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '元数据插件',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    '提供音乐搜索与元信息，仅支持上传一份',
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

        // 插件或空状态
        if (hasPlugin)
          Card(
            child: ListTile(
              leading: Icon(
                Icons.description,
                size: 20,
                color: colorScheme.primary,
              ),
              title: Text(
                p.basename(plugins.first),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                plugins.first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton.text(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: isLoading.value ? null : replaceMetadataPlugin,
                  ),
                  IconButton.text(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => removeMetadataPlugin(plugins.first),
                  ),
                ],
              ),
            ),
          )
        else
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
                      '尚未添加元数据插件',
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
        const Gap(8),

        // 添加按钮（仅有插件时隐藏）
        if (!hasPlugin)
          PrimaryButton(
            onPressed: isLoading.value ? null : addMetadataPlugin,
            child: isLoading.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('添加元数据插件'),
          ),
      ],
    );
  }
}

/// 添加 Lx 插件对话框（桌面端使用）
class AddLxPluginDialog extends StatelessWidget {
  const AddLxPluginDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lx 音乐插件管理'),
      content: const SizedBox(
        width: 460,
        height: 320,
        child: _LxPluginContent(),
      ),
      actions: [
        GhostButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}

/// Lx 插件管理页面（移动端使用）
class LxPluginPage extends StatelessWidget {
  const LxPluginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Lx 音乐插件'),
          leading: [
            IconButton.text(
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ],
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: _LxPluginContent(),
      ),
    );
  }
}
