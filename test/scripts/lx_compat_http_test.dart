import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pomelo/features/plugins/runtime/lx_crypto.dart';
import 'package:pomelo/features/plugins/runtime/pomelo_plugin_runtime.dart';

/// 回归测试：LX `lx.request` 的契约必须与原生一致。
///
/// - 对象请求体要序列化成 JSON，并自动补 Content-Type；
/// - 响应体是 JSON 时 `resp.body` 必须已解析为对象（ikun 等脚本直接读 body.code）；
/// - `currentScriptInfo.rawScript` 必须是脚本原文（野花用它做源码校验）。
class _EchoServer {
  late HttpServer _server;
  final received = <String>[];

  int get port => _server.port;

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server.listen((req) async {
      final body = await utf8.decoder.bind(req).join();
      received.add(body);
      req.response.headers.contentType = ContentType.json;
      req.response.write(
        jsonEncode({
          'code': 200,
          'data': {'url': 'https://example.test/ok', 'body': body},
        }),
      );
      await req.response.close();
    });
  }

  Future<void> stop() => _server.close(force: true);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // flutter_test 默认把所有 HTTP 变成 400，这里放开对本地回环的真实请求。
  HttpOverrides.global = null;

  test('lx.request 解析 JSON 响应并序列化对象请求体', () async {
    final server = _EchoServer();
    await server.start();
    addTearDown(server.stop);

    final script =
        '''
const {request, on, send, utils, currentScriptInfo} = globalThis.lx;
const sourceMd5 = utils.crypto.md5(
  utils.buffer.from(currentScriptInfo.rawScript, 'utf8'), 'hex');

on('request', ({source, action, info}) => {
  if (action !== 'musicUrl') return Promise.reject(new Error('unsupported'));
  return new Promise((resolve, reject) => {
    request('http://127.0.0.1:${server.port}/url', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: {id: info.musicInfo.songmid, rawMd5: sourceMd5},
    }, (err, resp) => {
      if (err) return reject(err);
      // 未解析 JSON 时这里会是 undefined，脚本会直接失败。
      if (resp.body.code !== 200) {
        return reject(new Error('bad body: ' + JSON.stringify(resp.body)));
      }
      resolve({url: resp.body.data.url});
    });
  });
});

send('inited', {
  status: true,
  sources: {kw: {name: 'kw', type: 'music', actions: ['musicUrl'], qualitys: ['128k']}}
});
''';

    final rt = await PomeloPluginRuntime.create();
    addTearDown(rt.dispose);
    await rt.loadPlugin(script, name: 'compat');
    expect(rt.initialized, isTrue, reason: rt.initError ?? '');

    final source = await rt.getMediaSource(
      {'id': 'abc', 'title': '歌名', 'artist': '歌手', '_pluginId': 'p'},
      'high',
      sourceKey: 'kw',
    );
    expect(source?['url'], 'https://example.test/ok');

    final sent = jsonDecode(server.received.single) as Map<String, dynamic>;
    expect(sent['id'], 'abc');
    expect(sent['rawMd5'], LxCrypto.md5Hex(script));
  });
}
