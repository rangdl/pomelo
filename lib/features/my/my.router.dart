import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/features/my/my.view.dart';

import '../../core/routers/constants.dart';
import '../../core/routers/router.provider.dart';

final navMyProvider = Provider<Nav>(
  (ref) => Nav(
    label: "我的",
    icon: Icons.person_outline,
    id: Routes.my.name,
    visible:
        ref.watch(settingsNavsAsyncProvider).value?[Routes.my.name] ?? true,
    sort: 4,
    route: StatefulShellBranch(
      routes: <RouteBase>[
        GoRoute(
          path: Routes.my.localPath,
          name: Routes.my.name,
          builder: (context, state) => const MyView(),
        ),
      ],
    ),
  ),
);
