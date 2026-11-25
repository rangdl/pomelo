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

/// 移动端底部玻璃导航栏:等距横排玻璃圆钮,选中项用主题色点亮。
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
    final accent = Theme.of(context).colorScheme.primary;
    final inactive = Theme.of(context).colorScheme.onSurfaceVariant;
    // SafeArea:全面屏手势机型上玻璃条不能压到手势区。
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: GlassContainer(
          shape: const LiquidRoundedSuperellipse(borderRadius: AppRadius.glass),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final (i, (icon, label)) in destinations.indexed)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GlassIconButton(
                      size: 40,
                      iconSize: 19,
                      icon: Icon(
                        icon,
                        color: i == currentIndex ? accent : inactive,
                      ),
                      onPressed: () => onTap(i),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: AppText.compact,
                        color: i == currentIndex ? accent : inactive,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
