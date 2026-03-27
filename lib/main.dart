import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'package:pomelo/features/example/ex.routes.dart';
import 'package:window_manager/window_manager.dart';

import 'core/helper.dart';
import 'core/registry/fluxy_registry.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home.routes.dart';

void main() async {
  // 1. Initialize Framework & Stability Policy
  // strictMode: true throws errors on layout violations (perfect for Dev)
  // strictMode: false (Relaxed) auto-fixes violations (perfect for Prod)
  await Fluxy.init(strictMode: false);

  // 2. Boot Modular Plugins (Auto-generated registry)
  registerFluxyPlugins();
  Fluxy.autoRegister();

  // 3. Setup Global Error Pipeline
  Fluxy.onError((error, stack) {
    debugPrint("Fluxy Global Error: $error");
  });

  await _runPlatformSpecificCode();
  runApp(
    Fluxy.debug(
      child: FluxyApp(
        title: 'Fluxy App',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        initialRoute: homeRoutes.first.path,
        routes: [...homeRoutes, ...exRoutes],
      ),
    ),
  );
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
