import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../providers/lx_metadata_plugin_paths_provider.dart';
import '../providers/lx_source_plugin_paths_provider.dart';

/// Lx 插件管理内容组件（桌面端对话框和移动端页面共享）
///
/// 不使用 Tab，元数据插件和音源插件作为两个独立区域依次展示。
class _LxPluginContent extends ConsumerStatefulWidget {
  const _LxPluginContent();

  @override
  ConsumerState<_LxPluginContent> createState() => _LxPluginContentState();
}

class _LxPluginContentState extends ConsumerState<_LxPluginContent> {
  bool _isLoading = false;

  // ========== 文件选择 ==========

  Future<List<String>> _pickFiles({bool allowMultiple = false}) async {
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

  Future<void> _addMetadataPlugin() async {
    setState(() => _isLoading = true);
    final paths = await _pickFiles();
    if (paths.isNotEmpty) {
      await ref.read(lxMetadataPluginPathsProvider.notifier).addPlugin(paths.first);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _replaceMetadataPlugin() async {
    setState(() => _isLoading = true);
    final paths = await _pickFiles();
    if (paths.isNotEmpty) {
      await ref.read(lxMetadataPluginPathsProvider.notifier).replacePlugin(paths.first);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _removeMetadataPlugin(String path) async {
    await ref.read(lxMetadataPluginPathsProvider.notifier).removePlugin(path);
  }

  // ========== 音源插件操作 ==========

  Future<void> _addSourcePlugins() async {
    setState(() => _isLoading = true);
    final paths = await _pickFiles(allowMultiple: true);
    for (final path in paths) {
      await ref.read(lxSourcePluginPathsProvider.notifier).addPlugin(path);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _replaceSourcePlugin(String oldPath) async {
    setState(() => _isLoading = true);
    final paths = await _pickFiles();
    if (paths.isNotEmpty) {
      await ref
          .read(lxSourcePluginPathsProvider.notifier)
          .replacePlugin(oldPath, paths.first);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _removeSourcePlugin(String path) async {
    await ref.read(lxSourcePluginPathsProvider.notifier).removePlugin(path);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildMetadataPluginSection(colorScheme),
        const Gap(24),
        _buildSourcePluginSection(colorScheme),
      ],
    );
  }

  /// 元数据插件区域
  Widget _buildMetadataPluginSection(ColorScheme colorScheme) {
    final plugins = ref.watch(lxMetadataPluginPathsProvider);
    final hasPlugin = plugins.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              leading: Icon(Icons.description, size: 20, color: colorScheme.primary),
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
                    onPressed: _isLoading ? null : _replaceMetadataPlugin,
                  ),
                  IconButton.text(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => _removeMetadataPlugin(plugins.first),
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
                      '尚未添加元数据插件',
                      style: TextStyle(fontSize: 13, color: colorScheme.mutedForeground),
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
            onPressed: _isLoading ? null : _addMetadataPlugin,
            child: _isLoading
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

  /// 音源插件区域
  Widget _buildSourcePluginSection(ColorScheme colorScheme) {
    final plugins = ref.watch(lxSourcePluginPathsProvider);

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
                    '提供音乐播放链接查询，支持多份上传',
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
                    leading: Icon(Icons.description, size: 20, color: colorScheme.primary),
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
                          onPressed: _isLoading
                              ? null
                              : () => _replaceSourcePlugin(plugins[i]),
                        ),
                        IconButton.text(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => _removeSourcePlugin(plugins[i]),
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
                    Icon(Icons.add_circle_outline, size: 28, color: colorScheme.mutedForeground),
                    const Gap(6),
                    Text(
                      '尚未添加音源插件',
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
          onPressed: _isLoading ? null : _addSourcePlugins,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('添加音源插件'),
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
      content: const SizedBox(width: 460, height: 500, child: _LxPluginContent()),
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
