import 'package:flutter_test/flutter_test.dart';
import 'package:pomelo/features/plugins/runtime/pomelo_plugin_runtime.dart';
import 'package:pomelo/shared/settings/audio_quality.dart';

/// 验证宿主音质值确实原样传给插件，以及 LX 包装层的档位映射/降级。
/// 使用合成插件，不依赖外网。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const musicFreeSource = r'''
module.exports = {
  platform: 'quality-echo',
  version: '1.0.0',
  search: async function () {
    return { isEnd: true, data: [{ id: '1', title: 't', artist: 'a' }] };
  },
  getMediaSource: async function (item, quality) {
    return { url: 'https://example.com/' + quality };
  }
};
''';

  const lxSource = r'''
lx.on(lx.EVENT_NAMES.request, function (e) {
  return Promise.resolve('https://example.com/' + e.info.type);
});
lx.send(lx.EVENT_NAMES.inited, {
  sources: {
    kw: {
      name: 'kw',
      type: 'music',
      actions: ['musicUrl'],
      qualitys: ['128k', '320k', 'flac', 'flac24bit']
    }
  }
});
''';

  const lxLimitedSource = r'''
lx.on(lx.EVENT_NAMES.request, function (e) {
  return Promise.resolve('https://example.com/' + e.info.type);
});
lx.send(lx.EVENT_NAMES.inited, {
  sources: {
    kw: {
      name: 'kw',
      type: 'music',
      actions: ['musicUrl'],
      qualitys: ['320k']
    }
  }
});
''';

  test('MusicFree 插件收到 low/standard/high/super', () async {
    final rt = await PomeloPluginRuntime.create();
    try {
      await rt.loadPlugin(musicFreeSource, name: 'quality-echo.js');
      for (final q in AudioQuality.values) {
        final src = await rt.getMediaSource({'id': '1'}, q.musicFreeValue);
        expect(
          src?['url'],
          'https://example.com/${q.musicFreeValue}',
          reason: '${q.name} 应传 ${q.musicFreeValue}',
        );
      }
    } finally {
      await rt.dispose();
    }
  });

  test('LX 四档音质按 128k/320k/flac/flac24bit 映射', () async {
    final rt = await PomeloPluginRuntime.create();
    try {
      await rt.loadPlugin(lxSource, name: 'quality-lx.js');
      expect(rt.initialized, isTrue, reason: rt.initError ?? '');
      for (final q in AudioQuality.values) {
        final src = await rt.getMediaSource(
          {'id': '1'},
          q.musicFreeValue,
          sourceKey: 'kw',
        );
        expect(
          src?['url'],
          'https://example.com/${q.lxValue}',
          reason: '${q.name} 应映射为 ${q.lxValue}',
        );
      }
      // 旧值仍可用，避免已安装脚本或外部调用回归。
      final legacyHigh = await rt.getMediaSource(
        {'id': '1'},
        'higher',
        sourceKey: 'kw',
      );
      expect(legacyHigh?['url'], 'https://example.com/flac');
      final legacySuper = await rt.getMediaSource(
        {'id': '1'},
        'highest',
        sourceKey: 'kw',
      );
      expect(legacySuper?['url'], 'https://example.com/flac24bit');
    } finally {
      await rt.dispose();
    }
  });

  test('LX 缺档时按 flac24bit > flac > 320k > 128k 降级', () async {
    final rt = await PomeloPluginRuntime.create();
    try {
      await rt.loadPlugin(lxLimitedSource, name: 'quality-lx-limited.js');
      expect(rt.initialized, isTrue, reason: rt.initError ?? '');
      final src = await rt.getMediaSource(
        {'id': '1'},
        AudioQuality.lossless.musicFreeValue,
        sourceKey: 'kw',
      );
      expect(src?['url'], 'https://example.com/320k');
    } finally {
      await rt.dispose();
    }
  });
}
