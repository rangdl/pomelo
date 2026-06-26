import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/module/module_manager.dart';
import 'package:pomelo/core/storage/settings.dart';
import 'package:pomelo/core/storage/storage_keys.dart';
import 'package:pomelo/modules/music_local/music_local_module.dart';
import 'service/local_music_service.dart';

/// 持有 MusicLocalModule 实例的 Provider
final musicLocalModuleProvider = Provider<MusicLocalModule?>((ref) {
  final mm = ModuleManager();
  return mm.find<MusicLocalModule>('music_local');
});

/// 本地音乐服务实例
final localMusicServiceProvider = Provider<LocalMusicService?>((ref) {
  return ref.watch(musicLocalModuleProvider)?.service;
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
    // 从 Settings 初始化
    return MusicLocalModule.loadDirectories();
  }

  /// 添加目录
  Future<void> addDirectory(String path) async {
    if (state.contains(path)) return;
    final module = ref.read(musicLocalModuleProvider);
    await module?.service.addDirectory(path);
    state = [...state, path];
    await _save();
    _bumpVersion();
  }

  /// 移除目录
  void removeDirectory(String path) {
    final module = ref.read(musicLocalModuleProvider);
    module?.service.removeDirectory(path);
    state = state.where((d) => d != path).toList();
    _save();
    _bumpVersion();
  }

  /// 重新扫描所有目录
  Future<void> rescanAll() async {
    final module = ref.read(musicLocalModuleProvider);
    await module?.service.rescanAll();
    _bumpVersion();
  }

  /// 递增版本号，通知下游 Provider 刷新
  void _bumpVersion() {
    ref.read(localMusicVersionProvider.notifier).bump();
  }

  Future<void> _save() async {
    await Settings.set(StorageKeys.musicLocalDirectories, jsonEncode(state));
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
  final service = ref.read(localMusicServiceProvider);
  return service?.trackCount ?? 0;
});
