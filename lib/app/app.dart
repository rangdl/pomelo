import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/app_keys.dart';
import '../../shared/layout/player_shortcuts.dart';
import '../../shared/settings/app_font.dart';
import '../../shared/settings/theme_color.dart';
import '../../shared/settings/theme_mode.dart';
import '../features/playback/presentation/playback_providers.dart';
import 'router.dart';
import 'theme.dart';

class PomeloApp extends ConsumerWidget {
  const PomeloApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 挂上播放状态持久化监听（队列/索引/当前曲/播放模式变化即写盘）。
    ref.watch(playbackPersistenceProvider);
    // iOS 控制中心 / 锁屏歌词联动。
    ref.watch(lockScreenLyricSyncProvider);
    // 主题色变化时整体重建 ThemeData,全应用即时生效。
    final seedColor = ref.watch(themeColorProvider).color;
    // 字体切换同样重建 ThemeData,所有文字立即换用新字体。
    final fontFamily = ref.watch(appFontProvider).fontFamily;
    return MaterialApp.router(
      title: '柚子音乐',
      scaffoldMessengerKey: globalScaffoldMessengerKey,
      theme: pomeloTheme(Brightness.light, seedColor, fontFamily: fontFamily),
      darkTheme: pomeloTheme(
        Brightness.dark,
        seedColor,
        fontFamily: fontFamily,
      ),
      themeMode: ref.watch(themeModeOptionProvider.select((m) => m.themeMode)),
      routerConfig: ref.watch(appRouterProvider),
      // 桌面端全局快捷键（空格播放/暂停、方向键快进快退等）。
      // 字号缩放限制在 1.0–1.3：桌面系统放大字体时不至于把列表行撑破。
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: 1.0,
        maxScaleFactor: 1.3,
        child: PlayerShortcuts(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
