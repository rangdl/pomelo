import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/module/module_manager.dart';
import 'package:pomelo/core/storage/settings.dart';
import 'package:pomelo/modules/music_lx/music_lx_module.dart';

/// Lx 搜索脚本路径 Notifier
///
/// 管理 Lx 搜索脚本文件（仅允许一份），
/// 供平台页面和设置页面共用。
/// 搜索脚本用于搜索音乐元数据。
class LxScriptPathsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return LxMusicModule.loadScriptPaths();
  }

  /// 添加搜索脚本
  ///
  /// 仅允许上传一份。若已有脚本则忽略。
  /// 如需替换请使用 [replaceScript]。
  Future<void> addScript(String path) async {
    if (state.isNotEmpty) return;
    final module = ModuleManager().find<LxMusicModule>('music_lx');
    if (module != null) {
      final success = await module.addScript(path);
      if (success) {
        state = [path];
      }
    } else {
      state = [path];
      await _save();
    }
  }

  /// 替换搜索脚本
  ///
  /// 用新文件替换现有的搜索脚本。
  Future<void> replaceScript(String newPath) async {
    final module = ModuleManager().find<LxMusicModule>('music_lx');
    if (module != null) {
      final success = await module.replaceScript(newPath);
      if (success) {
        state = [newPath];
      }
    } else {
      state = [newPath];
    }
    await _save();
  }

  /// 移除搜索脚本
  Future<void> removeScript(String path) async {
    final module = ModuleManager().find<LxMusicModule>('music_lx');
    await module?.removeScript(path);
    state = [];
    _save();
  }

  Future<void> _save() async {
    await Settings.set(
      'music_lx_script_paths',
      '[${state.map((p) => '"$p"').join(',')}]',
    );
  }
}

/// Lx 搜索脚本路径列表
final lxScriptPathsProvider =
    NotifierProvider<LxScriptPathsNotifier, List<String>>(
      LxScriptPathsNotifier.new,
    );
