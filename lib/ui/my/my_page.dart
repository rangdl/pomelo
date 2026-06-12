import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pomelo/core/storage/settings.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/modules/music_local/providers/local_music_providers.dart';

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
