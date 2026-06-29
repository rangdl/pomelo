import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/models/database/database_provider.dart';
import 'package:pomelo/core/models/metadata/track.dart';

/// 播放记录条目
class PlayHistoryEntry {
  final Track track;
  final DateTime playedAt;

  const PlayHistoryEntry({required this.track, required this.playedAt});
}

/// 播放记录 Provider（最近播放，去重）
///
/// 返回去重后的最近播放记录列表，按最后播放时间倒序。
/// 使用 autoDispose，通过 invalidate 手动刷新。
final playHistoryProvider =
    FutureProvider.autoDispose<List<PlayHistoryEntry>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final entities = await db.getRecentPlayed(limit: 100);
  return entities.map((e) {
    Track track;
    try {
      final json = jsonDecode(e.trackJson) as Map<String, dynamic>;
      track = Track.fromJson(json);
    } catch (_) {
      track = Track(id: e.trackId, title: e.title);
    }
    return PlayHistoryEntry(track: track, playedAt: e.playedAt);
  }).toList();
});
