import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../settings/nav_animation.dart';
import '../settings/nav_bar_style.dart';
import '../ui/tokens.dart';

/// 底部导航胶囊（真实导航与设置页预览共用同一份实现）。
///
/// 尺寸全部来自 [NavBarMetrics]，动画风格来自 [NavAnimationStyle]；
/// 选中指示器与图标/文字状态由同一个 [AnimationController] 驱动，
/// 因此动画过程中不会出现「目标格提前亮起」或两个指示器并存的情况。
class NavBarCapsule extends ConsumerStatefulWidget {
  const NavBarCapsule({
    super.key,
    required this.destinations,
    required this.currentIndex,
    this.onTap,
    this.metrics,
    this.style,
    this.color,
    this.animate = true,
  });

  final List<(IconData, String)> destinations;
  final int currentIndex;

  /// 为空表示只做预览：点击不会切换分支。
  final ValueChanged<int>? onTap;

  /// 为空时读取全局设置。
  final NavBarMetrics? metrics;
  final NavAnimationStyle? style;

  /// 强调色，默认取主题色。
  final Color? color;

  /// 预览时传 false，避免玻璃 shader 反复初始化。
  final bool animate;

  @override
  ConsumerState<NavBarCapsule> createState() => _NavBarCapsuleState();
}

class _NavBarCapsuleState extends ConsumerState<NavBarCapsule>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _durationFor(widget.style ?? NavAnimationStyle.slide),
    value: 1,
  );

  /// 动画起点：上一次停留的索引。
  late int _from = widget.currentIndex;

  static Duration _durationFor(NavAnimationStyle style) => switch (style) {
    NavAnimationStyle.slide => const Duration(milliseconds: 320),
    NavAnimationStyle.smooth => const Duration(milliseconds: 280),
    NavAnimationStyle.jelly => const Duration(milliseconds: 380),
    NavAnimationStyle.fade => const Duration(milliseconds: 240),
    NavAnimationStyle.bounce => const Duration(milliseconds: 460),
  };

  @override
  void didUpdateWidget(NavBarCapsule oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex == oldWidget.currentIndex) return;
    _from = oldWidget.currentIndex;
    _controller
      ..duration = _durationFor(widget.style ?? NavAnimationStyle.slide)
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final NavBarMetrics metrics =
        widget.metrics ?? ref.watch(navBarMetricsProvider);
    final NavAnimationStyle style =
        widget.style ?? ref.watch(navAnimationProvider);
    final accent = widget.color ?? scheme.primary;

    // 预览改风格时要立刻用新时长。
    if (_controller.duration != _durationFor(style)) {
      _controller.duration = _durationFor(style);
    }

    return GlassContainer(
      shape: const LiquidRoundedSuperellipse(borderRadius: AppRadius.glass),
      padding: EdgeInsets.all(metrics.inset),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final tween = NavIndicatorTween(
            style: style,
            fromIndex: _from,
            toIndex: widget.currentIndex,
            controller: _controller,
          );
          return SizedBox(
            height: metrics.height - metrics.inset * 2,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _IndicatorPainter(
                      tween: tween,
                      cellWidth: metrics.itemWidth,
                      cellHeight: metrics.height - metrics.inset * 2,
                      inset: metrics.inset,
                      color: accent.withValues(alpha: 0.16),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final (i, (icon, label))
                        in widget.destinations.indexed)
                      SizedBox(
                        width: metrics.itemWidth,
                        child: _NavItem(
                          icon: icon,
                          label: label,
                          // 距离指示器中心越近越「选中」，与动画同步。
                          emphasis: (1 - (tween.index - i).abs()).clamp(
                            0.0,
                            1.0,
                          ),
                          metrics: metrics,
                          color: accent,
                          idleColor: scheme.onSurfaceVariant,
                          onTap: widget.onTap == null
                              ? null
                              : () => widget.onTap!(i),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 绘制选中指示器：与导航项等宽等高的圆角矩形。
///
/// 不再画圆——选中范围就是整个标签格，靠圆角与内缩区分边界。
class _IndicatorPainter extends CustomPainter {
  _IndicatorPainter({
    required this.tween,
    required this.cellWidth,
    required this.cellHeight,
    required this.inset,
    required this.color,
  });

  final NavIndicatorTween tween;
  final double cellWidth;
  final double cellHeight;
  final double inset;
  final Color color;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final centerX = (tween.index + 0.5) * cellWidth;
    // 基础尺寸 = 格子宽高各内缩 inset，与相邻格、与胶囊外框都留出同样的缝。
    final baseW = cellWidth - inset * 2;
    final baseH = cellHeight - inset * 2;
    final paint = Paint()
      ..color = color.withValues(alpha: color.a * tween.opacity);
    // 果冻拉伸只在横向，且最多吃掉与相邻格之间的一半缝隙。
    final w = (baseW * tween.stretchX).clamp(0.0, cellWidth - inset);
    final h = baseH * tween.scale;
    // 圆角随高度自适应：取高的一半即胶囊形，不会因为高度调大而显方。
    final radius = h / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, canvasSize.height / 2),
          width: w,
          height: h,
        ),
        Radius.circular(radius),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_IndicatorPainter old) =>
      old.tween.index != tween.index ||
      old.tween.opacity != tween.opacity ||
      old.tween.stretchX != tween.stretchX ||
      old.tween.scale != tween.scale ||
      old.color != color;
}

/// 单个导航项：图标在上、文字在下。
///
/// 不画自己的选中背景——背景完全由指示器负责；这里只按 [emphasis]
/// 连续插值图标的颜色与缩放。也刻意不开启 InkWell，避免点击时
/// 在目标格上闪出一个涟漪/高亮方块。
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.emphasis,
    required this.metrics,
    required this.color,
    required this.idleColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final double emphasis;
  final NavBarMetrics metrics;
  final Color color;
  final Color idleColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = Color.lerp(idleColor, color, emphasis)!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // 预览时 onTap 为 null，不拦截点击。
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(top: metrics.iconTopPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: lerpDouble(0.92, 1.0, emphasis),
              child: Icon(icon, size: metrics.iconSize, color: fg),
            ),
            SizedBox(height: metrics.iconTextGap),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: metrics.fontSize,
                // 字重不能连续插值，过半程再切到加粗。
                fontWeight: emphasis > 0.5 ? FontWeight.w600 : FontWeight.w400,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
