/// Lx 音源脚本管理 Provider
///
/// 从 drift `lx_source_scripts` 表加载脚本，提供增删改查。
/// 添加脚本时使用 [parseLxMusicScriptInfo] 解析元信息，
/// 并通过 [LxSourceEngine.loadPlugin] 加载验证后获取库与音质列表。
///
/// 依赖此 Provider 的 [lxSourceEngineProvider] 会在脚本列表变化时自动重建。
library;

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/models/database/app_database.dart';
import 'package:pomelo/core/models/lx_source_script.dart';
import 'package:pomelo/modules/music_lx/model/lx_source_engine.dart';
import 'package:pomelo/provider/database/database_provider.dart';
import 'package:pomelo/services/logger/logger.dart';

/// 所有 Lx 音源脚本列表
///
/// 从 drift `lx_source_scripts` 表加载，按添加时间正序。
final lxSourceScriptsProvider = FutureProvider<List<LxSourceScript>>((ref) async {
  final db = ref.watch(databaseProvider);
  final rows = await db.getAllLxSourceScripts();
  return rows
      .map(
        (e) => LxSourceScript.fromEntity(
          id: e.id,
          name: e.name,
          description: e.description,
          author: e.author,
          homepage: e.homepage,
          version: e.version,
          script: e.script,
          librariesJson: e.librariesJson,
          createdAt: e.createdAt,
          enabled: e.enabled,
        ),
      )
      .toList();
});

/// Lx 音源脚本管理 Notifier
///
/// 提供脚本增删，所有写操作完成后刷新 [lxSourceScriptsProvider]。
class LxSourceScriptsNotifier extends Notifier<List<LxSourceScript>> {
  AppDatabase get _db => ref.read(databaseProvider);

  @override
  List<LxSourceScript> build() {
    return ref.watch(lxSourceScriptsProvider).value ?? const [];
  }

  /// 添加脚本
  ///
  /// 1. 使用 [parseLxMusicScriptInfo] 解析脚本头部元信息
  /// 2. 调用 [LxSourceEngine.loadPlugin] 临时加载验证并获取库列表
  /// 3. 持久化到 drift 表
  /// 4. 刷新 [lxSourceScriptsProvider]，触发 [lxSourceEngineProvider] 重建
  ///
  /// 返回库列表；加载失败返回 null。
  Future<List<LxSourceLibrary>?> addScript(String scriptContent) async {
    // 基于脚本内容生成稳定 id
    final id = 'lxsrc_${scriptContent.hashCode.abs()}';

    // 解析元信息
    final info = LxSourceEngine.parseLxMusicScriptInfo(scriptContent);
    final name = info['name']?.isNotEmpty == true ? info['name']! : '未命名脚本';

    // 临时加载验证并获取库列表
    final tempEngine = LxSourceEngine();
    List<LxSourceLibrary> libraries;
    try {
      libraries = await tempEngine.loadPlugin(scriptContent);
    } catch (e) {
      AppLogger.log.e('[LxSourceScripts] 脚本加载验证失败: $e');
      tempEngine.dispose();
      return null;
    } finally {
      // loadPlugin 失败时 engine 已被内部 dispose，成功时需要外部 dispose
      // 由于这里是临时验证引擎，始终 dispose 释放资源
    }
    // 临时验证引擎始终 dispose（已加载的插件不需要保留）
    tempEngine.dispose();

    if (libraries.isEmpty) {
      AppLogger.log.w('[LxSourceScripts] 脚本未注册任何库，仍保存以备后用');
    }

    // 持久化
    await _db.upsertLxSourceScript(
      LxSourceScriptTableCompanion.insert(
        id: id,
        name: name,
        description: Value(info['description']),
        author: Value(info['author']),
        homepage: Value(info['homepage']),
        version: Value(info['version']),
        script: scriptContent,
        librariesJson: Value(LxSourceScript.librariesToJson(libraries)),
        enabled: const Value(true),
      ),
    );

    // 刷新 Provider，触发 lxSourceEngineProvider 重建
    ref.invalidate(lxSourceScriptsProvider);
    AppLogger.log.i(
      '[LxSourceScripts] 脚本已保存 id=$id, 库: ${libraries.map((l) => l.id).join(", ")}',
    );
    return libraries;
  }

  /// 删除脚本
  Future<void> removeScript(String id) async {
    await _db.deleteLxSourceScript(id);
    ref.invalidate(lxSourceScriptsProvider);
    AppLogger.log.i('[LxSourceScripts] 脚本已删除 id=$id');
  }
}

/// Lx 音源脚本管理 Provider
final lxSourceScriptsNotifierProvider =
    NotifierProvider<LxSourceScriptsNotifier, List<LxSourceScript>>(
  LxSourceScriptsNotifier.new,
);
