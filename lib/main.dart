import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/app/app.provider.dart';
import 'package:pomelo/core/routers/router.provider.dart';
import 'package:window_manager/window_manager.dart';

import 'core/helper.dart';
import 'core/scroll_behavior.dart';
import 'core/theme/app_theme.dart';
import 'global.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _runPlatformSpecificCode();

  container = ProviderContainer();

  // Configure the App Metadata
  await initialize();

  await container.read(appSettingsProvider.future);
  await container.read(settingsNavsAsyncProvider.future);

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

Future<void> _runPlatformSpecificCode() async {
  if (!Helper.isDesktop) return;
  // 初始化窗口管理器
  await windowManager.ensureInitialized();
  final windowOptions = WindowOptions(
    size: Size(1050, 700),
    // minimumSize: Size(1050, 700),
    center: true,
    skipTaskbar: false,
    // titleBarStyle: TitleBarStyle.hidden, // 隐藏标题栏
    // windowButtonVisibility: false, // 隐藏窗口按钮
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setPreventClose(true);
  });
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      appSettingsProvider.select((v) => v.value!.themeMode),
    );

    return MaterialApp.router(
      title: 'Pomelo',
      debugShowCheckedModeBanner: false,
      scrollBehavior: AppCustomScrollBehavior(),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: ref.watch(routerProvider),
      builder: BotToastInit(), //1.调用BotToastInit
    );
  }
}
