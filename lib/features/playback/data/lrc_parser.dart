/// LRC 歌词解析。
///
/// 支持：
///   - 标准行时间标签 `[mm:ss.xxx]` / `[mm:ss.xx]` / `[mm:ss]`
///   - 一行多时间标签（同一句重复出现）
///   - 增强逐字歌词 `<mm:ss.xxx>`（汽水 KRC 转换后的形态），解析时按行起点
///     归入该行，逐字片段合并成纯文本（逐字高亮留待后续增强）
///   - 元信息行 `[ti:]` `[ar:]` 等忽略
class LyricLine {
  const LyricLine(this.time, this.text);

  final Duration time;
  final String text;
}

class LrcParser {
  static List<LyricLine> parse(String raw) {
    if (raw.trim().isEmpty) return const [];
    final lines = <LyricLine>[];
    final timeTag = RegExp(r'\[(\d+):(\d+)(?:[.:](\d+))?\]');
    // 增强逐字标签，行首可能是 [mm:ss.xxx]<...><...>
    final wordTag = RegExp(r'<\d+:\d+(?:[.:]\d+)?>');

    for (final rawLine in raw.split('\n')) {
      final line = rawLine.trimRight();
      if (line.isEmpty) continue;
      final matches = timeTag.allMatches(line);
      if (matches.isEmpty) continue; // 元信息或纯文本行

      // 取所有行时间标签，剩余部分是文本
      final text = line.replaceAll(timeTag, '').replaceAll(wordTag, '').trim();
      for (final m in matches) {
        final min = int.tryParse(m.group(1) ?? '0') ?? 0;
        final sec = int.tryParse(m.group(2) ?? '0') ?? 0;
        final fracRaw = m.group(3) ?? '0';
        // 处理 1~3 位小数
        final millis = int.tryParse(fracRaw.padRight(3, '0').substring(0, 3)) ?? 0;
        final time = Duration(minutes: min, seconds: sec, milliseconds: millis);
        lines.add(LyricLine(time, text));
      }
    }
    lines.sort((a, b) => a.time.compareTo(b.time));
    return lines;
  }

  /// 给定播放位置，返回当前应高亮的行索引（无歌词返回 -1）。
  static int activeIndex(List<LyricLine> lines, Duration position) {
    if (lines.isEmpty) return -1;
    for (var i = lines.length - 1; i >= 0; i--) {
      if (position >= lines[i].time) return i;
    }
    return 0;
  }
}
