import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pomelo/core/module/module_manager.dart';
import 'package:pomelo/core/storage/settings.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/modules/music_local/providers/local_music_providers.dart';
import 'package:pomelo/modules/music_lx/music_lx_module.dart';

/// 我的页面 — 用户设置中心
///
/// 包含应用全局设置项，各设置直接通过 Settings 读写，
/// 其他模块可通过 ref.watch(settingWatcherProvider('key')) 响应式监听。
@RoutePage()
class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  static const _themeOptions = [
    ('system', '跟随系统', Icons.settings_brightness),
    ('light', '浅色模式', Icons.light_mode),
    ('dark', '深色模式', Icons.dark_mode),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(settingWatcherProvider('my_theme_mode'));
    final themeMode = themeModeAsync.value ?? 'system';
    final localDirs = ref.watch(localMusicDirsProvider);
    final lxScriptPaths = ref.watch(_lxScriptPathsProvider);

    return Scaffold(
      headers: [AppBar(title: const Text('设置'))],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== 外观 =====
          Text(
            '外观',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.brightness_6, size: 20),
              title: const Text('主题模式'),
              trailing: Select<String>(
                value: themeMode,
                onChanged: (value) {
                  if (value != null) Settings.set('my_theme_mode', value);
                },
                popup: SelectPopup(
                  items: SelectItemList(
                    children: [
                      SelectItemButton(value: 'system', child: Text('跟随系统')),
                      SelectItemButton(value: 'light', child: Text('浅色模式')),
                      SelectItemButton(value: 'dark', child: Text('深色模式')),
                    ],
                  ),
                ).call,
                itemBuilder: (BuildContext context, String value) {
                  return Text(
                    _themeOptions.firstWhere((o) => o.$1 == value).$2,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.mutedForeground,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ===== 本地音乐 =====
          Text(
            '本地音乐',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.folder_open, size: 20),
                  title: const Text('添加音乐目录'),
                  subtitle: Text('已扫描 ${ref.watch(localMusicSongCountProvider)} 首歌曲'),
                  trailing: const Icon(Icons.add, size: 20),
                  onTap: () async {
                    final result = await FilePicker.platform.getDirectoryPath(
                      dialogTitle: '选择音乐目录',
                    );
                    if (result != null) {
                      await ref
                          .read(localMusicDirsProvider.notifier)
                          .addDirectory(result);
                    }
                  },
                ),
                if (localDirs.isNotEmpty) ...[
                  const Divider(height: 1),
                  ...localDirs.map(
                    (dir) => ListTile(
                      leading: const Icon(Icons.folder, size: 20),
                      title: Text(p.basename(dir)),
                      subtitle: Text(dir, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: IconButton.text(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () {
                          ref
                              .read(localMusicDirsProvider.notifier)
                              .removeDirectory(dir);
                        },
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.refresh, size: 20),
                    title: const Text('重新扫描'),
                    onTap: () async {
                      await ref
                          .read(localMusicDirsProvider.notifier)
                          .rescanAll();
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ===== Lx 音乐脚本 =====
          Text(
            'Lx 音乐脚本',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.code, size: 20),
                  title: const Text('上传脚本文件'),
                  subtitle: const Text('支持 .js 格式的 musicsdk 脚本'),
                  trailing: const Icon(Icons.add, size: 20),
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(
                      dialogTitle: '选择 JS 脚本文件',
                      type: FileType.custom,
                      allowedExtensions: ['js'],
                    );
                    if (result != null && result.files.isNotEmpty) {
                      final pickedFile = result.files.first;
                      if (pickedFile.path == null) return;
                      // 复制到应用内部存储
                      final appDir = await getApplicationSupportDirectory();
                      final scriptsDir = Directory(
                        p.join(appDir.path, 'lx_scripts'),
                      );
                      if (!await scriptsDir.exists()) {
                        await scriptsDir.create(recursive: true);
                      }
                      final destPath = p.join(
                        scriptsDir.path,
                        p.basename(pickedFile.path!),
                      );
                      await File(pickedFile.path!).copy(destPath);
                      // 加载脚本
                      await ref
                          .read(_lxScriptPathsProvider.notifier)
                          .addScript(destPath);
                    }
                  },
                ),
                if (lxScriptPaths.isNotEmpty) ...[
                  const Divider(height: 1),
                  ...lxScriptPaths.map(
                    (path) => ListTile(
                      leading: const Icon(Icons.description, size: 20),
                      title: Text(p.basename(path)),
                      subtitle: Text(
                        path,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton.text(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () {
                          ref
                              .read(_lxScriptPathsProvider.notifier)
                              .removeScript(path);
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ===== 更多设置占位 =====
          Text(
            '其他',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.volume_up, size: 20),
              title: const Text('播放设置'),
              trailing: const Icon(Icons.chevron_right, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Lx 脚本路径 Provider
// ============================================================

/// Lx 脚本路径列表 Notifier
class LxScriptPathsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return LxMusicModule.loadScriptPaths();
  }

  /// 添加脚本
  Future<void> addScript(String path) async {
    if (state.contains(path)) return;
    final module = ModuleManager().find<LxMusicModule>('music_lx');
    if (module != null) {
      final success = await module.addScript(path);
      if (success) {
        state = [...state, path];
      }
    } else {
      // 模块未初始化，先保存路径
      state = [...state, path];
      await _save();
    }
  }

  /// 移除脚本
  Future<void> removeScript(String path) async {
    final module = ModuleManager().find<LxMusicModule>('music_lx');
    await module?.removeScript(path);
    state = state.where((p) => p != path).toList();
    _save();
  }

  Future<void> _save() async {
    await Settings.set('music_lx_script_paths',
        '[${state.map((p) => '"$p"').join(',')}]');
  }
}

/// Lx 脚本路径列表
final _lxScriptPathsProvider =
    NotifierProvider<LxScriptPathsNotifier, List<String>>(
      LxScriptPathsNotifier.new,
    );
