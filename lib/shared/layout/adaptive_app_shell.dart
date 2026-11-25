import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../ui/tokens.dart';
import 'window_class.dart';

/// 应用外壳:标题栏与导航集中在这唯一一层,页面组件只提供内容。
///
/// - medium/expanded:左侧 [NavigationRail](Material 风格);
/// - compact:底部玻璃导航栏(全应用唯一保留玻璃效果的地方)。
///
/// 断点切换只换导航形态,[StatefulNavigationShell] 的 IndexedStack
/// 不重建,各分支的滚动位置与表单状态在拖动窗口大小时保留。
class AdaptiveAppShell extends StatelessWidget {
  const AdaptiveAppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const List<(IconData, String)> _destinations = [
    (Icons.home_rounded, '首页'),
    (Icons.favorite_rounded, '我的'),
    (Icons.settings_rounded, '设置'),
  ];

  static const List<String> _titles = ['Pomelo', '我的', '设置'];

  void _goBranch(int index) => navigationShell.goBranch(index);

  @override
  Widget build(BuildContext context) {
    final index = navigationShell.currentIndex;
    final title = Text(_titles[index.clamp(0, _titles.length - 1)]);

    return WindowClassBuilder(
      builder: (context, windowClass) {
        final wide = windowClass != WindowClass.compact;
        // medium(手机横屏/小平板)用窄轨只显图标,expanded 才展开文字。
        final expanded = windowClass == WindowClass.expanded;
        return Scaffold(
          appBar: AppBar(title: title),
          body: wide
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: index.clamp(0, _destinations.length - 1),
                      onDestinationSelected: _goBranch,
                      labelType: expanded
                          ? NavigationRailLabelType.all
                          : NavigationRailLabelType.none,
                      destinations: [
                        for (final (icon, label) in _destinations)
                          NavigationRailDestination(
                            icon: Icon(icon),
                            label: Text(label),
                          ),
                      ],
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: navigationShell),
                  ],
                )
              : navigationShell,
          bottomNavigationBar: wide
              ? null
              : _GlassBottomNavigation(
                  destinations: _destinations,
                  currentIndex: index,
                  onTap: _goBranch,
                ),
        );
      },
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
        ? scheme.primary.withValues(alpha: 0.16)
        : Colors.transparent;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
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
    );
  }
}

