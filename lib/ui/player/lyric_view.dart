import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/modules/music/model/track.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'lyric_parser.dart';

/// 歌词 Provider
///
/// 根据当前播放曲目获取 LRC 歌词文本。
/// 非在线曲目或服务不支持歌词时返回 null。
final lyricProvider =
    FutureProvider.autoDispose.family<String?, Track>((ref, song) async {
  if (song.src == null) return null;
  await ref.watch(musicServersProvider.future);
  final service = ref.watch(musicServerBySourceProvider(song.source?.id ?? ''));
  if (service == null) return null;
  try {
    return await service.getLyric(song);
  } catch (_) {
    return null;
  }
});

/// 歌词滚动展示组件
///
/// 根据当前播放进度自动滚动到对应歌词行，当前行高亮居中。
/// 点击歌词行可跳转播放进度（需提供 [onSeek]）。
class LyricView extends HookWidget {
  final List<LyricLine> lines;
  final Duration position;
  final double fontSize;
  final void Function(Duration)? onSeek;

  static const double _itemHeight = 52.0;

  const LyricView({
    super.key,
    required this.lines,
    required this.position,
    this.fontSize = 16,
    this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();
    final colorScheme = Theme.of(context).colorScheme;
    final currentIndex = LyricParser.findCurrentIndex(lines, position);

    useEffect(() {
      if (currentIndex < 0) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!controller.hasClients) return;
        final viewport = controller.position.viewportDimension;
        final target =
            (currentIndex * _itemHeight) - (viewport - _itemHeight) / 2;
        controller.animateTo(
          target.clamp(0.0, controller.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
      return null;
    }, [currentIndex]);

    if (lines.isEmpty) {
      return Center(
        child: Text(
          '暂无歌词',
          style: TextStyle(color: colorScheme.mutedForeground, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      controller: controller,
      itemExtent: _itemHeight,
      padding: const EdgeInsets.symmetric(vertical: 80),
      itemCount: lines.length,
      itemBuilder: (context, index) {
        final isActive = index == currentIndex;
        final text = lines[index].text;
        return GestureDetector(
          onTap: onSeek != null ? () => onSeek!(lines[index].time) : null,
          child: Container(
            height: _itemHeight,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              text.isEmpty ? '♪' : text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isActive ? fontSize + 2 : fontSize,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive
                    ? colorScheme.primary
                    : colorScheme.mutedForeground,
              ),
            ),
          ),
        );
      },
    );
  }
}
