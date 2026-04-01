import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../helper.dart';
import '../widgets/glass.dart';

// stack to track changes in navigationShell.currentIndex
// home is always at index 0 and at the start and should be the last before popping
// if stack is empty, push home, if already contains home, pop it
final Set<int> navigationShellStack = {};

const bottomBarHeight = 64;

/// Builds the "shell" for the app by building a Scaffold with a
/// BottomNavigationBar, where [child] is placed in the body of the Scaffold.
class ScaffoldWithNavBar extends HookConsumerWidget {
  /// Constructs an [ScaffoldWithNavBar].
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    // 竖屏
    final isVertical = size.height > size.width;
    return Scaffold(body: isVertical ? buildVertical() : buildHorizontal());
  }

  Widget buildVertical() {
    return Stack(
      alignment: AlignmentGeometry.bottomCenter,
      children: [
        navigationShell,
        RxBottomBar(
          currentIndex: navigationShell.currentIndex,
          onTap: _onTap,
          tabs: tabs,
        ),
      ],
    );
  }

  Widget buildHorizontal() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RxSideBar(
          currentIndex: navigationShell.currentIndex,
          onTap: _onTap,
          tabs: tabs,
        ),
        VerticalDivider(width: 0.5, thickness: 0.5),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: navigationShell,
          ),
        ),
      ],
    );
  }

  /// Navigate to the current location of the branch at the provided index when
  /// tapping an item in the BottomNavigationBar.
  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

final tabs = [
  RxTabItem(label: "首页", icon: Icons.home_outlined),
  RxTabItem(label: "收藏", icon: Icons.favorite_outline),
  RxTabItem(label: "统计", icon: Icons.bar_chart_outlined),
  RxTabItem(label: "我的", icon: Icons.person_outline),
  RxTabItem(label: "设置", icon: Icons.settings_outlined),
  if (Helper.isDebug) RxTabItem(label: "测试", icon: Icons.support_outlined),
];

class RxTabItem {
  final String label;
  final IconData icon;

  RxTabItem({required this.label, required this.icon});
}

class RxBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<RxTabItem> tabs;
  final bool animate;
  final Color? activeColor;
  final Color? baseColor;

  const RxBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.tabs,
    this.animate = true,
    this.activeColor,
    this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Helper.isDark(context);
    final effectiveActive =
        activeColor ?? Theme.of(context).colorScheme.primary;
    final effectiveBase =
        baseColor ?? (isDark ? Colors.white70 : Colors.black54);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Glass(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          spacing: 8,
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isActive = index == currentIndex;
            return GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: animate
                    ? const Duration(milliseconds: 400)
                    : Duration.zero,
                curve: Curves.easeOutBack,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                // decoration: BoxDecoration(
                //   color: isActive
                //       ? effectiveActive.withValues(alpha: 0.1)
                //       : Colors.transparent,
                //   borderRadius: BorderRadius.circular(12),
                // ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      color: isActive ? effectiveActive : effectiveBase,
                      size: 24,
                    ),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isActive ? effectiveActive : baseColor,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class RxSideBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<RxTabItem> tabs;
  final Widget? header;
  final Widget? footer;
  final double width;
  final bool animate;
  final Color? activeColor;
  final Color? baseColor;

  const RxSideBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.tabs,
    this.header,
    this.footer,
    this.width = 180,
    this.animate = true,
    this.activeColor,
    this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Helper.isDark(context);
    final effectiveActive =
        activeColor ?? Theme.of(context).colorScheme.primary;
    final effectiveBase =
        baseColor ?? (isDark ? Colors.white70 : Colors.black54);
    return Container(
      width: width,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ?header,
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                final item = tabs[index];
                final isActive = index == currentIndex;
                return GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: animate
                        ? const Duration(milliseconds: 400)
                        : Duration.zero,
                    curve: Curves.easeOutBack,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? effectiveActive.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(
                          item.icon,
                          color: isActive ? effectiveActive : effectiveBase,
                          size: 24,
                        ),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isActive ? effectiveActive : baseColor,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemCount: tabs.length,
            ),
          ),
          ?footer,
        ],
      ),
    );
  }
}
