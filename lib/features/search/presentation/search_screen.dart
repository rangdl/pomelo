import 'package:flutter/material.dart';

import 'search_view.dart';

/// 独立搜索页:从首页标题栏右侧的搜索按钮进入。
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('搜索')),
      body: const SearchView(),
    );
  }
}
