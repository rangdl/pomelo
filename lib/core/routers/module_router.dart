import 'package:auto_route/auto_route.dart';

/// 从 M.A.R.S. 模块中获取路由配置
///
/// 各模块可以贡献自己的路由分支，实现模块级路由自治。
///
/// 模块路由注册方式：
/// 1. 模块视图层添加 `@RoutePage()` 注解
/// 2. 在 `app_router.dart` 的 `@AutoRouterConfig` 中声明模块路由
/// 3. 通过 `context.pushRoute()` / `context.navigateTo()` 导航
class ModuleRouteProvider {
  /// 构建模块路由
  ///
  /// 各模块在此注册自己的路由分支，
  /// 最终由 [AppRouter] 统一收集管理。
  static List<PageRouteInfo> buildModuleRoutes() {
    return [
      // 模块路由统一在 lib/core/routers/app_router.dart 中声明式注册
      // 各模块只需在视图类上添加 @RoutePage() 注解
    ];
  }
}
