import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_js/flutter_js.dart';
import 'package:pomelo/modules/music/model/song.dart';
import 'package:pomelo/modules/music_lx/model/preload.dart';
import 'js_engine.dart';

/// 已加载的源脚本条目
///
/// 每个条目对应一个独立的 [JsEngine] 实例及其支持的平台列表。
class _SourceScriptEntry {
  final JsEngine engine;
  final List<String> platforms;

  _SourceScriptEntry({required this.engine, required this.platforms});
}

/// Lx 音乐源引擎
///
/// 负责加载源脚本（source script），提供查询音乐播放链接的能力。
/// 与 [LxJsEngine]（负责搜索音乐元数据）不同，本引擎专注于获取歌曲的实际播放 URL。
///
/// 支持导入多个源脚本，每个脚本使用独立的 [JsEngine] 实例。
/// 脚本加载后会通过 `sourceRegistry.all()` 自动检测其支持的平台列表。
/// 查询播放链接时，根据平台标识路由到对应的脚本引擎。
///
/// 源脚本需遵循以下协议：
/// - 暴露 `sourceRegistry` 对象，提供 `.all()` 方法返回 `[{id: 'tx'}, ...]`
/// - 暴露 `setup()` 函数用于初始化
/// - 暴露 `getMusicUrl(musicInfo, platform)` 函数，返回播放链接（或 Promise<string>）
class LxJsSourceEngine {
  /// 已加载的源脚本条目列表
  final List<_SourceScriptEntry> _scripts = [];

  /// 加载源脚本并返回其支持的平台列表
  ///
  /// 每个脚本在独立的 [JsEngine] 中运行。
  /// 加载后通过 `sourceRegistry.all()` 获取该平台支持的平台 ID 列表。
  ///
  /// 返回脚本支持的平台标识列表，加载失败返回空列表。
  Future<List<String>> loadScript(String scriptContent) async {
    final engine = JsEngine();

    // 加载Preloadjs
    final resultPreload = engine.jsRuntime.evaluate(preloadJS);
    if (resultPreload.isError) {
      print('LxJsSourceEngine: preloadJS加载失败: ${resultPreload.toString()}');
      engine.dispose();
      return [];
    }

    // 解析脚本
    final userApi = parseLxMusicScriptInfo(scriptContent);
    userApi['rawScript'] = scriptContent;
    // 初始化脚本运行环境
    final resultEnv = engine.jsRuntime.evaluate('initEnv($userApi)');
    if (resultEnv.isError) {
      print('LxJsSourceEngine: Env初始化失败: ${resultEnv.toString()}');
      engine.dispose();
      return [];
    }

    final completer = Completer<bool>();
    // 桥接 事件监听 inited
    engine.jsRuntime.onMessage('inited', (arguments) {
      // sources = (arguments['sources'] ?? {}) as Map<String, dynamic>;
      completer.complete(true);
    });
    // 桥接 事件监听 updateAlert
    engine.jsRuntime.onMessage('updateAlert', (arguments) {
      // log = arguments['log'] ?? '';
      final updateUrl = arguments['updateUrl'] ?? '';
      print('需要更新: $updateUrl');
      completer.complete(false);
    });

    // 执行脚本
    final result = engine.jsRuntime.evaluate(
      '!(function (){$scriptContent})();',
    );
    if (result.isError) {
      print('LxJsSourceEngine: 源脚本加载失败: ${result.toString()}');
      engine.dispose();
      return [];
    }
    // 等待初始化完成
    await completer.future;

    // 获取脚本支持的平台列表
    final platforms = await _getSupportedPlatforms(engine);
    if (platforms.isEmpty) {
      print('LxJsSourceEngine: 源脚本未注册任何平台');
      engine.dispose();
      return [];
    }

    _scripts.add(_SourceScriptEntry(engine: engine, platforms: platforms));
    print('LxJsSourceEngine: 源脚本加载成功，支持平台: ${platforms.join(", ")}');
    return platforms;
  }

  /// 获取脚本引擎中 sourceRegistry 注册的平台列表
  Future<List<String>> _getSupportedPlatforms(JsEngine engine) async {
    try {
      final result = await engine.jsRuntime.evaluateAsync(
        'JSON.stringify(Array.from(globalThis.lx.sources))',
      );
      engine.jsRuntime.executePendingJob();
      if (result.isError) return [];
      final asyncResult = await engine.jsRuntime.handlePromise(result);
      final raw = asyncResult.rawResult;
      if (raw is String) {
        final items = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
        return items
            .map((v) => v['id'] as String? ?? '')
            .where((id) => id.isNotEmpty)
            .toList();
      }
      return [];
    } catch (e) {
      print('LxJsSourceEngine: 获取平台列表失败: $e');
      return [];
    }
  }

  /// 查询音乐播放链接
  ///
  /// 根据 [platform] 找到对应的脚本引擎，调用其 `getMusicUrl` 函数。
  /// 返回播放链接 URL，若查询失败则返回空字符串。
  Future<String> getMusicUrl(
    String platform,
    Song song, {
    quality = '128k',
  }) async {
    // 找到支持该平台的脚本引擎
    final entry = _findEntry(platform);
    if (entry == null) {
      print('LxJsSourceEngine: 平台 $platform 未找到对应的源脚本');
      return '';
    }

    // 构建传递给 JS 端的歌曲信息
    final requestKey =
        "request__${Random().nextDouble().toString().substring(2)}";
    final data = {
      'source': platform,
      'action': 'musicUrl',
      'info': {
        'type': quality,
        'musicInfo': {...song.meta},
      },
    };
    final dataText = jsonEncode(data);

    try {
      final result = await entry.engine.jsRuntime.evaluateAsync(
        'globalThis.lx._dispatch(`$requestKey`, `request`, $dataText)',
      );
      entry.engine.jsRuntime.executePendingJob();

      if (result.isError) {
        print('LxJsSourceEngine: 获取 $platform 播放链接失败: ${result.toString()}');
        return '';
      }

      final asyncResult = await entry.engine.jsRuntime.handlePromise(result);
      final url = asyncResult.rawResult?.toString() ?? '';
      return url;
    } catch (e) {
      print('LxJsSourceEngine: 获取 $platform 播放链接异常: $e');
      return '';
    }
  }

  /// 查找支持指定平台的脚本条目
  _SourceScriptEntry? _findEntry(String platform) {
    for (final entry in _scripts) {
      if (entry.platforms.contains(platform)) return entry;
    }
    return null;
  }

  /// 检查指定平台是否已有源脚本支持
  bool hasPlatform(String platform) => _findEntry(platform) != null;

  /// 所有已加载的平台列表
  List<String> get platforms => _scripts.expand((e) => e.platforms).toList();

  /// 已加载的脚本数量
  int get scriptCount => _scripts.length;

  void dispose() {
    for (final entry in _scripts) {
      entry.engine.dispose();
    }
    _scripts.clear();
  }

  static Map<String, String> parseLxMusicScriptInfo(String script) {
    final RegExp headerRegex = RegExp(r'/\*[\s\S]+?\*/');
    final Match? headerMatch = headerRegex.firstMatch(script.trim());
    final Map<String, String> infos = {};

    if (headerMatch != null) {
      String header = headerMatch.group(0)!;
      List<String> lines = header.split(RegExp(r'\r?\n'));
      final RegExp lineRegex = RegExp(r'^\s?\*\s?@(\w+)\s(.+)$');

      for (String line in lines) {
        final Match? match = lineRegex.firstMatch(line);
        if (match == null) continue;
        final String key = match.group(1)!;
        if (!_infoNames.containsKey(key)) continue;
        final String value = match.group(2)!.trim();
        infos[key] = value;
      }
    }

    for (final MapEntry<String, int> entry in _infoNames.entries) {
      final String key = entry.key;
      final int maxLen = entry.value;
      infos.putIfAbsent(key, () => '');
      if (infos[key]!.length > maxLen) {
        infos[key] = infos[key]!.substring(0, maxLen) + '...';
      }
    }
    return infos;
  }
}

const Map<String, int> _infoNames = {
  'name': 24,
  'description': 256,
  'author': 56,
  'homepage': 1024,
  'version': 36,
};
