import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pomelo/features/plugins/runtime/pomelo_plugin_runtime.dart';
import 'package:quickjs_engine/extensions/xhr.dart';

/// 端到端跑通 `scripts/` 下的两个**真实**音源脚本：
///   1. xinghai-music-source-qs-v1.3.0.js  —— MusicFree 插件（搜索 + 取播放地址）
///   2. xinghai-music-sourcev2.3.19.js     —— LX UserApi 脚本（musicUrl 解析）
///
/// 这两个脚本依赖真实外网接口，因此标记为集成测试；网络不可达时应跳过
/// 而不是误报失败。
String _read(String name) => File('scripts/$name').readAsStringSync();

Future<bool> _reachable(String host) async {
  try {
    final socket = await Socket.connect(host, 443,
        timeout: const Duration(seconds: 6));
    socket.destroy();
    return true;
  } catch (_) {
    return false;
  }
}

/// 真实脚本初始化后会自己起后台任务（域名连通性自检 / 检查更新）。
/// 这些任务的连接错误（尤其备用域名在测试网络下不可解析）会在
/// quickjs 的 XHR 定时器回调里抛出并逃逸成测试失败。包一层容错客户端，
/// 把网络异常转成 503 响应，交回脚本逻辑自行处理，避免误报。
class _TolerantClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      return await _inner.send(request);
    } on SocketException {
      return http.StreamedResponse(const Stream.empty(), 503);
    } on http.ClientException {
      return http.StreamedResponse(const Stream.empty(), 503);
    }
  }
}

void main() {
  // 运行时通过 rootBundle 加载 fetch polyfill，需先初始化 binding。
  TestWidgetsFlutterBinding.ensureInitialized();
  // flutter_test 默认用 mock HttpClient（任何请求都返回 400），
  // 这里要打真实外网，必须清掉 HttpOverrides。
  setUpAll(() => HttpOverrides.global = null);
  // 脚本自带的后台探测任务不应让用例失败：注入容错 HTTP 客户端。
  setUpAll(() => xhrSetHttpClient(_TolerantClient()));

  // 真实网络 + 真实 JS 运行时，给足超时。
  const longTimeout = Timeout(Duration(minutes: 2));

  group('真实脚本 1：星海音乐源-汽水 (MusicFree 插件 qs v1.3.0)', () {
    late PomeloPluginRuntime rt;

    setUpAll(() async {
      rt = await PomeloPluginRuntime.create();
      await rt.loadPlugin(
        _read('xinghai-music-source-qs-v1.3.0.js'),
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
      expect(meta['methods'], contains('getLyric'));
    });

    test('搜索 -> getMediaSource 取到播放直链', () async {
      if (!await _reachable('yy1.zddyr.top')) {
        markTestSkipped('外网不可达，跳过');
        return;
      }
      final res = await rt.search('周杰伦', type: 'music');
      final list = res['data'] as List;
      expect(list, isNotEmpty, reason: '搜索应返回结果');

      final first = Map<String, dynamic>.from(list.first as Map);
      // ignore: avoid_print
      print('qs 搜索首条: ${first['title']} - ${first['artist']}');

      final src = await rt.getMediaSource(first, '320k');
      expect(src, isNotNull, reason: '应返回播放地址');
      expect(src!['url'], isA<String>());
      expect(src['url'], startsWith('http'));
      // ignore: avoid_print
      print('qs 播放直链: ${src['url']}');
    }, timeout: longTimeout);
  });

  group('真实脚本 2：星海音乐源 (LX UserApi v2.3.19)', () {
    late PomeloPluginRuntime rt;

    setUpAll(() async {
      rt = await PomeloPluginRuntime.create();
      await rt.loadPlugin(
        _read('xinghai-music-sourcev2.3.19.js'),
        name: 'XingHaiMusicSource',
      );
    });

    tearDownAll(() => rt.dispose());

    test('脚本初始化并声明音源', () async {
      final ok = await rt.waitForInit();
      expect(ok, isTrue, reason: rt.initError ?? '');
      expect(rt.sources.keys, containsAll(['wy', 'tx', 'kw', 'kg', 'mg', 'qs']));
      // ignore: avoid_print
      print('LX 声明音源: ${rt.sources.keys.join(", ")}');
    }, timeout: longTimeout);

    test('取播放地址（汽水 qs，端到端走后端令牌 + 取链）', () async {
      if (!await _reachable('yy1.zddyr.top')) {
        markTestSkipped('外网不可达，跳过');
        return;
      }
      final src = await rt.getMediaSource(
        {
          'id': '7568318335513184283',
          'songmid': '7568318335513184283',
          'name': '周杰伦新歌',
          'singer': '李晨阳',
          'albumName': '周杰伦新歌',
          'interval': '03:27',
        },
        'higher',
        sourceKey: 'qs',
      );
      expect(src, isNotNull);
      final url = src!['url'];
      expect(url, startsWith('http'));
      // ignore: avoid_print
      print('LX 播放直链: $url');
    }, timeout: longTimeout);
  });
}
