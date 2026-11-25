import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/plugins/presentation/lx_manager_screen.dart';
import '../features/plugins/presentation/plugin_manager_screen.dart';
import '../features/playback/presentation/player_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../shared/layout/adaptive_app_shell.dart';

/// 应用路由器。必须在 `ProviderScope` 内部创建：
/// 全局顶层构造的话，页面里的 ConsumerWidget 会找不到 scope。
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // 一级页面收进 IndexedStack 壳:切分支/换断点不丢状态。
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AdaptiveAppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      // 设置页内的二级页与播放页都留在壳外,全屏覆盖。
      GoRoute(path: '/plugins', builder: (context, state) => const PluginManagerScreen()),
      GoRoute(path: '/lx', builder: (context, state) => const LxManagerScreen()),
      GoRoute(path: '/player', builder: (context, state) => const PlayerScreen()),
    ],
  );
});
