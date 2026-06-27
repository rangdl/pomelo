import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pomelo/core/storage/settings.dart';
import 'package:pomelo/core/storage/storage_keys.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/routers/app_router.gr.dart';
import 'package:pomelo/modules/music_local/local_music_providers.dart';
import 'package:pomelo/modules/my/service/update_service.dart';
import 'package:pomelo/ui/my/playback_settings_page.dart';

/// 我的页面 — 用户设置中心
///
/// 包含应用全局设置项，各设置直接通过 Settings 读写，
/// 其他模块可通过 ref.watch(settingWatcherProvider('key')) 响应式监听。
@RoutePage()
class MyPage extends HookConsumerWidget {
  const MyPage({super.key});

  static const _themeOptions = [
    ('system', '跟随系统', Icons.settings_brightness),
    ('light', '浅色模式', Icons.light_mode),
    ('dark', '深色模式', Icons.dark_mode),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(
      settingWatcherProvider(StorageKeys.myThemeMode),
    );
    final themeMode = themeModeAsync.value ?? 'system';
    final localDirs = ref.watch(localMusicDirsProvider);
    final checking = useState(false);

    Future<void> checkForUpdate() async {
      if (checking.value) return;
      checking.value = true;
      try {
        final info = await PackageInfo.fromPlatform();
        final result = await UpdateService().checkForUpdate(info.version);
        if (!context.mounted) return;
        _showUpdateResult(context, result);
      } finally {
        checking.value = false;
      }
    }

    final children = <Widget>[
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
              if (value != null) Settings.set(StorageKeys.myThemeMode, value);
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
              subtitle: Text(
                '已扫描 ${ref.watch(localMusicSongCountProvider)} 首歌曲',
              ),
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
                  subtitle: Text(
                    dir,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                  await ref.read(localMusicDirsProvider.notifier).rescanAll();
                },
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 24),

      // ===== 其他设置 =====
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
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.volume_up, size: 20),
              title: const Text('播放设置'),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => openPlaybackSettings(context),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.system_update, size: 20),
              title: const Text('检查更新'),
              trailing: checking.value
                  ? const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.chevron_right, size: 20),
              onTap: checking.value ? null : checkForUpdate,
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.info_outline, size: 20),
              title: const Text('关于'),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => context.pushRoute(const AboutRoute()),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('设置'),
          trailing: [
            GhostButton(
              size: ButtonSize.small,
              onPressed: () => context.pushRoute(const LogRoute()),
              child: const Icon(Icons.article_outlined, size: 18),
            ),
          ],
        ),
      ],
      child: CenteredListView(
        maxWidth: 800,
        padding: const EdgeInsets.all(16),
        children: children,
      ),
    );
  }

  /// 展示更新检查结果
  void _showUpdateResult(BuildContext context, UpdateCheckResult result) {
    if (result.errorMessage != null) {
      showToast(
        context: context,
        builder: (ctx, overlay) => _ToastCard(text: result.errorMessage!),
      );
      return;
    }

    if (!result.hasUpdate) {
      showToast(
        context: context,
        builder: (ctx, overlay) =>
            _ToastCard(text: '当前已是最新版本（v${result.currentVersion}）'),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (_) => _UpdateDialog(result: result),
    );
  }
}

/// 更新可用对话框
///
/// 展示版本对比、可选的 GitHub 加速地址输入，以及「稍后再说 / 更新日志 /
/// 前往下载」三个操作。
class _UpdateDialog extends StatefulWidget {
  final UpdateCheckResult result;

  const _UpdateDialog({required this.result});

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  final _proxyController = TextEditingController();

  @override
  void dispose() {
    _proxyController.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context, rootNavigator: true).pop();

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    return AlertDialog(
      title: const Text('发现新版本'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当前版本：v${result.currentVersion}'),
            const Gap(4),
            Text('最新版本：${result.latestTag ?? '未知'}'),
            const Gap(12),
            Text(
              'GitHub 加速地址（可选）',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
            const Gap(4),
            TextField(
              controller: _proxyController,
              placeholder: const Text('https://proxy.example.com'),
            ),
          ],
        ),
      ),
      actions: [
        GhostButton(onPressed: _close, child: const Text('稍后再说')),
        GhostButton(
          onPressed: () =>
              launchUrl(Uri.parse(UpdateService.releasesLatestUrl)),
          child: const Text('更新日志'),
        ),
        PrimaryButton(
          onPressed: () {
            final url = result.downloadUrl;
            if (url == null) return;
            final finalUrl = UpdateService.applyProxy(
              url,
              _proxyController.text,
            );
            _close();
            launchUrl(Uri.parse(finalUrl));
          },
          child: const Text('前往下载'),
        ),
      ],
    );
  }
}

/// 简易 Toast 卡片
class _ToastCard extends StatelessWidget {
  final String text;

  const _ToastCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(text),
      ),
    );
  }
}
