import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../providers/lx_script_paths_provider.dart';

/// Lx 脚本管理内容组件（桌面端对话框和移动端页面共享）
class _LxScriptContent extends ConsumerStatefulWidget {
  const _LxScriptContent();

  @override
  ConsumerState<_LxScriptContent> createState() => _LxScriptContentState();
}

class _LxScriptContentState extends ConsumerState<_LxScriptContent> {
  bool _isLoading = false;

  Future<void> _pickAndAddFiles() async {
    setState(() => _isLoading = true);

    final result = await FilePicker.platform.pickFiles(
      dialogTitle: '选择 JS 脚本文件',
      type: FileType.custom,
      allowedExtensions: ['js'],
      allowMultiple: true,
    );

    if (result == null || result.files.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    final appDir = await getApplicationSupportDirectory();
    final scriptsDir = Directory(p.join(appDir.path, 'lx_scripts'));
    if (!await scriptsDir.exists()) {
      await scriptsDir.create(recursive: true);
    }

    final paths = <String>[];
    for (final pickedFile in result.files) {
      if (pickedFile.path == null) continue;
      final destPath = p.join(scriptsDir.path, p.basename(pickedFile.path!));
      if (!await File(destPath).exists()) {
        await File(pickedFile.path!).copy(destPath);
      }
      paths.add(destPath);
    }

    await ref.read(lxScriptPathsProvider.notifier).addScripts(paths);
    setState(() => _isLoading = false);
  }

  Future<void> _removeScript(String path) async {
    await ref.read(lxScriptPathsProvider.notifier).removeScript(path);
  }

  @override
  Widget build(BuildContext context) {
    final scripts = ref.watch(lxScriptPathsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 说明区域
        Row(
          children: [
            Icon(Icons.code, size: 32, color: colorScheme.primary),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'musicsdk 脚本',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Gap(2),
                  Text(
                    '选择 .js 格式的脚本文件，支持多选。脚本加载后会自动检测注册的音乐平台。',
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
        const Gap(16),

        // 已添加的脚本列表
        if (scripts.isNotEmpty) ...[
          Text(
            '已添加 (${scripts.length})',
            style: TextStyle(fontSize: 12, color: colorScheme.mutedForeground),
          ),
          const Gap(8),
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < scripts.length; i++) ...[
                  ListTile(
                    leading: Icon(
                      Icons.description,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    title: Text(
                      p.basename(scripts[i]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      scripts[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton.text(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => _removeScript(scripts[i]),
                    ),
                  ),
                  if (i < scripts.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
        ] else ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 32,
                    color: colorScheme.mutedForeground,
                  ),
                  const Gap(8),
                  Text(
                    '尚未添加任何脚本',
                    style: TextStyle(color: colorScheme.mutedForeground),
                  ),
                ],
              ),
            ),
          ),
        ],
        const Gap(16),

        // 添加按钮
        PrimaryButton(
          onPressed: _isLoading ? null : _pickAndAddFiles,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('添加脚本'),
        ),
      ],
    );
  }
}

/// 添加 Lx 脚本对话框（桌面端使用）
class AddLxScriptDialog extends StatelessWidget {
  const AddLxScriptDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lx 音乐脚本管理'),
      content: const SizedBox(width: 420, child: _LxScriptContent()),
      actions: [
        GhostButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}

/// Lx 脚本管理页面（移动端使用）
class LxScriptPage extends StatelessWidget {
  const LxScriptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Lx 音乐脚本'),
          leading: [IconButton.text(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          )],
        ),
      ],
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: _LxScriptContent(),
      ),
    );
  }
}
