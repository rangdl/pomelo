// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsView extends HookConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final controller = Fluxy.find<HomeController>();
    // return Fx(
    //   () => RxLayout(currentIndex: controller.currentIndex, tabs: tabs),
    // );
    return Text('Settings');
  }
}
