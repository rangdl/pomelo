import 'package:auto_route/auto_route.dart';
import 'app_router.gr.dart';

/// auto_route 全应用路由配置
///
/// 路由结构:
///   /             → RootPage (底部导航)
///   /home       → HomePage (首页)
///     /service    → ServicePage (平台)
///     /statistics → StatisticsPage (统计)
///     /settings   → SettingsPage (设置)
///   /ex           → ExListPage (示例列表)
///     /ex1        → Ex1DetailPage (示例1)
///
/// 生成规则: `replaceInRouteName: 'Page|View,Route'`
///   - RootPage → RootRoute
///   - HomePage → HomeRoute
///   - ServicePage → ServiceRoute
///   - SettingsPage → SettingsRoute
///   - ExListPage → ExListRoute
///   - Ex1DetailPage → Ex1DetailRoute
@AutoRouterConfig(replaceInRouteName: 'Page|View,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    /// 带底部导航的 Root
    AutoRoute(
      page: RootRoute.page,
      initial: true,
      children: [
        AutoRoute(path: 'home', page: HomeRoute.page),
        AutoRoute(path: 'service', page: ServiceRoute.page),
        AutoRoute(path: 'statistics', page: StatisticsRoute.page),
        AutoRoute(path: 'settings', page: SettingsRoute.page),
      ],
    ),

    /// 日志模块
    AutoRoute(path: '/log', page: LogRoute.page),

    /// 音乐搜索
    AutoRoute(path: '/search', page: MusicSearchRoute.page),

    /// 歌单详情
    AutoRoute(path: '/playlist', page: PlaylistDetailRoute.page),

    /// 播放页面（全屏）
    AutoRoute(path: '/playback', page: PlaybackRoute.page),

    /// 关于页面
    AutoRoute(path: '/about', page: AboutRoute.page),

    /// 示例模块（无底部导航）
    AutoRoute(
      path: '/ex',
      page: ExListRoute.page,
      children: [
        AutoRoute(path: 'ex1', page: Ex1DetailRoute.page),
        AutoRoute(path: 'ex3', page: JsEngineTestRoute.page),
      ],
    ),
  ];
}
