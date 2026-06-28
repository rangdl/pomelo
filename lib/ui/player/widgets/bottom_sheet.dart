import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 打开底部 Sheet
///
/// 基于 [openDrawer] 封装，统一移动端底部 sheet 的视觉与交互：
/// - 不缩放背景（`transformBackdrop: false`），保持 sheet 行为
/// - 隐藏默认 drag handle（默认顶部空白过大），改由内容自行渲染紧凑 handle
/// - 顶部圆角 20px，无边框
/// - 默认可下拉关闭（`draggable: true`）
Future<T?> openBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool draggable = true,
  bool barrierDismissible = true,
}) {
  return openDrawer<T>(
    context: context,
    position: OverlayPosition.bottom,
    draggable: draggable,
    barrierDismissible: barrierDismissible,
    transformBackdrop: false,
    showDragHandle: false,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
    builder: builder,
  );
}

/// 紧凑 drag handle 视觉指示器
///
/// 宽 32、高 4 的圆角短条，搭配上下 6 的间距，总高 16px。
/// 用于 [PlayQueueSheet] 等自定义 sheet 顶部，提示可下拉关闭。
class SheetDragHandle extends StatelessWidget {
  const SheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: 32,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.muted,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
