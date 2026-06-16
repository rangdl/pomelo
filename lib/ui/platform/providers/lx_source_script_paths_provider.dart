import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/module/module_manager.dart';
import 'package:pomelo/core/storage/settings.dart';
import 'package:pomelo/modules/music_lx/model/lx_js_source_engine.dart';
import 'package:pomelo/modules/music_lx/music_lx_module.dart';

/// Lx 源脚本路径列表 Notifier
///
/// 管理 Lx 源脚本（source script）的添加、替换与移除，
/// 支持多份源脚本，每份提供音乐播放链接查询能力。
class LxSourceScriptPathsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return LxMusicModule.loadSourceScriptPaths();
  }

  /// 添加源脚本
  ///
  /// 返回脚本支持的平台信息列表，加载失败返回空列表。
  Future<List<LxSourcePlatform>> addScript(String path) async {
    if (state.contains(path)) return [];
    final module = ModuleManager().find<LxMusicModule>('music_lx');
    if (module != null) {
      final platforms = await module.addSourceScript(path);
      if (platforms.isNotEmpty) {
        state = [...state, path];
      }
      return platforms;
    } else {
      state = [...state, path];
      await _save();
      return [];
    }
  }

  /// 替换源脚本
  ///
  /// 用新文件替换旧脚本，返回新脚本支持的平台列表。
  Future<List<LxSourcePlatform>> replaceScript(
    String oldPath,
    String newPath,
  ) async {
    final module = ModuleManager().find<LxMusicModule>('music_lx');
    if (module != null) {
      final platforms = await module.replaceSourceScript(oldPath, newPath);
      if (platforms.isNotEmpty) {
        state = state.map((p) => p == oldPath ? newPath : p).toList();
      } else {
        // 替换失败，移除旧路径
        state = state.where((p) => p != oldPath).toList();
      }
      await _save();
      return platforms;
    } else {
      state = state.map((p) => p == oldPath ? newPath : p).toList();
      await _save();
      return [];
    }
  }

  /// 移除源脚本
  Future<void> removeScript(String path) async {
    final module = ModuleManager().find<LxMusicModule>('music_lx');
    await module?.removeSourceScript(path);
    state = state.where((p) => p != path).toList();
    await _save();
  }

  Future<void> _save() async {
    await Settings.set(
      'music_lx_source_script_paths',
      '[${state.map((p) => '"$p"').join(',')}]',
    );
  }
}

/// Lx 源脚本路径列表
final lxSourceScriptPathsProvider =
    NotifierProvider<LxSourceScriptPathsNotifier, List<String>>(
      LxSourceScriptPathsNotifier.new,
    );
