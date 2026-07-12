import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/framework/pomelo_icons.dart';
import 'package:pomelo/core/helper.dart';
import 'package:pomelo/core/routers/app_router.gr.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/ui/home/home_providers.dart';
import 'package:pomelo/ui/music/music_section.dart';
import 'package:pomelo/ui/music/providers/music_ui_providers.dart';
import 'package:pomelo/ui/music/widgets/cover_image.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:window_manager/window_manager.dart';

import '../../global.dart';
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
        SafeArea(
          top: false,
          bottom: true,
          child: NavigationBar(
            alignment: NavigationBarAlignment.spaceAround,
            labelType: NavigationLabelType.all,
            labelSize: NavigationLabelSize.normal,
            expanded: extended,
            expandedSize: 68,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            iconSize: 24,
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
                    child: Icon(d.icon, size: 26),
                  ),
                )
                .toList(),
          ),
        ),
      ],
      child: children[tabsRouter.activeIndex],
    );
  }
}

/// 平板 / 桌面 / TV 布局 — 左侧 NavigationRail + 顶部标题栏
///
/// 布局结构：
/// ```
/// ┌──────────┬────────────────────┐
/// │  NavRail │  TopTitleBar       │
/// │  (上部)  ├────────────────────┤
/// │──────────│  Content           │
/// │  我的库  │  (tabRouter)       │
/// │  (下部)  ├────────────────────┤
/// │          │  MiniPlayer        │
/// └──────────┴────────────────────┘
/// ```
/// 左侧侧边栏分为上下两部分：上部为主导航，下部为我的库快捷入口。
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
          // 上部：侧边栏 + 标题栏 + 内容
          Expanded(
            child: Row(
              children: [
                // 左侧侧边栏 — 上下分区
                _Sidebar(
                  tabsRouter: tabsRouter,
                  extended: extended,
                  selectedKey: selectedKey.value,
                  onSelectKey: (key) {
                    final index = _navDestinations.indexWhere(
                      (d) => d.key == key,
                    );
                    if (index < 0) return;
                    if (index != tabsRouter.activeIndex) {
                      selectedKey.value = key;
                      tabsRouter.setActiveIndex(index);
                    } else if (index == 0) {
                      // 已在 Home Tab：点击「首页」按钮重置内联视图
                      // 同步 selectedKey，确保从「我的库」视图切回时上方主导航正确高亮
                      selectedKey.value = key;
                      ref.read(homeNavProvider.notifier).showNormal();
                    }
                  },
                ),
                const VerticalDivider(width: 1, thickness: 1),
                // 右侧：顶部标题栏 + 内容
                Expanded(
                  child: Column(
                    children: [
                      const _TopTitleBar(),
                      const Divider(height: 1, thickness: 1),
                      Expanded(child: children[tabsRouter.activeIndex]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 底部：迷你播放器（全宽，覆盖侧边栏）
          const MiniPlayer(),
        ],
      ),
    );
  }
}

/// 桌面端侧边栏 — 上下分区
///
/// 上半部分：主导航（首页/平台/统计/设置）
/// 下半部分：我的库（默认列表/我的收藏/我的歌单）
class _Sidebar extends HookConsumerWidget {
  final TabsRouter tabsRouter;
  final bool extended;
  final Key? selectedKey;
  final ValueChanged<Key?> onSelectKey;

  const _Sidebar({
    required this.tabsRouter,
    required this.extended,
    required this.selectedKey,
    required this.onSelectKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    // 当 Home Tab 处于「我的库」内联视图时（非 HomeNavNormal），
    // 上方主导航取消选中，下方对应入口高亮
    final homeNav = ref.watch(homeNavProvider);
    final libraryViewActive =
        tabsRouter.activeIndex == 0 && homeNav is! HomeNavNormal;

    // 固定侧边栏宽度：desktop 180 / tablet 80
    return SizedBox(
      width: extended ? 180 : 80,
      child: Column(
        children: [
          // 应用图标和名称
          _AppHeader(extended: extended, colorScheme: colorScheme),
          const Divider(height: 1),
          // 上半部分：主导航按钮（自然高度，显示标签文本）
          // 当下方「我的库」入口被选中时，上方主导航取消高亮
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _navDestinations
                  .map(
                    (d) => _NavButton(
                      key: d.key,
                      icon: d.icon,
                      label: d.label,
                      extended: extended,
                      isSelected: !libraryViewActive && selectedKey == d.key,
                      colorScheme: colorScheme,
                      onTap: () => onSelectKey(d.key),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Divider(height: 1),
          // 下半部分：我的库（占满剩余高度）
          Expanded(
            child: _LibrarySidebarSection(
              extended: extended,
              libraryViewActive: libraryViewActive,
              homeNav: homeNav,
            ),
          ),
        ],
      ),
    );
  }
}

/// 侧边栏顶部 — 应用图标和名称
class _AppHeader extends StatelessWidget {
  final bool extended;
  final ColorScheme colorScheme;

  const _AppHeader({required this.extended, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: extended
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PomeloIcons.music, size: 24, color: colorScheme.primary),
                const Gap(8),
                Text(
                  appNameDisplay,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.foreground,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PomeloIcons.music, size: 28, color: colorScheme.primary),
              ],
            ),
    );
  }
}

/// 侧边栏主导航按钮
///
/// 替代 shadcn_flutter NavigationRail，避免其内部 mainAxisSize:max
/// 在非 Expanded 环境下导致的无限高度约束问题。
class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool extended;
  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _NavButton({
    super.key,
    required this.icon,
    required this.label,
    required this.extended,
    required this.isSelected,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? colorScheme.primary
        : colorScheme.mutedForeground;
    final bgColor = isSelected
        ? colorScheme.primary.withAlpha(20)
        : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: extended
            ? Row(
                children: [
                  Icon(icon, size: 20, color: color),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(fontSize: 13, color: color),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 22, color: color),
                  const Gap(4),
                  Text(
                    label,
                    style: TextStyle(fontSize: 11, color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
      ),
    );
  }
}

/// 侧边栏下半部分 — 我的库
///
/// 包含三个快捷入口：默认列表 / 我的收藏 / 我的歌单。
/// 「我的歌单」为可折叠展开的二级菜单，歌单列表来自 [userListsProvider]。
///
/// 当 [libraryViewActive] 为 true 时，根据 [homeNav] 判断哪个入口被选中。
class _LibrarySidebarSection extends HookConsumerWidget {
  final bool extended;
  final bool libraryViewActive;
  final HomeNav homeNav;

  const _LibrarySidebarSection({
    required this.extended,
    required this.libraryViewActive,
    required this.homeNav,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = useState(false);
    final colorScheme = Theme.of(context).colorScheme;

    // 当 Home Tab 处于「我的库」视图时，根据 homeNav 类型判断选中项
    final isDefaultListSelected =
        libraryViewActive && homeNav is HomeNavDefaultList;
    final isFavoritesSelected =
        libraryViewActive && homeNav is HomeNavFavorites;
    final isPlaylistSelected = libraryViewActive && homeNav is HomeNavPlaylist;

    // 当处于某个具体歌单视图时，自动展开「我的歌单」子列表
    useEffect(() {
      if (isPlaylistSelected && !isExpanded.value) {
        isExpanded.value = true;
      }
      return null;
    }, [isPlaylistSelected]);

    void openInHome(VoidCallback action) {
      // 切换到 Home Tab 并执行操作
      final tabsRouter = AutoTabsRouter.of(context);
      if (tabsRouter.activeIndex != 0) {
        tabsRouter.setActiveIndex(0);
      }
      action();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 默认列表
          _SidebarEntry(
            icon: PomeloIcons.list,
            label: '默认列表',
            extended: extended,
            isSelected: isDefaultListSelected,
            colorScheme: colorScheme,
            onTap: () => openInHome(
              () => ref.read(homeNavProvider.notifier).showDefaultList(),
            ),
          ),
          // 我的收藏
          _SidebarEntry(
            icon: PomeloIcons.heart,
            label: '我的收藏',
            extended: extended,
            isSelected: isFavoritesSelected,
            colorScheme: colorScheme,
            onTap: () => openInHome(
              () => ref.read(homeNavProvider.notifier).showFavorites(),
            ),
          ),
          // 我的歌单（可折叠）
          _SidebarEntry(
            icon: PomeloIcons.playlist,
            label: '我的歌单',
            extended: extended,
            isSelected: isPlaylistSelected,
            colorScheme: colorScheme,
            trailing: RotatedBox(
              quarterTurns: isExpanded.value ? 1 : 3,
              child: Icon(
                PomeloIcons.angleDown,
                size: 14,
                color: colorScheme.mutedForeground,
              ),
            ),
            onTap: () => isExpanded.value = !isExpanded.value,
          ),
          // 展开的歌单列表
          if (isExpanded.value)
            _UserPlaylistList(
              extended: extended,
              homeNav: homeNav,
              libraryViewActive: libraryViewActive,
              onOpen: (playlistRef) => openInHome(
                () => ref
                    .read(homeNavProvider.notifier)
                    .showPlaylist(playlistRef),
              ),
            ),
        ],
      ),
    );
  }
}

/// 侧边栏条目（与[_NavButton] 样式统一）
class _SidebarEntry extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool extended;
  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SidebarEntry({
    required this.icon,
    required this.label,
    required this.extended,
    required this.colorScheme,
    required this.onTap,
    this.isSelected = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? colorScheme.primary
        : colorScheme.mutedForeground;
    final bgColor = isSelected
        ? colorScheme.primary.withAlpha(20)
        : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: extended
            ? Row(
                children: [
                  Icon(icon, size: 20, color: color),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(fontSize: 13, color: color),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 22, color: color),
                  const Gap(4),
                  Text(
                    label,
                    style: TextStyle(fontSize: 11, color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
      ),
    );
  }
}

/// 用户歌单列表（侧边栏二级菜单）
class _UserPlaylistList extends HookConsumerWidget {
  final bool extended;
  final HomeNav homeNav;
  final bool libraryViewActive;
  final void Function(PlaylistRef) onOpen;

  const _UserPlaylistList({
    required this.extended,
    required this.homeNav,
    required this.libraryViewActive,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(userListsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // 当前选中的歌单 ID（若处于歌单视图）
    final String? activePlaylistId =
        (libraryViewActive && homeNav is HomeNavPlaylist)
        ? (homeNav as HomeNavPlaylist).ref.playlistId
        : null;

    return listsAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.mutedForeground,
            ),
          ),
        ),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          '加载失败',
          style: TextStyle(fontSize: 12, color: colorScheme.mutedForeground),
        ),
      ),
      data: (data) {
        final playlists = data.userPlaylists;
        if (playlists.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '暂无歌单',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.mutedForeground,
              ),
            ),
          );
        }

        if (!extended) {
          // 紧凑模式：仅显示封面图标
          return Column(
            children: playlists.map((p) {
              final playlistId = (p.meta?['id'] as String?) ?? p.id;
              final isSelected = activePlaylistId == playlistId;
              return GestureDetector(
                onTap: () => onOpen(
                  PlaylistRef(
                    playlistId: playlistId,
                    sourceId: p.source?.id ?? '',
                    playlistName: p.name,
                    coverUrl: p.coverArt,
                    creator: p.owner ?? '',
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary.withAlpha(20)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CoverImage(
                    coverArt: p.coverArt,
                    colorScheme: colorScheme,
                    size: 36,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              );
            }).toList(),
          );
        }

        // 展开模式：显示封面 + 名称
        return Column(
          children: playlists.map((p) {
            final playlistId = (p.meta?['id'] as String?) ?? p.id;
            final isSelected = activePlaylistId == playlistId;
            final color = isSelected
                ? colorScheme.primary
                : colorScheme.foreground;
            final bgColor = isSelected
                ? colorScheme.primary.withAlpha(20)
                : Colors.transparent;
            return GestureDetector(
              onTap: () => onOpen(
                PlaylistRef(
                  playlistId: playlistId,
                  sourceId: p.source?.id ?? '',
                  playlistName: p.name,
                  coverUrl: p.coverArt,
                  creator: p.owner ?? '',
                ),
              ),
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CoverImage(
                      coverArt: p.coverArt,
                      colorScheme: colorScheme,
                      size: 28,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        p.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: color,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
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
      decoration: BoxDecoration(color: colorScheme.card),
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
