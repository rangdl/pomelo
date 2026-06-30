import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/log.dart';
import 'package:pomelo/core/preferences/user_preference.dart';
import 'package:pomelo/core/preferences/user_preference_provider.dart';
import 'package:pomelo/core/storage/music_cache_dir.dart';

import 'service/local_music_server.dart';

/// 本地音乐服务实例
///
/// 在初始化时创建实例并加载已保存的目录。
/// 若用户未配置任何目录，自动将音频流缓存目录作为默认目录添加。
/// 不监听 [UserPreference.localDirectories]，避免每次目录变化都重建整个实例。
/// 后续的 addDirectory/removeDirectory 通过 [LocalMusicDirsNotifier] 直接操作实例。
/// 监听 [UserPreference.localServerName] 以响应名称变更。
final localMusicServerProvider = FutureProvider<LocalMusicServer>((ref) async {
  final pref = ref.watch(userPreferenceProvider);
  final name = pref.localServerName;
  var dirs = pref.localDirectories;

  // 缓存目录作为默认目录：用户未配置任何目录时自动添加
  if (dirs.isEmpty) {
    try {
      final cacheDir = await MusicCacheDir.getOrCreate();
      dirs = [cacheDir];
      await ref.read(userPreferenceProvider.notifier).setLocalDirectories(dirs);
      log.info('LocalMusic', '已自动添加缓存目录作为默认目录: $cacheDir');
    } catch (e) {
      log.warning('LocalMusic', '获取缓存目录失败: $e');
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
class LocalMusicDirsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    // 从 UserPreference 初始化
    return ref.watch(userPreferenceProvider.select((p) => p.localDirectories));
  }

  /// 添加目录
  Future<void> addDirectory(String path) async {
    if (state.contains(path)) return;
    final server = await ref.read(localMusicServerProvider.future);
    await server.addDirectory(path);
    state = [...state, path];
    await _save();
    _bumpVersion();
  }

  /// 移除目录
  void removeDirectory(String path) {
    if (!state.contains(path)) return;
    final server = ref.read(localMusicServerProvider).value;
    server?.removeDirectory(path);
    state = state.where((d) => d != path).toList();
    _save();
    _bumpVersion();
  }

  /// 重新扫描所有目录
  Future<void> rescanAll() async {
    final server = await ref.read(localMusicServerProvider.future);
    await server.rescanAll();
    _bumpVersion();
  }

  /// 递增版本号，通知下游 Provider 刷新
  void _bumpVersion() {
    ref.read(localMusicVersionProvider.notifier).bump();
  }

  Future<void> _save() async {
    await ref.read(userPreferenceProvider.notifier).setLocalDirectories(state);
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
