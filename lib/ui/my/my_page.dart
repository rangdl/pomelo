import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' show ListTile;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Colors;
import 'package:pomelo/core/storage/settings.dart';

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
    final themeMode = ref.watch(settingWatcherProvider('my_theme_mode'));
    final effective = themeMode ?? 'system';

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
              leading: const Icon(Icons.brightness_6),
              title: const Text('主题模式'),
              trailing: Select<String>(
                value: effective,
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
              leading: const Icon(Icons.volume_up),
              title: const Text('播放设置'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: 导航到播放设置
              },
            ),
          ),
        ],
      ),
    );
  }
}
