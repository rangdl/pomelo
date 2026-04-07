import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:pomelo/core/app/app.provider.dart';
import 'package:pomelo/core/routers/router.provider.dart';
import 'package:smtc_windows/smtc_windows.dart';
import 'package:window_manager/window_manager.dart';

import 'core/helper.dart';
import 'core/scroll_behavior.dart';
import 'core/theme/app_theme.dart';
import 'global.dart';
import 'provider/audio_player/audio_player_streams.dart';
import 'services/logger/logger.dart';
import 'utils/platform.dart';

void main() async {
  AppLogger.initialize(false);

  AppLogger.runZoned(() async {
    WidgetsFlutterBinding.ensureInitialized();
    MediaKit.ensureInitialized();
    container = ProviderContainer(
      observers: const [AppLoggerProviderObserver()],
    );
    if (kIsWindows) {
      await SMTCWindows.initialize();
    }
    // Configure the App Metadata
    await initialize();
    // 持久化的provider 等待初始化完毕
    await initializeProvider();
    await _runPlatformSpecificCode();

    runApp(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
  });
}

Future<void> _runPlatformSpecificCode() async {
  if (!Helper.isDesktop) return;
  // 初始化窗口管理器
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
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
    final themeMode = ref.watch(appSettingsProvider.select((v) => v.themeMode));

    ref.listen(audioPlayerStreamListenersProvider, (_, __) {});

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
