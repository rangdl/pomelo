import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';

import '../widgets/bottom_bar.dart';

class RxLayout extends StatelessWidget {
  final Flux<int> currentIndex;
  final List<RxTabItem> tabs;
  // final Widget Function(BuildContext, int)? bottomNavBuilder;

  const RxLayout({super.key, required this.currentIndex, required this.tabs});

  @override
  Widget build(BuildContext context) {
    final responsiveBody = Fx.responsiveValue(
      context,
      xs: () => Fx(
        () => Fx.stack(
          alignment: AlignmentGeometry.bottomCenter,
          children: [indexedStack(), bottomBar()],
        ),
      ),
      md: () => Fx(
        () => Fx.row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [sidebar(), indexedStack()],
        ),
      ),
    );
    return Scaffold(body: responsiveBody());
  }

  Widget sidebar() {
    return FxSidebar(
      currentIndex: currentIndex.value,
      width: 180,
      activeColor: Fx.primary,
      onTap: (idx) => currentIndex.value = idx,
      items: tabs
          .map((tab) => FxSidebarItem(label: tab.label, icon: tab.icon))
          .toList(),
    );
  }

  Widget bottomBar() {
    return RxBottomBar(
      currentIndex: currentIndex.value,
      onTap: (index) => currentIndex.value = index,
      tabs: tabs,
    );
  }

  Widget indexedStack() {
    return IndexedStack(
      index: currentIndex.value,
      children: tabs.map((tab) => tab.widget).toList(),
    ).expand();
  }
}

class RxTabItem {
  final String label;
  final IconData icon;
  final Widget widget;

  RxTabItem({required this.label, required this.icon, required this.widget});
}
