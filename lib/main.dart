import 'dart:async';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:hive_ce/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart' show MediaKit;
import 'package:pomelo/core/module/module_manager.dart';
import 'package:pomelo/core/routers/app_router.dart';
import 'package:pomelo/core/storage/settings.dart';
import 'package:pomelo/core/theme/app_theme.dart';
import 'package:pomelo/core/log/log_module.dart';
import 'package:pomelo/core/log/log_providers.dart';
import 'package:pomelo/modules/audio_player/audio_player_module.dart';
import 'package:pomelo/modules/audio_player/module_providers.dart';
import 'package:pomelo/modules/favorite/favorite_module.dart';
import 'package:pomelo/modules/my/my_module.dart';
import 'package:pomelo/modules/music/music_module.dart';
import 'package:pomelo/modules/music_local/music_local_module.dart';
import 'package:pomelo/modules/music_lx/music_lx_module.dart';
import 'package:pomelo/modules/music_lx_server/music_lx_server_module.dart';
import 'package:pomelo/modules/music_subsonic/music_subsonic_module.dart';
import 'package:pomelo/modules/statistics/statistics_module.dart';
import 'package:pomelo/modules/home/home_module.dart';
import 'package:pomelo/modules/home/providers/home_providers.dart';
import 'package:pomelo/modules/example/example_module.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'core/helper.dart';

final appRouter = AppRouter();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  await _runPlatformSpecificCode();

  // ========== 存储层初始化（先于模块） ==========
  final appDir = await Helper.getAppDataDir();
  Hive.init(appDir);
  await Settings.init();
  // =============================================

  // ========== M.A.R.S. 模块初始化 ==========
  final moduleManager = ModuleManager();
  final homeModule = HomeModule();
  final logModule = LogModule();
  final audioPlayerModule = AudioPlayerModule();
  await moduleManager.registerAll([
    homeModule,
    ExampleModule(),
    FavoriteModule(),
    MyModule(),
    StatisticsModule(),
    MusicModule(),
    MusicLocalModule(),
    LxMusicModule(),
    MusicLxServerModule(),
    MusicSubsonicModule(),
    logModule,
    audioPlayerModule,
  ]);
  await moduleManager.initAll();
  await moduleManager.readyAll();
  // =========================================

  // ========== 全局错误处理 ==========
  final logService = logModule.service;

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    logService.error(
      'FlutterError',
      details.exceptionAsString(),
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    logService.fatal(
      'PlatformError',
      error.toString(),
      error: error,
      stackTrace: stack,
    );
    return true;
  };
  // ================================

  // ========== Riverpod ProviderContainer ==========
  // 显式创建 ProviderContainer，以便在 ProviderScope 之前注入到 audioPlayerModule
  // （ServerPlaybackRoutes 需要访问 trackUrlResolverProvider 完成播放链接解析）
  final container = ProviderContainer(
    overrides: [
      logServiceProvider.overrideWithValue(logModule.service),
      homeModuleProvider.overrideWithValue(homeModule),
      audioPlayerModuleProvider.overrideWithValue(audioPlayerModule),
    ],
  );
  audioPlayerModule.container = container;
  // ===============================================

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const _AppShell(),
    ),
  );
}

/// 应用壳 — 监听全局设置并响应式更新
class _AppShell extends HookConsumerWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 响应式监听主题模式设置
    final themeModeAsync = ref.watch(settingWatcherProvider('my_theme_mode'));
    final themeMode = _parseThemeMode(themeModeAsync.value);

    // 触发平台媒体控制服务初始化（Windows SMTC / 移动端通知栏）
    ref.watch(audioServicesProvider);

    // 监听当前曲目变化，同步元数据到系统媒体控制
    ref.listen(
      audioPlayerProvider.select((s) => s.activeTrack),
      (previous, next) {
        if (next == null) return;
        final audioServices = ref.read(audioServicesProvider).value;
        if (audioServices == null) return;
        audioServices.addTrack(next);
      },
    );

    return ShadcnApp.router(
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
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
