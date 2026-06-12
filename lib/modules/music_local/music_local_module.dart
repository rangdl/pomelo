import 'dart:convert';

import 'package:pomelo/core/mars.dart';
import 'package:pomelo/modules/music/music_module.dart';
import 'local_music_source.dart';
import 'repository/local_music_service.dart';

/// Settings key: 本地音乐目录列表（JSON 数组字符串）
const _kLocalMusicDirs = 'music_local_directories';

/// 本地音乐模块
///
/// 实现 [MusicService] 接口，提供本地音乐数据。
/// 初始化完成后通过 [MusicModule.register] 注册自身为数据服务。
///
/// 启动时从 Settings 读取已保存的目录列表，扫描后加载到内存。
class MusicLocalModule extends Module {
  late final LocalMusicSource _source;

  @override
  String get id => 'music_local';

  @override
  String get displayName => '本地音乐';

  @override
  bool get lazy => true;

  @override
  List<String> get dependencies => ['music'];

  /// 对外暴露来源实例
  LocalMusicSource get source => _source;

  /// 对外暴露服务实例（便捷访问）
  LocalMusicService get service => _source.service;

  @override
  Future<void> onInit() async {
    final localService = LocalMusicService();
    _source = LocalMusicSource(service: localService);
    // 从 Settings 读取已保存的目录列表并扫描
    final dirsJson = Settings.get(_kLocalMusicDirs);
    if (dirsJson != null) {
      try {
        final dirs = (jsonDecode(dirsJson) as List).cast<String>();
        for (final dir in dirs) {
          await localService.addDirectory(dir);
        }
      } catch (_) {
        // JSON 解析失败，忽略
      }
    }
  }

  @override
  Future<void> onReady() async {
    // 在 onReady 中将来源注册到 MusicModule
    final musicModule = ModuleManager().find<MusicModule>('music');
    await musicModule?.addSource(_source);
  }

  @override
  Future<void> onDispose() async {
    // 由 MusicModule.removeSource / dispose 负责清理
  }

  /// 保存当前目录列表到 Settings
  static Future<void> saveDirectories(List<String> dirs) async {
    await Settings.set(_kLocalMusicDirs, jsonEncode(dirs));
  }

  /// 从 Settings 读取已保存的目录列表
  static List<String> loadDirectories() {
    final dirsJson = Settings.get(_kLocalMusicDirs);
    if (dirsJson == null) return [];
    try {
      return (jsonDecode(dirsJson) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }
}
