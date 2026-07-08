import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:pomelo/services/logger/logger.dart';
import 'package:pomelo/core/models/metadata/track.dart';
import 'package:pomelo/modules/music_lx/model/preload.dart';
import 'js_engine.dart';

/// 音源插件声明的库能力
///
/// 每个音源插件通过 `globalThis.lx.sources` 暴露其支持的平台信息，
/// 本类描述其中一个库（如 kg、tx）的能力声明。
class LxSourceLibrary {
  final String id;
  final String name;
  final List<String> qualitys;

  const LxSourceLibrary({
    required this.id,
    required this.name,
    required this.qualitys,
  });
}

/// 已加载的音源插件条目
///
/// 每个条目对应一个独立的 [JsEngine] 实例及其支持的库列表。
class _SourcePluginEntry {
  final JsEngine engine;
  final List<LxSourceLibrary> libraries;

  _SourcePluginEntry({required this.engine, required this.libraries});
}

/// Lx 音源插件引擎
///
/// 负责加载音源插件（source plugin），提供查询音乐播放链接的能力。
/// 与 [LxMetadataEngine]（负责搜索音乐元数据）不同，本引擎专注于获取歌曲的实际播放 URL。
///
/// 支持导入多个音源插件，每个插件使用独立的 [JsEngine] 实例。
/// 插件加载后会通过 `globalThis.lx.sources` 自动检测其支持的库列表。
/// 查询播放链接时，根据库标识路由到对应的插件引擎。
///
/// 音源插件需遵循以下协议：
/// - 通过 `globalThis.lx.sources` 暴露库信息，格式为 `{kg: {actions, name, qualitys, type}, ...}`
/// - 通过 `globalThis.lx._dispatch(key, action, data)` 调度播放链接请求
class LxSourceEngine {
  /// 已加载的音源插件条目列表
  final List<_SourcePluginEntry> _plugins = [];

  /// 加载音源插件并返回其支持的库列表
  ///
  /// 每个插件在独立的 [JsEngine] 中运行。
  /// 加载后通过 `globalThis.lx.sources` 获取该插件支持的库信息。
  ///
  /// 返回插件支持的库信息列表，加载失败返回空列表。
  Future<List<LxSourceLibrary>> loadPlugin(String scriptContent) async {
    final engine = JsEngine();

    // 加载Preloadjs
    final resultPreload = engine.jsRuntime.evaluate(preloadJS);
    if (resultPreload.isError) {
      AppLogger.log.e(
        '[LxSourceEngine] preloadJS加载失败: ${resultPreload.toString()}',
      );
      engine.dispose();
      return [];
    }

    // 解析脚本
    final userApi = parseLxMusicScriptInfo(scriptContent);
    userApi['rawScript'] = scriptContent;
    final userApiText = jsonEncode(userApi);
    // 初始化脚本运行环境
    final resultEnv = engine.jsRuntime.evaluate('initEnv($userApiText)');
    if (resultEnv.isError) {
      AppLogger.log.e('[LxSourceEngine] Env初始化失败: ${resultEnv.toString()}');
      engine.dispose();
      return [];
    }

    final completer = Completer<bool>();
    List<LxSourceLibrary> libraries = [];
    // 桥接 事件监听 inited — 从 sources 参数直接解析库列表
    engine.jsRuntime.onMessage('inited', (arguments) {
      final sources = (arguments['sources'] ?? {}) as Map<String, dynamic>;
      libraries = _parseSources(sources);
      completer.complete(true);
    });
    // 桥接 事件监听 updateAlert
    engine.jsRuntime.onMessage('updateAlert', (arguments) {
      final updateUrl = arguments['updateUrl'] ?? '';
      // final log = arguments['log'] ?? '';
      AppLogger.log.i('[LxSourceEngine] 需要更新: $updateUrl');
      completer.complete(false);
    });
    // 执行脚本
    final result = engine.jsRuntime.evaluate(
      '!(function (){$scriptContent})();',
    );
    if (result.isError) {
      AppLogger.log.e('[LxSourceEngine] 音源插件加载失败: ${result.toString()}');
      engine.dispose();
      return [];
    }

    // 等待初始化完成
    await completer.future;

    if (libraries.isEmpty) {
      AppLogger.log.w('[LxSourceEngine] 音源插件未注册任何库');
      engine.dispose();
      return [];
    }

    _plugins.add(_SourcePluginEntry(engine: engine, libraries: libraries));
    AppLogger.log.i(
      '[LxSourceEngine] 音源插件加载成功，支持库: ${libraries.map((l) => l.id).join(", ")}',
    );
    return libraries;
  }

  /// 从 inited 事件的 sources 参数解析库列表
  ///
  /// `sources` 结构为对象：
  /// ```json
  /// {
  ///   "kg": { "actions": ["musicUrl"], "name": "kg", "qualitys": [...], "type": "music" },
  ///   ...
  /// }
  /// ```
  static List<LxSourceLibrary> _parseSources(Map<String, dynamic> sources) {
    final libraries = <LxSourceLibrary>[];
    for (final entry in sources.entries) {
      final id = entry.key;
      if (id.isEmpty) continue;
      final info = entry.value;
      if (info is! Map) continue;
      final infoMap = Map<String, dynamic>.from(info);
      libraries.add(
        LxSourceLibrary(
          id: id,
          name: (infoMap['name'] as String?) ?? id,
          qualitys:
              (infoMap['qualitys'] as List<dynamic>?)?.cast<String>() ??
              <String>[],
        ),
      );
    }
    return libraries;
  }

  /// 查询音乐播放链接
  ///
  /// 根据 [libraryId] 找到对应的音源插件引擎，调用其 `getMusicUrl` 函数。
  /// 返回播放链接 URL，若查询失败则返回空字符串。
  Future<String> getMusicUrl(
    String libraryId,
    Track track, {
    quality = '128k',
  }) async {
    // 找到支持该库的音源插件引擎
    final entry = _findEntry(libraryId);
    if (entry == null) {
      AppLogger.log.e('[LxSourceEngine] 库 $libraryId 未找到对应的音源插件');
      return '';
    }

    // 构建传递给 JS 端的歌曲信息
    final requestKey =
        "request__${Random().nextDouble().toString().substring(2)}";
    final data = {
      'source': libraryId,
      'action': 'musicUrl',
      'info': {
        'type': quality,
        'musicInfo': {...?track.meta},
      },
    };
    final dataText = jsonEncode(data);

    try {
      final raw = await entry.engine.evalAsync(
        'globalThis.lx._dispatch(`$requestKey`, `request`, $dataText)',
      );

      dynamic dynamicUrl = raw;
      if (raw is Future) {
        dynamicUrl = await raw;
      }
      final url = dynamicUrl.toString();
      return url;
    } catch (e, s) {
      AppLogger.reportError(
        e,
        s,
        '[LxSourceEngine] 获取 $libraryId 播放链接异常: $e',
      );
      return '';
    }
  }

  /// 查找支持指定库的音源插件条目
  _SourcePluginEntry? _findEntry(String libraryId) {
    for (final entry in _plugins) {
      if (entry.libraries.any((l) => l.id == libraryId)) return entry;
    }
    return null;
  }

  /// 检查指定库是否已有音源插件支持
  bool hasLibrary(String libraryId) => _findEntry(libraryId) != null;

  /// 所有已加载的库信息列表
  List<LxSourceLibrary> get libraries =>
      _plugins.expand((e) => e.libraries).toList();

  /// 所有已加载的库 ID 列表
  List<String> get libraryIds =>
      _plugins.expand((e) => e.libraries.map((l) => l.id)).toList();

  /// 已加载的插件数量
  int get pluginCount => _plugins.length;

  void dispose() {
    for (final entry in _plugins) {
      entry.engine.dispose();
    }
    _plugins.clear();
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
