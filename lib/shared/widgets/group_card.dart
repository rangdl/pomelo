import 'package:flutter/material.dart';

import '../ui/tokens.dart';

/// 分组卡片:一组行项目装在同一张圆角卡片里,行间以极细分隔线相连
/// (iOS 分组列表风格)。无阴影,分层只靠卡片色与背景差。
class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.children, this.dividerIndent = 66});

  final List<Widget> children;

  /// 分隔线左缩进,与行内容文字对齐(图标块 34 + 行内 padding 32)。
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: AppRadius.cardBorder,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, child) in children.indexed) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: dividerIndent,
                color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
              ),
            child,
          ],
        ],
      ),
    );
  }
}
