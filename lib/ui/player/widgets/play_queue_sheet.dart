import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'bottom_sheet.dart';
import 'play_queue_content.dart';

/// 移动端播放队列底部 Sheet 内容
///
/// 顶部紧凑 drag handle + 标题栏（含关闭按钮） + [PlayQueueContent]。
/// 供 [MiniPlayer._openPlayQueue] 与 [PlaybackPage._openPlayQueue] 移动端复用。
///
/// 外层圆角与背景色由 [openBottomSheet]（[openDrawer]）提供，此处不再重复。
class PlayQueueSheet extends StatelessWidget {
  const PlayQueueSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SheetDragHandle(),
        // 标题栏
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton.text(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => closeOverlay(context),
              ),
              const Gap(4),
              const Text(
                '播放队列',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        const Flexible(child: PlayQueueContent()),
      ],
    );
  }
}
