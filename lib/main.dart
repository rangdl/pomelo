import 'package:bot_toast/bot_toast.dart';
import 'package:hive_ce/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/module/module_manager.dart';
import 'package:pomelo/core/routers/app_router.dart';
import 'package:pomelo/core/storage/settings.dart';
import 'package:pomelo/modules/log/log_module.dart';
import 'package:pomelo/modules/log/providers/log_providers.dart';
import 'package:pomelo/modules/favorite/favorite_module.dart';
import 'package:pomelo/modules/my/my_module.dart';
import 'package:pomelo/modules/music_sdk/music_module.dart';
import 'package:pomelo/modules/music/music_module.dart';
import 'package:pomelo/modules/music_local/music_local_module.dart';
import 'package:pomelo/modules/music_lx/music_lx_module.dart';
import 'package:pomelo/modules/statistics/statistics_module.dart';
import 'package:pomelo/modules/home/home_module.dart';
import 'package:pomelo/modules/example/example_module.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'core/helper.dart';

final appRouter = AppRouter();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _runPlatformSpecificCode();

  // ========== 存储层初始化（先于模块） ==========
  final appDir = await Helper.getAppDataDir();
  Hive.init(appDir);
  await Settings.init();
  // =============================================

  // ========== M.A.R.S. 模块初始化 ==========
  final moduleManager = ModuleManager();
  final logModule = LogModule();
  await moduleManager.registerAll([
    HomeModule(),
    ExampleModule(),
    FavoriteModule(),
    MyModule(),
    StatisticsModule(),
    MusicSdkModule(),
    MusicModule(),
    MusicLocalModule(),
    LxMusicModule(),
    logModule,
  ]);
  await moduleManager.initAll();
  await moduleManager.readyAll();
  // =========================================

  runApp(
    ProviderScope(
      overrides: [logServiceProvider.overrideWithValue(logModule.service)],
      child: const _AppShell(),
    ),
  );
}

/// 应用壳 — 监听全局设置并响应式更新
class _AppShell extends ConsumerWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 响应式监听主题模式设置
    final themeModeStr = ref.watch(settingWatcherProvider('my_theme_mode'));
    final themeMode = _parseThemeMode(themeModeStr);

    return ShadcnApp.router(
      themeMode: themeMode,
      theme: ThemeData(colorScheme: ColorSchemes.lightSlate),
      darkTheme: ThemeData(colorScheme: ColorSchemes.darkSlate),
      routerConfig: appRouter.config(),
      builder: (context, child) {
        return BotToastInit()(context, child ?? const SizedBox.shrink());
      },
    );
  }

  ThemeMode _parseThemeMode(String? mode) {
    return switch (mode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
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
