
import 'package:pomelo/modules/music/model/track.dart';

/// 合并后的曲目展示模型
///
/// 合并相同 id 的曲目，记录所有来源供 UI 展示。
class MergedTrack {
  /// 主 Track（第一次出现的条目）
  final Track primary;

  /// 该曲目出现的所有来源
  final List<({String id, String name, String? libraryId, String? libraryName})> sources;

  /// 来源数 > 1 表示多平台都有
  bool get hasMultipleSources => sources.length > 1;

  /// 展示用来源文本
  String get displaySources => sources.map((s) => s.name).join(' / ');

  const MergedTrack({required this.primary, required this.sources});
}

/// 将 Track 列表按 id 去重合并，返回 [MergedTrack] 列表
List<MergedTrack> mergeTracks(Iterable<Track> tracks) {
  final map = <String, MergedTrack>{};
  for (final track in tracks) {
    final existing = map[track.id];
    if (existing != null) {
      // 已有，补充来源（去重）
      final hasSource = existing.sources.any((s) => s.id == track.source?.id);
      if (!hasSource) {
        map[track.id] = MergedTrack(
          primary: existing.primary,
          sources: [...existing.sources, if (track.source != null) track.source!],
        );
      }
    } else {
      map[track.id] = MergedTrack(
        primary: track,
        sources: [if (track.source != null) track.source!],
      );
    }
  }
  return map.values.toList();
}
