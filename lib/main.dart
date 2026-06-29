import 'dart:async';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:hive_ce/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart' show MediaKit;
import 'package:pomelo/core/log.dart';
import 'package:pomelo/core/log/log_module.dart';
import 'package:pomelo/core/log/log_providers.dart';
import 'package:pomelo/core/routers/app_router.dart';
import 'package:pomelo/core/storage/settings.dart';
import 'package:pomelo/core/storage/music_cache_dir.dart';
import 'package:pomelo/core/models/database/database_provider.dart';
import 'package:pomelo/core/preferences/user_preference.dart';
import 'package:pomelo/core/preferences/user_preference_provider.dart';
import 'package:pomelo/core/theme/app_theme.dart';
import 'package:pomelo/modules/audio_player/audio_player_module.dart';
import 'package:pomelo/modules/audio_player/module_providers.dart';
import 'package:pomelo/modules/audio_player/providers/current_lyric_provider.dart';
import 'package:pomelo/modules/home/home_module.dart';
import 'package:pomelo/modules/home/providers/home_providers.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'core/helper.dart';

final appRouter = AppRouter();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  await _runPlatformSpecificCode();

  // ========== 存储层初始化 ==========
  final appDir = await Helper.getAppDataDir();
  Hive.init(appDir);
  await Settings.init();
  // 迁移旧的散落 Settings key 到统一的 UserPreference
  // （必须在 ProviderContainer 创建前执行，UserPreferenceNotifier.build 会读取迁移结果）
  await UserPreferenceNotifier.migrateFromLegacySettings();
  // 初始化 MusicCacheDir 自定义目录（从持久化的 UserPreference 加载）
  MusicCacheDir.setCustomDirectory(
    UserPreference.loadFromBox().cacheDirectory,
  );
  // ================================

  // ========== 核心模块初始化 ==========
  // LogModule 必须先初始化，后续模块依赖日志服务
  final logModule = LogModule();
  await logModule.onInit();
  setLogService(logModule.service);

  final homeModule = HomeModule();
  await homeModule.onInit();

  final audioPlayerModule = AudioPlayerModule();
  await audioPlayerModule.onInit();
  // ===================================

  // ========== 全局错误处理 ==========
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    log.error(
      'FlutterError',
      details.exceptionAsString(),
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    log.fatal(
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
  // （ServerPlaybackRoutes 需要访问 sourcedTrackProvider 完成播放链接解析）
  final container = ProviderContainer(
    overrides: [
      logServiceProvider.overrideWithValue(logModule.service),
      homeModuleProvider.overrideWithValue(homeModule),
      audioPlayerModuleProvider.overrideWithValue(audioPlayerModule),
      appDatabaseProvider.overrideWithValue(audioPlayerModule.database),
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
    final themeModeStr = ref.watch(
      userPreferenceProvider.select((p) => p.themeMode),
    );
    final themeMode = _parseThemeMode(themeModeStr);

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

    // 监听当前歌词行，同步到系统媒体控制的 artist 展示位置
    ref.listen(currentLyricLineProvider, (previous, next) {
      final audioServices = ref.read(audioServicesProvider).value;
      if (audioServices == null) return;
      audioServices.updateLyric(next.value);
    });

    // 监听缓存目录设置变化，同步到 MusicCacheDir
    // 初始值已在 main() 中从持久化存储加载并应用，此处仅处理运行时变更
    ref.listen(
      userPreferenceProvider.select((p) => p.cacheDirectory),
      (previous, next) {
        MusicCacheDir.setCustomDirectory(next);
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
    size: const Size(1050, 700),
    center: true,
    skipTaskbar: false,
    // Windows 隐藏原生标题栏，使用自定义右侧标题栏
    titleBarStyle:
        Helper.isWindows ? TitleBarStyle.hidden : TitleBarStyle.normal,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setPreventClose(true);
  });
}
