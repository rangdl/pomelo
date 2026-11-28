import 'package:flutter_test/flutter_test.dart';
import 'package:pomelo/features/plugins/domain/fallback_chain.dart';
import 'package:pomelo/features/plugins/domain/plugin_record.dart';

void main() {
  test('默认链永远存在且排在最前', () {
    const chains = FallbackChains({'kg': ['a'], 'kw': ['b']});
    expect(chains.keys, [kDefaultChainKey, 'kg', 'kw']);
    expect(chains.keys.first, kDefaultChainKey);
  });

  test('未配置的音源回落到默认链', () {
    const chains = FallbackChains({
      kDefaultChainKey: ['a', 'b'],
      'kg': ['b'],
    });
    expect(chains.chainFor('mg'), ['a', 'b']);
    expect(chains.chainFor('kg'), ['b']);
  });

  test('清空某条链等于删除，默认链清空后保留空列表', () {
    const chains = FallbackChains({kDefaultChainKey: ['a'], 'kg': ['b']});
    final cleared = chains.withChain('kg', const []);
    expect(cleared.hasKey('kg'), isFalse);
    final clearedDefault = chains.withChain(kDefaultChainKey, const []);
    expect(clearedDefault.hasKey(kDefaultChainKey), isTrue);
    expect(clearedDefault.chainFor('xx'), isEmpty);
  });

  test('新增与删除链', () {
    const empty = FallbackChains({kDefaultChainKey: []});
    final added = empty.addKey('自定义源');
    expect(added.hasKey('自定义源'), isTrue);
    // 重复添加不覆盖已有顺序。
    final again = added.setChainDummy();
    expect(again.hasKey('自定义源'), isTrue);
    final removed = again.removeKey('自定义源');
    expect(removed.hasKey('自定义源'), isFalse);
    // 默认链不可删除。
    expect(removed.removeKey(kDefaultChainKey).hasKey(kDefaultChainKey), isTrue);
  });

  test('加入/移出插件不重复', () {
    const chains = FallbackChains({kDefaultChainKey: []});
    final one = chains.addPlugin(kDefaultChainKey, 'a');
    final two = one.addPlugin(kDefaultChainKey, 'a');
    expect(two.chainFor(kDefaultChainKey), ['a']);
    final three = two.addPlugin(kDefaultChainKey, 'b');
    expect(three.chainFor(kDefaultChainKey), ['a', 'b']);
    expect(
      three.removePlugin(kDefaultChainKey, 'a').chainFor(kDefaultChainKey),
      ['b'],
    );
  });

  test('JSON 往返保留所有链', () {
    const chains = FallbackChains({kDefaultChainKey: ['a'], 'kg': ['b', 'c']});
    final restored = FallbackChains(chains.toJson().cast<String, List<String>>());
    expect(restored.chainFor('kg'), ['b', 'c']);
  });

  test('新插件默认不参与兜底取链', () {
    final fresh = PluginRecord(
      id: 'fresh',
      name: 'fresh',
      platform: 'fresh',
      version: '1.0.0',
      source: '',
    );
    expect(fresh.allowFallback, isFalse);
    // 老数据缺字段时同样按关闭处理。
    final legacy = PluginRecord.fromJson({'id': 'old'});
    expect(legacy.allowFallback, isFalse);
  });

  test('类型只剩 musicfree 与 lx，旧的 official 按 id 归类', () {
    expect(PluginOrigin.values.map((o) => o.label), ['MusicFree', 'LX']);
    final legacy = PluginRecord.fromJson({
      'id': 'lx:某脚本',
      'origin': 'official',
    });
    expect(legacy.origin, PluginOrigin.lx);
    final mf = PluginRecord.fromJson({'id': '某插件', 'origin': 'official'});
    expect(mf.origin, PluginOrigin.musicfree);
  });
}

extension on FallbackChains {
  /// 模拟重复 addKey：内部走 hasKey 判定，重复时原样返回。
  FallbackChains setChainDummy() => addKey('自定义源');
}
