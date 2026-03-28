import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/home.view.dart';
import 'scaffold_with_nav_bar.dart';

part 'constants.dart';

final routerConfig = GoRouter(
  initialLocation: Routes.home.localPath,
  routes: [
    StatefulShellRoute.indexedStack(
      builder:
          (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell navigationShell,
          ) {
            return ScaffoldWithNavBar(navigationShell: navigationShell);
          },
      branches: [
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Routes.home.localPath,
              name: Routes.home.name,
              builder: (context, state) => const HomeView(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(path: '/home', builder: (context, state) => HomeView()),
  ],
);
