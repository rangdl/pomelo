/// Lx 音乐模块 - Riverpod Providers
///
/// 管理 Lx 插件路径的响应式状态，供 UI 层和模块内部共用。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/module/module_manager.dart';
import 'package:pomelo/core/storage/settings.dart';
import 'package:pomelo/core/storage/storage_keys.dart';
import 'package:pomelo/modules/music_lx/model/lx_source_engine.dart';
import 'package:pomelo/modules/music_lx/music_lx_module.dart';

/// Lx 元数据插件路径 Notifier
///
/// 管理 Lx 元数据插件文件（仅允许一份），
/// 供平台页面和设置页面共用。
/// 元数据插件用于提供音乐搜索、歌曲详情等元信息。
class LxMetadataPluginPathsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    final path = LxMusicModule.loadMetadataPluginPath();
    return path != null ? [path] : [];
  }

  /// 添加元数据插件
  ///
  /// 仅允许上传一份。若已有插件则忽略。
  /// 如需替换请使用 [replacePlugin]。
  Future<void> addPlugin(String path) async {
    if (state.isNotEmpty) return;
    final module = ModuleManager().find<LxMusicModule>('music_lx');
    if (module != null) {
      final success = await module.addMetadataPlugin(path);
      if (success) {
        state = [path];
      }
    } else {
      state = [path];
    }
  }

  /// 替换元数据插件
  ///
  /// 用新文件替换现有的元数据插件。
  Future<void> replacePlugin(String newPath) async {
    final module = ModuleManager().find<LxMusicModule>('music_lx');
    if (module != null) {
      final success = await module.replaceMetadataPlugin(newPath);
      if (success) {
        state = [newPath];
      }
    } else {
      state = [newPath];
    }
  }

  /// 移除元数据插件
  Future<void> removePlugin(String path) async {
    final module = ModuleManager().find<LxMusicModule>('music_lx');
    await module?.removeMetadataPlugin();
    state = [];
  }
}

/// Lx 元数据插件路径列表
final lxMetadataPluginPathsProvider =
    NotifierProvider<LxMetadataPluginPathsNotifier, List<String>>(
      LxMetadataPluginPathsNotifier.new,
    );

/// Lx 音源插件路径列表 Notifier
///
/// 管理 Lx 音源插件（source plugin）的添加、替换与移除，
/// 支持多份音源插件，每份提供音乐播放链接查询能力。
class LxSourcePluginPathsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return LxMusicModule.loadSourcePluginPaths();
  }

  /// 添加音源插件
  ///
  /// 返回插件支持的库信息列表，加载失败返回空列表。
  Future<List<LxSourceLibrary>> addPlugin(String path) async {
    if (state.contains(path)) return [];
    final module = ModuleManager().find<LxMusicModule>('music_lx');
    if (module != null) {
      final libraries = await module.addSourcePlugin(path);
      if (libraries.isNotEmpty) {
        state = [...state, path];
      }
      return libraries;
    } else {
      state = [...state, path];
      await _save();
      return [];
    }
  }

  /// 替换音源插件
  ///
  /// 用新文件替换旧插件，返回新插件支持的库列表。
  Future<List<LxSourceLibrary>> replacePlugin(
    String oldPath,
    String newPath,
  ) async {
    final module = ModuleManager().find<LxMusicModule>('music_lx');
    if (module != null) {
      final libraries = await module.replaceSourcePlugin(oldPath, newPath);
      if (libraries.isNotEmpty) {
        state = state.map((p) => p == oldPath ? newPath : p).toList();
      } else {
        // 替换失败，移除旧路径
        state = state.where((p) => p != oldPath).toList();
      }
      await _save();
      return libraries;
    } else {
      state = state.map((p) => p == oldPath ? newPath : p).toList();
      await _save();
      return [];
    }
  }

  /// 移除音源插件
  Future<void> removePlugin(String path) async {
    final module = ModuleManager().find<LxMusicModule>('music_lx');
    await module?.removeSourcePlugin(path);
    state = state.where((p) => p != path).toList();
    await _save();
  }

  Future<void> _save() async {
    await Settings.set(
      StorageKeys.musicLxSourcePluginPaths,
      '[${state.map((p) => '"$p"').join(',')}]',
    );
  }
}

/// Lx 音源插件路径列表
final lxSourcePluginPathsProvider =
    NotifierProvider<LxSourcePluginPathsNotifier, List<String>>(
      LxSourcePluginPathsNotifier.new,
    );
