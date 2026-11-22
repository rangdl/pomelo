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

/// 播放模式。
enum PlayMode {
  /// 列表循环
  listLoop,

  /// 单曲循环
  singleLoop,

  /// 顺序播放（播完最后一首停止）
  sequential;

  String get label => switch (this) {
        PlayMode.listLoop => '列表循环',
        PlayMode.singleLoop => '单曲循环',
        PlayMode.sequential => '顺序播放',
      };
}

/// 播放队列。
class PlayQueue extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() => const [];

  /// 替换整个队列并定位到 [index]。
  void setAll(List<Map<String, dynamic>> items, {int index = 0}) {
    state = List.unmodifiable(items);
    _index = index.clamp(0, items.isEmpty ? 0 : items.length - 1);
  }

  int _index = 0;
  int get index => _index;

  Map<String, dynamic>? get current =>
      (state.isEmpty || _index < 0 || _index >= state.length)
          ? null
          : state[_index];

  void jumpTo(int index) {
    if (state.isEmpty) return;
    _index = index.clamp(0, state.length - 1);
    // state 引用不变不会触发监听，故复制一份列表
    state = List.unmodifiable(state);
  }

  void clear() {
    state = const [];
    _index = 0;
  }
}

final playQueueProvider =
    NotifierProvider<PlayQueue, List<Map<String, dynamic>>>(PlayQueue.new);

class PlayModeNotifier extends Notifier<PlayMode> {
  @override
  PlayMode build() => PlayMode.listLoop;

  void cycle() {
    state = PlayMode.values[(state.index + 1) % PlayMode.values.length];
  }
}

final playModeProvider =
    NotifierProvider<PlayModeNotifier, PlayMode>(PlayModeNotifier.new);

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
            .map((e) => {
                  ...e,
                  '_pluginId': plugin.id,
                  // 结果自身没声明时，用插件级默认值
                  if (e['lxSource'] == null && plugin.lxSource != null)
                    'lxSource': plugin.lxSource,
                })
            .toList(),
      ));
    } catch (e, st) {
      results.set(AsyncValue.error(e, st));
    }
  }

  /// 解析并播放一首歌（不改变队列）。
  Future<void> playItem(Map<String, dynamic> item) async {
    final repo = await _ref.read(pluginRepositoryProvider.future);
    final player = _ref.read(audioPlayerProvider);
    final url = await _resolveUrl(repo, item);

    _ref.read(nowPlayingProvider.notifier).set(item);
    await player.open(url);
  }

  /// 从列表的某一首开始播放：替换队列并定位。
  Future<void> playFromList(
    List<Map<String, dynamic>> items,
    int index,
  ) async {
    if (items.isEmpty) return;
    final queue = _ref.read(playQueueProvider.notifier);
    queue.setAll(items, index: index);
    await playItem(items[index.clamp(0, items.length - 1)]);
  }

  /// 上一首 / 下一首。[auto] 表示由「播放完成」触发，需遵守播放模式。
  Future<void> skip({required bool next, bool auto = false}) async {
    final queue = _ref.read(playQueueProvider.notifier);
    final items = _ref.read(playQueueProvider);
    if (items.isEmpty) return;

    final mode = _ref.read(playModeProvider);
    if (auto && mode == PlayMode.singleLoop) {
      await playItem(items[queue.index]);
      return;
    }

    var nextIndex = next ? queue.index + 1 : queue.index - 1;
    if (nextIndex >= items.length) {
      // 顺序播放到末尾停止；否则回到开头
      if (mode == PlayMode.sequential && auto) {
        await _ref.read(audioPlayerProvider).pause();
        return;
      }
      nextIndex = 0;
    }
    if (nextIndex < 0) nextIndex = items.length - 1;

    queue.jumpTo(nextIndex);
    await playItem(items[nextIndex]);
  }

  Future<void> _playNextOnComplete() => skip(next: true, auto: true);

  Future<String> _resolveUrl(
    PluginRepository repo,
    Map<String, dynamic> item,
  ) async {
    final ownerId = item['_pluginId'] as String?;

    final lxPlugin = _pickLxPlugin(repo, item);
    if (lxPlugin != null) {
      try {
        final lx = await _ref.read(lxRuntimeProvider(lxPlugin).future);
        final lxSource = item['lxSource'] as String;
        final url = await lx.resolveMusicUrl(
          source: lxSource,
          musicInfo: {
            'songmid': '${item['id'] ?? ''}',
            'name': '${item['title'] ?? ''}',
            'singer': '${item['artist'] ?? ''}',
          },
        );
        debugPrint('[pomelo] LX 解析成功 plugin=${lxPlugin.platform} '
            'source=$lxSource url=$url');
        return url;
      } catch (e) {
        debugPrint('[pomelo] LX 解析失败，回退 MusicFree: $e');
      }
    }

    final url = await _resolveWithMusicFree(repo, ownerId, item);
    debugPrint('[pomelo] MusicFree 解析 url=$url');
    return url;
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

  /// 选出能处理该歌曲的 LX 插件。
  ///
  /// 匹配规则：歌曲带 `lxSource` → 用该源；此时优先选「声明了这个源」的脚本
  /// （用户手动指定的脚本若无此源，则从其它已启用脚本里找）。
  PluginRecord? _pickLxPlugin(
    PluginRepository repo,
    Map<String, dynamic> item,
  ) {
    final source = item['lxSource'];
    final lxPlugins = repo.plugins.where((p) => p.isLx && p.enabled).toList();
    if (lxPlugins.isEmpty) return null;

    if (source is String && source.isNotEmpty) {
      final selectedId = _ref.read(selectedLxPluginProvider);
      final selected =
          lxPlugins.where((p) => p.id == selectedId).firstOrNull;
      if (selected != null && selected.lxSources.contains(source)) {
        return selected;
      }
      return lxPlugins
          .where((p) => p.lxSources.contains(source))
          .firstOrNull;
    }

    // 歌曲未声明源：仅在用户显式指定脚本时使用，避免猜错平台。
    final selectedId = _ref.read(selectedLxPluginProvider);
    if (selectedId == null) return null;
    return lxPlugins.where((p) => p.id == selectedId).firstOrNull;
  }
}

final playerActionsProvider = Provider<PlayerActions>((ref) {
  final actions = PlayerActions(ref);
  // 播放完成后按播放模式自动切歌
  ref.read(audioPlayerProvider).onCompleted(() {
    actions._playNextOnComplete();
  });
  return actions;
});
