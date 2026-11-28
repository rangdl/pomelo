import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_store.dart';

/// 底部导航选中框的切换动画风格。
///
/// 只影响「指示器如何从旧标签过渡到新标签」，选中框本身的尺寸与配色不变。
enum NavAnimationStyle {
  /// 平滑滑过去，缓出收尾（默认）。
  slide('平滑滑动'),

  /// 两端缓入缓出，最克制。
  smooth('匀速淡滑'),

  /// 移动途中横向拉长成椭圆、到位恢复圆形，像果冻。
  jelly('果冻拉伸'),

  /// 不位移：旧位置的圆淡出，新位置的圆放大淡入。
  fade('淡入淡出'),

  /// 位置带轻微过冲、圆形本身带弹性缩放。
  bounce('弹性跃迁');

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

/// 选中指示器的动画参数：位置、形状与透明度。
///
/// 单独放在这里，方便被底部导航、预览图等共用。
class NavIndicatorTween {
  NavIndicatorTween({
    required this.style,
    required this.fromIndex,
    required this.toIndex,
    required this.controller,
  }) : curve = switch (style) {
         NavAnimationStyle.slide => Curves.easeOutCubic,
         NavAnimationStyle.smooth => Curves.easeInOutCubic,
         NavAnimationStyle.jelly => Curves.easeInOutCubic,
         NavAnimationStyle.fade => Curves.easeInOutCubic,
         NavAnimationStyle.bounce => Curves.easeOutBack,
       };

  final NavAnimationStyle style;
  final int fromIndex;
  final int toIndex;
  final AnimationController controller;
  final Curve curve;

  /// 进度（已 clamp 到 [0,1]）：可过冲的曲线在这里会被截断，
  /// 保证指示器永远不会跑出胶囊之外。
  double get _raw => controller.value;

  /// 位置插值所用的进度：bounce 允许轻微过冲（仍在格子范围内）。
  double get _positionT {
    if (style == NavAnimationStyle.bounce) {
      // 过冲限制在 8%，肉眼有弹性但不会越界。
      return curve.transform(_raw).clamp(-0.08, 1.08);
    }
    return curve.transform(_raw).clamp(0.0, 1.0);
  }

  /// 线性进度，用于形状/透明度这类不该过冲的量。
  double get _shapeT => _raw.clamp(0.0, 1.0);

  /// 从 fromIndex 到 toIndex 的插值索引（fade 风格直接落在目标位）。
  double get index {
    if (style == NavAnimationStyle.fade) return toIndex.toDouble();
    return fromIndex + (toIndex - fromIndex) * _positionT;
  }

  /// 横向拉伸倍数：jelly 在移动途中拉宽成椭圆。
  double get stretchX => switch (style) {
    NavAnimationStyle.jelly => 1 + math.sin(math.pi * _shapeT) * 0.42,
    _ => 1.0,
  };

  /// 圆形缩放：fade 从 0.6 放大到 1；bounce 到位时轻微回弹。
  double get scale => switch (style) {
    NavAnimationStyle.fade =>
      0.6 + 0.4 * curve.transform(_shapeT).clamp(0.0, 1.0),
    NavAnimationStyle.bounce =>
      1 - 0.18 * (1 - curve.transform(_shapeT).clamp(0.0, 1.0)),
    _ => 1.0,
  };

  /// 不透明度：fade 首尾淡入淡出，其余恒定。
  double get opacity => switch (style) {
    NavAnimationStyle.fade => math.sin(math.pi * _shapeT).clamp(0.0, 1.0),
    _ => 1.0,
  };
}
