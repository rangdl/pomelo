import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/module/module_manager.dart';
import 'package:pomelo/core/storage/settings.dart';
import 'package:pomelo/modules/music_lx/music_lx_module.dart';

/// Lx 脚本路径列表 Notifier
///
/// 管理 Lx JS 脚本文件的添加与移除，
/// 供平台页面和设置页面共用。
class LxScriptPathsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return LxMusicModule.loadScriptPaths();
  }

  /// 添加脚本
  Future<void> addScript(String path) async {
    if (state.contains(path)) return;
    final module = ModuleManager().find<LxMusicModule>('music_lx');
    if (module != null) {
      final success = await module.addScript(path);
      if (success) {
        state = [...state, path];
      }
    } else {
      // 模块未初始化，先保存路径
      state = [...state, path];
      await _save();
    }
  }

  /// 移除脚本
  Future<void> removeScript(String path) async {
    final module = ModuleManager().find<LxMusicModule>('music_lx');
    await module?.removeScript(path);
    state = state.where((p) => p != path).toList();
    _save();
  }

  Future<void> _save() async {
    await Settings.set('music_lx_script_paths',
        '[${state.map((p) => '"$p"').join(',')}]');
  }
}

/// Lx 脚本路径列表
final lxScriptPathsProvider =
    NotifierProvider<LxScriptPathsNotifier, List<String>>(
      LxScriptPathsNotifier.new,
    );
