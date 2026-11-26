import 'package:flutter/services.dart' show rootBundle;

import 'plugin_worker.dart';

/// 插件加载结果。
///
/// 宿主只关心这份结果，不区分插件是自有格式还是 LX 脚本——LX 脚本已由兼容层
/// 包装成同形的 `getMediaSource`。
class PluginLoadResult {
  const PluginLoadResult({
    required this.isLxCompat,
    required this.platform,
    required this.version,
    required this.author,
    required this.description,
    required this.supportedMethods,
    this.srcUrl,
    this.sourceKeys = const [],
    this.qualitys = const {},
    this.updateAlert,
  });

  /// 是否由 LX 兼容层包装而来。
  final bool isLxCompat;

  /// 插件身份标识（自有格式=导出 platform，LX=脚本名）。
  final String platform;
  final String version;
  final String author;
  final String description;

  /// 插件实际实现的方法（LX 包装插件固定为 `getMediaSource`）。
  final List<String> supportedMethods;

  /// 更新源地址（自有格式=srcUrl，LX=updateAlert.updateUrl）。
  final String? srcUrl;

  /// 可处理的音源 key 集合：自有格式为 `[platform]`，LX 为其声明的全部源。
  final List<String> sourceKeys;

  /// 音源 key → 该源支持的音质列表（仅 LX 有值）。
  final Map<String, List<String>> qualitys;

  /// LX 脚本上报的更新提示（`{log, updateUrl}`），非空即"有更新"。
  final Map<String, dynamic>? updateAlert;

  bool get hasUpdateAlert => updateAlert != null && updateAlert!.isNotEmpty;
}

/// 统一插件运行时（主 isolate 侧门面）。
///
/// 每个插件一个 QuickJS 引擎，运行在**独立 Isolate** 中：插件里的死循环、
/// 无限递归或卡死的 Promise 都不会冻结 UI。宿主通过端口用 JSON 协议通信。
///
/// - 自有格式：`module.exports = { platform, search, getMediaSource, ... }`
/// - LX 脚本：`lx.on('request', ...)` + `lx.send('inited', ...)`，由兼容层
///   包装成同形导出（只提供 `getMediaSource`）。
class PomeloPluginRuntime {
  PomeloPluginRuntime._(this._host);

  final PluginHost _host;

  /// LX 脚本声明的源（`kw/kg/tx/wy/mg/qs…`）。
  Map<String, dynamic> sources = {};

  /// 源 → 音质列表。
  Map<String, List<String>> qualitys = const {};

  /// LX 上报的更新提示。
  Map<String, dynamic>? updateAlert;

  bool initialized = false;
  String? initError;

  bool _disposed = false;

  /// 每次成功调用回调一次（上层可据此做闲置回收计时）。
  void Function()? onActivity;

  /// 创建实例：拉取 fetch polyfill 后启动插件 worker。
  static Future<PomeloPluginRuntime> create({
    int stackSize = 1024 * 1024,
    int? memoryLimit = 64 * 1024 * 1024,
    void Function(String tag, String message)? onLog,
  }) async {
    final polyfill = await rootBundle.loadString(
      'packages/quickjs_engine/assets/js/fetch.js',
    );
    final host = await PluginHost.spawn(
      fetchPolyfill: polyfill,
      stackSize: stackSize,
      memoryLimit: memoryLimit,
    );
    host.onLog = onLog;
    return PomeloPluginRuntime._(host);
  }

  /// 加载插件源码并自动判定格式。
  Future<PluginLoadResult> loadPlugin(
    String source, {
    String name = 'plugin',
    Duration initTimeout = const Duration(seconds: 20),
    Map<String, dynamic> userVariables = const {},
  }) async {
    final raw = await _host.call(
      'load',
      [source, name, initTimeout.inMilliseconds, userVariables],
      // 初始化本身在 worker 内有超时，这里留出余量。
      timeout: initTimeout + const Duration(seconds: 15),
    );
    final map = Map<String, dynamic>.from(raw as Map);
    sources = map['sources'] is Map
        ? Map<String, dynamic>.from(map['sources'] as Map)
        : const {};
    final rawQualitys = map['qualitys'];
    qualitys = rawQualitys is Map
        ? {
            for (final e in rawQualitys.entries)
              '${e.key}': (e.value as List?)?.map((q) => '$q').toList() ?? [],
          }
        : const {};
    updateAlert = map['updateAlert'] is Map
        ? Map<String, dynamic>.from(map['updateAlert'] as Map)
        : null;
    initialized = map['initialized'] == true;
    initError = map['initError'] is String ? map['initError'] as String : null;
    _notifyActivity();

    return PluginLoadResult(
      isLxCompat: map['isLxCompat'] == true,
      platform: '${map['platform'] ?? name}',
      version: '${map['version'] ?? ''}',
      author: '${map['author'] ?? ''}',
      description: '${map['description'] ?? ''}',
      supportedMethods:
          (map['supportedMethods'] as List?)?.map((e) => '$e').toList() ??
          const [],
      srcUrl: map['srcUrl'] is String ? map['srcUrl'] as String : null,
      sourceKeys:
          (map['sourceKeys'] as List?)?.map((e) => '$e').toList() ?? const [],
      qualitys: qualitys,
      updateAlert: updateAlert,
    );
  }

  /// 调用插件方法并等待结果。worker 内部串行，避免全局结果位互相覆盖。
  Future<dynamic> invoke(
    String method,
    List<dynamic> args, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    if (_disposed) throw StateError('插件运行时已关闭');
    final result = await _host.call('invoke', [
      method,
      args,
      timeout.inMilliseconds,
    ], timeout: timeout + const Duration(seconds: 5));
    _notifyActivity();
    return result;
  }

  void _notifyActivity() {
    try {
      onActivity?.call();
    } catch (_) {
      // 回调异常不影响调用本身。
    }
  }

  // ---------------------------------------------------------------------------
  // 便捷方法（全部可选，插件未实现时抛 UnsupportedError）
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> search(
    String query, {
    int page = 1,
    String type = 'music',
  }) async {
    final result = await invoke('search', [query, page, type]);
    if (result is Map<String, dynamic>) {
      final data = result['data'];
      return {
        'isEnd': result['isEnd'] ?? true,
        'data': data is List ? data : const [],
      };
    }
    return {'isEnd': true, 'data': const []};
  }

  /// 获取播放地址，返回 `{url, headers?}`；取不到返回 null。
  ///
  /// [sourceKey] 供 LX 包装插件选择具体音源；自有格式插件会忽略这个多余实参。
  Future<Map<String, dynamic>?> getMediaSource(
    Map<String, dynamic> musicItem,
    String quality, {
    String? sourceKey,
  }) async {
    final args = <dynamic>[musicItem, quality];
    if (sourceKey != null && sourceKey.isNotEmpty) args.add(sourceKey);
    final result = await invoke('getMediaSource', args);
    if (result is Map<String, dynamic>) {
      final url = result['url'];
      if (url is String && url.isNotEmpty) return result;
      return null;
    }
    if (result is String && result.isNotEmpty) return {'url': result};
    return null;
  }

  /// 单曲详情（部分插件会补齐歌词、音质等信息）。
  Future<Map<String, dynamic>?> getMusicInfo(
    Map<String, dynamic> musicItem,
  ) async {
    final result = await invoke('getMusicInfo', [musicItem]);
    if (result is Map<String, dynamic>) return result;
    if (result is Map && result['data'] is Map) {
      return (result['data'] as Map).cast<String, dynamic>();
    }
    return null;
  }

  /// 评论列表。返回 `{isEnd, data}` 里的 `data`。
  Future<List<Map<String, dynamic>>> getMusicComments(
    Map<String, dynamic> musicItem, {
    int page = 1,
    String sort = 'hot',
  }) async {
    final result = await invoke('getMusicComments', [
      musicItem,
      page,
      sort,
    ], timeout: const Duration(seconds: 30));
    final list = result is List
        ? result
        : (result is Map ? (result['data'] ?? result['comments']) : null);
    if (list is List) {
      return list
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    }
    return const [];
  }

  /// 歌手详情。
  Future<Map<String, dynamic>?> getArtistInfo(
    Map<String, dynamic> artistItem,
  ) async {
    final result = await invoke('getArtistInfo', [artistItem]);
    if (result is Map<String, dynamic>) return result;
    if (result is Map && result['data'] is Map) {
      return (result['data'] as Map).cast<String, dynamic>();
    }
    return null;
  }

  /// 导入分享的歌单，返回曲目列表。
  Future<List<Map<String, dynamic>>> importMusicSheet(String url) async {
    final result = await invoke('importMusicSheet', [
      url,
    ], timeout: const Duration(seconds: 45));
    final list = result is List
        ? result
        : (result is Map ? (result['data'] ?? result['musicList']) : null);
    if (list is List) {
      return list
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    }
    return const [];
  }

  /// 导入分享的单曲。
  Future<Map<String, dynamic>?> importMusicItem(String url) async {
    final result = await invoke('importMusicItem', [
      url,
    ], timeout: const Duration(seconds: 45));
    if (result is Map<String, dynamic>) return result;
    if (result is Map && result['data'] is Map) {
      return (result['data'] as Map).cast<String, dynamic>();
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getTopLists() async {
    try {
      final result = await invoke('getTopLists', []);
      if (result is List) return _maps(result);
    } catch (_) {
      // 插件未实现或出错：静默返回空。
    }
    return const [];
  }

  Future<List<Map<String, dynamic>>> getTopListDetail(
    Map<String, dynamic> topListItem, {
    int page = 1,
  }) async {
    final result = await getTopListDetailPage(topListItem, page: page);
    return result.data;
  }

  /// 榜单详情（带 `isEnd`，用于分页）。
  Future<({List<Map<String, dynamic>> data, bool isEnd})> getTopListDetailPage(
    Map<String, dynamic> topListItem, {
    int page = 1,
  }) async {
    final result = await invoke('getTopListDetail', [
      topListItem,
      page,
    ], timeout: const Duration(seconds: 45));
    return _pageResult(result, dataKey: 'musicList', altKeys: ['data']);
  }

  /// 推荐歌单标签列表。
  Future<List<Map<String, dynamic>>> getRecommendSheetTags() async {
    try {
      final result = await invoke(
        'getRecommendSheetTags',
        [],
        timeout: const Duration(seconds: 30),
      );
      if (result is List) return _maps(result);
      if (result is Map && result['data'] is List) {
        return _maps(result['data'] as List);
      }
    } catch (_) {
      // 插件未实现：静默返回空。
    }
    return const [];
  }

  /// 按标签分页获取推荐歌单（tag 为 getRecommendSheetTags 返回的标签对象）。
  Future<({List<Map<String, dynamic>> data, bool isEnd})>
  getRecommendSheetsByTag(dynamic tag, {int page = 1}) async {
    final result = await invoke('getRecommendSheetsByTag', [
      tag,
      page,
    ], timeout: const Duration(seconds: 45));
    return _pageResult(result, dataKey: 'data');
  }

  /// 歌单详情（歌曲列表）。
  Future<({List<Map<String, dynamic>> data, bool isEnd})> getMusicSheetInfo(
    Map<String, dynamic> sheetItem, {
    int page = 1,
  }) async {
    final result = await invoke('getMusicSheetInfo', [
      sheetItem,
      page,
    ], timeout: const Duration(seconds: 60));
    return _pageResult(result, dataKey: 'musicList', altKeys: const ['data']);
  }

  /// 歌手作品：`type` 为 `music`（单曲）或 `album`（专辑）。
  Future<({List<Map<String, dynamic>> data, bool isEnd})> getArtistWorks(
    Map<String, dynamic> artistItem, {
    int page = 1,
    String type = 'music',
  }) async {
    final result = await invoke('getArtistWorks', [
      artistItem,
      page,
      type,
    ], timeout: const Duration(seconds: 45));
    return _pageResult(
      result,
      dataKey: 'data',
      altKeys: const ['musicList', 'albumList'],
    );
  }

  /// 专辑详情（歌曲列表）。
  Future<({List<Map<String, dynamic>> data, bool isEnd})> getAlbumInfo(
    Map<String, dynamic> albumItem, {
    int page = 1,
  }) async {
    final result = await invoke('getAlbumInfo', [
      albumItem,
      page,
    ], timeout: const Duration(seconds: 45));
    return _pageResult(result, dataKey: 'musicList', altKeys: const ['data']);
  }

  /// 搜索建议（部分插件实现）。
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      final result = await invoke('getSearchSuggestions', [
        query,
      ], timeout: const Duration(seconds: 15));
      if (result is List) {
        return result
            .map((e) => '$e'.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } catch (_) {
      // 未实现：静默返回空。
    }
    return const [];
  }

  List<Map<String, dynamic>> _maps(List list) =>
      list.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();

  /// 兼容插件返回 `{isEnd, data/musicList}` 与直接返回数组两种形态。
  ({List<Map<String, dynamic>> data, bool isEnd}) _pageResult(
    dynamic result, {
    required String dataKey,
    List<String> altKeys = const [],
  }) {
    if (result is List) {
      return (data: _maps(result), isEnd: true);
    }
    if (result is Map) {
      dynamic list = result[dataKey];
      for (final key in altKeys) {
        if (list is List) break;
        list = result[key];
      }
      final isEnd = result['isEnd'];
      return (
        data: list is List ? _maps(list) : const <Map<String, dynamic>>[],
        isEnd: isEnd == null ? true : isEnd == true,
      );
    }
    return (data: const <Map<String, dynamic>>[], isEnd: true);
  }

  /// 直接触发 LX 脚本的 request 处理器（歌词等其它 action）。
  ///
  /// 仅 LX 兼容插件可用；自有格式插件没有 request 处理器，调用会抛错。
  Future<dynamic> lxRequest({
    required String source,
    required String action,
    required Map<String, dynamic> info,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    if (_disposed) throw StateError('插件运行时已关闭');
    if (!initialized) throw StateError('该插件不是 LX 音源脚本，未初始化');
    final result = await _host.call('lxRequest', [
      source,
      action,
      info,
      timeout.inMilliseconds,
    ], timeout: timeout + const Duration(seconds: 5));
    _notifyActivity();
    return result;
  }

  /// 释放运行时（结束 worker Isolate）。
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _host.close();
  }
}
