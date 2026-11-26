import 'package:flutter/material.dart';

import '../../features/playback/data/media_proxy_server.dart';
import '../ui/tokens.dart';

/// 从曲目 Map 中取封面 URL(各插件字段不统一,按常见 key 依次尝试)。
String trackArtwork(Map<String, dynamic> item) =>
    '${item['artwork'] ?? item['coverImgUrl'] ?? item['coverImg'] ?? item['cover'] ?? item['picUrl'] ?? ''}';

/// 歌曲列表行:40×40 封面 + 标题 + 歌手。点击即播放,不带 chevron。
///
/// 全应用歌曲列表(搜索/收藏/历史/榜单)的唯一行组件;
/// 设置类行用 [SettingsItem],两者不要混用。
class TrackTile extends StatelessWidget {
  const TrackTile({super.key, required this.item, this.trailing, this.onTap});

  final Map<String, dynamic> item;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// 行高基准:封面边长。
  static const double coverSize = 40;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final artwork = trackArtwork(item);
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: AppRadius.badgeBorder,
        child: SizedBox(
          width: coverSize,
          height: coverSize,
          child: artwork.isEmpty
              ? _placeholder(scheme)
              : Image.network(
                  cachedArtworkUrl(artwork),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _placeholder(scheme),
                ),
        ),
      ),
      title: Text(
        '${item['title'] ?? '未知'}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: AppText.rowTitle,
        ),
      ),
      subtitle: Text(
        '${item['artist'] ?? ''}',
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

  Widget _placeholder(ColorScheme scheme) {
    return ColoredBox(
      color: scheme.surfaceContainerHigh,
      child: Icon(
        Icons.music_note_rounded,
        size: 20,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}
