import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_store.dart';

/// 底部导航选中框的切换动画风格。
///
/// 只影响「指示器如何从旧标签过渡到新标签」，选中框本身的尺寸与配色不变。
enum NavAnimationStyle {
  /// 平滑滑过去，收尾略带回弹（默认）。
  slide('平滑滑动'),

  /// 纯缓出，不回弹、不放大，最克制。
  smooth('匀速淡滑'),

  /// 像果冻一样先向滑动方向轻微拉长再回弹。
  jelly('果冻拉伸'),

  /// 旧框缩小淡出、新框从略小状态放大淡入，不做位移。
  fade('淡入淡出'),

  /// 指示器沿弧线跃迁到新标签，像被抛过去一样。
  spring('弹性跃迁');

  const NavAnimationStyle(this.label);

  final String label;

  static NavAnimationStyle fromName(String? name) => values.firstWhere(
    (s) => s.name == name,
    orElse: () => NavAnimationStyle.slide,
  );
}

/// 启动时由 main() 注入已保存的动画风格。
final navAnimationInitializerProvider = Provider<NavAnimationStyle>(
  (ref) => NavAnimationStyle.slide,
);

class NavAnimationNotifier extends Notifier<NavAnimationStyle> {
  @override
  NavAnimationStyle build() => ref.watch(navAnimationInitializerProvider);

  Future<void> set(NavAnimationStyle style) async {
    if (style == state) return;
    state = style;
    await ref.read(settingsStoreProvider).patch({'navAnimation': style.name});
  }
}

final navAnimationProvider =
    NotifierProvider<NavAnimationNotifier, NavAnimationStyle>(
      NavAnimationNotifier.new,
    );

/// 从设置里还原导航动画风格。
NavAnimationStyle navAnimationFromStore(SettingsStore store) =>
    NavAnimationStyle.fromName(store.read<String>('navAnimation'));

/// 指示器的位置/形态动画控制器。
///
/// 抽出成独立组件，让"风格"只决定用哪组曲线与变换，
/// 底部导航侧无需关心动画细节。
class NavIndicatorAnimator extends StatefulWidget {
  const NavIndicatorAnimator({
    super.key,
    required this.index,
    required this.count,
    required this.cellWidth,
    required this.inset,
    required this.style,
    required this.color,
    required this.radius,
  });

  final int index;
  final int count;

  /// 单个标签格的宽度。
  final double cellWidth;

  /// 指示器相对格子左右上下的内缩量。
  final double inset;
  final NavAnimationStyle style;
  final Color color;
  final double radius;

  @override
  State<NavIndicatorAnimator> createState() => _NavIndicatorAnimatorState();
}

class _NavIndicatorAnimatorState extends State<NavIndicatorAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
    value: 1,
  );

  /// 动画起点（上一次停留的索引）。
  late int _from = widget.index;

  @override
  void didUpdateWidget(NavIndicatorAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 切换风格时立即停在新位置，避免旧风格的半程动画残留。
    if (widget.style != oldWidget.style) {
      _controller.duration = _durationFor(widget.style);
    }
    if (widget.index == oldWidget.index) return;
    _from = oldWidget.index;
    _controller.duration = _durationFor(widget.style);
    _controller.forward(from: 0);
  }

  Duration _durationFor(NavAnimationStyle style) => switch (style) {
    NavAnimationStyle.slide => const Duration(milliseconds: 420),
    NavAnimationStyle.smooth => const Duration(milliseconds: 300),
    NavAnimationStyle.jelly => const Duration(milliseconds: 460),
    NavAnimationStyle.fade => const Duration(milliseconds: 260),
    NavAnimationStyle.spring => const Duration(milliseconds: 680),
  };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Curve get _curve => switch (widget.style) {
    NavAnimationStyle.slide => Curves.easeOutBack,
    NavAnimationStyle.smooth => Curves.easeOutCubic,
    NavAnimationStyle.jelly => Curves.easeOutCubic,
    NavAnimationStyle.fade => Curves.easeOutCubic,
    NavAnimationStyle.spring => Curves.elasticOut,
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _curve.transform(_controller.value.clamp(0.0, 1.0));
        final fromLeft = _from * widget.cellWidth + widget.inset;
        final toLeft = widget.index * widget.cellWidth + widget.inset;
        final baseWidth = widget.cellWidth - widget.inset * 2;

        // 位移：多数风格按曲线插值；fade 风格保持在新位置做缩放淡入。
        final left = switch (widget.style) {
          NavAnimationStyle.fade => toLeft,
          _ => fromLeft + (toLeft - fromLeft) * t,
        };

        // 宽度：果冻风格在移动过程中向运动方向拉伸再收回。
        final width = switch (widget.style) {
          NavAnimationStyle.jelly =>
            baseWidth +
                math.sin(math.pi * _controller.value) *
                    (widget.cellWidth * 0.28),
          _ => baseWidth,
        };

        // 透明度：fade 风格首尾淡，其它风格恒定。
        final opacity = switch (widget.style) {
          NavAnimationStyle.fade =>
            1 - (math.sin(math.pi * _controller.value)).abs() * 0.55,
          _ => 1.0,
        };

        // 缩放：fade 风格从 0.72 放大到 1；spring 风格轻微过冲。
        final scale = switch (widget.style) {
          NavAnimationStyle.fade => 0.72 + 0.28 * t,
          NavAnimationStyle.spring => 1.0,
          _ => 1.0,
        };

        // 纵轴：spring 风格沿弧线跃起。
        final dy = switch (widget.style) {
          NavAnimationStyle.spring =>
            -math.sin(math.pi * _controller.value) * widget.cellWidth * 0.22,
          _ => 0.0,
        };

        // 以格子中心对齐：宽度变化（果冻拉伸）时向两侧对称张开，不偏位。
        final center = left + baseWidth / 2;
        return Stack(
          children: [
            Positioned(
              left: center - width / 2,
              top: widget.inset + dy,
              bottom: widget.inset - dy,
              width: width,
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(widget.radius),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
