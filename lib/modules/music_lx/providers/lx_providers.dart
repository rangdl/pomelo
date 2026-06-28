/// Lx 音乐模块 - Riverpod Providers
///
/// 管理 Lx 插件路径的响应式状态，并通过 Provider 直接创建 [LxMusicServer] 实例。
/// Provider 依赖 [userPreferenceProvider]，配置变化时自动重建。
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/log.dart';
import 'package:pomelo/core/preferences/user_preference_provider.dart';
import 'package:pomelo/modules/music_lx/model/lx_metadata_engine.dart';
import 'package:pomelo/modules/music_lx/model/lx_music_server.dart';
import 'package:pomelo/modules/music_lx/model/lx_source_engine.dart';

/// 从插件路径生成 pluginId（取文件名的 hash）
String _derivePluginId(String path) {
  final fileName = path
      .split(RegExp(r'[/\\]'))
      .last
      .replaceAll(RegExp(r'\.[^.]+$'), '');
  return '${fileName}_${path.hashCode.abs()}';
}

/// 检查插件文件是否存在，不存在则记录警告日志。
/// [label] 用于日志描述（如"元数据插件"/"音源插件"）。
Future<bool> _pluginExists(String path, String label) async {
  if (!await File(path).exists()) {
    log.warning('LxMusic', '$label文件不存在 $path');
    return false;
  }
  return true;
}

/// LxMetadataEngine + 已加载的插件信息
///
/// 依赖 [UserPreference.lxMetadataPluginPath]：
/// - 路径为空或文件不存在或加载失败时返回 null
/// - 路径变化时自动重建（dispose 旧引擎）
typedef LxMetadataEngineResult = ({
  LxMetadataEngine engine,
  List<({String id, String name})> libraries,
  String pluginId,
});

final lxMetadataEngineProvider =
    FutureProvider<LxMetadataEngineResult?>((ref) async {
      final pluginPath = ref.watch(
        userPreferenceProvider.select((p) => p.lxMetadataPluginPath),
      );
      if (pluginPath == null || pluginPath.isEmpty) return null;

      final engine = LxMetadataEngine();
      await engine.init();

      if (!await _pluginExists(pluginPath, '元数据插件')) {
        engine.dispose();
        return null;
      }
      final content = await File(pluginPath).readAsString();
      final libraries = await engine.loadPluginWithLibraries(content);
      if (libraries.isEmpty) {
        log.warning('LxMusic', '元数据插件 $pluginPath 未注册任何库，跳过');
        engine.dispose();
        return null;
      }

      final pluginId = _derivePluginId(pluginPath);
      ref.onDispose(() => engine.dispose());
      log.info(
        'LxMusic',
        '插件加载成功，注册了 ${libraries.length} 个库: '
        '${libraries.map((l) => l.id).join(", ")}',
      );
      return (engine: engine, libraries: libraries, pluginId: pluginId);
    });

/// LxSourceEngine + 已加载的音源插件
///
/// 依赖 [UserPreference.lxSourcePluginPaths]：路径列表变化时自动重建。
final lxSourceEngineProvider = FutureProvider<LxSourceEngine>((ref) async {
  final paths = ref.watch(
    userPreferenceProvider.select((p) => p.lxSourcePluginPaths),
  );
  final engine = LxSourceEngine();
  for (final path in paths) {
    if (!await _pluginExists(path, '音源插件')) continue;
    final content = await File(path).readAsString();
    await engine.loadPlugin(content);
  }
  ref.onDispose(() => engine.dispose());
  return engine;
});

/// Lx 音乐服务实例（元数据插件 + 音源插件组合）
///
/// 元数据插件未加载时返回 null。
final lxMusicServerProvider = FutureProvider<LxMusicServer?>((ref) async {
  final metadata = await ref.watch(lxMetadataEngineProvider.future);
  if (metadata == null) return null;

  final sourceEngine = await ref.watch(lxSourceEngineProvider.future);

  return LxMusicServer(
    metadataEngine: metadata.engine,
    sourceEngine: sourceEngine,
    pluginId: metadata.pluginId,
    libraries: metadata.libraries,
  );
});

/// Lx 元数据插件路径 Notifier
///
/// 管理 Lx 元数据插件文件（仅允许一份），
/// 供平台页面和设置页面共用。
/// 元数据插件用于提供音乐搜索、歌曲详情等元信息。
///
/// 注意：本 Notifier 仅负责路径状态与持久化，
/// 实际的引擎/服务创建由 [lxMetadataEngineProvider] / [lxMusicServerProvider] 自动完成。
class LxMetadataPluginPathsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    final path = ref.watch(
      userPreferenceProvider.select((p) => p.lxMetadataPluginPath),
    );
    return path != null ? [path] : [];
  }

  /// 添加元数据插件
  ///
  /// 仅允许上传一份。若已有插件则忽略。
  /// 如需替换请使用 [replacePlugin]。
  /// 返回是否添加成功（文件存在即视为成功，实际加载由 Provider 完成）。
  Future<bool> addPlugin(String path) async {
    if (state.isNotEmpty) return false;
    if (!await _pluginExists(path, '元数据插件')) return false;
    await ref
        .read(userPreferenceProvider.notifier)
        .setLxMetadataPluginPath(path);
    state = [path];
    return true;
  }

  /// 替换元数据插件
  ///
  /// 用新文件替换现有的元数据插件。
  Future<bool> replacePlugin(String newPath) async {
    if (!await _pluginExists(newPath, '元数据插件')) return false;
    await ref
        .read(userPreferenceProvider.notifier)
        .setLxMetadataPluginPath(newPath);
    state = [newPath];
    return true;
  }

  /// 移除元数据插件
  Future<void> removePlugin(String path) async {
    await ref
        .read(userPreferenceProvider.notifier)
        .setLxMetadataPluginPath(null);
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
///
/// 注意：本 Notifier 仅负责路径状态与持久化，
/// 实际的引擎创建由 [lxSourceEngineProvider] 自动完成。
class LxSourcePluginPathsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return ref.watch(
      userPreferenceProvider.select((p) => p.lxSourcePluginPaths),
    );
  }

  /// 添加音源插件
  ///
  /// 返回插件支持的库信息列表（兼容旧接口，新设计下实际加载由 Provider 完成，
  /// 此处返回空列表）。
  Future<List<LxSourceLibrary>> addPlugin(String path) async {
    if (state.contains(path)) return [];
    state = [...state, path];
    await _save();
    return [];
  }

  /// 替换音源插件
  ///
  /// 用新文件替换旧插件，返回新插件支持的库列表（兼容旧接口，返回空列表）。
  Future<List<LxSourceLibrary>> replacePlugin(
    String oldPath,
    String newPath,
  ) async {
    if (!state.contains(oldPath)) return [];
    state = state.map((p) => p == oldPath ? newPath : p).toList();
    await _save();
    return [];
  }

  /// 移除音源插件
  Future<void> removePlugin(String path) async {
    if (!state.contains(path)) return;
    state = state.where((p) => p != path).toList();
    await _save();
  }

  Future<void> _save() async {
    await ref
        .read(userPreferenceProvider.notifier)
        .setLxSourcePluginPaths(state);
  }
}

/// Lx 音源插件路径列表
final lxSourcePluginPathsProvider =
    NotifierProvider<LxSourcePluginPathsNotifier, List<String>>(
      LxSourcePluginPathsNotifier.new,
    );
