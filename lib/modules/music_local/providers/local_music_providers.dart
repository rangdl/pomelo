import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/module/module_manager.dart';
import 'package:pomelo/core/storage/settings.dart';
import 'package:pomelo/modules/music_local/music_local_module.dart';
import '../repository/local_music_provider.dart';

/// Settings key: 本地音乐目录列表（JSON 数组字符串）
const _kLocalMusicDirs = 'music_local_directories';

/// 持有 MusicLocalModule 实例的 Provider
final musicLocalModuleProvider = Provider<MusicLocalModule?>((ref) {
  final mm = ModuleManager();
  return mm.find<MusicLocalModule>('music_local');
});

/// 本地音乐提供者实例
final localMusicProviderProvider = Provider<LocalMusicProvider?>((ref) {
  return ref.watch(musicLocalModuleProvider)?.provider;
});

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
    await module?.provider.addDirectory(path);
    state = [...state, path];
    await _save();
  }

  /// 移除目录
  void removeDirectory(String path) {
    final module = ref.read(musicLocalModuleProvider);
    module?.provider.removeDirectory(path);
    state = state.where((d) => d != path).toList();
    _save();
  }

  /// 重新扫描所有目录
  Future<void> rescanAll() async {
    final module = ref.read(musicLocalModuleProvider);
    await module?.provider.rescanAll();
  }

  Future<void> _save() async {
    await Settings.set(_kLocalMusicDirs, jsonEncode(state));
  }
}

/// 本地音乐目录列表
final localMusicDirsProvider =
    NotifierProvider<LocalMusicDirsNotifier, List<String>>(
      LocalMusicDirsNotifier.new,
    );

/// 本地音乐歌曲数量
final localMusicSongCountProvider = Provider<int>((ref) {
  final provider = ref.watch(localMusicProviderProvider);
  return provider?.songCount ?? 0;
});
