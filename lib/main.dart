import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/routers/router.dart';
import 'package:window_manager/window_manager.dart';

import 'core/helper.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _runPlatformSpecificCode();

  await _runPlatformSpecificCode();
  runApp(ProviderScope(child: const MyApp()));
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pomelo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: routerConfig,
      builder: BotToastInit(), //1.调用BotToastInit
    );
  }
}
