import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart' show MediaKit;
import 'package:metadata_god/metadata_god.dart';
import 'package:pomelo/core/core.dart';
import 'package:pomelo/core/models/database/app_database.dart';
import 'package:pomelo/core/preferences/user_preference.dart';
import 'package:pomelo/core/preferences/user_preference_provider.dart';
import 'package:pomelo/core/routers/app_router.dart';
import 'package:pomelo/core/theme/app_theme.dart';
import 'package:pomelo/core/toast.dart';
import 'package:pomelo/provider/audio_player/audio_player_streams.dart';
import 'package:pomelo/provider/database/database_provider.dart';
import 'package:pomelo/provider/server/server.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:smtc_windows/smtc_windows.dart';
import 'package:window_manager/window_manager.dart';

import 'core/helper.dart';
import 'core/hooks/use_has_touch.dart';
import 'global.dart';
import 'services/audio_player/audio_player.dart' show audioPlayer;
import 'services/logger/logger.dart';

final appRouter = AppRouter(navigatorKey: appNavigatorKey);

void main() async {
  AppLogger.initialize(false);
  AppLogger.runZoned(() async {
    WidgetsFlutterBinding.ensureInitialized();
    MediaKit.ensureInitialized();
    MetadataGod.initialize();
    if (kIsWindows) {
      await SMTCWindows.initialize();
    }

    await _runPlatformSpecificCode();

    // ========== 存储层初始化 ==========
    // 提前创建 drift 数据库（所有模块共享同一实例）
    final database = AppDatabase();
    // 从 drift 数据库加载 UserPreference（用于初始化 MusicCacheDir）
    final userPreference = await UserPreference.loadFromDatabase(database);
    MusicCacheDir.setCustomDirectory(userPreference.cacheDirectory);
    MusicCacheDir.setSizeLimit(userPreference.cacheSizeLimitGB);
    // ================================

    // 无论启动是否完全成功都调用 runApp，避免白屏
    runApp(
      ProviderScope(
        observers: [AppLoggerProviderObserver()],
        overrides: [
          databaseProvider.overrideWithValue(database),
          userPreferencesProvider.overrideWithValue(userPreference),
        ],
        child: const Pomelo(),
      ),
    );
  });
}

/// 应用壳 — 监听全局设置并响应式更新
class Pomelo extends HookConsumerWidget {
  const Pomelo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 响应式监听主题模式设置
    final themeModeStr = ref.watch(
      userPreferenceProvider.select((p) => p.themeMode),
    );
    final themeMode = _parseThemeMode(themeModeStr);
    final hasTouchSupport = useHasTouch();

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

    // 监听音频流监听器变化
    ref.listen(audioPlayerStreamListenersProvider, (_, _) {});
    // 监听本地服务器状态变化
    ref.listen(serverProvider, (_, _) {});

    useEffect(() {
      return () {
        /// For enabling hot reload for audio player
        if (!kDebugMode) return;
        audioPlayer.dispose();
      };
    }, []);
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
                    PointerDeviceKind.trackpad,
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
    title: appNameDisplay,
    // Windows 隐藏原生标题栏，使用自定义右侧标题栏
    titleBarStyle: Helper.isWindows
        ? TitleBarStyle.hidden
        : TitleBarStyle.normal,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setPreventClose(true);
    // 从 Dart 侧设置窗口标题，避免 C++ 源文件编码导致的乱码
    await windowManager.setTitle(appNameDisplay);
  });
}
