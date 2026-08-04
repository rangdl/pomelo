/// 音乐服务配置 Provider
///
/// 统一管理所有音乐源配置的读取、写入、删除。
/// 配置持久化到 drift `music_server_configs` 表，
/// UI 与各音乐源 Provider 通过此 Provider 响应式获取配置。
library;

import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/models/database/app_database.dart';
import 'package:pomelo/provider/database/database_provider.dart';
import 'package:pomelo/core/models/metadata/music_source_type.dart';
import 'package:pomelo/core/models/music_server_config.dart';

/// 所有音乐服务配置列表
///
/// 从 drift `music_server_configs` 表加载全部配置。
/// 配置变更通过 [MusicServerConfigsNotifier] 的增删改方法触发刷新。
final musicServerConfigsProvider = FutureProvider<List<MusicServerConfig>>((
  ref,
) async {
  final db = ref.watch(databaseProvider);
  final rows = await db.getAllMusicServerConfigs();
  return rows.map(_entityToConfig).toList();
});

/// 音乐服务配置管理 Notifier
///
/// 负责配置的增删改，所有写操作完成后刷新 [musicServerConfigsProvider]。
class MusicServerConfigsNotifier extends Notifier<List<MusicServerConfig>> {
  AppDatabase get _db => ref.read(databaseProvider);

  @override
  List<MusicServerConfig> build() {
    return ref.watch(musicServerConfigsProvider).value ?? const [];
  }

  /// 新增或更新配置（upsert）
  Future<void> upsert(MusicServerConfig config) async {
    await _db.upsertMusicServerConfig(
      MusicServerConfigTableCompanion.insert(
        id: config.id,
        name: config.name,
        type: config.type.name,
        configJson: Value(jsonEncode(config.extraToJson())),
        enabled: const Value(true),
      ),
    );
    ref.invalidate(musicServerConfigsProvider);
  }

  /// 删除指定 id 的配置
  Future<void> remove(String id) async {
    await _db.deleteMusicServerConfig(id);
    ref.invalidate(musicServerConfigsProvider);
  }

  /// 获取指定类型的所有配置
  List<MusicServerConfig> getByType(MusicSourceType type) {
    return state.where((c) => c.type == type).toList();
  }

  /// 获取指定 id 的配置
  MusicServerConfig? getById(String id) {
    for (final c in state) {
      if (c.id == id) return c;
    }
    return null;
  }
}

/// 音乐服务配置管理
final musicServerConfigsNotifierProvider =
    NotifierProvider<MusicServerConfigsNotifier, List<MusicServerConfig>>(
      MusicServerConfigsNotifier.new,
    );

/// 将 drift 实体转换为 MusicServerConfig 子类实例
MusicServerConfig _entityToConfig(MusicServerConfigEntity entity) {
  final type = MusicSourceType.values.firstWhere(
    (t) => t.name == entity.type,
    orElse: () => MusicSourceType.local,
  );
  final extra = entity.configJson.isNotEmpty
      ? Map<String, dynamic>.from(jsonDecode(entity.configJson) as Map)
      : <String, dynamic>{};
  return MusicServerConfig.fromJson(entity.id, entity.name, type, extra);
}
