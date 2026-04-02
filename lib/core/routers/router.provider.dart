import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pomelo/core/app/app.provider.dart';
import 'package:pomelo/core/routers/scaffold_with_nav_bar.dart';
import 'package:pomelo/features/home/home.view.dart';

import '../../features/example/ex.view.dart';
import '../../features/settings/settings.view.dart';
import '../../global.dart';
import '../helper.dart';
import 'router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final routerConfig = GoRouter(
    observers: [BotToastNavigatorObserver()],
    navigatorKey: navigatorKey,
    initialLocation: ref.read(initialLocationProvider),
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
        branches: ref.watch(routerIndexProvider),
      ),
      GoRoute(path: '/home', builder: (context, state) => HomeView()),
    ],
  );
  return routerConfig;
});

final routerIndexProvider = Provider<List<StatefulShellBranch>>((ref) {
  final navs = ref.watch(navsSortProvider);
  return navs.map((nav) => nav.route).toList();
});

final initialLocationProvider = Provider<String>((ref) {
  final navs = ref.watch(navsSortProvider);
  return (navs.first.route.routes.first as GoRoute).path;
});

final navsSortProvider = Provider<List<Nav>>((ref) {
  final navs = ref.read(navsProvider);
  navs.sort((a, b) => a.sort.compareTo(b.sort));
  final navsVisible = navs.where((nav) => nav.visible).toList();
  return navsVisible;
});

class _NavsNotifier extends Notifier<List<Nav>> {
  @override
  List<Nav> build() {
    final asyncSettingsNavs = ref.watch(settingsNavsAsyncProvider);
    final settingsNavs = asyncSettingsNavs.value ?? {};
    final navs = [
      Nav(
        label: "首页",
        icon: Icons.home_outlined,
        id: Routes.home.name,
        visible: settingsNavs[Routes.home.name] ?? true,
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
      Nav(
        label: "收藏",
        icon: Icons.favorite_outline,
        id: Routes.favorite.name,
        visible: settingsNavs[Routes.favorite.name] ?? true,
        sort: 2,
        route: StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Routes.favorite.localPath,
              name: Routes.favorite.name,
              builder: (context, state) => const Text('收藏'),
            ),
          ],
        ),
      ),
      Nav(
        label: "统计",
        icon: Icons.bar_chart_outlined,
        id: Routes.statistics.name,
        visible: settingsNavs[Routes.statistics.name] ?? true,
        sort: 3,
        route: StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Routes.statistics.localPath,
              name: Routes.statistics.name,
              builder: (context, state) => const Text('统计'),
            ),
          ],
        ),
      ),
      Nav(
        label: "我的",
        icon: Icons.person_outline,
        id: Routes.my.name,
        visible: settingsNavs[Routes.my.name] ?? true,
        sort: 4,
        route: StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Routes.my.localPath,
              name: Routes.my.name,
              builder: (context, state) => const Text('我的'),
            ),
          ],
        ),
      ),
      Nav(
        label: "设置",
        icon: Icons.settings_outlined,
        id: Routes.settings.name,
        visible: settingsNavs[Routes.settings.name] ?? true,
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
      if (Helper.isDebug)
        Nav(
          label: "测试",
          icon: Icons.support_outlined,
          id: Routes.ex.name,
          visible: settingsNavs[Routes.ex.name] ?? true,
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
    ];
    return navs;
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = state.removeAt(oldIndex);
    state.insert(newIndex, item);
    state = [...state];
  }
}

final navsProvider = NotifierProvider<_NavsNotifier, List<Nav>>(
  () => _NavsNotifier(),
);

class _SettingsNavsNotifier extends AsyncNotifier<Map<String, bool>> {
  @override
  Future<Map<String, bool>> build() async {
    await persist(
      ref.watch(storageProvider.future),
      key: 'app_settings_navs',
      encode: (obj) => jsonEncode(obj),
      decode: (json) => (jsonDecode(json) as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value as bool),
      ),
      options: const StorageOptions(
        destroyKey: '1.0',
        cacheTime: StorageCacheTime.unsafe_forever,
      ),
    ).future;
    return state.value ?? {};
  }

  Future<void> set(String key, bool visible) async {
    state = AsyncData({...(await future), key: visible});
  }
}

final settingsNavsAsyncProvider =
    AsyncNotifierProvider<_SettingsNavsNotifier, Map<String, bool>>(
      () => _SettingsNavsNotifier(),
    );
