/// Lx 音乐模块 - Riverpod Providers
///
/// 管理音源脚本引擎 [LxSourceEngine] 的响应式加载与增量同步。
/// 脚本内容持久化于 drift 表（[LxSourceScriptTable]），不依赖文件系统。
library;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/services/logger/logger.dart';
import 'package:pomelo/core/models/lx_source_script.dart';
import 'package:pomelo/provider/database/database_provider.dart';
import 'package:pomelo/modules/music_lx/model/lx_source_engine.dart';
import 'package:pomelo/modules/music_lx/providers/lx_source_scripts_provider.dart';

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
