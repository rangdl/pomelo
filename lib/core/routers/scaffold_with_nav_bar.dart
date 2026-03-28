import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// stack to track changes in navigationShell.currentIndex
// home is always at index 0 and at the start and should be the last before popping
// if stack is empty, push home, if already contains home, pop it
final Set<int> navigationShellStack = {};

const bottomBarHeight = 64;

/// Builds the "shell" for the app by building a Scaffold with a
/// BottomNavigationBar, where [child] is placed in the body of the Scaffold.
class ScaffoldWithNavBar extends HookConsumerWidget {
  /// Constructs an [ScaffoldWithNavBar].
  const ScaffoldWithNavBar({required this.navigationShell, Key? key})
    : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

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
      children: [navigationShell, Text('bottomBar')],
    );
  }

  Widget buildHorizontal() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text('bottomBar'), navigationShell],
    );
  }

  /// Navigate to the current location of the branch at the provided index when
  /// tapping an item in the BottomNavigationBar.
  void _onTap(BuildContext context, int index, WidgetRef ref) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
