import 'package:flutter/material.dart';

import '../ui/duration_fmt.dart';
import '../ui/tokens.dart';
import 'cover_image.dart';

/// 从曲目 Map 中取封面 URL(各插件字段不统一,按常见 key 依次尝试)。
String trackArtwork(Map<String, dynamic> item) =>
    '${item['artwork'] ?? item['coverImgUrl'] ?? item['coverImg'] ?? item['cover'] ?? item['picUrl'] ?? ''}';

/// 歌曲列表行:40×40 封面 + 标题 + 歌手。点击即播放,不带 chevron。
///
/// 全应用歌曲列表(搜索/收藏/历史/榜单)的唯一行组件;
/// 设置类行用 [SettingsItem],两者不要混用。
class TrackTile extends StatelessWidget {
  const TrackTile({
    super.key,
    required this.item,
    this.trailing,
    this.onTap,
    this.isPlaying = false,
  });

  final Map<String, dynamic> item;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// 是否正在播放：标题高亮 + 封面角标，便于在一长串列表里找回当前曲。
  final bool isPlaying;

  /// 行高基准:封面边长。
  static const double coverSize = 40;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final artwork = trackArtwork(item);
    final duration = _durationText();
    final artist = '${item['artist'] ?? ''}';
    final subtitle = [
      if (artist.isNotEmpty) artist,
      if (duration.isNotEmpty) duration,
    ].join(' · ');

    return ListTile(
      selected: isPlaying,
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: AppRadius.badgeBorder,
        child: SizedBox(
          width: coverSize,
          height: coverSize,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CoverImage(url: artwork, decodeWidth: coverSize, iconSize: 20),
              if (isPlaying)
                const ColoredBox(
                  color: Colors.black45,
                  child: Icon(
                    Icons.graphic_eq_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
      title: Text(
        '${item['title'] ?? '未知'}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: AppText.rowTitle,
          color: isPlaying ? scheme.primary : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: AppText.rowSubtitle,
          color: scheme.onSurfaceVariant,
        ),
      ),
      trailing: trailing,
    );
  }

  String _durationText() {
    final raw = item['duration'];
    final seconds = raw is int ? raw : int.tryParse('${raw ?? ''}') ?? 0;
    if (seconds <= 0) return '';
    return formatDuration(Duration(seconds: seconds));
  }
}
