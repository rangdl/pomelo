import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/app_keys.dart';
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
    // 主题色变化时整体重建 ThemeData,全应用即时生效。
    final seedColor = ref.watch(themeColorProvider).color;
    return MaterialApp.router(
      title: 'Pomelo',
      scaffoldMessengerKey: globalScaffoldMessengerKey,
      theme: pomeloTheme(Brightness.light, seedColor),
      darkTheme: pomeloTheme(Brightness.dark, seedColor),
      themeMode: ref.watch(themeModeOptionProvider.select((m) => m.themeMode)),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
