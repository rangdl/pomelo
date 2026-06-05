import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pomelo/core/routers/app_router.gr.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Root 路由页面 — 带底部导航栏的框架
///
/// 使用 AutoTabsScaffold + AutoTabsRouter 实现多 Tab 导航。
@RoutePage()
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [
        HomeRoute(),
        FavoriteRoute(),
        StatisticsRoute(),
        MyRoute(),
      ],
      bottomNavigationBuilder: (_, tabsRouter) {
        final shadTheme = ShadTheme.of(context);
        final activeColor = shadTheme.colorScheme.primary;
        final baseColor = shadTheme.colorScheme.mutedForeground;

        return BottomNavigationBar(
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
          selectedItemColor: activeColor,
          unselectedItemColor: baseColor,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(LucideIcons.house), label: '首页'),
            BottomNavigationBarItem(icon: Icon(LucideIcons.heart), label: '收藏'),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.barChart3),
              label: '统计',
            ),
            BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: '我的'),
          ],
        );
      },
    );
  }
}
