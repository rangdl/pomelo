import 'package:flutter/material.dart';

import '../layout/window_class.dart';
import '../ui/tokens.dart';

/// 全应用统一的弹层入口：移动端从底部弹出（带拖拽条，单手可达），
/// 平板/桌面以居中对话框呈现。
///
/// - [body] 内容（接收弹层自己的 context，便于内部 `Navigator.pop(ctx, value)`）；
/// - [actions] 用 builder 形式给出，移动端与桌面端都能正确关闭；
/// - [isScrollControlled] 内容可能超出半屏时置 true（如长列表）。
Future<T?> showAppModal<T>({
  required BuildContext context,
  required String title,
  WidgetBuilder? body,
  List<Widget> Function(BuildContext context)? actions,
  bool isScrollControlled = false,
}) {
  final compact = context.windowClass == WindowClass.compact;

  if (!compact) {
    return showDialog<T>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: body?.call(ctx),
        actions: actions?.call(ctx),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    // 弹层要盖住外壳的迷你播放胶囊与底部导航，必须走根 Navigator。
    useRootNavigator: true,
    isScrollControlled: isScrollControlled,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppText.heading,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (body != null) Flexible(child: body(ctx)),
            if (actions != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (final (i, action) in actions(ctx).indexed) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.sm),
                      action,
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

/// 二次确认弹层（破坏性操作走 error 色）。返回是否确认。
Future<bool> showAppConfirm({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = '确定',
  String cancelLabel = '取消',
  bool danger = false,
}) async {
  final confirmed = await showAppModal<bool>(
    context: context,
    title: title,
    body: (ctx) => Text(message),
    actions: (ctx) {
      final scheme = Theme.of(ctx).colorScheme;
      return [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          style: danger
              ? FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                )
              : null,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ];
    },
  );
  return confirmed ?? false;
}
