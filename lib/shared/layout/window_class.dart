import 'package:flutter/widgets.dart';

/// Material 3 窗口分级(也即 Jetpack Compose 的 `WindowSizeClass`)。
///
/// 分级数字是跨端行业标准,不是本项目自定的:
/// - compact:  宽 < 600(手机竖屏)
/// - medium:   600 ≤ 宽 < 840(手机横屏 / 小平板)
/// - expanded: 宽 ≥ 840(平板横屏 / 桌面)
///
/// 新增页面时只允许依赖 [WindowClass],不要自己再取
/// `MediaQuery.sizeOf` 判断宽度;断点集中在这里,布局决策才集中。
enum WindowClass { compact, medium, expanded }

const double _mediumBreakpoint = 600;
const double _expandedBreakpoint = 840;

/// 按宽度归入窗口分级。
WindowClass windowClassFromWidth(double width) => switch (width) {
      >= _expandedBreakpoint => WindowClass.expanded,
      >= _mediumBreakpoint => WindowClass.medium,
      _ => WindowClass.compact,
    };

extension WindowClassX on BuildContext {
  /// 当前窗口分级。会随窗口尺寸变化重建调用方。
  WindowClass get windowClass => windowClassFromWidth(MediaQuery.sizeOf(this).width);
}

/// 窗口跨断点时才重建子树的 [LayoutBuilder]。
///
/// 与 [WindowClassX.windowClass] 二选一:
/// 前者适合页面局部重排;本组件适合"整块换布局"的场景
/// (约束驱动,不依赖 MediaQuery,在桌面窗口上同样可靠)。
class WindowClassBuilder extends StatelessWidget {
  const WindowClassBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, WindowClass windowClass) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          builder(context, windowClassFromWidth(constraints.maxWidth)),
    );
  }
}

/// 超宽窗口时限制内容行宽并居中,避免列表/表单行被拉满整屏。
class CenteredMaxWidth extends StatelessWidget {
  const CenteredMaxWidth({super.key, this.maxWidth = 720, required this.child});

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
