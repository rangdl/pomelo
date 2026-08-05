import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 统一的空状态 / 错误状态占位
///
/// 三种用法：
/// - 纯文字：`EmptyHint(text: '暂无排行榜')`
/// - 图标 + 文字：`EmptyHint(text: '暂无收藏歌曲', icon: PomeloIcons.heart)`
/// - 错误态：`EmptyHint.error(error)` —— 统一「加载失败: xxx」文案
///
/// 全部使用 `colorScheme.mutedForeground`，避免各页面重复手写 Center + Column。
class EmptyHint extends StatelessWidget {
  final String text;

  /// 可选的顶部图标。不传则只显示文字。
  final IconData? icon;

  /// 图标尺寸
  final double iconSize;

  const EmptyHint({
    super.key,
    required this.text,
    this.icon,
    this.iconSize = 48,
  });

  /// 错误态便捷构造：统一「加载失败: $error」文案
  EmptyHint.error(Object error, {super.key, this.icon, this.iconSize = 48})
    : text = '加载失败: $error';

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.mutedForeground;
    final label = Text(text, style: TextStyle(color: color));

    if (icon == null) return Center(child: label);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: color),
          const Gap(12),
          label,
        ],
      ),
    );
  }
}
