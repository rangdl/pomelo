import 'package:go_router/go_router.dart';

/// 从 M.A.R.S. 模块中获取路由配置
///
/// 各模块可以贡献自己的路由分支，实现模块级路由自治。
class ModuleRouteProvider {
  /// 构建模块路由
  static List<RouteBase> buildModuleRoutes() {
    return [
      // 目前顶层路由在 router.dart 中集中管理
      // 未来各模块可通过 ModuleRouter 接口自注册
    ];
  }
}
