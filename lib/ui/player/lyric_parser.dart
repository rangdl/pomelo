
/// LRC 歌词行
class LyricLine {
  final Duration time;
  final String text;

  const LyricLine({required this.time, required this.text});

  @override
  String toString() => 'LyricLine(${time.inMilliseconds}ms, $text)';
}

/// LRC 歌词解析器
///
/// 解析标准 LRC 格式歌词文本，支持：
/// - 多时间标签行 `[00:01.00][00:30.00]歌词`
/// - 元数据行 `[ti:标题][ar:艺术家][al:专辑]`（自动忽略）
/// - 2 位或 3 位毫秒 `[mm:ss.xx]` / `[mm:ss.xxx]`
class LyricParser {
  LyricParser._();

  static final _timeRegex = RegExp(r'\[(\d{1,2}):(\d{2})[.:](\d{2,3})\]');

  /// 解析 LRC 文本为歌词行列表（按时间升序）
  static List<LyricLine> parse(String lrc) {
    final lines = lrc.split('\n');
    final result = <LyricLine>[];
    for (final line in lines) {
      final matches = _timeRegex.allMatches(line);
      if (matches.isEmpty) continue;
      // 去除所有时间标签后的文本
      final text = line.replaceAll(_timeRegex, '').trim();
      for (final match in matches) {
        final min = int.parse(match.group(1)!);
        final sec = int.parse(match.group(2)!);
        final msStr = match.group(3)!;
        final ms = int.parse(msStr);
        // 2 位毫秒按百分秒处理
        final msValue = msStr.length == 2 ? ms * 10 : ms;
        result.add(LyricLine(
          time: Duration(minutes: min, seconds: sec, milliseconds: msValue),
          text: text,
        ));
      }
    }
    result.sort((a, b) => a.time.compareTo(b.time));
    return result;
  }

  /// 根据当前播放进度查找当前歌词行索引
  ///
  /// 返回最后一行 time <= position 的索引，无匹配返回 -1。
  static int findCurrentIndex(List<LyricLine> lines, Duration position) {
    if (lines.isEmpty) return -1;
    final posMs = position.inMilliseconds;
    var result = -1;
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].time.inMilliseconds <= posMs) {
        result = i;
      } else {
        break;
      }
    }
    return result;
  }
}
