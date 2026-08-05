import 'package:flutter/widgets.dart';

/// ============================================================
/// 响应式布局工具
/// ============================================================

/// 响应式断点常量
abstract final class ResponsiveBreakpoints {
  /// 手机 (< 600px)
  static const double mobile = 600;

  /// 平板 (600~1024px)
  static const double tablet = 1024;

  /// 桌面 (1024~1440px)
  static const double desktop = 1440;

  /// TV (> 1440px)
  static const double tv = 1440;
}

/// ============================================================
/// 主工具类
/// ============================================================

class Rx {
  Rx._();

  /// 当前可用宽度
  ///
  /// 使用 [MediaQuery.sizeOf] 而非 `MediaQuery.of(context).size`，
  /// 只订阅 size 这一个切面：键盘弹出（viewInsets）、字体缩放、安全区变化
  /// 都不会再触发依赖方 rebuild。
  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;

  /// 是否为移动端布局（宽度 < 600）
  ///
  /// 全局唯一的断点判断入口，避免各页面重复写
  /// `MediaQuery.of(context).size.width < ResponsiveBreakpoints.mobile`。
  static bool isMobile(BuildContext context) =>
      width(context) < ResponsiveBreakpoints.mobile;

  /// 是否为桌面级宽度（>= 600），即 [isMobile] 的反面
  static bool isDesktop(BuildContext context) => !isMobile(context);

  /// 响应式布局
  ///
  /// 根据屏幕宽度自动选择合适的布局组件。
  ///
  /// 用法:
  /// ```dart
  /// Rx.layout(
  ///   context,
  ///   mobile: () => _MobileWidget(),
  ///   tablet: () => _TabletWidget(),
  ///   desktop: () => _DesktopWidget(),
  /// )
  /// ```
  ///
  /// 未提供的断点按以下规则回退:
  /// - mobile   → tablet → desktop → tv
  /// - tablet  → desktop → mobile → tv
  /// - desktop → tablet → tv → mobile
  /// - tv      → desktop → tablet → mobile
  static Widget layout(
    BuildContext context, {
    Widget Function()? mobile,
    Widget Function()? tablet,
    Widget Function()? desktop,
    Widget Function()? tv,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _resolve(
          constraints.maxWidth,
          mobile: mobile,
          tablet: tablet,
          desktop: desktop,
          tv: tv,
        );
      },
    );
  }

  /// 响应式动作
  ///
  /// 与 [layout] 不同，此方法不创建 Widget，而是根据当前屏幕宽度
  /// 立即执行对应的回调函数。适用于导航跳转、弹窗显示等动作场景。
  ///
  /// 用法:
  /// ```dart
  /// Rx.action(
  ///   context,
  ///   mobile: () => Navigator.push(context, ...),
  ///   tablet: () => showDialog(context, ...),
  /// );
  /// ```
  static void action(
    BuildContext context, {
    void Function()? mobile,
    void Function()? tablet,
    void Function()? desktop,
    void Function()? tv,
  }) {
    final width = Rx.width(context);
    if (width < ResponsiveBreakpoints.mobile) {
      (mobile ?? tablet ?? desktop ?? tv)?.call();
    } else if (width < ResponsiveBreakpoints.tablet) {
      (tablet ?? desktop ?? mobile ?? tv)?.call();
    } else if (width < ResponsiveBreakpoints.desktop) {
      (desktop ?? tablet ?? tv ?? mobile)?.call();
    } else {
      (tv ?? desktop ?? tablet ?? mobile)?.call();
    }
  }

  /// 响应式网格列数
  ///
  /// 根据 [width] 自动计算网格列数，从 [base] 起步随断点递增：
  /// - mobile(<600)：base
  /// - tablet(600~1024)：base + 1
  /// - desktop(1024~1440)：base + 2
  /// - tv(>=1440)：base + 3
  ///
  /// 用法:
  /// ```dart
  /// final crossAxisCount = Rx.gridColumns(constraints.maxWidth, base: 2);
  /// ```
  static int gridColumns(double width, {int base = 2}) {
    if (width < ResponsiveBreakpoints.mobile) return base;
    if (width < ResponsiveBreakpoints.tablet) return base + 1;
    if (width < ResponsiveBreakpoints.desktop) return base + 2;
    return base + 3;
  }

  static Widget _resolve(
    double width, {
    Widget Function()? mobile,
    Widget Function()? tablet,
    Widget Function()? desktop,
    Widget Function()? tv,
  }) {
    final shrink = const SizedBox.shrink();

    if (width < ResponsiveBreakpoints.mobile) {
      return (mobile ?? tablet ?? desktop ?? tv)?.call() ?? shrink;
    }
    if (width < ResponsiveBreakpoints.tablet) {
      return (tablet ?? desktop ?? mobile ?? tv)?.call() ?? shrink;
    }
    if (width < ResponsiveBreakpoints.desktop) {
      return (desktop ?? tablet ?? tv ?? mobile)?.call() ?? shrink;
    }
    return (tv ?? desktop ?? tablet ?? mobile)?.call() ?? shrink;
  }
}
