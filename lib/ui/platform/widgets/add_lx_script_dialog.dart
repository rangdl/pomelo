import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../providers/lx_script_paths_provider.dart';
import '../providers/lx_source_script_paths_provider.dart';

/// Lx 脚本管理内容组件（桌面端对话框和移动端页面共享）
///
/// 不使用 Tab，搜索脚本和源脚本作为两个独立区域依次展示。
class _LxScriptContent extends ConsumerStatefulWidget {
  const _LxScriptContent();

  @override
  ConsumerState<_LxScriptContent> createState() => _LxScriptContentState();
}

class _LxScriptContentState extends ConsumerState<_LxScriptContent> {
  bool _isLoading = false;

  // ========== 文件选择 ==========

  Future<List<String>> _pickFiles({bool allowMultiple = false}) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: '选择 JS 脚本文件',
      type: FileType.custom,
      allowedExtensions: ['js'],
      allowMultiple: allowMultiple,
    );

    if (result == null || result.files.isEmpty) return [];

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
    return paths;
  }

  // ========== 搜索脚本操作 ==========

  Future<void> _addSearchScript() async {
    setState(() => _isLoading = true);
    final paths = await _pickFiles();
    if (paths.isNotEmpty) {
      await ref.read(lxScriptPathsProvider.notifier).addScript(paths.first);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _replaceSearchScript() async {
    setState(() => _isLoading = true);
    final paths = await _pickFiles();
    if (paths.isNotEmpty) {
      await ref.read(lxScriptPathsProvider.notifier).replaceScript(paths.first);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _removeSearchScript(String path) async {
    await ref.read(lxScriptPathsProvider.notifier).removeScript(path);
  }

  // ========== 源脚本操作 ==========

  Future<void> _addSourceScripts() async {
    setState(() => _isLoading = true);
    final paths = await _pickFiles(allowMultiple: true);
    for (final path in paths) {
      await ref.read(lxSourceScriptPathsProvider.notifier).addScript(path);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _replaceSourceScript(String oldPath) async {
    setState(() => _isLoading = true);
    final paths = await _pickFiles();
    if (paths.isNotEmpty) {
      await ref
          .read(lxSourceScriptPathsProvider.notifier)
          .replaceScript(oldPath, paths.first);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _removeSourceScript(String path) async {
    await ref.read(lxSourceScriptPathsProvider.notifier).removeScript(path);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildSearchScriptSection(colorScheme),
        const Gap(24),
        _buildSourceScriptSection(colorScheme),
      ],
    );
  }

  /// 搜索脚本区域
  Widget _buildSearchScriptSection(ColorScheme colorScheme) {
    final scripts = ref.watch(lxScriptPathsProvider);
    final hasScript = scripts.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题 + 说明
        Row(
          children: [
            Icon(Icons.search, size: 24, color: colorScheme.primary),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '搜索脚本',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    '用于搜索音乐元数据，仅支持上传一份',
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

        // 脚本或空状态
        if (hasScript)
          Card(
            child: ListTile(
              leading: Icon(Icons.description, size: 20, color: colorScheme.primary),
              title: Text(
                p.basename(scripts.first),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                scripts.first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton.text(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: _isLoading ? null : _replaceSearchScript,
                  ),
                  IconButton.text(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => _removeSearchScript(scripts.first),
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
                    Icon(Icons.add_circle_outline, size: 28, color: colorScheme.mutedForeground),
                    const Gap(6),
                    Text(
                      '尚未添加搜索脚本',
                      style: TextStyle(fontSize: 13, color: colorScheme.mutedForeground),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const Gap(8),

        // 添加按钮（仅有脚本时隐藏）
        if (!hasScript)
          PrimaryButton(
            onPressed: _isLoading ? null : _addSearchScript,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('添加搜索脚本'),
          ),
      ],
    );
  }

  /// 源脚本区域
  Widget _buildSourceScriptSection(ColorScheme colorScheme) {
    final scripts = ref.watch(lxSourceScriptPathsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题 + 说明
        Row(
          children: [
            Icon(Icons.link, size: 24, color: colorScheme.primary),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '源脚本',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    '用于查询音乐播放链接，支持多份上传',
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

        // 脚本列表或空状态
        if (scripts.isNotEmpty) ...[
          Text(
            '已添加 (${scripts.length})',
            style: TextStyle(fontSize: 12, color: colorScheme.mutedForeground),
          ),
          const Gap(4),
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < scripts.length; i++) ...[
                  ListTile(
                    leading: Icon(Icons.description, size: 20, color: colorScheme.primary),
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton.text(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: _isLoading
                              ? null
                              : () => _replaceSourceScript(scripts[i]),
                        ),
                        IconButton.text(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => _removeSourceScript(scripts[i]),
                        ),
                      ],
                    ),
                  ),
                  if (i < scripts.length - 1) const Divider(height: 1),
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
                    Icon(Icons.add_circle_outline, size: 28, color: colorScheme.mutedForeground),
                    const Gap(6),
                    Text(
                      '尚未添加源脚本',
                      style: TextStyle(fontSize: 13, color: colorScheme.mutedForeground),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const Gap(8),

        // 添加按钮
        PrimaryButton(
          onPressed: _isLoading ? null : _addSourceScripts,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('添加源脚本'),
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
      content: const SizedBox(width: 460, height: 500, child: _LxScriptContent()),
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
        child: _LxScriptContent(),
      ),
    );
  }
}
