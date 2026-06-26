import 'package:pomelo/modules/music/model/song.dart';

/// 合并后的歌曲展示模型
///
/// 合并相同 id 的歌曲，记录所有来源供 UI 展示。
class MergedSong {
  /// 主 Song（第一次出现的条目）
  final Song primary;

  /// 该歌曲出现的所有来源
  final List<({String id, String name, String? libraryId, String? libraryName})> sources;

  /// 来源数 > 1 表示多平台都有
  bool get hasMultipleSources => sources.length > 1;

  /// 展示用来源文本
  String get displaySources => sources.map((s) => s.name).join(' / ');

  const MergedSong({required this.primary, required this.sources});
}

/// 将 Song 列表按 id 去重合并，返回 [MergedSong] 列表
List<MergedSong> mergeSongs(Iterable<Song> songs) {
  final map = <String, MergedSong>{};
  for (final song in songs) {
    final existing = map[song.id];
    if (existing != null) {
      // 已有，补充来源（去重）
      final hasSource = existing.sources.any((s) => s.id == song.source.id);
      if (!hasSource) {
        map[song.id] = MergedSong(
          primary: existing.primary,
          sources: [...existing.sources, song.source],
        );
      }
    } else {
      map[song.id] = MergedSong(primary: song, sources: [song.source]);
    }
  }
  return map.values.toList();
}
