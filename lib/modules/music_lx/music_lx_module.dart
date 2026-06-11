import 'dart:convert';
import 'dart:io';

import 'package:pomelo/core/mars.dart';
import 'package:pomelo/modules/music/music_module.dart';
import 'package:pomelo/modules/music_lx/model/lx_music_service.dart';
import 'package:pomelo/modules/music_lx/providers/musicsdk_provider.dart';
import 'package:pomelo/modules/music_lx/providers/providers.dart';

/// Settings key: Lx 音乐脚本文件路径列表（JSON 数组字符串）
const _kLxScriptPaths = 'music_lx_script_paths';

/// Lx 音乐模块
///
/// 通过 quickjs 动态加载用户上传的 JS 脚本文件，
/// 提供 tx/kg/wy/kw/mg 五个音乐平台的 [MusicService] 实现。
/// 初始化完成后通过 [MusicModule.register] 注册自身为数据服务。
class LxMusicModule extends Module {
  late final LxJsEngine _jsEngine;
  late final TxMusicService _txMusicService;
  late final KgMusicService _kgMusicService;
  late final WyMusicService _wyMusicService;
  late final KwMusicService _kwMusicService;
  late final MgMusicService _mgMusicService;

  /// 已加载的脚本路径列表
  final List<String> _scriptPaths = [];

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

  /// 已加载的脚本路径列表（只读）
  List<String> get scriptPaths => List.unmodifiable(_scriptPaths);

  /// 获取指定平台的服务
  LxMusicService? service(String platformId) {
    return switch (platformId) {
      'tx' => _txMusicService,
      'kg' => _kgMusicService,
      'wy' => _wyMusicService,
      'kw' => _kwMusicService,
      'mg' => _mgMusicService,
      _ => null,
    };
  }

  @override
  Future<void> onInit() async {
    _jsEngine = LxJsEngine();
    await _jsEngine.init();

    // 创建各平台服务
    _txMusicService = TxMusicService(jsEngine: _jsEngine);
    _kgMusicService = KgMusicService(jsEngine: _jsEngine);
    _wyMusicService = WyMusicService(jsEngine: _jsEngine);
    _kwMusicService = KwMusicService(jsEngine: _jsEngine);
    _mgMusicService = MgMusicService(jsEngine: _jsEngine);

    // 从 Settings 读取已保存的脚本文件路径并加载
    final pathsJson = Settings.get(_kLxScriptPaths);
    if (pathsJson != null) {
      try {
        final paths = (jsonDecode(pathsJson) as List).cast<String>();
        for (final path in paths) {
          await _loadScriptFile(path);
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
    musicModule.register(_txMusicService);
    musicModule.register(_kgMusicService);
    musicModule.register(_wyMusicService);
    musicModule.register(_kwMusicService);
    musicModule.register(_mgMusicService);
  }

  @override
  Future<void> onDispose() async {
    _jsEngine.dispose();
  }

  /// 加载脚本文件
  Future<bool> _loadScriptFile(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return false;
      final content = await file.readAsString();
      final success = _jsEngine.loadScript(content);
      if (success && !_scriptPaths.contains(path)) {
        _scriptPaths.add(path);
      }
      return success;
    } catch (e) {
      print('LxMusicModule: 加载脚本失败 $path: $e');
      return false;
    }
  }

  /// 添加并加载脚本文件
  Future<bool> addScript(String path) async {
    final success = await _loadScriptFile(path);
    if (success) {
      await saveScriptPaths();
    }
    return success;
  }

  /// 移除脚本（从列表移除，JS 引擎需重新初始化才能完全卸载）
  void removeScript(String path) {
    _scriptPaths.remove(path);
    saveScriptPaths();
  }

  /// 保存脚本路径列表到 Settings
  Future<void> saveScriptPaths() async {
    await Settings.set(_kLxScriptPaths, jsonEncode(_scriptPaths));
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
}
