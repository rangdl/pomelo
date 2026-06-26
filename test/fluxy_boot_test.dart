// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pomelo/modules/music_lx/model/lx_metadata_engine.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // await tester.pumpWidget(const MyApp());

    // // Verify that our counter starts at 0.
    // expect(find.text('0'), findsOneWidget);
    // expect(find.text('1'), findsNothing);

    // // Tap the '+' icon and trigger a frame.
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();

    // // Verify that our counter has incremented.
    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsOneWidget);
    final item = jsonDecode(
      """{"name":"兰亭序","singer":"吴紫涵","album":"情动心弦（1）","albumId":"003U8q1Q4YNmwZ","duration":254,"source":"tx","musicId":"003soNj642HaUC","img":"https://y.gtimg.cn/music/photo_new/T002R500x500M000003U8q1Q4YNmwZ.jpg","types":[{"type":"128k","size":"3.89MB"},{"type":"320k","size":"9.71MB"},{"type":"flac","size":"25.01MB"}],"songmid":"003soNj642HaUC","albumMid":"003U8q1Q4YNmwZ","strMediaMid":"003rxjsu3Vh267"}""",
    );
    final a1 = item.map((key, value) => MapEntry(key.toString(), value));
    print(a1);
    final a2 = Map<String, dynamic>.from(item);
    print(a2);
    final a = PomeloTrackObjectMeta.fromJson(
      // Map<String, dynamic>.from(item),
      a2,
    ).toTrack(
      sourceId: 'lx-test',
      sourceName: '测试',
    );
    print(a);
  });
}
