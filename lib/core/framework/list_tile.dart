/// shadcn_flutter 风格的列表项组件
///
/// 替代 Material 的 `ListTile`，使用 `Row` + `Column` 构建，
/// 完全基于 shadcn_flutter 的设计语言。
///
/// 用法:
/// ```dart
/// // 基础用法（在 Card 内）
/// Card(
///   child: ListTile(
///     leading: const Icon(Icons.music_note),
///     title: const Text('歌曲名'),
///     subtitle: const Text('艺术家'),
///     trailing: const Icon(Icons.chevron_right),
///     onTap: () {},
///   ),
/// )
///
/// // 仅标题 + 尾部组件
/// Card(
///   child: ListTile(
///     leading: const Icon(Icons.brightness_6),
///     title: const Text('主题模式'),
///     trailing: Select<String>(...),
///   ),
/// )
///
/// // 仅标题 + 副标题（无 leading/trailing）
/// Card(
///   child: ListTile(
///     title: const Text('示例1'),
///     subtitle: const Text('描述文字'),
///     trailing: PrimaryButton(...),
///   ),
/// )
/// ```
library;

import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 列表项组件 — Material ListTile 的 shadcn_flutter 替代方案
///
/// 布局结构: `[leading] [Gap] Expanded(title, subtitle) [trailing]`
class ListTile extends StatelessWidget {
  /// 左侧组件（图标、徽章等）
  final Widget? leading;

  /// 主标题
  final Widget title;

  /// 副标题（显示在标题下方）
  final Widget? subtitle;

  /// 右侧组件（箭头、按钮、选择器等）
  final Widget? trailing;

  /// 点击回调
  final VoidCallback? onTap;

  /// 内边距，默认 `EdgeInsets.symmetric(horizontal: 16, vertical: 12)`
  final EdgeInsetsGeometry padding;

  /// 标题与副标题之间的间距
  final double subtitleGap;

  const ListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.subtitleGap = 2,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const Gap(12),
          ],
          Expanded(
            child: subtitle != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      SizedBox(height: subtitleGap),
                      DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.mutedForeground,
                        ),
                        child: subtitle!,
                      ),
                    ],
                  )
                : title,
          ),
          if (trailing != null) ...[
            const Gap(8),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: onTap, child: content),
      );
    }

    return content;
  }
}
