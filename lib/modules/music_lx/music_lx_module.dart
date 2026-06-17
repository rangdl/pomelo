import 'dart:convert';
import 'dart:io';

import 'package:pomelo/core/mars.dart';
import 'package:pomelo/modules/music/music_module.dart';
import 'package:pomelo/modules/music_lx/model/lx_source_engine.dart';
import 'package:pomelo/modules/music_lx/providers/musicsdk_provider.dart';
import 'model/lx_music_service.dart';

/// Settings key: Lx 元数据插件文件路径（单路径字符串，仅支持一份）
const _kLxMetadataPluginPath = 'music_lx_metadata_plugin_path';

/// Settings key: Lx 音源插件文件路径列表（JSON 数组字符串）
const _kLxSourcePluginPaths = 'music_lx_source_plugin_paths';

/// Lx 音乐模块
///
/// 通过 quickjs 动态加载用户上传的 JS 插件文件，
/// 支持两种插件类型：
/// - **元数据插件**：提供音乐搜索、歌曲详情等元信息，仅允许一份，注册若干库（tx/wy/kg 等）
/// - **音源插件**：提供音乐播放链接查询能力，支持多份叠加
///
/// 元数据插件 + 关联的音源插件组成一个统一的 [LxMusicService]，
/// 注册为单个音乐服务到 [MusicModule]。
///
/// 所有元数据插件共享同一个 [LxMetadataEngine] 实例。
class LxMusicModule extends Module {
  late final LxMetadataEngine _metadataEngine;
  late LxSourceEngine _sourceEngine;

  /// 当前元数据插件文件路径
  String? _metadataPluginPath;

  /// 当前 Lx 音乐服务实例（元数据插件加载后创建）
  LxMusicService? _service;

  /// 已加载的音源插件路径列表
  final List<String> _sourcePluginPaths = [];

  @override
  String get id => 'music_lx';

  @override
  String get displayName => 'Lx 音乐平台';

  @override
  bool get lazy => true;

  @override
  List<String> get dependencies => ['music'];

  /// 对外暴露元数据引擎
  LxMetadataEngine get metadataEngine => _metadataEngine;

  /// 对外暴露音源插件引擎
  LxSourceEngine get sourceEngine => _sourceEngine;

  /// 当前 Lx 音乐服务（可能为 null，元数据插件未加载时）
  LxMusicService? get service => _service;

  /// 已加载的音源插件路径列表（只读）
  List<String> get sourcePluginPaths => List.unmodifiable(_sourcePluginPaths);

  /// 当前元数据插件文件路径
  String? get metadataPluginPath => _metadataPluginPath;

  @override
  Future<void> onInit() async {
    _metadataEngine = LxMetadataEngine();
    await _metadataEngine.init();
    _sourceEngine = LxSourceEngine();

    // 加载已保存的音源插件
    await _loadSavedSourcePlugins();

    // 从 Settings 读取已保存的元数据插件路径并加载
    final savedPath = Settings.get(_kLxMetadataPluginPath);
    if (savedPath != null && savedPath.isNotEmpty) {
      await _loadMetadataPlugin(savedPath);
    }
  }

  @override
  Future<void> onReady() async {
    final musicModule = ModuleManager().find<MusicModule>('music');
    if (musicModule == null || _service == null) return;
    musicModule.register(_service!);
  }

  @override
  Future<void> onDispose() async {
    _metadataEngine.dispose();
    _sourceEngine.dispose();
    _service = null;
  }

  // ========== 元数据插件管理（仅允许一份） ==========

  /// 添加元数据插件
  ///
  /// 仅允许上传一份元数据插件。若已有插件则返回 false。
  /// 如需替换请使用 [replaceMetadataPlugin]。
  Future<bool> addMetadataPlugin(String path) async {
    if (_service != null) return false;
    final loaded = await _loadMetadataPlugin(path);
    if (!loaded) return false;
    if (isInitialized) {
      final musicModule = ModuleManager().find<MusicModule>('music');
      musicModule?.register(_service!);
    }
    return true;
  }

  /// 替换元数据插件
  ///
  /// 移除现有元数据插件，加载新的插件文件。
  /// 返回是否替换成功。
  Future<bool> replaceMetadataPlugin(String newPath) async {
    if (_service == null) return false;
    // 从 MusicModule 注销旧服务
    final musicModule = ModuleManager().find<MusicModule>('music');
    musicModule?.unregister(_service!.sourceId);
    _service = null;

    // 加载新插件
    final loaded = await _loadMetadataPlugin(newPath);
    if (!loaded) {
      await _saveMetadataPluginPath();
      return false;
    }
    if (isInitialized) {
      musicModule?.register(_service!);
    }
    await _saveMetadataPluginPath();
    return true;
  }

  /// 移除元数据插件
  Future<void> removeMetadataPlugin() async {
    if (_service == null) return;
    final musicModule = ModuleManager().find<MusicModule>('music');
    musicModule?.unregister(_service!.sourceId);
    _service = null;
    _metadataPluginPath = null;
    await _saveMetadataPluginPath();
  }

  /// 加载元数据插件文件并创建服务
  Future<bool> _loadMetadataPlugin(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      print('LxMusicModule: 元数据插件文件不存在 $path');
      return false;
    }
    final content = await file.readAsString();
    final libraries = await _metadataEngine.loadPluginWithLibraries(content);
    if (libraries.isEmpty) {
      print('LxMusicModule: 元数据插件 $path 未注册任何库，跳过');
      return false;
    }
    _metadataPluginPath = path;

    // 生成 pluginId（基于文件名 hash）
    final pluginId = _derivePluginId(path);

    _service = LxMusicService(
      metadataEngine: _metadataEngine,
      sourceEngine: _sourceEngine,
      pluginId: pluginId,
      libraries: libraries,
    );

    await _saveMetadataPluginPath();
    print(
        'LxMusicModule: 插件加载成功，注册了 ${libraries.length} 个库: '
        '${libraries.map((l) => l.id).join(", ")}');
    return true;
  }

  /// 保存元数据插件路径到 Settings
  Future<void> _saveMetadataPluginPath() async {
    await Settings.set(_kLxMetadataPluginPath, _metadataPluginPath ?? '');
  }

  /// 从 Settings 读取已保存的元数据插件路径
  static String? loadMetadataPluginPath() {
    final path = Settings.get(_kLxMetadataPluginPath);
    return (path != null && path.isNotEmpty) ? path : null;
  }

  /// 从插件路径生成 pluginId（取文件名的 hash）
  static String _derivePluginId(String path) {
    final fileName = path.split(RegExp(r'[/\\]')).last.replaceAll(RegExp(r'\.[^.]+$'), '');
    return '${fileName}_${path.hashCode.abs()}';
  }

  // ========== 音源插件管理（支持多份） ==========

  /// 加载已保存的音源插件
  Future<void> _loadSavedSourcePlugins() async {
    final pathsJson = Settings.get(_kLxSourcePluginPaths);
    if (pathsJson == null) return;
    try {
      final paths = (jsonDecode(pathsJson) as List).cast<String>();
      for (final path in paths) {
        final libraries = await _loadSourcePluginFile(path);
        if (libraries.isNotEmpty) {
          _sourcePluginPaths.add(path);
        }
      }
    } catch (_) {
      // JSON 解析失败，忽略
    }
  }

  /// 添加音源插件
  ///
  /// [path] 音源插件文件路径
  /// 加载插件后自动检测其支持的库。
  /// 返回插件支持的库信息列表，加载失败返回空列表。
  Future<List<LxSourceLibrary>> addSourcePlugin(String path) async {
    if (_sourcePluginPaths.contains(path)) return [];
    final libraries = await _loadSourcePluginFile(path);
    if (libraries.isNotEmpty) {
      _sourcePluginPaths.add(path);
      await _saveSourcePluginPaths();
    }
    return libraries;
  }

  /// 替换音源插件
  ///
  /// 重建音源引擎，用新文件替换旧插件，重新加载所有音源插件。
  /// 返回新插件支持的库信息列表，加载失败返回空列表。
  Future<List<LxSourceLibrary>> replaceSourcePlugin(
    String oldPath,
    String newPath,
  ) async {
    final idx = _sourcePluginPaths.indexOf(oldPath);
    if (idx == -1) return [];
    // 重建音源引擎
    _sourceEngine.dispose();
    _sourceEngine = LxSourceEngine();
    // 更新服务中的 sourceEngine 引用
    _service?.sourceEngine = _sourceEngine;
    // 替换路径
    _sourcePluginPaths[idx] = newPath;
    List<LxSourceLibrary> newLibraries = [];
    // 重新加载所有音源插件
    for (final p in _sourcePluginPaths) {
      final libraries = await _loadSourcePluginFile(p);
      if (p == newPath) newLibraries = libraries;
    }
    await _saveSourcePluginPaths();
    return newLibraries;
  }

  /// 移除音源插件
  ///
  /// 重建音源引擎并重新加载剩余的音源插件。
  Future<void> removeSourcePlugin(String path) async {
    if (!_sourcePluginPaths.remove(path)) return;
    _sourceEngine.dispose();
    _sourceEngine = LxSourceEngine();
    // 更新服务中的 sourceEngine 引用
    _service?.sourceEngine = _sourceEngine;
    for (final p in _sourcePluginPaths) {
      await _loadSourcePluginFile(p);
    }
    await _saveSourcePluginPaths();
  }

  /// 加载单个音源插件文件
  Future<List<LxSourceLibrary>> _loadSourcePluginFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      print('LxMusicModule: 音源插件文件不存在 $path');
      return [];
    }
    final content = await file.readAsString();
    return _sourceEngine.loadPlugin(content);
  }

  /// 保存音源插件路径列表到 Settings
  Future<void> _saveSourcePluginPaths() async {
    await Settings.set(_kLxSourcePluginPaths, jsonEncode(_sourcePluginPaths));
  }

  /// 从 Settings 读取已保存的音源插件路径列表
  static List<String> loadSourcePluginPaths() {
    final pathsJson = Settings.get(_kLxSourcePluginPaths);
    if (pathsJson == null) return [];
    try {
      return (jsonDecode(pathsJson) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }
}
