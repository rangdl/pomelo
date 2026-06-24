import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 封面占位图（无图片时展示）
///
/// 支持指定尺寸，默认填满父容器。
class CoverPlaceholder extends StatelessWidget {
  final ColorScheme colorScheme;
  final double? width;
  final double? height;

  const CoverPlaceholder({
    super.key,
    required this.colorScheme,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: colorScheme.muted,
      child: Center(
        child: Icon(
          Icons.queue_music,
          size: 36,
          color: colorScheme.mutedForeground,
        ),
      ),
    );
  }
}
