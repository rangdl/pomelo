// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // final controller = Fluxy.find<HomeController>();
    // return Fx(
    //   () => RxLayout(currentIndex: controller.currentIndex, tabs: tabs),
    // );
    return Text(
      '在 Flutter 中实现毛玻璃效果，主要使用 BackdropFilter 组件结合 ImageFilter.blur 来实现。在 Flutter 中实现毛玻璃效果，主要使用 BackdropFilter 组件结合 ImageFilter.blur 来实现。',
    );
  }
}
