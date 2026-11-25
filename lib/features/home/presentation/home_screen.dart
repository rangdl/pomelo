import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../playback/presentation/now_playing_bar.dart';
import '../../plugins/presentation/plugin_providers.dart';
import '../../search/presentation/search_view.dart';
import '../../../shared/layout/window_class.dart';
import '../../../shared/widgets/widgets.dart';

/// 首页内容(外壳 [AdaptiveAppShell] 提供标题栏与自适应导航)。
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plugins = ref.watch(pluginListProvider);
    return plugins.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载插件失败: $e')),
      data: (list) => list.isEmpty
          ? EmptyState(
              icon: Icons.extension_off_rounded,
              title: '还没有安装插件',
              message: '到设置页安装 MusicFree 插件或 LX 音源脚本。',
              actions: [
                FilledButton.tonalIcon(
                  onPressed: () => context.push('/plugins'),
                  icon: const Icon(Icons.extension_rounded),
                  label: const Text('MusicFree 插件'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => context.push('/lx'),
                  icon: const Icon(Icons.code_rounded),
                  label: const Text('LX 音源'),
                ),
              ],
            )
          : const Column(
              children: [
                Expanded(child: SearchView()),
                // 宽屏下迷你播放条与内容同宽,不拉满整窗。
                CenteredMaxWidth(child: NowPlayingBar()),
              ],
            ),
    );
  }
}
