import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/module/module_manager.dart';
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
