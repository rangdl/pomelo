import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/lx_manager_screen.dart';
import '../screens/plugin_manager_screen.dart';

/// 应用路由器。必须在 `ProviderScope` 内部创建：
/// 全局顶层构造的话，页面里的 ConsumerWidget 会找不到 scope。
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/plugins',
        builder: (context, state) => const PluginManagerScreen(),
      ),
      GoRoute(
        path: '/lx',
        builder: (context, state) => const LxManagerScreen(),
      ),
    ],
  );
});
