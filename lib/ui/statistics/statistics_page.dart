import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// 统计页面
@RoutePage()
class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('统计')));
  }
}
