import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../../shared/storage/json_file_store.dart';
import '../domain/plugin_record.dart';
import '../domain/source_keys.dart';
import '../runtime/pomelo_plugin_runtime.dart';

/// 检查更新的结果。
class PluginUpdateResult {
  const PluginUpdateResult({
    required this.source,
    required this.version,
    this.log,
  });

  /// 新版本源码
  final String source;
  final String version;

  /// 更新说明（LX 脚本可提供）
  final String? log;
}

/// 基于文件系统的插件仓库（持久化 plugins.json）：`<appSupport>/plugins/plugins.json`。
class PluginRepository {
  PluginRepository._(this._store);

  final JsonFileStore _store;
  final List<PluginRecord> _plugins = [];

  /// 本次启动是否因插件体系升级清空过旧记录（用于提示用户重新导入）。
  bool clearedLegacy = false;

  List<PluginRecord> get plugins => List.unmodifiable(_plugins);

  static Future<PluginRepository> open() async {
    final dir = await getApplicationSupportDirectory();
    final pluginDir = Directory('${dir.path}/plugins');
    if (!await pluginDir.exists()) await pluginDir.create(recursive: true);
    final file = File('${pluginDir.path}/plugins.json');
    final store = PluginRepository._(JsonFileStore(file));
    await store._load();
    return store;
  }

  Future<void> _load() async {
    final raw = await _store.read();
    if (raw == null) return;
    try {
      final list = raw as List;
      final entries = list.cast<Map<String, dynamic>>();
      // 插件体系已升级：旧记录（带 kind 字段）不再兼容，清空后要求重新导入。
      if (entries.any((e) => e.containsKey('kind'))) {
        _plugins.clear();
        clearedLegacy = true;
        await _save();
        return;
      }
      // 先完整解析再替换，避免单条记录损坏时留下半截列表。
      final parsed = entries.map(PluginRecord.fromJson).toList();
      // 老数据没有 origin：洛雪按 id 前缀识别，其余先按 MusicFree 归类，
      // 是否官方由 seed 阶段按内置清单补写（见 markOfficial）。
      for (final p in parsed) {
        p.origin ??= p.id.startsWith('lx:')
            ? PluginOrigin.lx
            : PluginOrigin.musicfree;
      }
      _plugins
        ..clear()
        ..addAll(parsed);
    } catch (e) {
      if (kDebugMode) debugPrint('读取插件列表失败: $e');
    }
  }

  Future<void> _save() async {
    await _store.write(_plugins.map((e) => e.toJson()).toList());
  }

  /// 安装插件（自有格式与 LX 脚本统一入口，格式自动识别）。
  ///
  /// 同 id 视为更新：替换源码与元信息，保留用户的启用状态与兜底开关。
  Future<PluginRecord> install(
    String source, {
    String? fallbackName,
    bool official = false,
  }) async {
    final loaded = await probe(source, name: fallbackName ?? 'plugin');

    var platform = loaded.platform.trim();
    if (loaded.isLxCompat && (platform.isEmpty || platform == 'plugin')) {
      platform = 'LX: ${loaded.sourceKeys.join(", ")}';
    }
    if (platform.isEmpty) platform = fallbackName ?? 'unknown';

    final id = loaded.isLxCompat ? 'lx:$platform' : platform;
    final existingIndex = _plugins.indexWhere((p) => p.id == id);
    final existing = existingIndex >= 0 ? _plugins[existingIndex] : null;

    final alertLog = loaded.updateAlert?['log'];
    final origin = official
        ? PluginOrigin.official
        : (loaded.isLxCompat ? PluginOrigin.lx : PluginOrigin.musicfree);
    final record = PluginRecord(
      id: id,
      name: platform,
      platform: platform,
      version: loaded.version,
      description: loaded.description,
      author: loaded.author,
      enabled: existing?.enabled ?? true,
      allowFallback: existing?.allowFallback ?? true,
      disableResolve: existing?.disableResolve ?? false,
      // 用户手动指定过的音源 key 必须跨更新保留。
      userSourceKeys: existing?.userSourceKeys,
      origin: origin,
      source: source,
      supportedMethods: loaded.supportedMethods,
      // MusicFree 的 sourceKeys 是 platform 显示名，落库前统一规范化成
      // kg/kw/... 这类标准 key，否则它永远不会成为别人的兜底候选。
      sourceKeys: normalizeSourceKeys(
        declared: loaded.sourceKeys,
        platform: platform,
        isLxCompat: loaded.isLxCompat,
      ),
      qualitys: loaded.qualitys,
      srcUrl: loaded.srcUrl,
      updateLog: (alertLog is String && alertLog.trim().isNotEmpty)
          ? alertLog.trim()
          : null,
    );

    if (existingIndex >= 0) {
      _plugins[existingIndex] = record;
    } else {
      _plugins.add(record);
    }
    await _save();
    return record;
  }

  /// 从网络地址下载并安装插件（自有格式与 LX 脚本统一识别）。
  Future<PluginRecord> installFromUrl(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      throw StateError('请输入 http(s) 开头的脚本地址');
    }
    final source = await _download(uri.toString());
    if (source.trim().isEmpty) throw StateError('下载内容为空');

    final head = source.length > 512 ? source.substring(0, 512) : source;
    final headLower = head.toLowerCase();
    if (headLower.contains('<!doctype html') || headLower.contains('<html')) {
      throw StateError('该地址返回的是网页而非脚本');
    }

    final last = uri.pathSegments.isEmpty ? 'plugin' : uri.pathSegments.last;
    final name = last.replaceAll(
      RegExp(r'\.(js|txt)$', caseSensitive: false),
      '',
    );
    return install(source, fallbackName: name.isEmpty ? 'plugin' : name);
  }

  /// 用运行时加载插件，反射元信息后立即释放实例。
  Future<PluginLoadResult> probe(
    String source, {
    String name = 'plugin',
  }) async {
    final runtime = await PomeloPluginRuntime.create();
    try {
      return await runtime.loadPlugin(source, name: name);
    } finally {
      await runtime.dispose();
    }
  }

  /// 检查更新：从 `srcUrl` 拉取最新源码并比对版本。
  ///
  /// 没有更新地址、或内容与已安装版本一致时返回 null。
  Future<PluginUpdateResult?> checkUpdate(PluginRecord plugin) async {
    final url = plugin.srcUrl?.trim();
    if (url == null || url.isEmpty) return null;

    final source = await _download(url);
    // 更新地址可能只是发布页/仓库首页：给出明确提示，让用户去浏览器打开。
    final head = source.length > 512 ? source.substring(0, 512) : source;
    final headLower = head.toLowerCase();
    if (headLower.contains('<!doctype html') || headLower.contains('<html')) {
      throw StateError('该更新地址返回的是网页而非脚本，请使用「在浏览器打开更新地址」');
    }

    final loaded = await probe(source, name: plugin.platform);

    if (loaded.isLxCompat) {
      // LX 脚本的版本号常不更新，内容变化即视为更新。
      if (source.trim() == plugin.source.trim()) return null;
      final alertLog = loaded.updateAlert?['log'];
      return PluginUpdateResult(
        source: source,
        version: loaded.version.isEmpty ? plugin.version : loaded.version,
        log: (alertLog is String && alertLog.trim().isNotEmpty)
            ? alertLog.trim()
            : '检测到脚本内容更新',
      );
    }

    if (loaded.version.trim() == plugin.version.trim()) return null;
    return PluginUpdateResult(
      source: source,
      version: loaded.version,
      log: loaded.description.isEmpty ? null : loaded.description,
    );
  }

  Future<String> _download(String url) async {
    final client = HttpClient();
    // 更新检查不能无限挂起：连接 15s、读取 30s，最多 5MB。
    client.connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set(HttpHeaders.userAgentHeader, 'pomelo');
      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      if (response.statusCode != 200) {
        throw StateError('下载失败: HTTP ${response.statusCode}');
      }
      final length = response.contentLength;
      if (length > 5 * 1024 * 1024) {
        throw StateError('文件过大（${length ~/ 1024} KB），已取消');
      }
      final bytes = await consolidateHttpClientResponseBytes(response)
          .timeout(const Duration(seconds: 30));
      if (bytes.length > 5 * 1024 * 1024) {
        throw StateError('文件过大，已取消');
      }
      return utf8.decode(bytes, allowMalformed: true);
    } finally {
      client.close();
    }
  }

  /// 忽略更新提示（清除 updateLog 角标）。
  Future<void> clearUpdateLog(String id) async {
    final p = _plugins.firstWhere((e) => e.id == id);
    p.updateLog = null;
    await _save();
  }

  Future<void> setEnabled(String id, bool enabled) async {
    final p = _plugins.firstWhere((e) => e.id == id);
    p.enabled = enabled;
    await _save();
  }

  /// 是否允许其它插件缺音源时调用本插件。
  Future<void> setAllowFallback(String id, bool allow) async {
    final p = _plugins.firstWhere((e) => e.id == id);
    p.allowFallback = allow;
    await _save();
  }

  /// 禁用/恢复本插件自身取链（禁用后直接走同音源兜底）。
  Future<void> setDisableResolve(String id, bool disabled) async {
    final p = _plugins.firstWhere((e) => e.id == id);
    p.disableResolve = disabled;
    await _save();
  }

  Future<void> remove(String id) async {
    _plugins.removeWhere((e) => e.id == id);
    await _save();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _plugins.removeAt(oldIndex);
    _plugins.insert(newIndex, item);
    await _save();
  }

  /// 以「最终位置」移动插件（newIndex 已完成源位置修正，不再二次调整）。
  ///
  /// Flutter 新版 `onReorderItem` 回调给出的 newIndex 已是最终下标，用这个入口
  /// 避免再次 `newIndex -= 1` 导致往下拖动时错位。
  Future<void> moveTo(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _plugins.length) return;
    final item = _plugins.removeAt(oldIndex);
    _plugins.insert(newIndex.clamp(0, _plugins.length), item);
    await _save();
  }

  List<PluginRecord> get enabledPlugins =>
      _plugins.where((p) => p.enabled).toList();

  /// 可为指定音源 key 提供播放链接的兜底插件。
  ///
  /// 匹配用 [effectiveSourceKeys] 而非原始 `sourceKeys`：老数据里存的是
  /// platform 显示名（如「风誰·酷狗」），规范化后才能命中 `kg`。
  /// 结果按 [orderedIds] 给出的顺序排列，其余按安装顺序跟在后面。
  List<PluginRecord> fallbackCandidates(
    String sourceKey, {
    String? excludeId,
    List<String> orderedIds = const [],
  }) {
    final matched = _plugins
        .where(
          (p) =>
              p.enabled &&
              p.allowFallback &&
              p.canProvideMediaSource &&
              !p.disableResolve &&
              p.id != excludeId &&
              effectiveSourceKeys(p).contains(sourceKey),
        )
        .toList();
    if (orderedIds.isEmpty) return matched;

    // 兜底链里明确排过序的排在前面，未列出的保持安装顺序接在后面。
    final rank = {for (final (i, id) in orderedIds.indexed) id: i};
    final inChain = matched.where((p) => rank.containsKey(p.id)).toList()
      ..sort((a, b) => rank[a.id]!.compareTo(rank[b.id]!));
    final rest = matched.where((p) => !rank.containsKey(p.id));
    return [...inChain, ...rest];
  }

  /// 按源码内容把内置插件标记为官方。
  ///
  /// 用内容比对而非 id/名字：老用户的记录里没有出身字段，而内置脚本的
  /// 源码就是最可靠的指纹。内置脚本升级后老记录匹配不上，seed 重装时会
  /// 重新打标，不影响正确性。
  Future<void> markOfficialBySource(Set<String> sources) async {
    if (sources.isEmpty) return;
    var changed = false;
    for (final p in _plugins) {
      if (p.origin == PluginOrigin.official) continue;
      if (sources.contains(p.source.trim())) {
        p.origin = PluginOrigin.official;
        changed = true;
      }
    }
    if (changed) await _save();
  }

  /// 更新用户手动指定的音源 key（传 null/空 表示恢复自动推断）。
  Future<void> setUserSourceKeys(String id, List<String>? keys) async {
    final p = _plugins.firstWhere((e) => e.id == id);
    p.userSourceKeys = (keys == null || keys.isEmpty) ? null : keys;
    await _save();
  }
}
