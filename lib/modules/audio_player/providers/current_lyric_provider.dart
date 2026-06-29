import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/log.dart';
import 'package:pomelo/core/models/metadata/track.dart';
import 'package:pomelo/modules/audio_player/module_providers.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/ui/player/lyric_parser.dart';

/// 当前歌词行文本 Provider
///
/// 监听当前播放曲目的位置流，实时输出对应的歌词行文本。
/// 当曲目无歌词或无活跃曲目时输出 null。
/// 用于将歌词同步到系统媒体控制（audio_service / SMTC）的 artist 展示位置。
final currentLyricLineProvider = StreamProvider.autoDispose<String?>((ref) async* {
  final state = ref.watch(audioPlayerProvider.select((s) => s.activeTrack));
  final track = state;
  if (track == null) {
    yield null;
    return;
  }

  // 本地曲目无在线歌词
  if (track.src == null) {
    yield null;
    return;
  }

  // 获取音乐服务
  await ref.watch(musicServersProvider.future);
  final service =
      ref.watch(musicServerBySourceProvider(track.source?.id ?? ''));
  if (service == null) {
    yield null;
    return;
  }

  // 获取歌词文本
  String? lyricText;
  try {
    lyricText = await service.getLyric(track);
  } catch (e) {
    log.warning('Lyric', '获取歌词失败: $e');
    yield null;
    return;
  }

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
