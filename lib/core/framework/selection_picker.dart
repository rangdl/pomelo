/// 响应式下拉选择器
///
/// 桌面端使用 [showDropdown] + [DropdownMenu]，
/// 移动端使用 [openSheet] 从底部弹出。
///
/// 适用于所有"下拉选择按钮"场景：平台选择、库选择、排序选择等。
///
/// 用法:
/// ```dart
/// showSelectionPicker<String>(
///   context: context,
///   title: '选择音乐平台',
///   options: [
///     SelectionOption(value: null, label: '全部来源', selected: sourceId == null),
///     ...services.map((s) => SelectionOption(
///       value: s.sourceId,
///       label: s.sourceName,
///       selected: s.sourceId == sourceId,
///     )),
///   ],
///   onSelected: (value) => ref.read(provider.notifier).select(value),
/// );
/// ```
library;

import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'list_tile.dart';
import 'package:pomelo/core/rx.dart';

/// 选项数据
class SelectionOption<T> {
  /// 选项值
  final T value;

  /// 显示文本
  final String label;

  /// 是否选中
  final bool selected;

  /// 左侧图标
  final IconData? icon;

  const SelectionOption({
    required this.value,
    required this.label,
    this.selected = false,
    this.icon,
  });
}

/// 显示响应式选择器
///
/// 桌面端：[showDropdown] + [DropdownMenu]（标题 + 分隔线 + 菜单项）。
/// 移动端：[openSheet] 从底部弹出（标题 + ListTile 列表）。
///
/// 选中后自动关闭面板并通过 [onSelected] 回调返回选中值。
///
/// 关闭方式说明：
/// - 桌面端 dropdown：`MenuButton` 默认 `autoClose: true`，按下后自动关闭。
/// - 移动端 sheet：在 `_SelectionSheetContent` 内调用 `closeOverlay(context)` 关闭。
///
/// [anchorAlignment] 与 [alignment] 控制桌面端下拉菜单与按钮的对齐方式，
/// 默认左对齐（按钮左下角 ↔ 菜单左上角）。
void showSelectionPicker<T>({
  required BuildContext context,
  required String title,
  required List<SelectionOption<T>> options,
  required ValueChanged<T> onSelected,
  AlignmentGeometry anchorAlignment = Alignment.bottomLeft,
  AlignmentGeometry alignment = Alignment.topLeft,
}) {
  Rx.action(
    context,
    mobile: () => openSheet(
      context: context,
      position: OverlayPosition.bottom,
      draggable: true,
      builder: (_) => _SelectionSheetContent(
        title: title,
        options: options,
        onSelected: onSelected,
      ),
    ),
    tablet: () => showDropdown(
      context: context,
      anchorAlignment: anchorAlignment,
      alignment: alignment,
      builder: (_) => DropdownMenu(
        children: _buildMenuItems(title, options, onSelected),
      ),
    ),
  );
}

List<MenuItem> _buildMenuItems<T>(
  String title,
  List<SelectionOption<T>> options,
  ValueChanged<T> onSelected,
) {
  return [
    MenuLabel(child: Text(title)),
    const MenuDivider(),
    ...options.map((opt) {
      return MenuButton(
        leading: opt.icon != null ? Icon(opt.icon, size: 18) : null,
        trailing: opt.selected ? const Icon(Icons.check, size: 16) : null,
        onPressed: (_) => onSelected(opt.value),
        child: Text(opt.label),
      );
    }),
  ];
}

/// 移动端底部 Sheet 内容
class _SelectionSheetContent<T> extends StatelessWidget {
  final String title;
  final List<SelectionOption<T>> options;
  final ValueChanged<T> onSelected;

  const _SelectionSheetContent({
    required this.title,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          // 选项列表
          for (int i = 0; i < options.length; i++) ...[
            ListTile(
              leading: options[i].icon != null
                  ? Icon(options[i].icon, size: 20)
                  : null,
              title: Text(
                options[i].label,
                style: TextStyle(
                  fontWeight: options[i].selected ? FontWeight.w600 : null,
                  color: options[i].selected ? colorScheme.primary : null,
                ),
              ),
              trailing: options[i].selected
                  ? Icon(Icons.check, size: 18, color: colorScheme.primary)
                  : null,
              onTap: () {
                closeOverlay(context);
                onSelected(options[i].value);
              },
            ),
            if (i < options.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}
