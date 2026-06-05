import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/module/module_manager.dart';
import 'package:pomelo/core/routers/router.dart';
import 'package:pomelo/modules/home/home_module.dart';
import 'package:pomelo/modules/example/example_module.dart';
import 'package:pomelo/core/theme/app_theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:window_manager/window_manager.dart';

import 'core/helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _runPlatformSpecificCode();

  // ========== M.A.R.S. 模块初始化 ==========
  final moduleManager = ModuleManager();
  await moduleManager.registerAll([HomeModule(), ExampleModule()]);
  await moduleManager.initAll();
  await moduleManager.readyAll();
  // =========================================

  runApp(
    ProviderScope(
      child: ShadApp.custom(
        themeMode: ThemeMode.system,
        theme: ShadThemeData(
          brightness: Brightness.light,
          colorScheme: const ShadSlateColorScheme.light(),
        ),
        darkTheme: ShadThemeData(
          brightness: Brightness.dark,
          colorScheme: const ShadSlateColorScheme.dark(),
        ),
        appBuilder: (context) => const MyApp(),
      ),
    ),
  );
}

Future<void> _runPlatformSpecificCode() async {
  if (!Helper.isDesktop) return;
  await windowManager.ensureInitialized();
  final windowOptions = WindowOptions(
    size: Size(1050, 700),
    center: true,
    skipTaskbar: false,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setPreventClose(true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pomelo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: routerConfig,
      builder: (context, child) {
        return BotToastInit()(context, ShadAppBuilder(child: child!));
      },
    );
  }
}
