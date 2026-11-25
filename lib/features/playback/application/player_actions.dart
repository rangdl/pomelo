import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../plugins/data/plugin_repository.dart';
import '../../plugins/domain/plugin_record.dart';
import '../../plugins/presentation/plugin_providers.dart';
import '../../search/presentation/search_providers.dart';
import '../domain/play_mode.dart';
import '../presentation/playback_providers.dart';

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
      results.set(
        AsyncValue.data(
          data
              .map((e) => Map<String, dynamic>.from(e as Map))
              .map(
                (e) => {
                  ...e,
                  '_pluginId': plugin.id,
                  // 结果自身没声明时，用插件级默认值
                  if (e['lxSource'] == null && plugin.lxSource != null)
                    'lxSource': plugin.lxSource,
                },
              )
              .toList(),
        ),
      );
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
  Future<void> playFromList(List<Map<String, dynamic>> items, int index) async {
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
        debugPrint(
          '[pomelo] LX 解析成功 plugin=${lxPlugin.platform} '
          'source=$lxSource url=$url',
        );
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
      final selected = lxPlugins.where((p) => p.id == selectedId).firstOrNull;
      if (selected != null && selected.lxSources.contains(source)) {
        return selected;
      }
      return lxPlugins.where((p) => p.lxSources.contains(source)).firstOrNull;
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
