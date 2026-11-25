import 'package:flutter/material.dart';

import '../ui/tokens.dart';

/// 分组列表的 section 标题(如"数据""偏好"),13sp 次要色。
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppText.sectionHeader,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
