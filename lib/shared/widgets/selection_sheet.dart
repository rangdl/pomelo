import 'package:flutter/material.dart';

import '../layout/window_class.dart';
import '../ui/tokens.dart';
import 'adaptive_dialog.dart';

/// 单选弹层的一个选项。
class SelectionOption<T> {
  const SelectionOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// 单选选择器(全应用单选场景的统一入口)。
///
/// 移动端复用 [showModalBottomSheet] 形态（与其它弹层一致从底部弹出），
/// 桌面端以居中对话框呈现。
///
/// 用法:
/// ```dart
/// final picked = await showSelectionSheet<ThemeModeOption>(
///   context: context,
///   title: '主题模式',
///   current: mode,
///   options: [...],
/// );
/// ```
Future<T?> showSelectionSheet<T>({
  required BuildContext context,
  required String title,
  required List<SelectionOption<T>> options,
  T? current,
  String? description,
}) {
  final compact = context.windowClass == WindowClass.compact;

  Widget list(BuildContext ctx) {
    return RadioGroup<T>(
      groupValue: current,
      onChanged: (value) => Navigator.pop(ctx, value),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options)
            RadioListTile<T>(
              value: option.value,
              title: Text(option.label),
              secondary: option.icon == null ? null : Icon(option.icon),
            ),
        ],
      ),
    );
  }

  final hint = description == null
      ? null
      : Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Text(
            description,
            style: TextStyle(
              fontSize: AppText.rowSubtitle,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );

  if (!compact) {
    return showAppModal<T>(
      context: context,
      title: title,
      body: (ctx) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [?hint, list(ctx)],
        ),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    // 一级页面位于分支 Navigator 内,必须走根 Navigator,
    // 否则会被外壳浮层(迷你播放胶囊)盖住。
    useRootNavigator: true,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ?hint,
          list(ctx),
        ],
      ),
    ),
  );
}
