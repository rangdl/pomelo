import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pomelo/features/plugins/runtime/lx_runtime.dart';
import 'package:pomelo/features/plugins/runtime/musicfree_runtime.dart';

/// 真机集成测试：在 Android 设备上用真实 JS 运行时（APK 内打包的 quickjs 原生库）
/// + 真实网络，端到端跑通 `scripts/` 下的两个真实音源脚本：
///   1. xinghai-music-source-qs-v1.3.0.js  —— MusicFree 插件（搜索 + 取播放地址）
///   2. xinghai-music-sourcev2.3.19.js     —— LX UserApi 脚本（musicUrl 解析）
///
/// 脚本随 pubspec assets 打包，设备上通过 rootBundle 读取（设备无源码目录）。
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const longTimeout = Timeout(Duration(minutes: 3));

  Future<String> loadScript(String assetPath) => rootBundle.loadString(assetPath);

  group('真机 · 星海音乐源-汽水 (MusicFree 插件 qs v1.3.0)', () {
    late MusicFreeRuntime rt;

    setUpAll(() async {
      rt = await MusicFreeRuntime.create();
      rt.loadPlugin(
        await loadScript('scripts/xinghai-music-source-qs-v1.3.0.js'),
        name: 'xinghai-qs',
      );
    });

    tearDownAll(() => rt.dispose());

    test('插件加载并暴露元信息', () {
      final meta = rt.evaluateJson('''
        (function() {
          var m = __pluginModule.exports || {};
          return {
            platform: m.platform,
            version: m.version,
            methods: Object.keys(m).filter(function(k){ return typeof m[k] === 'function'; })
          };
        })()
      ''');
      expect(meta, isNotNull);
      expect(meta!['platform'], '星海音乐源-汽水');
      expect(meta['methods'], contains('search'));
      expect(meta['methods'], contains('getMediaSource'));
      // ignore: avoid_print
      print('[真机] qs 插件 platform=${meta['platform']} version=${meta['version']}');
    });

    test('搜索 -> getMediaSource 取到播放直链', () async {
      final res = await rt.search('周杰伦', type: 'music');
      final list = res['data'] as List;
      expect(list, isNotEmpty, reason: '搜索应返回结果');

      final first = Map<String, dynamic>.from(list.first as Map);
      // ignore: avoid_print
      print('[真机] qs 搜索首条: ${first['title']} - ${first['artist']}');

      final src = await rt.getMediaSource(first, '320k');
      expect(src, isNotNull, reason: '应返回播放地址');
      expect(src!['url'], isA<String>());
      expect(src['url'], startsWith('http'));
      // ignore: avoid_print
      print('[真机] qs 播放直链: ${src['url']}');
    }, timeout: longTimeout);
  });

  group('真机 · 星海音乐源 (LX UserApi v2.3.19)', () {
    late LxUserApiRuntime rt;

    setUpAll(() async {
      rt = await LxUserApiRuntime.create();
      rt.loadScript(
        await loadScript('scripts/xinghai-music-sourcev2.3.19.js'),
        id: 'xinghai-lx',
        name: 'XingHaiMusicSource',
      );
    });

    tearDownAll(() => rt.dispose());

    test('脚本初始化并声明音源', () async {
      final ok = await rt.waitForInit();
      expect(ok, isTrue, reason: rt.initError ?? '');
      expect(rt.sources.keys, containsAll(['wy', 'tx', 'kw', 'kg', 'mg', 'qs']));
      // ignore: avoid_print
      print('[真机] LX 声明音源: ${rt.sources.keys.join(", ")}');
    }, timeout: longTimeout);

    test('取播放地址（汽水 qs，端到端走后端令牌 + 取链）', () async {
      final url = await rt.resolveMusicUrl(
        source: 'qs',
        musicInfo: {
          'id': '7568318335513184283',
          'songmid': '7568318335513184283',
          'name': '周杰伦新歌',
          'singer': '李晨阳',
          'albumName': '周杰伦新歌',
          'interval': '03:27',
        },
        quality: '320k',
      );
      expect(url, startsWith('http'));
      // ignore: avoid_print
      print('[真机] LX 播放直链: $url');
    }, timeout: longTimeout);
  });
}
