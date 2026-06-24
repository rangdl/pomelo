import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 通用 Chip 标签组件
///
/// 支持选中/未选中态，可自定义颜色、尺寸、图标。
/// 用于分类标签、排序标签、筛选标签、Tab 标签等场景。
class AppChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  /// 选中时的基础颜色，默认为主题主色
  final Color? selectedColor;

  /// 未选中时的基础颜色，默认为 muted
  final Color? unselectedColor;

  /// true = 选中时实心填充，false = 选中时半透明背景
  final bool fill;

  /// 可选前缀图标
  final IconData? icon;

  /// 内边距
  final EdgeInsets padding;

  /// 圆角半径
  final double borderRadius;

  /// 字号
  final double fontSize;

  /// 未选中时是否显示边框
  final bool borderWhenUnselected;

  const AppChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
    this.unselectedColor,
    this.fill = false,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.borderRadius = 14,
    this.fontSize = 12,
    this.borderWhenUnselected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = isSelected
        ? (selectedColor ?? colorScheme.primary)
        : (unselectedColor ?? colorScheme.muted);

    Color bgColor;
    Border? border;

    if (isSelected) {
      bgColor = fill ? baseColor : baseColor.withValues(alpha: 0.15);
      border = fill ? null : Border.all(color: baseColor.withValues(alpha: 0.5));
    } else {
      bgColor = borderWhenUnselected
          ? colorScheme.muted.withValues(alpha: 0.3)
          : Colors.transparent;
      border = borderWhenUnselected
          ? Border.all(color: colorScheme.muted.withValues(alpha: 0.6))
          : null;
    }

    final textColor = isSelected
        ? (fill ? colorScheme.primaryForeground : baseColor)
        : colorScheme.mutedForeground;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: fontSize + 2, color: textColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
