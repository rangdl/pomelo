import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'cover_placeholder.dart';

/// 统一的封面图加载组件
///
/// 封装 `coverArt` 为空/加载失败的兜底逻辑（显示 [CoverPlaceholder]）。
/// 可选 [size] 指定正方形边长（为 null 时撑满父容器，常配合 AspectRatio/Expanded 使用）。
/// 可选 [borderRadius] 自动包裹 ClipRRect，省去外部手动裁剪。
class CoverImage extends StatelessWidget {
  final String? coverArt;
  final ColorScheme colorScheme;
  final double? size;
  final BorderRadius? borderRadius;

  const CoverImage({
    super.key,
    required this.coverArt,
    required this.colorScheme,
    this.size,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final Widget image = coverArt != null && coverArt!.isNotEmpty
        ? Image.network(
            coverArt!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => CoverPlaceholder(
              colorScheme: colorScheme,
              width: size,
              height: size,
            ),
          )
        : CoverPlaceholder(
            colorScheme: colorScheme,
            width: size,
            height: size,
          );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
