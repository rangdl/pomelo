import 'package:flutter_test/flutter_test.dart';
import 'package:pomelo/features/playback/data/lrc_parser.dart';

void main() {
  test('解析标准时间标签并排序', () {
    final lines = LrcParser.parse('[00:10.50]第二句\n[00:05.00]第一句\n');
    expect(lines.length, 2);
    expect(lines.first.text, '第一句');
    expect(lines.first.time, const Duration(seconds: 5));
    expect(lines.last.time, const Duration(seconds: 10, milliseconds: 500));
  });

  test('一行多个时间标签会展开成多行', () {
    final lines = LrcParser.parse('[00:01.00][00:03.00]副歌');
    expect(lines.map((e) => e.text), ['副歌', '副歌']);
    expect(lines.last.time, const Duration(seconds: 3));
  });

  test('元信息与纯文本行被忽略', () {
    final lines = LrcParser.parse('[ti:标题]\n[ar:歌手]\n没有时间标签');
    expect(lines, isEmpty);
  });

  test('增强逐字标签被剥离，只保留文本', () {
    final lines = LrcParser.parse('[00:02.00]<00:02.00>你<00:02.50>好');
    expect(lines.single.text, '你好');
  });

  test('1~3 位小数都能换算成毫秒', () {
    expect(
      LrcParser.parse('[00:01.5]a').single.time,
      const Duration(seconds: 1, milliseconds: 500),
    );
    expect(
      LrcParser.parse('[00:01.25]a').single.time,
      const Duration(seconds: 1, milliseconds: 250),
    );
    expect(
      LrcParser.parse('[00:01.125]a').single.time,
      const Duration(seconds: 1, milliseconds: 125),
    );
  });

  test('activeIndex 定位当前行', () {
    final lines = LrcParser.parse('[00:00.00]a\n[00:10.00]b\n[00:20.00]c');
    expect(LrcParser.activeIndex(lines, const Duration(seconds: 12)), 1);
    expect(LrcParser.activeIndex(lines, const Duration(seconds: 20)), 2);
    expect(LrcParser.activeIndex(const [], Duration.zero), -1);
  });
}
