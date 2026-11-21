import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../runtime/musicfree_runtime.dart';

/// 一个已安装的插件（元信息 + 源码 + 启用状态）。
class PluginRecord {
  PluginRecord({
    required this.id,
    required this.name,
    required this.platform,
    required this.version,
    this.description = '',
    this.author = '',
    this.enabled = true,
    required this.source,
    this.supportedMethods = const [],
  });

  /// 稳定 id，默认用 platform，重名时加后缀
  String id;

  /// 显示名（插件导出的 platform）
  String name;
  String platform;
  String version;
  String description;
  String author;
  bool enabled;

  /// 原始 JS 源码
  String source;

  /// 从实例反射得到的可用方法
  List<String> supportedMethods;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'platform': platform,
        'version': version,
        'description': description,
        'author': author,
        'enabled': enabled,
        'source': source,
        'supportedMethods': supportedMethods,
      };

  static PluginRecord fromJson(Map<String, dynamic> json) => PluginRecord(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        platform: json['platform'] as String? ?? '',
        version: json['version'] as String? ?? '',
        description: json['description'] as String? ?? '',
        author: json['author'] as String? ?? '',
        enabled: json['enabled'] as bool? ?? true,
        source: json['source'] as String? ?? '',
        supportedMethods:
            (json['supportedMethods'] as List?)?.cast<String>() ?? const [],
      );
}

/// 基于文件系统的插件仓库：`<appSupport>/plugins/plugins.json`。
class PluginStore {
  PluginStore._(this._file);

  final File _file;
  final List<PluginRecord> _plugins = [];

  List<PluginRecord> get plugins => List.unmodifiable(_plugins);

  static Future<PluginStore> open() async {
    final dir = await getApplicationSupportDirectory();
    final pluginDir = Directory('${dir.path}/plugins');
    if (!await pluginDir.exists()) await pluginDir.create(recursive: true);
    final store = PluginStore._(File('${pluginDir.path}/plugins.json'));
    await store._load();
    return store;
  }

  Future<void> _load() async {
    if (!await _file.exists()) return;
    try {
      final raw = await _file.readAsString();
      final list = jsonDecode(raw) as List;
      _plugins
        ..clear()
        ..addAll(list.map((e) => PluginRecord.fromJson(e as Map<String, dynamic>)));
    } catch (e) {
      if (kDebugMode) debugPrint('读取插件列表失败: $e');
    }
  }

  Future<void> _save() async {
    await _file.writeAsString(
      jsonEncode(_plugins.map((e) => e.toJson()).toList()),
    );
  }

  /// 安装插件源码。若 platform 重复则替换。
  Future<PluginRecord> install(String source, {String? fallbackName}) async {
    final meta = await _probe(source);
    final platform = (meta['platform'] as String?)?.trim().isNotEmpty == true
        ? meta['platform'] as String
        : (fallbackName ?? 'unknown');

    final existing = _plugins.where((p) => p.platform == platform).toList();
    final record = PluginRecord(
      id: existing.isNotEmpty ? existing.first.id : platform,
      name: platform,
      platform: platform,
      version: (meta['version'] as String?) ?? '',
      description: (meta['description'] as String?) ?? '',
      author: (meta['author'] as String?) ?? '',
      source: source,
      supportedMethods:
          (meta['supportedMethods'] as List?)?.cast<String>() ?? const [],
    );

    if (existing.isNotEmpty) {
      final idx = _plugins.indexOf(existing.first);
      _plugins[idx] = record;
    } else {
      _plugins.add(record);
    }
    await _save();
    return record;
  }

  /// 用运行时反射插件导出对象的元信息，不保留运行时实例。
  Future<Map<String, dynamic>> _probe(String source) async {
    final runtime = await MusicFreeRuntime.create();
    try {
      runtime.loadPlugin(source);
      final meta = runtime.evaluateJson('''
        (function() {
          var m = __pluginModule.exports || {};
          return {
            platform: m.platform,
            version: m.version,
            description: m.description,
            author: m.author,
            supportedMethods: Object.keys(m).filter(function(k) {
              return typeof m[k] === 'function';
            })
          };
        })()
      ''');
      return meta ?? {};
    } finally {
      runtime.dispose();
    }
  }

  Future<void> setEnabled(String id, bool enabled) async {
    final p = _plugins.firstWhere((e) => e.id == id);
    p.enabled = enabled;
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

  List<PluginRecord> get enabledPlugins =>
      _plugins.where((p) => p.enabled).toList();
}
