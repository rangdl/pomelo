import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../player/audio_player_service.dart';
import '../plugins/plugin_repository.dart';
import '../runtime/lx_runtime.dart';
import '../runtime/musicfree_runtime.dart';

// ---------------------------------------------------------------------------
// 仓库与列表
// ---------------------------------------------------------------------------

/// 插件仓库（异步初始化，整个应用共享一份）。
final pluginRepositoryProvider = FutureProvider<PluginRepository>((ref) async {
  return PluginRepository.open();
});

/// 已安装插件列表。仓库发生变更后由调用方 `ref.invalidate` 刷新。
final pluginListProvider = FutureProvider<List<PluginRecord>>((ref) async {
  final repo = await ref.watch(pluginRepositoryProvider.future);
  return repo.plugins;
});

/// 可搜索的 MusicFree 插件。
final searchablePluginsProvider = Provider<List<PluginRecord>>((ref) {
  final list = ref.watch(pluginListProvider).value ?? const [];
  return list
      .where((p) =>
          p.isMusicFree && p.enabled && p.supportedMethods.contains('search'))
      .toList();
});

/// 已启用的 LX 插件。
final lxPluginsProvider = Provider<List<PluginRecord>>((ref) {
  final list = ref.watch(pluginListProvider).value ?? const [];
  return list.where((p) => p.isLx && p.enabled).toList();
});

// ---------------------------------------------------------------------------
// 选择状态
// ---------------------------------------------------------------------------

class SelectedSearchPlugin extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

final selectedSearchPluginProvider =
    NotifierProvider<SelectedSearchPlugin, String?>(SelectedSearchPlugin.new);

class SelectedLxPlugin extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

final selectedLxPluginProvider =
    NotifierProvider<SelectedLxPlugin, String?>(SelectedLxPlugin.new);

// ---------------------------------------------------------------------------
// 搜索结果 / 当前播放
// ---------------------------------------------------------------------------

class SearchResults extends Notifier<AsyncValue<List<Map<String, dynamic>>>> {
  @override
  AsyncValue<List<Map<String, dynamic>>> build() => const AsyncValue.data([]);

  void set(AsyncValue<List<Map<String, dynamic>>> value) => state = value;
}

final searchResultsProvider =
    NotifierProvider<SearchResults, AsyncValue<List<Map<String, dynamic>>>>(
  SearchResults.new,
);

class NowPlaying extends Notifier<Map<String, dynamic>?> {
  @override
  Map<String, dynamic>? build() => null;

  void set(Map<String, dynamic>? item) => state = item;
}

final nowPlayingProvider =
    NotifierProvider<NowPlaying, Map<String, dynamic>?>(NowPlaying.new);

// ---------------------------------------------------------------------------
// 播放器与运行时
// ---------------------------------------------------------------------------

/// 播放器服务（应用生命周期内单例）。
final audioPlayerProvider = Provider<AudioPlayerService>((ref) {
  final player = AudioPlayerService();
  ref.onDispose(player.dispose);
  return player;
});

/// MusicFree 运行时，按插件区分。
///
/// 注意不能用 autoDispose：`playItem` 里会先 `ref.read(...future)` 拿实例，
/// 若无其他监听者，provider 会在读取间隙被回收，导致引擎里已加载的
/// `__pluginModule` 丢失（实测报 "not defined"）。
final musicFreeRuntimeProvider =
    FutureProvider.family<MusicFreeRuntime, PluginRecord>(
  (ref, plugin) async {
    final rt = await MusicFreeRuntime.create();
    try {
      rt.loadPlugin(plugin.source, name: plugin.platform);
    } catch (_) {
      rt.dispose();
      rethrow;
    }
    ref.onDispose(rt.dispose);
    return rt;
  },
);

/// LX 运行时，加载后自动等待脚本 inited。同样不能用 autoDispose。
final lxRuntimeProvider =
    FutureProvider.family<LxUserApiRuntime, PluginRecord>(
  (ref, plugin) async {
    final rt = await LxUserApiRuntime.create();
    try {
      rt.loadScript(plugin.source, id: plugin.id, name: plugin.platform);
      final ok = await rt.waitForInit();
      if (!ok) {
        throw StateError('LX 脚本初始化失败: ${rt.initError ?? "未知原因"}');
      }
    } catch (_) {
      rt.dispose();
      rethrow;
    }
    ref.onDispose(rt.dispose);
    return rt;
  },
);

// ---------------------------------------------------------------------------
// 业务动作
// ---------------------------------------------------------------------------

class PlayerActions {
  PlayerActions(this._ref);

  final Ref _ref;

  Future<void> search(PluginRecord plugin, String query) async {
    final results = _ref.read(searchResultsProvider.notifier);
    results.set(const AsyncValue.loading());
    try {
      final rt = await _ref.read(musicFreeRuntimeProvider(plugin).future);
      final result = await rt.search(query);
      final data = (result['data'] as List).cast<dynamic>();
      results.set(AsyncValue.data(
        data
            .map((e) => Map<String, dynamic>.from(e as Map))
            .map((e) => {...e, '_pluginId': plugin.id})
            .toList(),
      ));
    } catch (e, st) {
      results.set(AsyncValue.error(e, st));
    }
  }

  /// 播放：优先用 LX 脚本按平台解析直链，失败则回退到 MusicFree 插件。
  Future<void> playItem(Map<String, dynamic> item) async {
    final repo = await _ref.read(pluginRepositoryProvider.future);
    final player = _ref.read(audioPlayerProvider);
    final ownerId = item['_pluginId'] as String?;

    String? url;
    final lxPlugin = _pickLxPlugin(repo);
    if (lxPlugin != null) {
      try {
        final lx = await _ref.read(lxRuntimeProvider(lxPlugin).future);
        final lxSource = _pickLxSource(lxPlugin, item);
        url = await lx.resolveMusicUrl(
          source: lxSource,
          musicInfo: {
            'songmid': '${item['id'] ?? ''}',
            'name': '${item['title'] ?? ''}',
            'singer': '${item['artist'] ?? ''}',
          },
        );
        debugPrint('[pomelo] LX 解析成功 plugin=${lxPlugin.platform} '
            'source=$lxSource url=$url');
      } catch (e) {
        debugPrint('[pomelo] LX 解析失败，回退 MusicFree: $e');
        url = null; // 回退
      }
    }
    if (url == null) {
      url = await _resolveWithMusicFree(repo, ownerId, item);
      debugPrint('[pomelo] MusicFree 解析 url=$url');
    }

    _ref.read(nowPlayingProvider.notifier).set(item);
    await player.open(url);
  }

  Future<String> _resolveWithMusicFree(
    PluginRepository repo,
    String? pluginId,
    Map<String, dynamic> item,
  ) async {
    final plugin = repo.plugins.where((p) => p.id == pluginId).firstOrNull;
    if (plugin == null) throw StateError('找不到来源插件');
    final rt = await _ref.read(musicFreeRuntimeProvider(plugin).future);
    final source = await rt.getMediaSource(
      Map<String, dynamic>.from(item)..remove('_pluginId'),
      'standard',
    );
    if (source == null || source['url'] is! String) {
      throw StateError('插件未返回可播放地址');
    }
    return source['url'] as String;
  }

  PluginRecord? _pickLxPlugin(PluginRepository repo) {
    final selectedId = _ref.read(selectedLxPluginProvider);
    if (selectedId != null) {
      final chosen = repo.plugins.where((p) => p.id == selectedId).firstOrNull;
      if (chosen != null && chosen.enabled) return chosen;
    }
    return repo.plugins.where((p) => p.isLx && p.enabled).firstOrNull;
  }

  /// 推断该歌曲属于哪个 LX 源：显式字段优先，其次 id 前缀，最后取脚本声明的第一个源。
  String _pickLxSource(PluginRecord lxPlugin, Map<String, dynamic> item) {
    for (final key in ['_lxSource', 'source']) {
      final v = item[key];
      if (v is String && lxPlugin.lxSources.contains(v)) return v;
    }
    final id = '${item['id'] ?? ''}';
    if (id.contains(':')) {
      final prefix = id.split(':').first;
      if (lxPlugin.lxSources.contains(prefix)) return prefix;
    }
    if (lxPlugin.lxSources.isEmpty) {
      throw StateError('LX 脚本未声明任何源');
    }
    return lxPlugin.lxSources.first;
  }
}

final playerActionsProvider = Provider<PlayerActions>(PlayerActions.new);
