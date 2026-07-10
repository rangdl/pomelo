/// Lx 音乐模块 - Riverpod Providers
///
/// 管理 Lx 插件配置的响应式状态，并通过 Provider 直接创建 [LxMusicServer] 实例。
/// 元数据插件从 [musicServerConfigsProvider] 读取 LxPluginConfig.metadataPluginPath，
/// 音源脚本从 [lxSourceScriptsProvider] 读取（持久化到 drift 表，不依赖文件）。
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/services/logger/logger.dart';
import 'package:pomelo/core/models/lx_source_script.dart';
import 'package:pomelo/core/models/music_server_config.dart';
import 'package:pomelo/provider/database/database_provider.dart';
import 'package:pomelo/provider/music/music_server_config_provider.dart';
import 'package:pomelo/modules/music_lx/model/lx_metadata_engine.dart';
import 'package:pomelo/modules/music_lx/model/lx_music_server.dart';
import 'package:pomelo/modules/music_lx/model/lx_source_engine.dart';
import 'package:pomelo/modules/music_lx/providers/lx_source_scripts_provider.dart';

/// Lx 插件配置 ID（固定）
const _lxConfigId = 'lx';

/// 从插件路径生成 pluginId（取文件名的 hash）
String _derivePluginId(String path) {
  final fileName = path
      .split(RegExp(r'[/\\]'))
      .last
      .replaceAll(RegExp(r'\.[^.]+$'), '');
  return '${fileName}_${path.hashCode.abs()}';
}

/// 检查插件文件是否存在，不存在则记录警告日志。
Future<bool> _pluginExists(String path, String label) async {
  if (!await File(path).exists()) {
    AppLogger.log.w('[LxMusic] $label文件不存在 $path');
    return false;
  }
  return true;
}

/// LxMetadataEngine + 已加载的插件信息
typedef LxMetadataEngineResult = ({
  LxMetadataEngine engine,
  List<({String id, String name})> libraries,
  String pluginId,
});

/// LxMetadataEngine Provider
///
/// 从 [musicServerConfigsProvider] 读取 LxPluginConfig.metadataPluginPath。
/// 路径为空或文件不存在或加载失败时返回 null。
final lxMetadataEngineProvider = FutureProvider<LxMetadataEngineResult?>((
  ref,
) async {
  final configs = await ref.watch(musicServerConfigsProvider.future);
  final lxConfig = configs.whereType<LxPluginConfig>().firstOrNull;
  final pluginPath = lxConfig?.metadataPluginPath;
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
    AppLogger.log.w('[LxMusic] 元数据插件 $pluginPath 未注册任何库，跳过');
    engine.dispose();
    return null;
  }

  final pluginId = _derivePluginId(pluginPath);
  ref.onDispose(() => engine.dispose());
  AppLogger.log.i(
    '[LxMusic] 插件加载成功，注册了 ${libraries.length} 个库: '
    '${libraries.map((l) => l.id).join(", ")}',
  );
  return (engine: engine, libraries: libraries, pluginId: pluginId);
});

/// LxSourceEngine Provider
///
/// 从 [lxSourceScriptsProvider] 读取所有持久化的音源脚本，
/// 逐个加载到 [LxSourceEngine]。脚本内容直接存于 drift 表，不依赖文件系统。
///
/// 增量更新：脚本列表变化（添加/删除/启停）时，仅对差异部分操作，
/// 不全量重建引擎。通过 [LxSourceEngine.loadPluginWithId] / [unloadPlugin] 实现。
final lxSourceEngineProvider = FutureProvider<LxSourceEngine>((ref) async {
  final scripts = await ref.watch(lxSourceScriptsProvider.future);
  final engine = LxSourceEngine();

  // 首次加载所有已启用的脚本
  for (final script in scripts) {
    if (!script.enabled) continue;
    try {
      final libs = await engine.loadPluginWithId(script.id, script.script);
      AppLogger.log.i(
        '[LxSourceEngine] 脚本 ${script.name} 加载成功，库: ${libs.map((l) => l.id).join(", ")}',
      );
    } catch (e, s) {
      AppLogger.reportError(
        e,
        s,
        '[LxSourceEngine] 脚本 ${script.name} 加载失败: $e',
      );
    }
  }

  // 使用统计上报：每次 getMusicUrl 完成后写入数据库
  engine.onUsageReport = (scriptId, libraryId, success, durationMs) async {
    try {
      final db = ref.read(databaseProvider);
      await db.incrementLxSourceUsage(
        scriptId: scriptId,
        libraryId: libraryId,
        success: success,
        durationMs: durationMs,
      );
    } catch (e) {
      AppLogger.log.w('[LxSourceEngine] 使用统计写入失败: $e');
    }
  };

  // 监听脚本列表变化，增量同步（不全量重建）
  ref.listen<AsyncValue<List<LxSourceScript>>>(
    lxSourceScriptsProvider,
    (prev, next) {
      next.whenData((newScripts) {
        final oldScripts = prev?.value ?? const <LxSourceScript>[];
        _syncPlugins(engine, oldScripts, newScripts);
      });
    },
  );

  ref.onDispose(() => engine.dispose());
  return engine;
});

/// 增量同步插件：对比新旧脚本列表，仅对差异部分操作
///
/// 对比维度：
/// - 删除：旧列表中存在但新列表中不存在的 scriptId → [LxSourceEngine.unloadPlugin]
/// - 新增：新列表中存在但旧列表中不存在的 scriptId → 若启用则 [loadPluginWithId]
/// - 内容变化：script 字段不同 → 卸载后重新加载（若启用）
/// - 启停变化：仅 enabled 不同 → 启用时加载，禁用时卸载
void _syncPlugins(
  LxSourceEngine engine,
  List<LxSourceScript> oldScripts,
  List<LxSourceScript> newScripts,
) {
  final oldMap = {for (final s in oldScripts) s.id: s};
  final newMap = {for (final s in newScripts) s.id: s};

  // 1. 移除已删除的脚本
  for (final id in oldMap.keys) {
    if (!newMap.containsKey(id)) {
      engine.unloadPlugin(id);
    }
  }

  // 2. 处理新增或变更的脚本
  for (final newScript in newMap.values) {
    final oldScript = oldMap[newScript.id];

    if (oldScript == null) {
      // 新增脚本
      if (newScript.enabled) {
        _loadScriptAsync(engine, newScript);
      }
      continue;
    }

    // 已存在，检查是否需要变更
    final contentChanged = oldScript.script != newScript.script;
    final enabledChanged = oldScript.enabled != newScript.enabled;

    if (contentChanged) {
      // 内容变化，卸载后按启用状态重新加载
      engine.unloadPlugin(newScript.id);
      if (newScript.enabled) {
        _loadScriptAsync(engine, newScript);
      }
    } else if (enabledChanged) {
      // 仅启停状态变化
      if (newScript.enabled) {
        _loadScriptAsync(engine, newScript);
      } else {
        engine.unloadPlugin(newScript.id);
      }
    }
  }
}

/// 异步加载脚本（fire-and-forget），失败仅记录日志
Future<void> _loadScriptAsync(LxSourceEngine engine, LxSourceScript script) async {
  try {
    final libs = await engine.loadPluginWithId(script.id, script.script);
    AppLogger.log.i(
      '[LxSourceEngine] 脚本 ${script.name} 增量加载成功，库: ${libs.map((l) => l.id).join(", ")}',
    );
  } catch (e, s) {
    AppLogger.reportError(e, s, '[LxSourceEngine] 脚本 ${script.name} 增量加载失败: $e');
  }
}

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
/// 读写 LxPluginConfig.metadataPluginPath（通过 [musicServerConfigsNotifierProvider]）。
class LxMetadataPluginPathsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    final configs = ref.watch(musicServerConfigsProvider).value ?? const [];
    final lxConfig = configs.whereType<LxPluginConfig>().firstOrNull;
    final path = lxConfig?.metadataPluginPath;
    return (path != null && path.isNotEmpty) ? [path] : [];
  }

  /// 添加元数据插件（仅允许一份）
  Future<bool> addPlugin(String path) async {
    if (state.isNotEmpty) return false;
    if (!await _pluginExists(path, '元数据插件')) return false;
    await _save(metadataPath: path);
    state = [path];
    return true;
  }

  /// 替换元数据插件
  Future<bool> replacePlugin(String newPath) async {
    if (!await _pluginExists(newPath, '元数据插件')) return false;
    await _save(metadataPath: newPath);
    state = [newPath];
    return true;
  }

  /// 移除元数据插件
  Future<void> removePlugin(String path) async {
    await _save(metadataPath: '');
    state = [];
  }

  Future<void> _save({required String metadataPath}) async {
    final configs = ref.read(musicServerConfigsProvider).value ?? const [];
    final lxConfig = configs.whereType<LxPluginConfig>().firstOrNull;
    await ref
        .read(musicServerConfigsNotifierProvider.notifier)
        .upsert(
          LxPluginConfig(
            id: _lxConfigId,
            name: lxConfig?.name ?? 'Lx 音乐',
            metadataPluginPath: metadataPath,
            // sourcePluginPaths 已废弃，音源脚本改用 LxSourceScriptTable 存储
            sourcePluginPaths: const [],
          ),
        );
  }
}

/// Lx 元数据插件路径列表
final lxMetadataPluginPathsProvider =
    NotifierProvider<LxMetadataPluginPathsNotifier, List<String>>(
      LxMetadataPluginPathsNotifier.new,
    );
