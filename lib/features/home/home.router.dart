import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/routers/constants.dart';
import '../../core/routers/router.provider.dart';
import 'home.view.dart';

final navHomeProvider = Provider<Nav>(
  (ref) => Nav(
    label: "首页",
    icon: Icons.home_outlined,
    id: Routes.home.name,
    visible:
        ref.watch(settingsNavsAsyncProvider).value?[Routes.home.name] ?? true,
    sort: 1,
    route: StatefulShellBranch(
      routes: <RouteBase>[
        GoRoute(
          path: Routes.home.localPath,
          name: Routes.home.name,
          builder: (context, state) => const HomeView(),
        ),
      ],
    ),
  ),
);
