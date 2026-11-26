import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../features/playback/presentation/now_playing_bar.dart';
import '../../features/plugins/presentation/plugin_picker_button.dart';
import '../ui/tokens.dart';
import 'window_class.dart';

/// 导航目标（首页 / 我的 / 设置）。详情页复用时保持同一份定义。
const List<(IconData, String)> appNavDestinations = [
  (Icons.home_rounded, '首页'),
  (Icons.favorite_rounded, '我的'),
  (Icons.settings_rounded, '设置'),
];

const List<String> _appNavTitles = ['Pomelo', '我的', '设置'];

/// 当前选中的导航分支。
///
/// 详情页（榜单/歌单/插件管理等）不在外壳的 IndexedStack 里，需要靠这个
/// 状态让它们左侧导航栏的高亮与进入前保持一致。
class ActiveBranchNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int index) => state = index;
}

final activeBranchProvider = NotifierProvider<ActiveBranchNotifier, int>(
  ActiveBranchNotifier.new,
);

/// 应用外壳:标题栏与导航集中在这唯一一层,页面组件只提供内容。
///
/// - medium/expanded:左侧导航(图标在左、文字在右,贯穿整个窗口高度);
/// - compact:底部玻璃导航栏。
///
/// 断点切换只换导航形态,[StatefulNavigationShell] 的 IndexedStack
/// 不重建,各分支的滚动位置与表单状态在拖动窗口大小时保留。
class AdaptiveAppShell extends ConsumerWidget {
  const AdaptiveAppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(WidgetRef ref, int index) {
    ref.read(activeBranchProvider.notifier).set(index);
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = navigationShell.currentIndex;
    final isHome = index == 0;
    final title = Text(_appNavTitles[index.clamp(0, _appNavTitles.length - 1)]);

    // 路由跳转（如深链到 /settings）时同步高亮，详情页才能继承正确分支。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(activeBranchProvider) != index) {
        ref.read(activeBranchProvider.notifier).set(index);
      }
    });

    return WindowClassBuilder(
      builder: (context, windowClass) {
        final wide = windowClass != WindowClass.compact;
        final expanded = windowClass == WindowClass.expanded;
        final collapsed = windowClass == WindowClass.medium;

        // 首页标题栏:左侧插件切换,右侧搜索入口。
        final appBar = AppBar(
          centerTitle: !isHome,
          titleSpacing: AppSpacing.sm,
          title: isHome ? _HomeTitleBar(showBrand: !wide) : title,
          actions: isHome
              ? [
                  IconButton(
                    tooltip: '搜索',
                    icon: const Icon(Icons.search_rounded),
                    onPressed: () => context.push('/search'),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ]
              : null,
        );

        if (wide) {
          // 桌面/平板：左侧导航贯穿整个窗口高度，右侧是标题栏 + 内容区。
          return Scaffold(
            body: Row(
              children: [
                AppSideNavigation(
                  currentIndex: index.clamp(0, appNavDestinations.length - 1),
                  width: expanded ? 208 : (collapsed ? 76 : 176),
                  collapsed: collapsed,
                  onTap: (i) => _goBranch(ref, i),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Scaffold(
                    appBar: appBar,
                    body: _ShellBody(child: navigationShell),
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          appBar: appBar,
          body: _ShellBody(child: navigationShell),
          bottomNavigationBar: _GlassBottomNavigation(
            destinations: appNavDestinations,
            currentIndex: index,
            onTap: (i) => _goBranch(ref, i),
          ),
        );
      },
    );
  }
}

/// 首页标题栏左侧:插件切换(宽屏品牌在侧栏,不再重复)。
class _HomeTitleBar extends StatelessWidget {
  const _HomeTitleBar({required this.showBrand});

  final bool showBrand;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBrand) ...[
          Text(
            'Pomelo',
            style: TextStyle(
              fontSize: AppText.detailTitle,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        const Expanded(child: PluginPickerButton()),
      ],
    );
  }
}

/// 内容区 + 浮在内容之上的迷你播放胶囊。
class _ShellBody extends StatelessWidget {
  const _ShellBody({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: FloatingNowPlaying(),
        ),
      ],
    );
  }
}

/// 桌面端左侧导航：图标在左、文字在右的横排。
///
/// 与移动端的「图标在上文字在下」明确区分；选中态用整块圆角高亮覆盖
/// 图标 + 文字，宽度/底色/字重/字色一起过渡。
class AppSideNavigation extends StatelessWidget {
  const AppSideNavigation({
    super.key,
    required this.currentIndex,
    required this.width,
    required this.onTap,
    this.collapsed = false,
    this.destinations = appNavDestinations,
  });

  final List<(IconData, String)> destinations;
  final int currentIndex;
  final double width;

  /// 折叠为纯图标栏(medium 断点),用 Tooltip 补足文字。
  final bool collapsed;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      color: scheme.surfaceContainerLowest,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                collapsed ? 0 : AppSpacing.lg,
                AppSpacing.lg,
                collapsed ? 0 : AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: collapsed
                  ? Icon(
                      Icons.graphic_eq_rounded,
                      color: scheme.primary,
                      size: 22,
                    )
                  : Row(
                      children: [
                        Icon(
                          Icons.graphic_eq_rounded,
                          color: scheme.primary,
                          size: 22,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Pomelo',
                          style: TextStyle(
                            fontSize: AppText.detailTitle,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                      ],
                    ),
            ),
            for (final (i, (icon, label)) in destinations.indexed)
              _SideNavItem(
                icon: icon,
                label: label,
                selected: i == currentIndex,
                collapsed: collapsed,
                onTap: () => onTap(i),
              ),
          ],
        ),
      ),
    );
  }
}

/// 单个侧栏导航项：整行（图标 + 文字）一起做选中动画。
class _SideNavItem extends StatelessWidget {
  const _SideNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.collapsed = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const duration = Duration(milliseconds: 220);
    final iconColor = selected ? scheme.primary : scheme.onSurfaceVariant;

    final content = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.cardBorder,
        onTap: onTap,
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 0 : AppSpacing.md,
            vertical: collapsed ? 12 : 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primary.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: AppRadius.cardBorder,
          ),
          child: collapsed
              ? Icon(icon, size: 22, color: iconColor)
              : Row(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: selected ? 1 : 0,
                        end: selected ? 1 : 0,
                      ),
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      builder: (context, t, child) => Icon(
                        icon,
                        size: 20,
                        color: Color.lerp(
                          scheme.onSurfaceVariant,
                          scheme.primary,
                          t,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: duration,
                        curve: Curves.easeOutCubic,
                        style: TextStyle(
                          fontSize: AppText.rowTitle,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: collapsed ? AppSpacing.md : AppSpacing.sm,
        vertical: 2,
      ),
      child: collapsed ? Tooltip(message: label, child: content) : content,
    );
  }
}

/// 移动端底部玻璃导航栏。
///
/// 参照 iOS 26 浮动胶囊:整条是一个玻璃胶囊,宽度按内容自适应(不撑满屏),
/// 每个标签「图标在上、文字在下」,选中项在胶囊内用高亮圆角块点亮并整块动画。
class _GlassBottomNavigation extends StatelessWidget {
  const _GlassBottomNavigation({
    required this.destinations,
    required this.currentIndex,
    required this.onTap,
  });

  final List<(IconData, String)> destinations;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    // SafeArea:全面屏手势机型上玻璃条不能压到手势区。
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        // 水平居中、高度贴合内容(不能用 Center 撑满整屏)。
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassContainer(
              shape: const LiquidRoundedSuperellipse(
                borderRadius: AppRadius.glass,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (i, (icon, label)) in destinations.indexed)
                    _NavItem(
                      icon: icon,
                      label: label,
                      selected: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 单个导航项:图标在上、文字在下;选中时整块淡主题色圆角背景 + 平滑过渡。
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = selected ? scheme.primary : scheme.onSurfaceVariant;
    final bg = selected
        ? scheme.primary.withValues(alpha: 0.14)
        : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.glass),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.glass),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOut,
                scale: selected ? 1.0 : 0.92,
                child: Icon(icon, size: 20, color: fg),
              ),
              const SizedBox(height: 1),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOut,
                style: TextStyle(
                  fontSize: AppText.compact,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: fg,
                ),
                child: Text(label, maxLines: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
