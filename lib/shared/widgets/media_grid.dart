import 'package:flutter/material.dart';

import '../../features/playback/data/media_proxy_server.dart';
import '../layout/window_class.dart';
import '../ui/tokens.dart';

/// 媒体网格列数:随窗口分级变化,禁止写死列数。
int mediaGridColumns(WindowClass windowClass) => switch (windowClass) {
  WindowClass.compact => 3,
  WindowClass.medium => 4,
  WindowClass.expanded => 6,
};

/// 配合 [WindowClassBuilder] 使用:
/// `GridView(gridDelegate: mediaGridDelegate(windowClass))`。
SliverGridDelegate mediaGridDelegate(
  WindowClass windowClass, {
  double childAspectRatio = 0.72,
}) {
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: mediaGridColumns(windowClass),
    mainAxisSpacing: AppSpacing.gridGap,
    crossAxisSpacing: AppSpacing.gridGap,
    childAspectRatio: childAspectRatio,
  );
}

/// 媒体封面卡:封面(圆角 12)+ 下方 13sp 标题 / 11sp 副信息;
/// [badge] 以深色半透明胶囊压在封面左下角(评分/品质类信息)。
class PosterCard extends StatelessWidget {
  const PosterCard({
    super.key,
    required this.title,
    this.subtitle,
    this.coverUrl,
    this.aspectRatio = 1,
    this.badge,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? coverUrl;

  /// 音乐 1:1,影视 2:3。
  final double aspectRatio;
  final String? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.cardBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: aspectRatio,
            child: ClipRRect(
              borderRadius: AppRadius.cardBorder,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (coverUrl != null)
                    Image.network(
                      cachedArtworkUrl(coverUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholder(scheme),
                    )
                  else
                    _placeholder(scheme),
                  if (badge != null)
                    Positioned(left: 6, bottom: 6, child: _Badge(badge!)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs + 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: AppText.cardTitle,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppText.compact,
                color: scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder(ColorScheme scheme) {
    return Container(
      color: scheme.surfaceContainerHigh,
      alignment: Alignment.center,
      child: Icon(
        Icons.music_note_rounded,
        size: 32,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: AppRadius.badgeBorder,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: AppText.compact, color: Colors.white),
      ),
    );
  }
}
