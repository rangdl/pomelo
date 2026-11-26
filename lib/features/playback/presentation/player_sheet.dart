import 'package:flutter/material.dart';

import 'player_screen.dart';

/// 以「从底部滑入、可下滑关闭」的全屏层打开播放页。
///
/// 用全屏 [PageRoute] 而非 modal bottom sheet：sheet 的默认高度约束在部分
/// 设备/版本上无法真正撑满全屏（会露出底层页面）。这里用全屏路由 + 自绘
/// 滑入动画，并叠加一个下滑手势用于关闭，行为更接近音乐 App 的播放页。
Future<void> showPlayerSheet(BuildContext context) {
  // 必须用根 Navigator：底部导航/标题栏属于外层 StatefulShell 壳，普通
  // Navigator.of(context) 会把播放页 push 到壳的子 Navigator 里，只覆盖中间
  // 内容区（顶部 AppBar 与底部导航栏露在外面）。根 Navigator 才能全屏覆盖。
  return Navigator.of(
    context,
    rootNavigator: true,
  ).push<void>(_PlayerPageRoute());
}

class _PlayerPageRoute extends PageRoute<void> {
  _PlayerPageRoute();

  @override
  // 半透明路由：下滑关闭时顶部能透出下层页面，而不是一片黑。
  bool get opaque => false;

  @override
  Color? get barrierColor => Colors.black.withValues(alpha: 0.28);

  @override
  String? get barrierLabel => null;

  @override
  bool get barrierDismissible => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 320);

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _PlayerSheetBody(animation: animation);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 从底部滑入。
    final slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
    return SlideTransition(position: slide, child: child);
  }
}

class _PlayerSheetBody extends StatefulWidget {
  const _PlayerSheetBody({required this.animation});

  final Animation<double> animation;

  @override
  State<_PlayerSheetBody> createState() => _PlayerSheetBodyState();
}

class _PlayerSheetBodyState extends State<_PlayerSheetBody> {
  // 下滑关闭：记录拖拽位移，超过阈值则 pop。
  double _dragDy = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (d) {
        if (d.delta.dy > 0 && _dragDy >= 0) {
          setState(() => _dragDy += d.delta.dy);
        }
      },
      onVerticalDragEnd: (d) {
        final shouldClose = _dragDy > 120 || (d.primaryVelocity ?? 0) > 700;
        if (shouldClose) {
          Navigator.of(context).maybePop();
        } else {
          setState(() => _dragDy = 0);
        }
      },
      child: Transform.translate(
        offset: Offset(0, _dragDy.clamp(0, double.infinity)),
        // 全屏播放页：铺满整页，顶部左右不留圆角。
        child: const PlayerScreen(),
      ),
    );
  }
}
