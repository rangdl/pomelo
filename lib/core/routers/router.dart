import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/example/ex.view.dart';
import '../../features/home/home.view.dart';
import '../../features/settings/settings.view.dart';
import '../../global.dart';
import 'scaffold_with_nav_bar.dart';

part 'constants.dart';

final routerConfig = GoRouter(
  observers: [BotToastNavigatorObserver()],
  navigatorKey: navigatorKey,
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
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Routes.favorite.localPath,
              name: Routes.favorite.name,
              builder: (context, state) => const Text('收藏'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Routes.statistics.localPath,
              name: Routes.statistics.name,
              builder: (context, state) => const Text('统计'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Routes.my.localPath,
              name: Routes.my.name,
              builder: (context, state) => const Text('我的'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Routes.settings.localPath,
              name: Routes.settings.name,
              builder: (context, state) => const SettingsView(),
            ),
          ],
        ),
        StatefulShellBranch(
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
      ],
    ),
    GoRoute(path: '/home', builder: (context, state) => HomeView()),
  ],
);
