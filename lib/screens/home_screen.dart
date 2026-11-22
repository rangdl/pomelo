import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_providers.dart';
import '../widgets/now_playing_bar.dart';
import 'search_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plugins = ref.watch(pluginListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomelo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.extension),
            tooltip: 'MusicFree 插件',
            onPressed: () => context.push('/plugins'),
          ),
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'LX 音源脚本',
            onPressed: () => context.push('/lx'),
          ),
        ],
      ),
      body: plugins.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载插件失败: $e')),
        data: (list) => list.isEmpty
            ? const _EmptyState()
            : const Column(
                children: [
                  Expanded(child: SearchView()),
                  NowPlayingBar(),
                ],
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.extension_off, size: 56),
            const SizedBox(height: 12),
            const Text('还没有安装插件', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              '用右上角的两个入口安装 MusicFree 插件或 LX 音源脚本。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
