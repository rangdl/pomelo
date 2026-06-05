import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/routers/app_router.gr.dart';
import 'package:pomelo/core/rx.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 导航标签定义
const _navDestinations = [
  (key: ValueKey(0), icon: Icons.home, label: '首页'),
  (key: ValueKey(1), icon: Icons.favorite, label: '收藏'),
  (key: ValueKey(2), icon: Icons.bar_chart, label: '统计'),
  (key: ValueKey(3), icon: Icons.person, label: '我的'),
];

/// Root 路由页面 — 响应式壳导航
///
/// 使用 [Rx.layout] 根据屏幕宽度自动选择合适的导航布局：
/// - 手机：BottomNavigationBar
/// - 平板：NavigationRail（紧凑）
/// - 桌面/TV：NavigationRail（展开，带图标和标签）
///
/// 通过单 [AutoTabsRouter] 确保窗口缩放时各 Tab 状态不丢失。
@RoutePage()
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter.builder(
      routes: const [
        HomeRoute(),
        FavoriteRoute(),
        StatisticsRoute(),
        MyRoute(),
      ],
      builder: (context, children, tabsRouter) {
        return Rx.layout(
          context,
          mobile: () => _PhoneLayout(
            tabsRouter: tabsRouter,
            extended: true,
            children: children,
          ),
          tablet: () => _NavigationRailLayout(
            tabsRouter: tabsRouter,
            extended: false,
            children: children,
          ),
          desktop: () => _NavigationRailLayout(
            tabsRouter: tabsRouter,
            extended: true,
            children: children,
          ),
        );
      },
    );
  }
}

/// 手机布局 — 底部导航栏
class _PhoneLayout extends HookConsumerWidget {
  final TabsRouter tabsRouter;
  final List<Widget> children;
  final bool extended;

  const _PhoneLayout({
    required this.tabsRouter,
    required this.children,
    required this.extended,
  });

  @override
  Widget build(BuildContext context, ref) {
    final selectedKey = useState<Key?>(ValueKey(tabsRouter.activeIndex));
    return Scaffold(
      footers: [
        NavigationBar(
          alignment: NavigationBarAlignment.spaceAround,
          labelType: NavigationLabelType.none,
          expanded: extended,
          onSelected: (key) {
            selectedKey.value = key;
          },
          selectedKey: selectedKey.value,
          children: _navDestinations
              .map(
                (d) => NavigationItem(
                  key: d.key,
                  label: Text(d.label),
                  child: Icon(d.icon),
                ),
              )
              .toList(),
        ),
      ],
      child: children[tabsRouter.activeIndex],
    );
  }
}

/// 平板 / 桌面 / TV 布局 — NavigationRail
class _NavigationRailLayout extends HookConsumerWidget {
  final TabsRouter tabsRouter;
  final List<Widget> children;
  final bool extended;

  const _NavigationRailLayout({
    required this.tabsRouter,
    required this.children,
    required this.extended,
  });

  @override
  Widget build(BuildContext context, ref) {
    final selectedKey = useState<Key?>(ValueKey(tabsRouter.activeIndex));

    return Scaffold(
      child: Row(
        children: [
          NavigationRail(
            alignment: NavigationRailAlignment.start,
            labelType: NavigationLabelType.none,
            expanded: extended,
            onSelected: (key) {
              selectedKey.value = key;
            },
            selectedKey: selectedKey.value,
            children: _navDestinations
                .map(
                  (d) => NavigationItem(
                    key: d.key,
                    label: Text(d.label),
                    child: Icon(d.icon),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: children[tabsRouter.activeIndex]),
        ],
      ),
    );
  }
}
