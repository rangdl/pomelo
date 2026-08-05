import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 分段式 Tab 项
///
/// 图标 + 文字的胶囊型标签，选中态实心填充，切换带 200ms 过渡动画。
/// 用于首页、收藏页等顶部分段导航。
///
/// 与 [AppChip] 的区别：
/// - [SegmentTabItem]：尺寸更大、带切换动画、未选中态有底色，用作页面级分段导航
/// - [AppChip]：紧凑标签，用作筛选/分类等次级选择
class SegmentTabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  /// 配色。不传则从 `Theme.of(context)` 取。
  /// 父级已持有 colorScheme 时传入可省一次查找。
  final ColorScheme? colorScheme;

  const SegmentTabItem({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = colorScheme ?? Theme.of(context).colorScheme;
    final foreground = isSelected
        ? scheme.primaryForeground
        : scheme.mutedForeground;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? scheme.primary : scheme.muted.withAlpha(30),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: foreground),
            const Gap(6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
