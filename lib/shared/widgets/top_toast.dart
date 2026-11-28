import 'dart:async';

import 'package:flutter/material.dart';

import '../ui/tokens.dart';

/// 顶部提示浮层。
///
/// 页面底部常驻播放胶囊，SnackBar 无论 floating 还是 fixed 都会被它挡住或
/// 顶得很难看；这里统一改用屏幕顶部的轻量浮层：不挤占布局、不遮播放器。
///
/// 全局只有一个实例（挂在 MaterialApp.builder 上），后一条提示直接替换前一条。
class TopToastHost extends StatefulWidget {
  const TopToastHost({super.key, required this.child});

  final Widget child;

  @override
  State<TopToastHost> createState() => _TopToastHostState();
}

/// 当前挂载的提示浮层（全局唯一）。
_TopToastHostState? _current;

void _registerTopToast(_TopToastHostState state) => _current = state;

void _unregisterTopToast(_TopToastHostState state) {
  if (identical(_current, state)) _current = null;
}

class _TopToastHostState extends State<TopToastHost> {
  static const Duration _visible = Duration(seconds: 3);

  String? _message;
  bool _isError = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _registerTopToast(this);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _unregisterTopToast(this);
    super.dispose();
  }

  /// 显示一条提示；新提示立即覆盖旧提示并重置计时。
  void show(String message, {bool isError = false}) {
    if (!mounted) return;
    _timer?.cancel();
    setState(() {
      _message = message;
      _isError = isError;
    });
    _timer = Timer(_visible, () {
      if (!mounted) return;
      setState(() => _message = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final message = _message;
    final topInset = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        widget.child,
        if (message != null)
          Positioned(
            top: topInset + AppSpacing.sm,
            left: AppSpacing.page,
            right: AppSpacing.page,
            child: SafeArea(
              bottom: false,
              child: IgnorePointer(
                child: Material(
                  color: Colors.transparent,
                  child: AnimatedOpacity(
                    opacity: 1,
                    duration: const Duration(milliseconds: 160),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: _isError
                            ? scheme.errorContainer
                            : scheme.inverseSurface,
                        borderRadius: AppRadius.cardBorder,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isError
                                ? Icons.error_outline_rounded
                                : Icons.info_outline_rounded,
                            size: 18,
                            color: _isError
                                ? scheme.onErrorContainer
                                : scheme.onInverseSurface,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              message,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: AppText.rowSubtitle,
                                color: _isError
                                    ? scheme.onErrorContainer
                                    : scheme.onInverseSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 顶部提示句柄：`TopToast.show('已重置')`。
class TopToast {
  const TopToast._();

  /// 当前挂载的浮层（由 [TopToastHost] 在 initState 注册）。
  static _TopToastHostState? get _host => _current;

  static void show(String message) => _host?.show(message);

  static void error(String message) => _host?.show(message, isError: true);

  /// 用 ScaffoldMessenger 的调用点统一改走这里，避免底部提示被播放胶囊遮挡。
  static void showOn(BuildContext context, String message) => show(message);
}
