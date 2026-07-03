import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/models/metadata/metadata.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/ui/player/lyric_parser.dart';

/// 歌词 Provider
///
/// 根据当前播放曲目获取 LRC 歌词文本。
/// 非在线曲目或服务不支持歌词时返回 null。
final lyricProvider = FutureProvider.autoDispose.family<String?, Track>((
  ref,
  song,
) async {
  if (song.src == null) return null;
  // await ref.watch(musicServersProvider.future);
  final service = await ref.watch(
    musicServerByProvider(song.source?.id ?? '').future,
  );
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
      if (lyricText == null || lyricText.isEmpty) {
        return [];
      }
      return LyricParser.parse(lyricText);
    });
