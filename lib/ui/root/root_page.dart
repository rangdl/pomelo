import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/helper.dart';
import 'package:pomelo/core/routers/app_router.gr.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/ui/music/music_section.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:window_manager/window_manager.dart';

import '../player/mini_player.dart';
import 'root_providers.dart';

/// 导航标签定义
const _navDestinations = [
  (key: ValueKey(0), icon: Icons.home, label: '首页'),
  (key: ValueKey(1), icon: Icons.layers, label: '平台'),
  (key: ValueKey(2), icon: Icons.bar_chart, label: '统计'),
  (key: ValueKey(3), icon: Icons.settings, label: '设置'),
];

/// Root 路由页面 — 响应式壳导航
///
/// 使用 [Rx.layout] 根据屏幕宽度自动选择合适的导航布局：
/// - 手机：BottomNavigationBar
/// - 平板：NavigationRail（紧凑）+ 顶部固定标题栏
/// - 桌面/TV：NavigationRail（展开，带图标和标签）+ 顶部固定标题栏
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
        ServiceRoute(),
        StatisticsRoute(),
        SettingsRoute(),
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

    // 同步当前 Tab 索引到全局 Provider（延迟到 build 后执行，避免在 build 期间修改 provider）
    useEffect(() {
      Future.microtask(
        () => ref
            .read(activeTabIndexProvider.notifier)
            .set(tabsRouter.activeIndex),
      );
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

/// 平板 / 桌面 / TV 布局 — 顶部标题栏 + 右侧 NavigationRail
///
/// 布局结构：
/// ```
/// ┌────────────────────┬──────────┐
/// │  TopTitleBar       │          │
/// ├────────────────────┤  NavRail │
/// │  Content           │  (全高)  │
/// │  (tabRouter)       │          │
/// ├────────────────────┤          │
/// │  MiniPlayer        │          │
/// └────────────────────┴──────────┘
/// ```
/// 顶部标题栏与 tabRouter 内容区对齐；右侧 NavigationRail 占满全高。
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

    // 同步当前 Tab 索引到全局 Provider（延迟到 build 后执行，避免在 build 期间修改 provider）
    useEffect(() {
      Future.microtask(
        () => ref
            .read(activeTabIndexProvider.notifier)
            .set(tabsRouter.activeIndex),
      );
      return null;
    }, [tabsRouter.activeIndex]);

    return Scaffold(
      child: Row(
        children: [
          // 左侧：顶部标题栏 + 内容 + MiniPlayer
          Expanded(
            child: Column(
              children: [
                const _TopTitleBar(),
                const Divider(height: 1, thickness: 1),
                Expanded(child: children[tabsRouter.activeIndex]),
                const MiniPlayer(),
              ],
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          // 右侧 NavigationRail — 占满全高
          NavigationRail(
            alignment: NavigationRailAlignment.start,
            labelType: NavigationLabelType.none,
            expanded: extended,
            onSelected: (key) {
              final index = _navDestinations.indexWhere(
                (d) => d.key == key,
              );
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
      ),
    );
  }
}

/// 顶部水平标题栏
///
/// 自左而右：返回按钮 → 库切换 → 平台切换 → 搜索入口 → 弹性间距 →
/// 窗口控制按钮（最小化 / 关闭，仅 Windows 显示）。
class _TopTitleBar extends HookConsumerWidget {
  const _TopTitleBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final canPop = ref.watch(rootCanPopProvider);
    final popCallback = ref.watch(rootPopCallbackProvider);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.card,
      ),
      child: Row(
        children: [
          // 返回按钮 — 监听内联导航状态
          IconButton.ghost(
            density: ButtonDensity.icon,
            icon: Icon(
              Icons.arrow_back,
              size: 20,
              color: canPop ? null : colorScheme.mutedForeground,
            ),
            enabled: canPop,
            onPressed: () => popCallback?.call(),
          ),
          // 库切换
          const LibrarySwitchButton(),
          // 平台切换
          const SourceSwitchButton(),
          // 搜索入口 — 点击跳转搜索页
          IconButton.ghost(
            density: ButtonDensity.icon,
            icon: const Icon(Icons.search, size: 20),
            onPressed: () => context.pushRoute(MusicSearchRoute()),
          ),
          const Spacer(),
          // 窗口控制按钮 — 仅 Windows
          if (Helper.isWindows) ...[
            IconButton.ghost(
              density: ButtonDensity.icon,
              icon: const Icon(Icons.horizontal_rule, size: 18),
              onPressed: () => windowManager.minimize(),
            ),
            IconButton.ghost(
              density: ButtonDensity.icon,
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => windowManager.destroy(),
            ),
          ],
        ],
      ),
    );
  }
}
