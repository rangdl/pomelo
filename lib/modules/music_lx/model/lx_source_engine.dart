import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:pomelo/services/js_engine/js_engine.dart';
import 'package:pomelo/services/js_engine/preload.dart';
import 'package:pomelo/services/logger/logger.dart';
import 'package:pomelo/core/models/metadata/track.dart';
// import 'package:pomelo/modules/music_lx/model/preload.dart';
// import 'js_engine.dart';

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
  /// 已加载的音源插件条目（按 scriptId 索引，支持增量增删）
  final Map<String, _SourcePluginEntry> _plugins = {};

  /// 使用统计上报回调
  ///
  /// 参数：(scriptId, libraryId, success, durationMs)
  /// 在 [getMusicUrl] 完成后调用（无论成功或失败）。
  void Function(
    String scriptId,
    String libraryId,
    bool success,
    int durationMs,
  )?
  onUsageReport;

  /// 加载音源插件并返回其支持的库列表
  ///
  /// 每个插件在独立的 [JsEngine] 中运行。
  /// 加载后通过 `globalThis.lx.sources` 获取该插件支持的库信息。
  ///
  /// 返回插件支持的库信息列表，加载失败返回空列表。
  ///
  /// 注意：此方法使用临时 scriptId，适合一次性验证场景。
  /// 增量管理（添加/移除/启停）请使用 [loadPluginWithId] / [unloadPlugin]。
  Future<List<LxSourceLibrary>> loadPlugin(String scriptContent) async {
    final scriptId = 'tmp_${scriptContent.hashCode.abs()}';
    return loadPluginWithId(scriptId, scriptContent);
  }

  /// 加载音源插件并指定 scriptId（用于增量管理）
  ///
  /// 若 [scriptId] 已存在，先卸载旧插件再加载新的。
  /// 返回插件支持的库信息列表，加载失败返回空列表。
  Future<List<LxSourceLibrary>> loadPluginWithId(
    String scriptId,
    String scriptContent,
  ) async {
    // 已存在同 id 的插件，先卸载
    _plugins.remove(scriptId)?.engine.dispose();

    final engine = JsEngine();

    // 加载Preloadjs
    try {
      engine.eval(preloadJS);
    } catch (e, s) {
      AppLogger.reportError(e, s, '[LxSourceEngine] preloadJS加载失败: $e');
      engine.dispose();
      return [];
    }

    // 解析脚本
    final userApi = parseLxMusicScriptInfo(scriptContent);
    userApi['rawScript'] = scriptContent;
    final userApiText = jsonEncode(userApi);
    List<LxSourceLibrary> libraries = [];
    // 初始化脚本运行环境
    try {
      // engine.eval('initEnv($userApiText)');
      // final result = engine.jsRuntime.call('initEnv', [userApi]);
      final args = await engine.evalAsync('initEnv($userApiText)');
      String type = args[0] as String;
      Map<String, dynamic> arguments = args[1] as Map<String, dynamic>;
      if (type == 'inited') {
        final sources = (arguments['sources'] ?? {}) as Map<String, dynamic>;
        libraries = _parseSources(sources);
      } else if (type == 'updateAlert') {
        final updateUrl = arguments['updateUrl'] ?? '';
        // final log = arguments['log'] ?? '';
        AppLogger.log.i('[LxSourceEngine] 需要更新: $updateUrl');
      }
    } catch (e, s) {
      AppLogger.reportError(e, s, '[LxSourceEngine] 脚本初始化失败: $e');
      engine.dispose();
      return [];
    }

    if (libraries.isEmpty) {
      AppLogger.log.w('[LxSourceEngine] 音源插件未注册任何库');
      engine.dispose();
      return [];
    }

    _plugins[scriptId] = _SourcePluginEntry(
      engine: engine,
      libraries: libraries,
    );
    AppLogger.log.i(
      '[LxSourceEngine] 音源插件加载成功 scriptId=$scriptId, 支持库: ${libraries.map((l) => l.id).join(", ")}',
    );
    return libraries;
  }

  /// 卸载指定 scriptId 的插件
  ///
  /// 释放对应的 [JsEngine] 资源。不存在则无操作。
  void unloadPlugin(String scriptId) {
    final entry = _plugins.remove(scriptId);
    if (entry != null) {
      entry.engine.dispose();
      AppLogger.log.i('[LxSourceEngine] 音源插件已卸载 scriptId=$scriptId');
    }
  }

  /// 检查指定 scriptId 是否已加载
  bool hasPlugin(String scriptId) => _plugins.containsKey(scriptId);

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
  ///
  /// 调用结束后通过 [onUsageReport] 上报使用统计（含计时）。
  Future<String> getMusicUrl(
    String libraryId,
    Track track, {
    quality = '128k',
  }) async {
    final stopwatch = Stopwatch()..start();
    String? usedScriptId;
    bool success = false;

    try {
      // 找到支持该库的音源插件引擎（按 scriptId 升序，保证排序优先级）
      final matched = _plugins.entries
          .where(
            (e) => e.value.libraries.any(
              (l) => l.id == libraryId && l.qualitys.contains(quality),
            ),
          )
          .toList();
      if (matched.isEmpty) {
        AppLogger.log.e('[LxSourceEngine] 库 $libraryId $quality 未找到对应的音源插件');
        return '';
      }
      // 构建传递给 JS 端的歌曲信息
      final data = {
        'source': libraryId,
        'action': 'musicUrl',
        'info': {
          'type': quality,
          'musicInfo': {...?track.meta},
        },
      };
      final dataText = jsonEncode(data);
      for (final entry in matched) {
        usedScriptId = entry.key;
        final requestKey =
            "request__${Random().nextDouble().toString().substring(2)}";
        try {
          final raw = await entry.value.engine.evalAsync(
            'globalThis.lx._dispatch(`$requestKey`, `request`, $dataText)',
          );
          final url = raw.toString();
          if (url.isNotEmpty && url != 'undefined') {
            success = true;
            return url;
          }
        } catch (e, s) {
          AppLogger.reportError(
            e,
            s,
            '[LxSourceEngine] 获取 $libraryId $quality 播放链接异常: $e',
          );
        }
      }
      return '';
    } finally {
      stopwatch.stop();
      final report = onUsageReport;
      if (usedScriptId != null && report != null) {
        report(usedScriptId, libraryId, success, stopwatch.elapsedMilliseconds);
      }
    }
  }

  /// 查找支持指定库的音源插件条目
  _SourcePluginEntry? _findEntry(String libraryId) {
    for (final entry in _plugins.values) {
      if (entry.libraries.any((l) => l.id == libraryId)) return entry;
    }
    return null;
  }

  /// 检查指定库是否已有音源插件支持
  bool hasLibrary(String libraryId) => _findEntry(libraryId) != null;

  /// 所有已加载的库信息列表
  List<LxSourceLibrary> get libraries =>
      _plugins.values.expand((e) => e.libraries).toList();

  /// 所有已加载的库 ID 列表
  List<String> get libraryIds =>
      _plugins.values.expand((e) => e.libraries.map((l) => l.id)).toList();

  /// 已加载的插件数量
  int get pluginCount => _plugins.length;

  void dispose() {
    for (final entry in _plugins.values) {
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
