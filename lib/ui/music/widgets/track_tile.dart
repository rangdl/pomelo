import 'package:flutter/widgets.dart' show Stack, Positioned;
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/models/metadata/track.dart';
import 'package:pomelo/ui/music/widgets/cover_image.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Stack, Positioned;

/// 统一的曲目列表项组件
///
/// 在所有展示曲目列表的场景复用，保证样式一致：封面图、标题、副标题（艺术家·时长）、
/// 可选序号 badge、可选 trailing 操作区、可选 onTap。
///
/// 封面统一 40px，
/// padding使用 theme.density.baseContentPadding * theme.scaling
/// 用于根据主题密度动态调整 padding，保持在不同设备上的显示效果一致。
class TrackTile extends StatelessWidget {
  final Track track;

  /// 序号（1-based）。传入后会在封面右上角叠加序号 badge。
  final int? index;

  /// 是否为当前播放曲目。true 时标题高亮。
  final bool isActive;

  /// 活跃状态指示 Widget，覆盖默认的序号 badge。
  /// 传入后当 [isActive] 为 true 时显示此 Widget（如播放队列的均衡器图标）。
  final Widget? activeLeading;

  /// trailing 操作区。通常包含 PlayPauseButton、来源文本、更多操作按钮等。
  final Widget? trailing;

  /// 点击整行的回调。
  final VoidCallback? onTap;

  /// 外层 Card 之下的额外间距（默认仅底部 4）。
  final EdgeInsets padding;

  /// 是否显示封面图。false 时仅显示序号（无封面场景）。
  final bool showCover;

  const TrackTile({
    super.key,
    required this.track,
    this.index,
    this.isActive = false,
    this.activeLeading,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.only(bottom: 4),
    this.showCover = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final coverSize = 40.0;
    final tilePadding = theme.density.baseContentPadding * theme.scaling;
    return Padding(
      padding: padding,
      child: Card(
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: _buildLeading(context, colorScheme, coverSize),
          title: Text(
            track.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isActive ? colorScheme.primary : null,
              fontWeight: isActive ? FontWeight.w600 : null,
            ),
          ),
          subtitle: Text(
            '${track.artist}  ·  ${track.formattedDuration}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: trailing,
          onTap: onTap,
          padding: EdgeInsets.all(tilePadding),
        ),
      ),
    );
  }

  Widget _buildLeading(
    BuildContext context,
    ColorScheme colorScheme,
    double coverSize,
  ) {
    // 活跃且提供了 activeLeading：完全替换（如均衡器图标）
    if (isActive && activeLeading != null) {
      return SizedBox(width: coverSize, child: activeLeading!);
    }

    if (!showCover) {
      // 无封面场景：只显示序号
      return _buildIndexOnly(colorScheme, coverSize);
    }

    // 封面图
    final cover = CoverImage(
      coverArt: track.coverArt,
      colorScheme: colorScheme,
      size: coverSize,
      borderRadius: BorderRadius.circular(6),
    );

    if (index == null) return cover;

    // 序号 + 封面并存：序号作为右上角 badge 叠加在封面上
    return SizedBox(
      width: coverSize,
      height: coverSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          cover,
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: colorScheme.background,
                border: Border.all(color: colorScheme.muted, width: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$index',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _indexColor(colorScheme),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndexOnly(ColorScheme colorScheme, double coverSize) {
    if (index == null) {
      return SizedBox(
        width: coverSize,
        height: coverSize,
        child: Icon(Icons.music_note, color: colorScheme.primary, size: 24),
      );
    }
    return Container(
      width: coverSize,
      height: coverSize,
      alignment: Alignment.center,
      child: Text(
        '$index',
        style: TextStyle(
          fontSize: 14,
          fontWeight: (index! - 1) < 3 ? FontWeight.bold : null,
          color: _indexColor(colorScheme),
        ),
      ),
    );
  }

  Color _indexColor(ColorScheme colorScheme) {
    final isTop3 = index != null && (index! - 1) < 3;
    return isTop3 ? colorScheme.primary : colorScheme.mutedForeground;
  }
}
