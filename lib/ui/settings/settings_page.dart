import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pomelo/core/preferences/user_preference_provider.dart';
import 'package:pomelo/core/toast.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/routers/app_router.gr.dart';
import 'package:pomelo/services/update/update_service.dart';
import 'package:pomelo/ui/settings/playback_settings_page.dart';
import 'package:pomelo/ui/settings/audio_source_settings_page.dart';

/// 设置页面 — 用户设置中心
///
/// 包含应用全局设置项，各设置直接通过 UserPreference 读写。
@RoutePage()
class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  static const _themeOptions = [
    ('system', '跟随系统', Icons.settings_brightness),
    ('light', '浅色模式', Icons.light_mode),
    ('dark', '深色模式', Icons.dark_mode),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      userPreferenceProvider.select((p) => p.themeMode),
    );
    final checking = useState(false);
    // 检查更新点击计数（短时间连续点击 3 次以上未发现新版本时，提示刷新 CDN 缓存）
    final checkClickCount = useState(0);
    final firstClickTime = useState<DateTime?>(null);

    Future<void> checkForUpdate() async {
      if (checking.value) return;
      checking.value = true;
      try {
        final info = await PackageInfo.fromPlatform();
        final result = await UpdateService().checkForUpdate(info.version);
        if (!context.mounted) return;

        // 记录点击时间戳，10 秒内累计计数
        final now = DateTime.now();
        if (firstClickTime.value == null ||
            now.difference(firstClickTime.value!).inSeconds > 10) {
          firstClickTime.value = now;
          checkClickCount.value = 1;
        } else {
          checkClickCount.value++;
        }

        // 未发现新版本且短时间点击 3 次以上，提示刷新 CDN 缓存
        if (!result.hasUpdate &&
            result.errorMessage == null &&
            checkClickCount.value >= 3) {
          checkClickCount.value = 0;
          firstClickTime.value = null;
          _showCdnPurgeDialog(context, ref);
          return;
        }

        _showUpdateResult(context, ref, result);
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
      const Gap(8),
      Card(
        child: ListTile(
          leading: const Icon(Icons.brightness_6, size: 20),
          title: const Text('主题模式'),
          trailing: Select<String>(
            value: themeMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(userPreferenceProvider.notifier).setThemeMode(value);
              }
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
      const Gap(24),

      // ===== 其他设置 =====
      Text(
        '其他',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.mutedForeground,
        ),
      ),
      const Gap(8),
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
              leading: const Icon(Icons.graphic_eq, size: 20),
              title: const Text('音源设置'),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => openAudioSourceSettings(context),
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
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.info_outline, size: 20),
              title: const Text('测试'),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                AppToast().info('成功');
              },
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

  /// 提示是否刷新 CDN 缓存
  ///
  /// 短时间内连续检查更新 3 次以上未发现新版本时触发。
  void _showCdnPurgeDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('刷新 CDN 缓存'),
        content: const SizedBox(
          width: 380,
          child: Text('多次检查未发现新版本，可能是 CDN 缓存未更新。\n是否刷新 jsDelivr CDN 缓存后重新检查？'),
        ),
        actions: [
          GhostButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          PrimaryButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await UpdateService().purgeCdnCache();
              if (!context.mounted) return;
              if (success) {
                context.toast.success('CDN 缓存刷新成功');
              } else {
                context.toast.error('CDN 缓存刷新失败');
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 展示更新检查结果
  void _showUpdateResult(
    BuildContext context,
    WidgetRef ref,
    UpdateCheckResult result,
  ) {
    if (result.errorMessage != null) {
      context.toast.error(result.errorMessage!);
      return;
    }

    if (!result.hasUpdate) {
      context.toast.info('当前已是最新版本（v${result.currentVersion}）');
      return;
    }

    showDialog<void>(
      context: context,
      builder: (_) => _UpdateDialog(
        result: result,
        savedProxy: ref.read(userPreferenceProvider).updateProxy,
        onSaveProxy: (proxy) =>
            ref.read(userPreferenceProvider.notifier).setUpdateProxy(proxy),
      ),
    );
  }
}

/// 更新可用对话框
///
/// 展示版本对比、可选的 GitHub 加速地址输入，以及「稍后再说 / 更新日志 /
/// 前往下载」三个操作。
class _UpdateDialog extends StatefulWidget {
  final UpdateCheckResult result;
  final String? savedProxy;
  final Future<void> Function(String proxy) onSaveProxy;

  const _UpdateDialog({
    required this.result,
    required this.savedProxy,
    required this.onSaveProxy,
  });

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  final _proxyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 自动填入上次输入的 GitHub 加速地址
    final saved = widget.savedProxy;
    if (saved != null && saved.isNotEmpty) {
      _proxyController.text = saved;
    }
  }

  @override
  void dispose() {
    _proxyController.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context, rootNavigator: true).pop();

  /// 持久化加速地址并跳转下载
  Future<void> _download() async {
    final url = widget.result.downloadUrl;
    if (url == null) return;
    final proxy = _proxyController.text;
    // 持久化以便下次自动填入
    await widget.onSaveProxy(proxy);
    final finalUrl = UpdateService.applyProxy(url, proxy);
    _close();
    launchUrl(Uri.parse(finalUrl));
  }

  /// 通过巨魔商店（TrollStore）安装 IPA
  ///
  /// 调用 URL scheme `apple-magnifier://install?url=<IPA_URL>` 拉起巨魔商店。
  /// 加速地址处理与 [_download] 一致，便于在受限网络环境下使用。
  Future<void> _openWithTrollStore() async {
    final url = widget.result.downloadUrl;
    if (url == null) return;
    final proxy = _proxyController.text;
    await widget.onSaveProxy(proxy);
    final finalUrl = UpdateService.applyProxy(url, proxy);
    final trollUrl =
        'apple-magnifier://install?url=${Uri.encodeComponent(finalUrl)}';
    _close();
    launchUrl(Uri.parse(trollUrl));
  }

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
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 4,
          runSpacing: 4,
          children: [
            // GhostButton(onPressed: _close, child: const Text('稍后再说')),
            GhostButton(
              onPressed: () =>
                  launchUrl(Uri.parse(UpdateService.releasesLatestUrl)),
              child: const Text('更新日志'),
            ),
            PrimaryButton(
              onPressed: _openWithTrollStore,
              child: const Text('巨魔打开'),
            ),
            PrimaryButton(onPressed: _download, child: const Text('前往下载')),
          ],
        ),
      ],
    );
  }
}
