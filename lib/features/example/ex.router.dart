import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/routers/constants.dart';
import '../../core/routers/router.provider.dart';
import 'ex.view.dart';

final navExProvider = Provider<Nav>(
  (ref) => Nav(
    label: "测试",
    icon: Icons.support_outlined,
    id: Routes.ex.name,
    visible:
        ref.watch(settingsNavsAsyncProvider).value?[Routes.ex.name] ?? true,
    sort: 6,
    route: StatefulShellBranch(
      routes: <RouteBase>[
        GoRoute(
          path: Routes.ex.localPath,
          name: Routes.ex.name,
          builder: (context, state) => const ExView(),
          routes: [
            GoRoute(
              path: Routes.ex1.localPath,
              name: Routes.ex1.name,
              builder: (context, state) => const Ex1View(),
            ),
            GoRoute(
              path: Routes.ex2.localPath,
              name: Routes.ex2.name,
              builder: (context, state) => const Ex2View(),
            ),
          ],
        ),
      ],
    ),
  ),
);
