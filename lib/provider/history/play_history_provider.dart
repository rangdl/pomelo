import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/provider/database/database_provider.dart';
import 'package:pomelo/core/models/metadata/track.dart';

/// 播放记录条目
class PlayHistoryEntry {
  final Track track;
  final DateTime playedAt;
  final int playCount;

  const PlayHistoryEntry({
    required this.track,
    required this.playedAt,
    required this.playCount,
  });
}

/// 播放记录 Provider（最近播放）
///
/// 返回最近播放记录列表，按最后播放时间倒序。
/// v2 起每个曲目仅一行（upsert 语义），[PlayHistoryEntry.playCount] 记录累计播放次数。
/// 使用 autoDispose，通过 invalidate 手动刷新。
final playHistoryProvider = FutureProvider.autoDispose<List<PlayHistoryEntry>>((
  ref,
) async {
  final db = ref.watch(databaseProvider);
  final entities = await db.getRecentPlayed(limit: 100);
  return entities.map((e) {
    Track track;
    try {
      final json = jsonDecode(e.trackJson) as Map<String, dynamic>;
      track = Track.fromJson(json);
    } catch (_) {
      track = Track(
        id: e.trackId,
        title: e.title,
        source: (
          id: e.sourceId,
          name: e.sourceName,
          libraryId: null,
          libraryName: null,
        ),
      );
    }
    return PlayHistoryEntry(
      track: track,
      playedAt: e.playedAt,
      playCount: e.playCount,
    );
  }).toList();
});
