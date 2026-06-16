import 'dart:convert';
import 'dart:io';

import 'package:pomelo/core/mars.dart';
import 'package:pomelo/modules/music/music_module.dart';
import 'package:pomelo/modules/music_lx/model/lx_js_source_engine.dart';
import 'package:pomelo/modules/music_lx/providers/musicsdk_provider.dart';
import 'lx_script_source.dart';

/// Settings key: Lx 音乐脚本文件路径列表（JSON 数组字符串）
const _kLxScriptPaths = 'music_lx_script_paths';

/// Settings key: Lx 音乐源脚本文件路径列表（JSON 数组字符串）
const _kLxSourceScriptPaths = 'music_lx_source_script_paths';

/// Lx 音乐模块
///
/// 通过 quickjs 动态加载用户上传的 JS 脚本文件，
/// 每个脚本文件作为一个 [LxScriptSource] 来源，
/// 自动检测脚本注册的平台并创建对应的 [MusicService]。
///
/// 所有脚本共享同一个 [LxJsEngine] 实例。
class LxMusicModule extends Module {
  late final LxJsEngine _jsEngine;
  late LxJsSourceEngine _sourceEngine;

  /// 已加载的源脚本路径列表
  final List<String> _sourceScriptPaths = [];

  /// 已加载的脚本来源列表
  final List<LxScriptSource> _scriptSources = [];

  @override
  String get id => 'music_lx';

  @override
  String get displayName => 'Lx 音乐平台';

  @override
  bool get lazy => true;

  @override
  List<String> get dependencies => ['music'];

  /// 对外暴露 JS 引擎
  LxJsEngine get jsEngine => _jsEngine;

  /// 对外暴露音乐源引擎
  LxJsSourceEngine get sourceEngine => _sourceEngine;

  /// 已加载的源脚本路径列表（只读）
  List<String> get sourcePaths => List.unmodifiable(_sourceScriptPaths);

  /// 已加载的脚本来源列表（只读）
  List<LxScriptSource> get scriptSources => List.unmodifiable(_scriptSources);

  /// 已加载的脚本路径列表
  List<String> get scriptPaths =>
      _scriptSources.map((s) => s.scriptPath).toList();

  @override
  Future<void> onInit() async {
    _jsEngine = LxJsEngine();
    await _jsEngine.init();
    _sourceEngine = LxJsSourceEngine();

    // 加载已保存的源脚本
    await _loadSavedSourceScripts();

    // 从 Settings 读取已保存的脚本文件路径并加载
    final pathsJson = Settings.get(_kLxScriptPaths);
    if (pathsJson != null) {
      try {
        final paths = (jsonDecode(pathsJson) as List).cast<String>();
        for (final path in paths) {
          await _createScriptSource(path);
        }
      } catch (_) {
        // JSON 解析失败，忽略
      }
    }
  }

  @override
  Future<void> onReady() async {
    final musicModule = ModuleManager().find<MusicModule>('music');
    if (musicModule == null) return;
    // 将每个脚本来源注册到 MusicModule
    for (final source in _scriptSources) {
      await musicModule.addSource(source);
    }
  }

  @override
  Future<void> onDispose() async {
    _jsEngine.dispose();
    _sourceEngine.dispose();
    _scriptSources.clear();
  }

  /// 添加并加载脚本文件
  ///
  /// 加载脚本、检测平台、创建服务，并注册到 MusicModule。
  /// 返回是否加载成功。
  Future<bool> addScript(String path) async {
    // 避免重复添加
    if (_scriptSources.any((s) => s.scriptPath == path)) return false;
    final source = await _createScriptSource(path);
    if (source == null) return false;
    // 如果模块已就绪，立即注册到 MusicModule
    if (isInitialized) {
      final musicModule = ModuleManager().find<MusicModule>('music');
      await musicModule?.addSource(source);
    }
    await saveScriptPaths();
    return true;
  }

  /// 移除脚本
  ///
  /// 从 MusicModule 注销其服务，并移除来源。
  Future<void> removeScript(String path) async {
    final idx = _scriptSources.indexWhere((s) => s.scriptPath == path);
    if (idx == -1) return;
    final source = _scriptSources.removeAt(idx);
    // 从 MusicModule 注销
    final musicModule = ModuleManager().find<MusicModule>('music');
    await musicModule?.removeSource(source.id);
    await saveScriptPaths();
  }

  /// 创建脚本来源并尝试初始化
  Future<LxScriptSource?> _createScriptSource(String path) async {
    final source = LxScriptSource(
      scriptPath: path,
      jsEngine: _jsEngine,
      sourceEngine: _sourceEngine,
    );
    await source.init();
    if (source.services.isEmpty) {
      print('LxMusicModule: 脚本 $path 未注册任何平台，跳过');
      await source.dispose();
      return null;
    }
    _scriptSources.add(source);
    return source;
  }

  /// 保存脚本路径列表到 Settings
  Future<void> saveScriptPaths() async {
    await Settings.set(_kLxScriptPaths, jsonEncode(scriptPaths));
  }

  /// 从 Settings 读取已保存的脚本路径列表
  static List<String> loadScriptPaths() {
    final pathsJson = Settings.get(_kLxScriptPaths);
    if (pathsJson == null) return [];
    try {
      return (jsonDecode(pathsJson) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  // ========== 源脚本管理 ==========

  /// 加载已保存的源脚本
  Future<void> _loadSavedSourceScripts() async {
    final pathsJson = Settings.get(_kLxSourceScriptPaths);
    if (pathsJson == null) return;
    try {
      final paths = (jsonDecode(pathsJson) as List).cast<String>();
      for (final path in paths) {
        final platforms = await _loadSourceScriptFile(path);
        if (platforms.isNotEmpty) {
          _sourceScriptPaths.add(path);
        }
      }
    } catch (_) {
      // JSON 解析失败，忽略
    }
  }

  /// 添加源脚本
  ///
  /// [path] 源脚本文件路径
  /// 加载脚本后自动检测其支持的平台。
  /// 返回脚本支持的平台列表，加载失败返回空列表。
  Future<List<String>> addSourceScript(String path) async {
    if (_sourceScriptPaths.contains(path)) return [];
    final platforms = await _loadSourceScriptFile(path);
    if (platforms.isNotEmpty) {
      _sourceScriptPaths.add(path);
      await _saveSourceScriptPaths();
    }
    return platforms;
  }

  /// 移除源脚本
  ///
  /// 重建源引擎并重新加载剩余的源脚本。
  Future<void> removeSourceScript(String path) async {
    if (!_sourceScriptPaths.remove(path)) return;
    // 重建源引擎
    _sourceEngine.dispose();
    _sourceEngine = LxJsSourceEngine();
    // 重新加载剩余的源脚本
    for (final p in _sourceScriptPaths) {
      await _loadSourceScriptFile(p);
    }
    await _saveSourceScriptPaths();
  }

  /// 加载单个源脚本文件
  Future<List<String>> _loadSourceScriptFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      print('LxMusicModule: 源脚本文件不存在 $path');
      return [];
    }
    final content = await file.readAsString();
    return _sourceEngine.loadScript(content);
  }

  /// 保存源脚本路径列表到 Settings
  Future<void> _saveSourceScriptPaths() async {
    await Settings.set(_kLxSourceScriptPaths, jsonEncode(_sourceScriptPaths));
  }

  /// 从 Settings 读取已保存的源脚本路径列表
  static List<String> loadSourceScriptPaths() {
    final pathsJson = Settings.get(_kLxSourceScriptPaths);
    if (pathsJson == null) return [];
    try {
      return (jsonDecode(pathsJson) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }
}
