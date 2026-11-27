import 'dart:convert';
import 'dart:io';

import 'package:charset/charset.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomelo/features/plugins/runtime/pomelo_plugin_runtime.dart';

/// 验证 LX 专用 HTTP 桥：二进制 raw、formData、timeout、取消，以及 zlib。
class _Captured {
  _Captured(this.path, this.contentType, this.body);

  final String path;
  final String? contentType;
  final List<int> body;
}

class _TestServer {
  late HttpServer _server;
  final captured = <_Captured>[];

  int get port => _server.port;

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server.listen((req) async {
      try {
        final body = await req.fold<List<int>>(
          <int>[],
          (all, chunk) => all..addAll(chunk),
        );
        captured.add(
          _Captured(req.uri.path, req.headers.contentType?.toString(), body),
        );
        if (req.uri.path == '/binary') {
          req.response.headers.contentType = ContentType.binary;
          req.response.add([0, 1, 2, 127, 128, 255]);
        } else if (req.uri.path == '/gbk') {
          req.response.headers.contentType =
              ContentType('text', 'plain', charset: 'gbk');
          req.response.add(gbk.encode('中文测试'));
        } else if (req.uri.path == '/gbk-plain') {
          req.response.headers.contentType = ContentType('text', 'plain');
          req.response.add(gbk.encode('中文测试'));
        } else if (req.uri.path == '/slow') {
          await Future<void>.delayed(const Duration(milliseconds: 250));
          req.response.headers.contentType = ContentType.json;
          req.response.write('{"ok":true}');
        } else {
          req.response.headers.contentType = ContentType.json;
          req.response.write(jsonEncode({'ok': true, 'path': req.uri.path}));
        }
        await req.response.close();
      } catch (_) {
        // 客户端取消后连接已关闭，忽略写回失败。
      }
    });
  }

  Future<void> stop() => _server.close(force: true);
}

String _script(int port, String body) => '''
const {request, on, send, utils} = globalThis.lx;
on('request', () => new Promise((resolve, reject) => {
$body
}));
send('inited', {
  status: true,
  sources: {kw: {name: 'kw', type: 'music', actions: ['musicUrl'], qualitys: ['128k']}}
});
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // flutter_test 默认拦截真实 HTTP，这里放开本地回环。
  HttpOverrides.global = null;

  late _TestServer server;
  late PomeloPluginRuntime rt;

  setUp(() async {
    server = _TestServer();
    await server.start();
    rt = await PomeloPluginRuntime.create();
    addTearDown(() async {
      await rt.dispose();
      await server.stop();
    });
  });

  Future<Map<String, dynamic>?> play(String body) async {
    await rt.loadPlugin(_script(server.port, body), name: 'lx-http');
    expect(rt.initialized, isTrue, reason: rt.initError ?? '');
    return rt.getMediaSource({'id': '1'}, 'high', sourceKey: 'kw');
  }

  test('二进制响应保留原始字节', () async {
    const raw = [0, 1, 2, 127, 128, 255];
    final source = await play('''
  request('http://127.0.0.1:${server.port}/binary', {}, function(err, resp) {
    if (err) return reject(err);
    resolve({url: 'https://example.com/' +
      utils.buffer.bufToString(resp.raw, 'base64') + ':' + resp.bytes});
  });
''');
    expect(source?['url'], 'https://example.com/${base64Encode(raw)}:${raw.length}');
    expect(server.captured.single.path, '/binary');
  });

  test('formData 生成 multipart 请求体', () async {
    final source = await play('''
  request('http://127.0.0.1:${server.port}/form', {
    method: 'POST',
    formData: {
      name: 'hello',
      file: {
        buffer: new Uint8Array([1, 2, 255]),
        filename: 'x.bin',
        contentType: 'application/octet-stream'
      }
    }
  }, function(err, resp) {
    if (err) return reject(err);
    resolve({url: 'https://example.com/ok'});
  });
''');
    expect(source?['url'], 'https://example.com/ok');
    final captured = server.captured.single;
    expect(captured.contentType, contains('multipart/form-data; boundary='));
    final text = utf8.decode(captured.body, allowMalformed: true);
    expect(text, contains('name="name"'));
    expect(text, contains('hello'));
    expect(text, contains('filename="x.bin"'));
    expect(captured.body, containsAllInOrder([1, 2, 255]));
  });

  test('timeout 会中断请求并回调错误', () async {
    final source = await play('''
  request('http://127.0.0.1:${server.port}/slow', {timeout: 50},
    function(err, resp) {
      resolve({url: err ? 'https://example.com/timeout' : 'https://example.com/ok'});
    });
''');
    expect(source?['url'], 'https://example.com/timeout');
  });

  test('取消后不再触发回调', () async {
    final source = await play('''
  var cancel = request('http://127.0.0.1:${server.port}/slow', {},
    function() { resolve({url: 'https://example.com/callback'}); });
  cancel();
  setTimeout(function() {
    resolve({url: 'https://example.com/cancelled'});
  }, 120);
''');
    expect(source?['url'], 'https://example.com/cancelled');
  });

  test('按 Content-Type charset 解码 GBK，未声明时 GBK 兜底', () async {
    final source = await play('''
  function get(path) {
    return new Promise(function(resolve, reject) {
      request('http://127.0.0.1:${server.port}' + path, {},
        function(err, resp) {
          if (err) return reject(err);
          resolve(resp.body);
        });
    });
  }
  Promise.all([get('/gbk'), get('/gbk-plain')]).then(function(list) {
    resolve({url: 'https://example.com/' + list.join('/')});
  }).catch(reject);
''');
    expect(source?['url'], 'https://example.com/中文测试/中文测试');
  });

  test('zlib 支持 deflate/inflate 往返与 gzip 自动识别', () async {
    final gzipB64 = base64Encode(gzip.encode(utf8.encode('hello')));
    final source = await play('''
  var z = utils.zlib;
  Promise.all([
    z.deflate(utils.buffer.from('hello', 'utf8')).then(function(b) {
      return z.inflate(b);
    }),
    z.inflate(utils.buffer.from('$gzipB64', 'base64'))
  ]).then(function(list) {
    resolve({url: 'https://example.com/' +
      utils.buffer.bufToString(list[0], 'utf8') + '/' +
      utils.buffer.bufToString(list[1], 'utf8')});
  }).catch(reject);
''');
    expect(source?['url'], 'https://example.com/hello/hello');
  });
}
