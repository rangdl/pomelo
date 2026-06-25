import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/module/module_manager.dart';
import 'package:pomelo/core/routers/app_router.gr.dart';
import 'package:pomelo/core/rx.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../player/mini_player.dart';

/// 导航标签定义
const _navDestinations = [
  (key: ValueKey(0), icon: Icons.home, label: '首页'),
  (key: ValueKey(1), icon: Icons.layers, label: '平台'),
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

/// Tab 索引到模块 ID 的映射
const _tabModuleIds = ['home', 'favorite', 'statistics', 'my'];

/// 延迟初始化对应 Tab 的 M.A.R.S. 模块
void _lazyInitModule(int index) {
  if (index < 0 || index >= _tabModuleIds.length) return;
  final moduleId = _tabModuleIds[index];
  // home 是即时加载模块，不需要延迟初始化
  if (moduleId == 'home') return;
  unawaited(ModuleManager().lazyInit(moduleId));
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

    // 延迟加载非首屏模块 — 用户切到对应 Tab 时才初始化
    useEffect(() {
      _lazyInitModule(tabsRouter.activeIndex);
      return null;
    }, [tabsRouter.activeIndex]);

    return Scaffold(
      footers: [
        const MiniPlayer(),
        NavigationBar(
          alignment: NavigationBarAlignment.spaceAround,
          labelType: NavigationLabelType.none,
          expanded: extended,
          onSelected: (key) {
            final index = _navDestinations.indexWhere((d) => d.key == key);
            if (index >= 0 && index != tabsRouter.activeIndex) {
              selectedKey.value = key;
              tabsRouter.setActiveIndex(index);
            }
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

    // 延迟加载非首屏模块 — 用户切到对应 Tab 时才初始化
    useEffect(() {
      _lazyInitModule(tabsRouter.activeIndex);
      return null;
    }, [tabsRouter.activeIndex]);

    return Scaffold(
      child: Row(
        children: [
          NavigationRail(
            alignment: NavigationRailAlignment.start,
            labelType: NavigationLabelType.none,
            expanded: extended,
            onSelected: (key) {
              final index = _navDestinations.indexWhere((d) => d.key == key);
              if (index >= 0 && index != tabsRouter.activeIndex) {
                selectedKey.value = key;
                tabsRouter.setActiveIndex(index);
              }
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
          Expanded(
            child: Column(
              children: [
                Expanded(child: children[tabsRouter.activeIndex]),
                const MiniPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
