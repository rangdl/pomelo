import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routers/constants.dart';
import '../../core/routers/router.provider.dart';
import 'settings.home.view.dart';
import 'settings.view.dart';

final navSettingsProvider = Provider<Nav>(
  (ref) => Nav(
    label: "设置",
    icon: Icons.settings_outlined,
    id: Routes.settings.name,
    visible:
        ref.watch(settingsNavsAsyncProvider).value?[Routes.settings.name] ??
        true,
    sort: 5,
    route: StatefulShellBranch(
      routes: <RouteBase>[
        GoRoute(
          path: Routes.settings.localPath,
          name: Routes.settings.name,
          builder: (context, state) => const SettingsView(),
          routes: [
            GoRoute(
              path: Routes.settingsHome.localPath,
              name: Routes.settingsHome.name,
              builder: (context, state) => const SettingsHomeView(),
            ),
          ],
        ),
      ],
    ),
  ),
);
