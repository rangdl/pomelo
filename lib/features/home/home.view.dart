// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:pomelo/core/layout/rx_layout.dart';

import '../example/ex.view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // final controller = Fluxy.find<HomeController>();
    // return Fx(
    //   () => RxLayout(currentIndex: controller.currentIndex, tabs: tabs),
    // );
    return Text('data');
  }
}

final tabs = [
  // RxTabItem(label: "首页", icon: Icons.home_outlined, widget: SizedBox.shrink()),
  // RxTabItem(
  //   label: "收藏",
  //   icon: Icons.favorite_outline,
  //   widget: SizedBox.shrink(),
  // ),
  // RxTabItem(
  //   label: "统计",
  //   icon: Icons.bar_chart_outlined,
  //   widget: SizedBox.shrink(),
  // ),
  // RxTabItem(label: "我的", icon: Icons.person_outline, widget: SizedBox.shrink()),
  // RxTabItem(label: "测试", icon: Icons.support_outlined, widget: ExView()),
];
