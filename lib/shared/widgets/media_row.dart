import 'package:flutter/material.dart';

import '../ui/tokens.dart';
import 'track_tile.dart';
import 'cover_image.dart';

/// 歌单 / 专辑 / 歌手等「集合」类结果行:40 封面 + 标题 + 副标题 + 箭头。
///
/// 搜索页与歌手页共用,避免同一配方被复制两次。
class CollectionRow extends StatelessWidget {
  const CollectionRow({
    super.key,
    required this.item,
    required this.fallbackTitle,
    required this.onTap,
    this.placeholderIcon = Icons.queue_music_rounded,
  });

  final Map<String, dynamic> item;

  /// 缺少标题字段时的占位文案(如「歌单」/「专辑」)。
  final String fallbackTitle;
  final VoidCallback onTap;

  /// 缺少封面时的占位图标。
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final cover = trackArtwork(item);
    return ListTile(
      leading: ClipRRect(
        borderRadius: AppRadius.badgeBorder,
        child: SizedBox(
          width: 40,
          height: 40,
          child: cover.isEmpty
              ? Icon(placeholderIcon)
              : CoverImage(url: cover, decodeWidth: 40, icon: placeholderIcon),
        ),
      ),
      title: Text(
        firstText(item, const ['title', 'name'], fallbackTitle),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: AppText.rowTitle,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        firstText(item, const [
          'description',
          'desc',
          'artist',
          'artistName',
          'creator',
          'date',
          'releaseDate',
        ], ''),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: AppText.rowSubtitle),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  /// 依序取第一个非空字段,都没有时返回 [fallback]。
  static String firstText(
    Map<String, dynamic> item,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = item[key];
      if (value != null && '$value'.trim().isNotEmpty) return '$value';
    }
    return fallback;
  }
}
