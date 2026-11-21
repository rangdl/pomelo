import 'dart:convert';

import 'package:flutter/material.dart';

import 'runtime/lx_runtime.dart';
import 'runtime/musicfree_runtime.dart';

void main() {
  runApp(const MainApp());
}

/// MusicFree 风格插件：只用 fetch + JSON，无 npm 依赖。
const _mfPlugin = r'''
module.exports = {
  platform: "demo",
  version: "0.0.1",
  async search(query, page, type) {
    const resp = await fetch("https://httpbin.org/get?q=" + encodeURIComponent(query));
    const data = await resp.json();
    return {
      isEnd: true,
      data: [{
        id: "demo-1",
        platform: "demo",
        title: "搜索结果: " + query,
        artist: "httpbin",
        url: data.url || "",
        artwork: "",
        album: "bridge-test"
      }]
    };
  },
  async getMediaSource(musicItem, quality) {
    return { url: musicItem.url, headers: { "user-agent": "pomelo/0.1" } };
  }
};
''';

/// LX 风格脚本：只负责按平台解析播放链接。
const _lxScript = r'''
lx.on('request', async ({ source, action, info }) => {
  if (action === 'musicUrl') {
    const r = await fetch('https://httpbin.org/get?song=' + encodeURIComponent(info.musicInfo.name || ''));
    const j = await r.json();
    return j.url || 'https://example.com/fallback.mp3';
  }
  throw new Error('unsupported action: ' + action);
});

lx.send('inited', {
  status: true,
  sources: {
    kw: { name: '酷我(demo)', type: 'music', actions: ['musicUrl'], qualitys: ['128k', '320k'] }
  }
});
''';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final List<String> _log = [];
  bool _busy = false;

  void _add(String s) {
    if (!mounted) return;
    setState(() {
      _log.add(s);
      if (_log.length > 60) _log.removeAt(0);
    });
  }

  Future<void> _runMusicFree() async {
    setState(() {
      _log.clear();
      _busy = true;
    });
    MusicFreeRuntime? rt;
    try {
      final sw = Stopwatch()..start();
      rt = await MusicFreeRuntime.create();
      _add('引擎: ${rt.js.getEngineInstanceId()} 启动 ${sw.elapsedMilliseconds}ms');
      _add('2+2 = ${rt.js.evaluate("2 + 2").stringResult}');

      rt.loadPlugin(_mfPlugin, name: 'demo');
      _add('插件加载 OK, platform=${rt.js.evaluate("__pluginModule.exports.platform").stringResult}');

      final result = await rt.invoke('search', ['bridge', 1, 'music']);
      _add('search → ${jsonEncode(result)}');

      final src = await rt.invoke('getMediaSource', [
        {'url': 'https://example.com/a.mp3'},
        'standard',
      ]);
      _add('getMediaSource → ${jsonEncode(src)}');
      _add('✓ MusicFree 协议链路通过');
    } catch (e) {
      _add('✗ $e');
    } finally {
      rt?.dispose();
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _runLx() async {
    setState(() {
      _log.clear();
      _busy = true;
    });
    LxUserApiRuntime? rt;
    try {
      rt = await LxUserApiRuntime.create();
      rt.loadScript(_lxScript, id: 'demo-lx', name: 'Demo LX');
      _add('LX 脚本加载 OK');

      final ok = await rt.waitForInit();
      _add('初始化: $ok, 声明源=${rt.sources.keys.join(",")}');
      if (!ok) {
        _add('✗ ${rt.initError}');
        return;
      }

      final url = await rt.request(
        source: 'kw',
        action: 'musicUrl',
        info: {
          'musicInfo': {'name': '稻香', 'singer': '周杰伦'},
          'type': '128k',
        },
      );
      _add('musicUrl → $url');
      _add('✓ LX 协议链路通过');
    } catch (e) {
      _add('✗ $e');
    } finally {
      rt?.dispose();
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('插件运行时验证')),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _busy ? null : _runMusicFree,
                      child: const Text('MusicFree 协议'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _busy ? null : _runLx,
                      child: const Text('LX 协议'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: const Color(0xFFF3F3F3),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _log.join('\n'),
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
