import 'package:flutter_test/flutter_test.dart';
import 'package:pomelo/features/playback/data/lrc_parser.dart';

void main() {
  test('解析主歌词并保留原有行为', () {
    final lines = LrcParser.parse('''
[ti:标题]
[00:01.00]第一句
[00:05.50][00:09.00]重复句
''');
    expect(lines.length, 3);
    expect(lines[0].text, '第一句');
    expect(lines[0].time, const Duration(seconds: 1));
    expect(lines[1].time, const Duration(seconds: 5, milliseconds: 500));
    expect(lines[1].text, '重复句');
    expect(lines[1].translation, isNull);
  });

  test('翻译按时间戳对齐，对不上的行保持无翻译', () {
    final lines = LrcParser.parse(
      '[00:01.00]你好\n[00:05.00]再见\n[00:09.00]只有原文',
      translation: '[00:01.00]Hello\n[00:05.10]Bye',
    );
    expect(lines[0].translation, 'Hello');
    // 100ms 误差在容差内，视为同一句。
    expect(lines[1].translation, 'Bye');
    expect(lines[2].translation, isNull);
  });

  test('翻译时间明显偏离时不误配', () {
    final lines = LrcParser.parse(
      '[00:01.00]第一句\n[00:20.00]第二句',
      translation: '[00:01.00]One',
    );
    expect(lines[0].translation, 'One');
    expect(lines[1].translation, isNull);
  });

  test('没有翻译时原样返回', () {
    final lines = LrcParser.parse('[00:01.00]独白');
    expect(lines.single.translation, isNull);
    expect(LrcParser.parse('[00:01.00]独白', translation: '  ').single.translation,
        isNull);
  });

  test('activeIndex 定位当前行', () {
    final lines = LrcParser.parse('[00:01.00]a\n[00:05.00]b');
    expect(LrcParser.activeIndex(lines, const Duration(seconds: 3)), 0);
    expect(LrcParser.activeIndex(lines, const Duration(seconds: 6)), 1);
    expect(LrcParser.activeIndex(const [], Duration.zero), -1);
  });
}
