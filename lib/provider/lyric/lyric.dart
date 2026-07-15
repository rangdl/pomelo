import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/models/metadata/metadata.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/ui/player/lyric_parser.dart';

/// 歌词 Provider
///
/// 根据当前播放曲目获取 LRC 歌词文本。
/// 优先使用 [Track.lyrics] 中已缓存的歌词（缓存曲目时同步获取并持久化）；
/// 未缓存时通过 [MusicServer.getLyric] 在线获取。
/// 非在线曲目或服务不支持歌词时返回 null。
final lyricProvider = FutureProvider.autoDispose.family<String?, Track>((
  ref,
  song,
) async {
  // 优先使用已缓存的歌词
  if (song.lyrics != null && song.lyrics!.isNotEmpty) {
    return song.lyrics;
  }
  if (song.src == null) return null;
  final service = await ref.watch(musicServerProvider(song.source.id).future);
  if (!ref.mounted) return null;
  if (service == null) return null;
  try {
    return await service.getLyric(song);
  } catch (_) {
    return null;
  }
});
// 歌词解析 Provider
///
/// 根据当前播放曲目解析 LRC 歌词文本。
/// 非在线曲目或服务不支持歌词时返回空列表。
final lyricLinesProvider = FutureProvider.autoDispose
    .family<List<LyricLine>, Track>((ref, song) async {
      final lyricText = await ref.watch(lyricProvider(song).future);
      if (!ref.mounted) return [];
      if (lyricText == null || lyricText.isEmpty) {
        return [];
      }
      return LyricParser.parse(lyricText);
    });
