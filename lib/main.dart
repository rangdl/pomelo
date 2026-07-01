import 'dart:async';
import 'dart:ui';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart' show MediaKit;
import 'package:pomelo/core/models/database/app_database.dart';
import 'package:pomelo/core/models/database/database_provider.dart';
import 'package:pomelo/core/preferences/user_preference.dart';
import 'package:pomelo/core/preferences/user_preference_provider.dart';
import 'package:pomelo/core/routers/app_router.dart';
import 'package:pomelo/core/storage/music_cache_dir.dart';
import 'package:pomelo/core/theme/app_theme.dart';
import 'package:pomelo/core/toast.dart';
import 'package:pomelo/modules/audio_player/module_providers.dart';
import 'package:pomelo/modules/audio_player/providers/current_lyric_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'core/helper.dart';
import 'core/hooks/use_has_touch.dart';
import 'services/logger.dart';

final appRouter = AppRouter(navigatorKey: appNavigatorKey);

void main() async {
  AppLogger.initialize(false);
  AppLogger.runZoned(() async {
    WidgetsFlutterBinding.ensureInitialized();
    MediaKit.ensureInitialized();

    await _runPlatformSpecificCode();

    // ========== 存储层初始化 ==========
    // 提前创建 drift 数据库（所有模块共享同一实例）
    final database = AppDatabase();
    // 从 drift 数据库加载 UserPreference（用于初始化 MusicCacheDir）
    final persistedPref = await UserPreference.loadFromDatabase(database);
    MusicCacheDir.setCustomDirectory(persistedPref.cacheDirectory);
    MusicCacheDir.setSizeLimit(persistedPref.cacheSizeLimitGB);
    // ================================

    // ========== Riverpod ProviderContainer ==========
    // 显式创建 ProviderContainer，便于在 runApp 前触发各模块初始化
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      observers: [AppLoggerProviderObserver()],
    );

    // ========== 核心模块初始化 ==========
    final audioPlayerModule = await container.read(
      audioPlayerModuleProvider.future,
    );
    // 注入 ProviderContainer，供 ServerPlaybackRoutes 访问 sourcedTrackProvider
    audioPlayerModule.container = container;
    // ==================================================================
    // 异步加载 UserPreference 到 Riverpod 状态
    await container.read(userPreferenceProvider.notifier).initialize();
    // ===============================================

    runApp(
      UncontrolledProviderScope(container: container, child: const Pomelo()),
    );
  });
}

/// 应用壳 — 监听全局设置并响应式更新
class Pomelo extends HookConsumerWidget {
  const Pomelo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 响应式监听主题模式设置
    final themeModeStr = ref.watch(
      userPreferenceProvider.select((p) => p.themeMode),
    );
    final themeMode = _parseThemeMode(themeModeStr);
    final hasTouchSupport = useHasTouch();

    // 触发平台媒体控制服务初始化（Windows SMTC / 移动端通知栏）
    ref.watch(audioServicesProvider);

    // 监听当前曲目变化，同步元数据到系统媒体控制
    ref.listen(audioPlayerProvider.select((s) => s.activeTrack), (
      previous,
      next,
    ) {
      if (next == null) return;
      final audioServices = ref.read(audioServicesProvider).value;
      if (audioServices == null) return;
      audioServices.addTrack(next);
    });

    // 监听当前歌词行，同步到系统媒体控制的 artist 展示位置
    ref.listen(currentLyricLineProvider, (previous, next) {
      final audioServices = ref.read(audioServicesProvider).value;
      if (audioServices == null) return;
      audioServices.updateLyric(next.value);
    });

    // 监听缓存目录设置变化，同步到 MusicCacheDir
    // 初始值已在 main() 中从持久化存储加载并应用，此处仅处理运行时变更
    ref.listen(userPreferenceProvider.select((p) => p.cacheDirectory), (
      previous,
      next,
    ) {
      MusicCacheDir.setCustomDirectory(next);
    });

    // 监听缓存大小上限变化，同步到 MusicCacheDir
    ref.listen(userPreferenceProvider.select((p) => p.cacheSizeLimitGB), (
      previous,
      next,
    ) {
      MusicCacheDir.setSizeLimit(next);
    });

    return ShadcnApp.router(
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter.config(),
      builder: (context, child) {
        child = ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: hasTouchSupport
                ? {
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.touch,
                    PointerDeviceKind.stylus,
                    PointerDeviceKind.invertedStylus,
                  }
                : null,
          ),
          child: child!,
        );

        if (Helper.isLinux) {
          child = DragToResizeArea(resizeEdgeSize: 2.5, child: child);
        }

        return child;
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
    title: '柚子音乐',
    // Windows 隐藏原生标题栏，使用自定义右侧标题栏
    titleBarStyle: Helper.isWindows
        ? TitleBarStyle.hidden
        : TitleBarStyle.normal,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setPreventClose(true);
    // 从 Dart 侧设置窗口标题，避免 C++ 源文件编码导致的乱码
    await windowManager.setTitle('柚子音乐');
  });
}
