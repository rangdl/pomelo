import 'package:flutter_test/flutter_test.dart';
import 'package:pomelo/features/plugins/domain/plugin_record.dart';
import 'package:pomelo/features/plugins/domain/source_keys.dart';

void main() {
  group('inferSourceKeyFromPlatform', () {
    test('中文平台名', () {
      expect(inferSourceKeyFromPlatform('风誰·酷狗'), 'kg');
      expect(inferSourceKeyFromPlatform('风誰·酷我'), 'kw');
      expect(inferSourceKeyFromPlatform('风誰·QQ音乐'), 'tx');
      expect(inferSourceKeyFromPlatform('网易云音乐'), 'wy');
      expect(inferSourceKeyFromPlatform('咪咕音乐'), 'mg');
      expect(inferSourceKeyFromPlatform('汽水音乐'), 'qs');
    });

    test('洛雪别名', () {
      expect(inferSourceKeyFromPlatform('小蜗'), 'kw');
      expect(inferSourceKeyFromPlatform('小秋'), 'tx');
      expect(inferSourceKeyFromPlatform('小芸'), 'wy');
      expect(inferSourceKeyFromPlatform('小枸'), 'kg');
      expect(inferSourceKeyFromPlatform('小蜜'), 'mg');
    });

    test('英文名', () {
      expect(inferSourceKeyFromPlatform('kugou'), 'kg');
      expect(inferSourceKeyFromPlatform('netease'), 'wy');
      expect(inferSourceKeyFromPlatform('migu'), 'mg');
      expect(inferSourceKeyFromPlatform('kuwo'), 'kw');
    });

    test('2 字母 key 需整词匹配，不能被英文单词误命中', () {
      // "kugou" 里含 "kg" 但不是独立词，应判成 kg 而不是靠子串。
      expect(inferSourceKeyFromPlatform('kg'), 'kg');
      expect(inferSourceKeyFromPlatform('kg 音源'), 'kg');
      // 独立平台推断不出。
      expect(inferSourceKeyFromPlatform('猫耳FM'), isNull);
      expect(inferSourceKeyFromPlatform('YouTube'), isNull);
      expect(inferSourceKeyFromPlatform(''), isNull);
    });

    test('重叠别名优先匹配更长的', () {
      // 「网易云」应优先于「网易」，两者都指向 wy，结果一致即可。
      expect(inferSourceKeyFromPlatform('网易云'), 'wy');
      expect(inferSourceKeyFromPlatform('qq音乐'), 'tx');
    });
  });

  group('normalizeSourceKeys', () {
    test('MusicFree 的平台显示名被规范化成标准 key', () {
      final keys = normalizeSourceKeys(
        declared: const ['风誰·酷狗'],
        platform: '风誰·酷狗',
        isLxCompat: false,
      );
      expect(keys, ['kg']);
    });

    test('LX 脚本自报的 key 原样保留', () {
      final keys = normalizeSourceKeys(
        declared: const ['kw', 'tx'],
        platform: 'LX: kw, tx',
        isLxCompat: true,
      );
      expect(keys, ['kw', 'tx']);
    });

    test('推断不出时保留原值', () {
      final keys = normalizeSourceKeys(
        declared: const ['猫耳FM'],
        platform: '猫耳FM',
        isLxCompat: false,
      );
      expect(keys, ['猫耳FM']);
    });
  });

  group('effectiveSourceKeys', () {
    PluginRecord make({List<String>? user, List<String> keys = const ['风誰·酷狗']}) {
      return PluginRecord(
        id: 'fengsui-kg',
        name: '风誰·酷狗',
        platform: '风誰·酷狗',
        version: '0.4.9',
        source: '',
        sourceKeys: keys,
        userSourceKeys: user,
      );
    }

    test('没有手动指定时走规范化推断', () {
      expect(effectiveSourceKeys(make()), ['kg']);
    });

    test('用户手动指定优先', () {
      expect(effectiveSourceKeys(make(user: const ['mg'])), ['mg']);
    });

    test('userSourceKeys 能 JSON 往返', () {
      final r = make(user: const ['kg', 'mg']);
      final restored = PluginRecord.fromJson(r.toJson());
      expect(restored.userSourceKeys, ['kg', 'mg']);
      expect(restored.origin, PluginOrigin.musicfree);
    });
  });
}
