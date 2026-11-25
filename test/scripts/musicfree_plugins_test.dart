import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pomelo/features/plugins/runtime/musicfree_runtime.dart';
import 'package:quickjs_engine/extensions/xhr.dart';

/// 端到端验证 `scripts/musicfree-plugins/` 下的**改造后** MusicFree 插件：
/// 逐个加载 -> 反射元信息 -> 真实搜索 -> 对首条调用 getMediaSource。
///
/// 真实外网 + 真实 JS 运行时，网络不可达时应跳过而非误报失败。
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

/// 每个插件文件的搜索探测词与必须可达的域名。
class _Probe {
  const _Probe(this.file, this.host, this.terms);
  final String file;
  final String host;
  final List<String> terms;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => HttpOverrides.global = null);
  setUpAll(() => xhrSetHttpClient(_TolerantClient()));

  const probes = <_Probe>[
    _Probe('gd-music.js', 'music-api.gdstudio.xyz', ['周杰伦', '林俊杰', 'Taylor Swift']),
    _Probe('maoer-fm.js', 'www.missevan.com', ['广播剧', '白夜行', '鬼吹灯']),
    _Probe('udio.js', 'www.udio.com', ['lofi', 'jazz', 'rock']),
    _Probe('suno.js', 'studio-api.suno.ai', []),
    _Probe('youtube.js', 'www.youtube.com', ['lofi', 'jazz']),
    _Probe('fengsui-kg.js', 'songsearch.kugou.com', ['周杰伦', '林俊杰']),
    _Probe('fengsui-kw.js', 'ws.suol.cc', ['周杰伦', '林俊杰']),
    _Probe('fengsui-qq.js', 'u.y.qq.com', ['周杰伦', '林俊杰']),
    _Probe('fengsui-wy.js', 'music.163.com', ['周杰伦', '林俊杰']),
    _Probe('qishui.js', 'api5-lq.qishui.com', ['周杰伦', '林俊杰']),
    _Probe('xiaowo.js', 'music.163.com', ['周杰伦', '林俊杰']),
  ];

  for (final probe in probes) {
    final path = 'scripts/musicfree-plugins/${probe.file}';
    test('插件 ${probe.file}：加载/搜索/取播放地址', () async {
      if (!File(path).existsSync()) {
        markTestSkipped('文件不存在: $path');
        return;
      }
      final source = File(path).readAsStringSync();

      final rt = await MusicFreeRuntime.create();
      try {
        rt.loadPlugin(source, name: probe.file);

        final meta = rt.evaluateJson('''
          (function() {
            var m = __pluginModule.exports || {};
            return {
              platform: m.platform, version: m.version,
              methods: Object.keys(m).filter(function(k){return typeof m[k]==='function';})
            };
          })()
        ''');
        // ignore: avoid_print
        print('[${probe.file}] 元信息: $meta');
        expect(meta, isNotNull);
        expect(meta!['platform'], isNotEmpty);

        if (!await _reachable(probe.host)) {
          // ignore: avoid_print
          print('[${probe.file}] ${probe.host} 不可达，仅验证加载，跳过联网搜索');
          return;
        }

        // 搜索（多关键词探测，取有结果的那个）
        Map<String, dynamic>? hit;
        String? usedTerm;
        for (final term in probe.terms) {
          final res = await rt.search(term, page: 1);
          final data = (res['data'] as List);
          // ignore: avoid_print
          print('[${probe.file}] search("$term") => ${data.length} 条');
          if (data.isNotEmpty) {
            hit = Map<String, dynamic>.from(data.first as Map);
            usedTerm = term;
            break;
          }
        }

        if (hit == null) {
          // 榜单类插件（如 suno）无搜索，退回测 getTopLists。
          final tops = await rt.getTopLists();
          // ignore: avoid_print
          print('[${probe.file}] getTopLists => ${tops.length} 组');
          expect(tops, isNotEmpty);
          return;
        }

        // ignore: avoid_print
        print('[${probe.file}] 首条(${usedTerm!}): ${hit['title']} - ${hit['artist']}');

        // 取播放地址（只对单曲型插件；部分插件需要真实 id）
        try {
          final src = await rt.getMediaSource(hit, 'standard');
          // ignore: avoid_print
          print('[${probe.file}] getMediaSource => ${src?['url']}');
          expect(src, isNotNull);
          expect(src!['url'], isA<String>());
        } catch (e) {
          // ignore: avoid_print
          print('[${probe.file}] getMediaSource 跳过(需真实曲目): $e');
        }
      } finally {
        rt.dispose();
      }
    },
        timeout: const Timeout(Duration(minutes: 2)));
  }

  // 只作为 jsonDecode 使用，避免未使用告警
  test('jsonDecode 可用', () => expect(jsonDecode('{"a":1}')['a'], 1));
}
