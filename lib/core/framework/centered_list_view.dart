/// 居中限宽可滚动列表
///
/// 滚动区域占满全宽（滚动条位于屏幕最右侧），
/// 内容按 [maxWidth] 居中显示，避免在宽屏上内容过宽、
/// 同时避免滚动条出现在屏幕中间。
///
/// 当可用宽度小于 [maxWidth] 时（如手机端），
/// [Center] + [ConstrainedBox] 不会产生约束，行为与普通 [ListView] 一致。
library;

import 'package:flutter/widgets.dart';

class CenteredListView extends StatelessWidget {
  /// 内容最大宽度，超过此宽度时居中显示
  final double maxWidth;

  /// 列表外边距（作用于全宽滚动区域）
  final EdgeInsets padding;

  /// 列表子项
  final List<Widget> children;

  const CenteredListView({
    super.key,
    required this.maxWidth,
    required this.children,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: padding,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}
