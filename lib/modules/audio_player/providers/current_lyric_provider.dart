import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/modules/audio_player/module_providers.dart';
import 'package:pomelo/ui/player/lyric_parser.dart';
import 'package:pomelo/ui/player/lyric_view.dart';

/// 当前歌词行文本 Provider
///
/// 监听当前播放曲目的位置流，实时输出对应的歌词行文本。
/// 当曲目无歌词或无活跃曲目时输出 null。
/// 用于将歌词同步到系统媒体控制（audio_service / SMTC）的 artist 展示位置。
///
/// 复用 [lyricProvider] 的缓存结果，避免与 UI 歌词渲染重复请求歌词。
final currentLyricLineProvider = StreamProvider.autoDispose<String?>((
  ref,
) async* {
  final track = ref.watch(audioPlayerProvider.select((s) => s.activeTrack));
  if (track == null) {
    yield null;
    return;
  }

  // 本地曲目无在线歌词
  if (track.src == null) {
    yield null;
    return;
  }

  // 复用 lyricProvider 的缓存，避免重复请求歌词
  final lyricText = await ref.watch(lyricProvider(track).future);
  if (lyricText == null || lyricText.isEmpty) {
    yield null;
    return;
  }

  // 解析歌词
  final lines = LyricParser.parse(lyricText);
  if (lines.isEmpty) {
    yield null;
    return;
  }

  // 监听位置流，输出当前歌词行
  final audioPlayer = ref.read(audioPlayerProvider.notifier).audioPlayer;
  String? lastLine;

  await for (final position in audioPlayer.positionStream) {
    final index = LyricParser.findCurrentIndex(lines, position);
    final line = index >= 0 ? lines[index].text : null;

    // 去重：仅在歌词行变化时输出
    if (line != lastLine) {
      lastLine = line;
      yield line;
    }
  }
});
