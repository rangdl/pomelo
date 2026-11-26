import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/playback/presentation/now_playing_bar.dart';
import 'adaptive_app_shell.dart';
import 'window_class.dart';

/// 详情页外壳：宽屏时保留左侧导航，详情内容显示在右侧；
/// 移动端退回普通全屏页面。播放页等约定的全屏页面不使用它。
class ShellDetailScaffold extends ConsumerWidget {
  const ShellDetailScaffold({super.key, required this.child});

  final Widget child;

  static const _tabPaths = ['/', '/library', '/settings'];

  void _goTab(BuildContext context, WidgetRef ref, int index) {
    ref.read(activeBranchProvider.notifier).set(index);
    context.go(_tabPaths[index]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final body = Stack(
      children: [
        Positioned.fill(child: child),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: FloatingNowPlaying(),
        ),
      ],
    );

    return WindowClassBuilder(
      builder: (context, windowClass) {
        if (windowClass == WindowClass.compact) return body;
        return Scaffold(
          body: Row(
            children: [
              AppSideNavigation(
                currentIndex: ref.watch(activeBranchProvider),
                width: windowClass == WindowClass.expanded ? 208 : 176,
                onTap: (i) => _goTab(context, ref, i),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}
