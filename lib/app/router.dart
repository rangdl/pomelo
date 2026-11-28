import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/plugins/presentation/collection_screens.dart';
import '../features/plugins/presentation/library_screen.dart';
import '../features/plugins/presentation/fallback_chain_screen.dart';
import '../features/plugins/presentation/plugin_detail_screen.dart';
import '../features/plugins/presentation/plugin_manager_screen.dart';
import '../features/plugins/presentation/sheets_browse_screen.dart';
import '../features/plugins/presentation/toplists_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/settings/presentation/appearance_settings_screen.dart';
import '../features/settings/presentation/logs_screen.dart';
import '../features/settings/presentation/nav_bar_settings_screen.dart';
import '../features/settings/presentation/playback_settings_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/presentation/storage_settings_screen.dart';
import '../shared/layout/adaptive_app_shell.dart';
import '../shared/layout/detail_scaffold.dart';

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
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
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
      // 搜索页:从首页标题栏右侧按钮进入,宽屏仍保留左侧导航。
      GoRoute(
        path: '/search',
        builder: (context, state) =>
            const ShellDetailScaffold(child: SearchScreen()),
      ),
      // 设置页内的二级页：宽屏沿用左侧导航，详情内容显示在右栏（不再整页覆盖）。
      GoRoute(
        path: '/settings/appearance',
        builder: (context, state) =>
            const ShellDetailScaffold(child: AppearanceSettingsScreen()),
      ),
      GoRoute(
        path: '/settings/navbar',
        builder: (context, state) =>
            const ShellDetailScaffold(child: NavBarSettingsScreen()),
      ),
      GoRoute(
        path: '/settings/playback',
        builder: (context, state) =>
            const ShellDetailScaffold(child: PlaybackSettingsScreen()),
      ),
      GoRoute(
        path: '/settings/storage',
        builder: (context, state) =>
            const ShellDetailScaffold(child: StorageSettingsScreen()),
      ),
      GoRoute(
        path: '/plugins',
        builder: (context, state) =>
            const ShellDetailScaffold(child: PluginManagerScreen()),
      ),
      // 运行日志：查看/复制/导出/清空，方便反馈问题时附上现场。
      GoRoute(
        path: '/plugin-detail',
        builder: (context, state) => ShellDetailScaffold(
          child: PluginDetailScreen(pluginId: '${state.extra ?? ''}'),
        ),
      ),
      GoRoute(
        path: '/fallback-chain',
        builder: (context, state) =>
            const ShellDetailScaffold(child: FallbackChainScreen()),
      ),
      GoRoute(
        path: '/logs',
        builder: (context, state) =>
            const ShellDetailScaffold(child: LogsScreen()),
      ),
      // extra 可传榜单 item,直接进入该榜单的歌曲列表(搜索发现区跳入用)。
      GoRoute(
        path: '/toplists',
        builder: (context, state) => ShellDetailScaffold(
          child: TopListsScreen(
            initialItem: state.extra as Map<String, dynamic>?,
          ),
        ),
      ),
      // 推荐歌单浏览(按标签分页)。
      GoRoute(
        path: '/sheets',
        builder: (context, state) =>
            const ShellDetailScaffold(child: SheetsBrowseScreen()),
      ),
      // 歌单/专辑/歌手详情:extra 必须带条目本身(含 _pluginId),否则按不可用处理。
      GoRoute(
        path: '/sheet',
        builder: (context, state) => ShellDetailScaffold(
          child: SheetScreen(
            item: state.extra as Map<String, dynamic>? ?? const {},
          ),
        ),
      ),
      GoRoute(
        path: '/album',
        builder: (context, state) => ShellDetailScaffold(
          child: AlbumScreen(
            item: state.extra as Map<String, dynamic>? ?? const {},
          ),
        ),
      ),
      GoRoute(
        path: '/artist',
        builder: (context, state) => ShellDetailScaffold(
          child: ArtistScreen(
            item: state.extra as Map<String, dynamic>? ?? const {},
          ),
        ),
      ),
    ],
  );
});
