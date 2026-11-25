import 'package:flutter/material.dart';

/// 单选弹层的一个选项。
class SelectionOption<T> {
  const SelectionOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// 底部弹层单选选择器(全应用单选场景的统一入口)。
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
}) {
  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
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
          RadioGroup<T>(
            groupValue: current,
            onChanged: (value) => Navigator.pop(context, value),
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
          ),
        ],
      ),
    ),
  );
}
