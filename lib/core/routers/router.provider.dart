import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pomelo/core/app/app.provider.dart';
import 'package:pomelo/core/routers/scaffold_with_nav_bar.dart';
import 'package:pomelo/features/home/home.view.dart';

import '../../features/example/ex.router.dart';
import '../../features/home/home.router.dart';
import '../../features/my/my.router.dart';
import '../../features/settings/settings.router.dart';
import '../../global.dart';
import '../helper.dart';
import 'constants.dart';

// 全部路由
final routerProvider = Provider<GoRouter>((ref) {
  final navs = ref.watch(navsSortProvider);
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
        branches: navs.map((nav) => nav.route).toList(),
      ),
      GoRoute(path: '/home', builder: (context, state) => HomeView()),
    ],
  );
  return routerConfig;
});

// 初始展示的导航页
final initialLocationProvider = Provider<String>((ref) {
  final navs = ref.watch(navsSortProvider);
  return (navs.first.route.routes.first as GoRoute).path;
});

// 筛选需要显示的导航页列表
final navsSortProvider = Provider<List<Nav>>((ref) {
  final navs = ref.read(navsProvider);
  navs.sort((a, b) => a.sort.compareTo(b.sort));
  final navsVisible = navs.where((nav) => nav.visible).toList();
  return navsVisible;
});

class _NavsNotifier extends Notifier<List<Nav>> {
  @override
  List<Nav> build() {
    final navs = [
      ref.watch(navHomeProvider),
      ref.watch(navMyProvider),
      ref.watch(navSettingsProvider),

      if (Helper.isDebug) ref.watch(navExProvider),
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

// 全部导航页列表
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

// 持久化的设置导航页是否显示
final settingsNavsAsyncProvider =
    AsyncNotifierProvider<_SettingsNavsNotifier, Map<String, bool>>(
      () => _SettingsNavsNotifier(),
    );
