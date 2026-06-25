import 'package:auto_route/auto_route.dart';
import 'app_router.gr.dart';

/// auto_route 全应用路由配置
///
/// 路由结构:
///   /             → RootPage (底部导航)
///   /home       → HomePage (首页)
///     /favorite   → FavoritePage (平台)
///     /statistics → StatisticsPage (统计)
///     /my         → MyPage (我的)
///   /ex           → ExListPage (示例列表)
///     /ex1        → Ex1DetailPage (示例1)
///     /ex2        → Ex2DetailPage (示例2)
///
/// 生成规则: `replaceInRouteName: 'Page|View,Route'`
///   - RootPage → RootRoute
///   - HomePage → HomeRoute
///   - FavoritePage → FavoriteRoute
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
        AutoRoute(path: 'favorite', page: FavoriteRoute.page),
        AutoRoute(path: 'statistics', page: StatisticsRoute.page),
        AutoRoute(path: 'my', page: MyRoute.page),
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

    /// 播放队列（移动端全屏；桌面端走 openSheet 不入路由）
    AutoRoute(path: '/play-queue', page: PlayQueueRoute.page),

    /// 示例模块（无底部导航）
    AutoRoute(
      path: '/ex',
      page: ExListRoute.page,
      children: [
        AutoRoute(path: 'ex1', page: Ex1DetailRoute.page),
        AutoRoute(path: 'ex2', page: Ex2DetailRoute.page),
        AutoRoute(path: 'ex3', page: JsEngineTestRoute.page),
      ],
    ),
  ];
}
