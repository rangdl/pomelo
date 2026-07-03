import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/services/logger/logger.dart';
import 'package:pomelo/core/models/music_server_config.dart';
import 'package:pomelo/provider/music/music_server_config_provider.dart';
import 'package:pomelo/core/storage/music_cache_dir.dart';

import 'service/local_music_server.dart';

/// 本地音乐配置 ID（固定）
const _localConfigId = 'local';

/// 本地音乐服务实例
///
/// 从 [musicServerConfigsProvider] 读取 LocalMusicConfig，
/// 配置变化时自动重建。
/// 若用户未配置任何目录，自动将音频流缓存目录作为默认目录添加。
final localMusicServerProvider = FutureProvider<LocalMusicServer>((ref) async {
  final configs = await ref.watch(musicServerConfigsProvider.future);
  final localConfig = configs.whereType<LocalMusicConfig>().firstOrNull;

  var name = localConfig?.name ?? '本地音乐';
  var dirs = localConfig?.directories ?? const <String>[];

  // 缓存目录作为默认目录：用户未配置任何目录时自动添加
  if (dirs.isEmpty) {
    try {
      final cacheDir = await MusicCacheDir.getOrCreate();
      dirs = [cacheDir];
      // 自动写入默认配置
      await ref
          .read(musicServerConfigsNotifierProvider.notifier)
          .upsert(
            LocalMusicConfig(id: _localConfigId, name: name, directories: dirs),
          );
      AppLogger.log.i('[LocalMusic] 已自动添加缓存目录作为默认目录: $cacheDir');
    } catch (e) {
      AppLogger.log.w('[LocalMusic] 获取缓存目录失败: $e');
    }
  }

  final server = LocalMusicServer(name: name);
  for (final dir in dirs) {
    await server.addDirectory(dir);
  }
  ref.onDispose(() => server.clear());
  return server;
});

/// 本地音乐数据版本号 Notifier
///
/// 每次目录增删或扫描完成后自增，驱动依赖此 Provider 的下游刷新。
class LocalMusicVersionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

/// 本地音乐数据版本号
final localMusicVersionProvider =
    NotifierProvider<LocalMusicVersionNotifier, int>(
      LocalMusicVersionNotifier.new,
    );

/// 本地音乐目录列表 Notifier
///
/// 读写 LocalMusicConfig（通过 [musicServerConfigsNotifierProvider]）。
class LocalMusicDirsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    final configs = ref.watch(musicServerConfigsProvider).value ?? const [];
    final localConfig = configs.whereType<LocalMusicConfig>().firstOrNull;
    return localConfig?.directories ?? const [];
  }

  /// 添加目录
  Future<void> addDirectory(String path) async {
    if (state.contains(path)) return;
    final server = await ref.read(localMusicServerProvider.future);
    await server.addDirectory(path);
    final newDirs = [...state, path];
    await _save(newDirs);
    _bumpVersion();
  }

  /// 移除目录
  void removeDirectory(String path) {
    if (!state.contains(path)) return;
    final server = ref.read(localMusicServerProvider).value;
    server?.removeDirectory(path);
    final newDirs = state.where((d) => d != path).toList();
    _save(newDirs);
    _bumpVersion();
  }

  /// 重新扫描所有目录
  Future<void> rescanAll() async {
    final server = await ref.read(localMusicServerProvider.future);
    await server.rescanAll();
    _bumpVersion();
  }

  /// 更新服务名称
  Future<void> setName(String name) async {
    final configs = ref.read(musicServerConfigsProvider).value ?? const [];
    final localConfig = configs.whereType<LocalMusicConfig>().firstOrNull;
    await ref
        .read(musicServerConfigsNotifierProvider.notifier)
        .upsert(
          LocalMusicConfig(
            id: _localConfigId,
            name: name,
            directories: localConfig?.directories ?? state,
          ),
        );
  }

  /// 递增版本号，通知下游 Provider 刷新
  void _bumpVersion() {
    ref.read(localMusicVersionProvider.notifier).bump();
  }

  Future<void> _save(List<String> dirs) async {
    final configs = ref.read(musicServerConfigsProvider).value ?? const [];
    final localConfig = configs.whereType<LocalMusicConfig>().firstOrNull;
    await ref
        .read(musicServerConfigsNotifierProvider.notifier)
        .upsert(
          LocalMusicConfig(
            id: _localConfigId,
            name: localConfig?.name ?? '本地音乐',
            directories: dirs,
          ),
        );
    state = dirs;
  }
}

/// 本地音乐目录列表
final localMusicDirsProvider =
    NotifierProvider<LocalMusicDirsNotifier, List<String>>(
      LocalMusicDirsNotifier.new,
    );

/// 本地音乐歌曲数量
///
/// 依赖 [localMusicVersionProvider]，在目录/扫描变更后自动刷新。
final localMusicSongCountProvider = Provider<int>((ref) {
  // 监听版本号，版本变化时触发重建
  ref.watch(localMusicVersionProvider);
  final server = ref.watch(localMusicServerProvider).value;
  return server?.trackCount ?? 0;
});
