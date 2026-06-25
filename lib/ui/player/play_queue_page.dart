import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'widgets/play_queue_content.dart';

/// 播放队列页面（移动端全屏）
///
/// 桌面端不进入此路由，由 PlaybackPage 通过 openSheet 直接渲染 PlayQueueContent。
@RoutePage()
class PlayQueuePage extends HookConsumerWidget {
  const PlayQueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      headers: [
        AppBar(
          leading: [
            GhostButton(
              density: ButtonDensity.icon,
              onPressed: () => context.router.maybePop(),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ],
          title: const Text('播放队列'),
        ),
        const Divider(),
      ],
      child: const PlayQueueContent(),
    );
  }
}
