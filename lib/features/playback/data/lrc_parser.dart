/// LRC 歌词解析。
///
/// 支持：
///   - 标准行时间标签 `[mm:ss.xxx]` / `[mm:ss.xx]` / `[mm:ss]`
///   - 一行多时间标签（同一句重复出现）
///   - 增强逐字歌词 `<mm:ss.xxx>`（汽水 KRC 转换后的形态），解析时按行起点
///     归入该行，逐字片段合并成纯文本（逐字高亮留待后续增强）
///   - 元信息行 `[ti:]` `[ar:]` 等忽略
///   - 翻译歌词：单独一段 LRC，按时间戳对齐到主歌词行
class LyricLine {
  const LyricLine(this.time, this.text, {this.translation});

  final Duration time;
  final String text;

  /// 该行的翻译；没有翻译或对不上时间戳时为 null。
  final String? translation;

  LyricLine withTranslation(String? value) =>
      LyricLine(time, text, translation: value);
}

class LrcParser {
  static List<LyricLine> parse(String raw, {String? translation}) {
    final lines = parseLines(raw);
    if (lines.isEmpty || translation == null || translation.trim().isEmpty) {
      return lines;
    }
    return attachTranslation(lines, translation);
  }

  /// 只解析主歌词（忽略翻译）。
  static List<LyricLine> parseLines(String raw) {
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
        lines.add(LyricLine(_timeOf(m), text));
      }
    }
    lines.sort((a, b) => a.time.compareTo(b.time));
    return lines;
  }

  static Duration _timeOf(RegExpMatch m) {
    final min = int.tryParse(m.group(1) ?? '0') ?? 0;
    final sec = int.tryParse(m.group(2) ?? '0') ?? 0;
    final fracRaw = m.group(3) ?? '0';
    // 处理 1~3 位小数
    final millis = int.tryParse(fracRaw.padRight(3, '0').substring(0, 3)) ?? 0;
    return Duration(minutes: min, seconds: sec, milliseconds: millis);
  }

  /// 把翻译按时间戳对齐到主歌词行。
  ///
  /// 采用双指针近似匹配：翻译行时间与主歌词行相差在 [tolerance] 内即视为同一句。
  /// 对不上的主歌词行保持无翻译（与 MusicFree 置空的做法一致，只是容差更宽）。
  static List<LyricLine> attachTranslation(
    List<LyricLine> lines,
    String translation, {
    Duration tolerance = const Duration(milliseconds: 300),
  }) {
    final transLines = parseLines(translation);
    if (transLines.isEmpty) return lines;

    final merged = <LyricLine>[];
    var p2 = 0;
    for (final line in lines) {
      // 跳过明显早于当前主歌词行的翻译行。
      while (p2 < transLines.length - 1 &&
          transLines[p2].time + tolerance < line.time) {
        p2++;
      }
      final diff = transLines[p2].time - line.time;
      final abs = diff.isNegative ? -diff : diff;
      final text = transLines[p2].text;
      merged.add(
        abs <= tolerance && text.isNotEmpty ? line.withTranslation(text) : line,
      );
    }
    return merged;
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
