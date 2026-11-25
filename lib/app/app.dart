import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/settings/theme_mode.dart';
import 'router.dart';
import 'theme.dart';

class PomeloApp extends ConsumerWidget {
  const PomeloApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Pomelo',
      theme: pomeloLightTheme,
      darkTheme: pomeloDarkTheme,
      themeMode: ref.watch(themeModeOptionProvider.select((m) => m.themeMode)),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
