import 'dart:async';

import 'package:flutter/material.dart';

/// 单行文字：放得下时静态显示，放不下时缓慢滚动（跑马灯）。
///
/// 播放条 / 播放页的「歌名 - 歌手」用它：长标题不会被省略号截断，也不会
/// 额外占一行。滚动到末尾后回到起点，停 [pause] 再继续。
class MarqueeText extends StatefulWidget {
  const MarqueeText(
    this.text, {
    super.key,
    this.style,
    this.velocity = 26,
    this.pause = const Duration(milliseconds: 1200),
  });

  final String text;
  final TextStyle? style;

  /// 滚动速度（逻辑像素 / 秒）。
  final double velocity;

  /// 每轮滚完回到起点后的停顿。
  final Duration pause;

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> {
  final ScrollController _controller = ScrollController();
  bool _scrolling = false;

  @override
  void initState() {
    super.initState();
    _scheduleEnsure();
  }

  @override
  void didUpdateWidget(covariant MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      // 换歌后从头开始，避免停在上一首的偏移上。
      if (_controller.hasClients) _controller.jumpTo(0);
      _scheduleEnsure();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 等本次布局完成后再判断是否溢出；build 里也会调用一次以覆盖窗口缩放。
  void _scheduleEnsure() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureScrolling());
  }

  Future<void> _ensureScrolling() async {
    if (!mounted || _scrolling || !_controller.hasClients) return;
    if (_controller.position.maxScrollExtent <= 0) return;
    _scrolling = true;
    try {
      while (mounted && _controller.hasClients) {
        await Future<void>.delayed(widget.pause);
        if (!mounted || !_controller.hasClients) break;
        final max = _controller.position.maxScrollExtent;
        if (max <= 0) break;
        final duration = Duration(
          milliseconds: (max / widget.velocity * 1000).round(),
        );
        await _controller.animateTo(
          max,
          duration: duration,
          curve: Curves.linear,
        );
        if (!mounted || !_controller.hasClients) break;
        _controller.jumpTo(0);
      }
    } catch (_) {
      // 布局变化 / 页面销毁时动画被打断，忽略即可。
    } finally {
      _scrolling = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style.merge(widget.style);
    _scheduleEnsure();
    return SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(widget.text, maxLines: 1, softWrap: false, style: style),
    );
  }
}
