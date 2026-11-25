import 'package:flutter/material.dart';

import '../ui/tokens.dart';

/// 分组列表行:34×34 图标徽章 + 15sp 标题 + 12.5sp 副标题 + 尾部 chevron。
///
/// [danger] 为 true 时图标徽章与标题走 error 色(重置/删除类操作)。
class SettingsItem extends StatelessWidget {
  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// 不传且 [onTap] 非空时,默认显示 chevron。
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final badgeBg = danger
        ? scheme.errorContainer
        : AppIconBadge.background(brightness);
    final badgeFg = danger ? scheme.error : AppIconBadge.foreground(brightness);

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: AppIconBadge.size,
        height: AppIconBadge.size,
        decoration: BoxDecoration(
          color: badgeBg,
          borderRadius: AppRadius.badgeBorder,
        ),
        child: Icon(icon, size: AppIconBadge.glyphSize, color: badgeFg),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: AppText.rowTitle,
          color: danger ? scheme.error : null,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppText.rowSubtitle,
                color: scheme.onSurfaceVariant,
              ),
            ),
      trailing:
          trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onSurfaceVariant,
                )
              : null),
    );
  }
}
