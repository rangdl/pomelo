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
/// 每个标签是一个「图标 + 文字」一体的玻璃胶囊按钮，宽度随内容自适应，
/// 选中项整块高亮并带玻璃选中动画（不再是图标单独动、文字在下面堆高度）。
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
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: Row(
          children: [
            for (final (i, (icon, label)) in destinations.indexed)
              // 每项按内容宽度自适应；间距用 Expanded 均分到两侧。
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _NavItem(
                    icon: icon,
                    label: label,
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 单个底部导航项：图标 + 文字一体的玻璃胶囊，选中整块高亮。
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
    // 选中项用主题色淡底胶囊强调；未选中透明（融入玻璃栏）。
    final bg = selected
        ? scheme.primary.withValues(alpha: 0.16)
        : Colors.transparent;

    return GlassButton.custom(
      onTap: onTap,
      isSelected: selected,
      style: GlassButtonStyle.transparent,
      width: null,
      height: 48,
      shape: const LiquidRoundedSuperellipse(borderRadius: AppRadius.floating),
      // 图标与文字内部再套一层动画容器，让选中态的颜色/底/字重平滑过渡。
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.floating),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              scale: selected ? 1.0 : 0.92,
              child: Icon(icon, size: 20, color: fg),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                style: TextStyle(
                  fontSize: AppText.compact,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: fg,
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
    );
  }
}

