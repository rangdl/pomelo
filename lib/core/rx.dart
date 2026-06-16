import 'package:bot_toast/bot_toast.dart';
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
  static RxToast get toast => RxToast();

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
    final width = MediaQuery.of(context).size.width;
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

// 文档 https://github.com/MMMzq/bot_toast/blob/master/API_zh.md
class RxToast {
  // 单例
  static final RxToast _instance = RxToast._internal();
  factory RxToast() => _instance;
  RxToast._internal();

  // 默认显示时间
  final Duration _duration = Duration(seconds: 2);

  CancelFunc success(String msg, {Duration? duration}) {
    return info(msg, contentColor: Color(0xFF22C55E));
  }

  CancelFunc error(String msg, {Duration? duration}) {
    return info(msg, contentColor: Color(0xFFEF4444));
  }

  CancelFunc warning(String msg, {Duration? duration}) {
    return info(msg, contentColor: Color(0xFFF59E0B));
  }

  CancelFunc info(String msg, {Duration? duration, Color? contentColor}) {
    return BotToast.showText(
      text: msg,
      duration: duration ?? _duration,
      contentColor: contentColor ?? Color(0xFF3B82F6),
    );
  }
}
