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
  (key: ValueKey(3), icon: Icons.person, label: '我的'),
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

/// 平板 / 桌面 / TV 布局 — NavigationRail + 顶部固定标题栏
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
      child: Column(
        children: [
          // 顶部固定标题栏
          const _DesktopTitleBar(),
          Expanded(
            child: Row(
              children: [
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
          ),
        ],
      ),
    );
  }
}

/// 桌面端固定标题栏
///
/// 左侧：返回按钮（监听内联导航状态）+ 库切换 + 平台切换 + 搜索框
/// 右侧：最小化 + 关闭（仅桌面平台显示）
class _DesktopTitleBar extends HookConsumerWidget {
  const _DesktopTitleBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final canPop = ref.watch(rootCanPopProvider);
    final popCallback = ref.watch(rootPopCallbackProvider);
    final searchController = useTextEditingController();

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colorScheme.card,
        border: Border(bottom: BorderSide(color: colorScheme.border, width: 1)),
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
          const Gap(4),
          // 库切换
          const LibrarySwitchButton(),
          const Gap(4),
          // 平台切换
          const SourceSwitchButton(),
          const Gap(12),
          // 搜索框
          Expanded(
            child: TextField(
              controller: searchController,
              placeholder: const Text('搜索歌曲...'),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  context.pushRoute(MusicSearchRoute(keyword: value.trim()));
                  searchController.clear();
                }
              },
              features: [
                InputFeature.leading(const Icon(Icons.search, size: 18)),
              ],
            ),
          ),
          const Gap(8),
          // 窗口控制按钮 — 仅桌面平台
          if (Helper.isDesktop) ...[
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
