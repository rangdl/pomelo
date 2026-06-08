import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/storage/settings.dart';

/// 我的页面
///
/// 演示如何在 Widget 中响应式使用 Settings：
/// - ref.watch(settingsProvider) 监听所有设置变化
/// - ref.watch(settingWatcherProvider('key')) 监听单个键
/// - 直接 Settings.get() 一次性读取
@RoutePage()
class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 方案 A：监听单个设置项（自动重建 Widget）
    final themeMode = ref.watch(settingWatcherProvider('my_theme_mode'));

    // 方案 B：监听所有设置变化（可提取某个 key 使用）
    ref.watch(settingsProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('当前主题模式: $themeMode'),
            const SizedBox(height: 16),
            // 修改设置 — 所有 watch 者自动重建
            FilledButton(
              onPressed: () {
                Settings.set(
                  'my_theme_mode',
                  themeMode == 'dark' ? 'light' : 'dark',
                );
              },
              child: const Text('切换主题'),
            ),
          ],
        ),
      ),
    );
  }
}
