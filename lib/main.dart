import 'package:bot_toast/bot_toast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/module/module_manager.dart';
import 'package:pomelo/core/routers/app_router.dart';
import 'package:pomelo/modules/home/home_module.dart';
import 'package:pomelo/modules/example/example_module.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'core/helper.dart';

final appRouter = AppRouter();

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
      child: ShadcnApp.router(
        themeMode: ThemeMode.system,
        theme: ThemeData(colorScheme: ColorSchemes.lightSlate),
        darkTheme: ThemeData(colorScheme: ColorSchemes.darkSlate),
        routerConfig: appRouter.config(),
        builder: (context, child) {
          return BotToastInit()(context, child ?? const SizedBox.shrink());
        },
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
