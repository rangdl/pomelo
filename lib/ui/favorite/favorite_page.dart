import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// 收藏页面
@RoutePage()
class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('收藏')));
  }
}
