import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/app_keys.dart';
import '../../plugins/data/plugin_repository.dart';
import '../../plugins/domain/plugin_record.dart';
import '../../plugins/presentation/plugin_providers.dart';
import '../../search/presentation/search_providers.dart';
import '../data/audio_player_service.dart';
import '../domain/play_mode.dart';
import '../presentation/playback_providers.dart';

/// 一次「解析结果」：可播放地址 + 底层需要的请求头（防盗链 Referer/UA 等）。
class ResolvedSource {
  const ResolvedSource(this.url, [this.headers]);

  final String url;
  final Map<String, String>? headers;
}

class PlayerActions {
  PlayerActions(this._ref);

  final Ref _ref;

  Future<void> search(PluginRecord plugin, String query, {int page = 1}) async {
    final results = _ref.read(searchResultsProvider.notifier);
    // 第一页显示 loading，加载更多时保留旧结果、追加展示。
    if (page <= 1) {
      results.set(const AsyncValue.loading());
    }
    try {
      final rt = await _ref.read(musicFreeRuntimeProvider(plugin).future);
      final result = await rt.search(query, page: page);
      final data = (result['data'] as List).cast<dynamic>();
      final mapped = data
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
          .toList();
      // 记录是否还有下一页，供「加载更多」判断。
      _searchHasMore = result['isEnd'] != true && mapped.isNotEmpty;
      if (page <= 1) {
        results.set(AsyncValue.data(mapped));
      } else {
        final prev = _ref.read(searchResultsProvider).value ?? const [];
        results.set(AsyncValue.data([...prev, ...mapped]));
      }
    } catch (e, st) {
      if (page <= 1) {
        results.set(AsyncValue.error(e, st));
      } else {
        _searchHasMore = false;
        _toast('加载更多失败: $e');
      }
    }
  }

  /// 上一次搜索是否还有更多结果（控制「加载更多」按钮显隐）。
  bool _searchHasMore = false;
  bool get searchHasMore => _searchHasMore;

  /// 解析并播放一首歌（不改变队列）。
  Future<void> playItem(Map<String, dynamic> item) async {
    final repo = await _ref.read(pluginRepositoryProvider.future);
    final player = _ref.read(audioPlayerProvider);
    _ref.read(nowPlayingProvider.notifier).set(item);
    // 同步通知栏的队列位置（高亮当前曲）。
    player.updateQueueIndex(_ref.read(playQueueProvider.notifier).index);
    try {
      final source = await _resolveUrl(repo, item);
      final art = '${item['artwork'] ?? ''}';
      await player.open(
        source.url,
        headers: source.headers,
        meta: MediaMeta(
          id: '${item['id'] ?? source.url}',
          title: '${item['title'] ?? '未知歌曲'}',
          artist: '${item['artist'] ?? ''}',
          album: '${item['album'] ?? ''}',
          artUri: art.isEmpty ? null : Uri.tryParse(art),
          duration: _durationOf(item),
        ),
      );
    } catch (e) {
      _reportPlayFailure(item, '$e');
      rethrow;
    }
  }

  Duration? _durationOf(Map<String, dynamic> item) {
    final raw = item['duration'];
    final secs = raw is int ? raw : int.tryParse('${raw ?? ''}');
    if (secs == null || secs <= 0) return null;
    return Duration(seconds: secs);
  }

  /// 获取歌词原文（LRC 文本）。优先 LX 脚本 lyric action，退回 MusicFree
  /// 插件的 getLyric。拿不到返回 null。
  Future<String?> fetchLyric(Map<String, dynamic> item) async {
    final repo = await _ref.read(pluginRepositoryProvider.future);

    // 1) LX 脚本：lyric action（脚本内已缓存取链时的歌词）
    final lxPlugin = _pickLxPlugin(repo, item);
    if (lxPlugin != null) {
      try {
        final lx = await _ref.read(lxRuntimeProvider(lxPlugin).future);
        final raw = await lx.request(
          source: '${item['lxSource'] ?? ''}',
          action: 'lyric',
          info: {
            'musicInfo': {
              'songmid': '${item['id'] ?? ''}',
              'name': '${item['title'] ?? ''}',
              'singer': '${item['artist'] ?? ''}',
              'hash': '${item['id'] ?? ''}',
            },
          },
        );
        final lyric = _extractLyric(raw);
        if (lyric != null && lyric.isNotEmpty) return lyric;
      } catch (e) {
        debugPrint('[pomelo] LX 歌词获取失败: $e');
      }
    }

    // 2) MusicFree 插件 getLyric
    final ownerId = item['_pluginId'] as String?;
    final plugin = repo.plugins.where((p) => p.id == ownerId).firstOrNull;
    if (plugin != null && plugin.supportedMethods.contains('getLyric')) {
      try {
        final rt = await _ref.read(musicFreeRuntimeProvider(plugin).future);
        final raw = await rt.invoke(
          'getLyric',
          [Map<String, dynamic>.from(item)..remove('_pluginId')],
        );
        final lyric = _extractLyric(raw);
        if (lyric != null && lyric.isNotEmpty) return lyric;
      } catch (e) {
        debugPrint('[pomelo] MusicFree 歌词获取失败: $e');
      }
    }
    return null;
  }

  /// 从脚本返回值里提取 LRC 文本。兼容字符串 / {lyric|rawLrc} / {lyric:{lyric|rawLrc}}。
  String? _extractLyric(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return raw;
    if (raw is Map) {
      for (final key in const ['lyric', 'rawLrc', 'lrc', 'content']) {
        final v = raw[key];
        if (v is String && v.isNotEmpty) return v;
        if (v is Map) {
          final inner = _extractLyric(v);
          if (inner != null && inner.isNotEmpty) return inner;
        }
      }
    }
    return null;
  }

  /// 从列表的某一首开始播放：替换队列并定位。
  Future<void> playFromList(List<Map<String, dynamic>> items, int index) async {
    if (items.isEmpty) return;
    final queue = _ref.read(playQueueProvider.notifier);
    queue.setAll(items, index: index);
    try {
      await playItem(items[index.clamp(0, items.length - 1)]);
    } catch (_) {
      // 错误已在 playItem 内提示，这里吞掉避免 UI 抛未捕获异常。
    }
  }

  /// 播放/暂停切换。
  ///
  /// 恢复的快照只有元信息、播放器里并没有真正加载过媒体；此时点「播放」需
  /// 重新解析并加载当前曲，而不是对空播放器调 play()。
  Future<void> togglePlay() async {
    final player = _ref.read(audioPlayerProvider);
    final current = _ref.read(playQueueProvider.notifier).current;
    final fallback = _ref.read(nowPlayingProvider);
    final target = current ?? fallback;
    final currentId = '${target?['id'] ?? ''}';
    // 引擎里已加载的就是这首 → 正常播放/暂停切换。
    if (player.hasLoaded(currentId)) {
      if (player.playing) {
        await player.pause();
      } else {
        await player.play();
      }
      return;
    }
    // 尚未加载（如重启后恢复的快照、或点的是队列里另一首）：重新解析并播放。
    if (target != null) {
      await _safePlay(target);
    }
  }

  /// 上一首 / 下一首。[auto] 表示由「播放完成」触发，需遵守播放模式。
  Future<void> skip({required bool next, bool auto = false}) async {
    final queue = _ref.read(playQueueProvider.notifier);
    final items = _ref.read(playQueueProvider);
    if (items.isEmpty) return;

    final mode = _ref.read(playModeProvider);
    if (auto && mode == PlayMode.singleLoop) {
      await _safePlay(items[queue.index]);
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
    await _safePlay(items[nextIndex]);
  }

  Future<void> _playNextOnComplete() => skip(next: true, auto: true);

  Timer? _errorProbeTimer;
  String? _errorProbeItemId;
  Duration _errorProbePosition = Duration.zero;

  /// 播放失败（解码/网络错误）处理。
  ///
  /// media_kit 的 error 流会把 mpv 日志里所有 error 行都发上来，其中大量是
  /// 可恢复的瞬时错误（如首次 open 的 "Failed to open"、分片重试），mpv 会
  /// 自行恢复。所以这里**不立即判死**：收到错误后延迟采样，若届时曲目已正常
  /// 推进/在播放，就忽略；只有确实卡住不动，才提示并自动跳下一首。
  void _handlePlayError(Map<String, dynamic>? item, String message) {
    // 去重：同一曲目只挂一个探测。
    final id = '${item?['id'] ?? ''}';
    if (_errorProbeTimer?.isActive == true && _errorProbeItemId == id) return;

    _errorProbeItemId = id;
    _errorProbeTimer?.cancel();
    final player = _ref.read(audioPlayerProvider);
    _errorProbePosition = player.position;

    _errorProbeTimer = Timer(const Duration(seconds: 3), () {
      final cur = _ref.read(nowPlayingProvider);
      if ('${cur?['id'] ?? ''}' != id) return; // 已经切走了
      final nowPos = player.position;
      final playing = player.playing;
      // 3 秒后仍在推进或处于播放态 → 说明 mpv 已自行恢复，忽略该错误。
      if (playing && nowPos > _errorProbePosition) return;
      if (nowPos > _errorProbePosition) return;
      // 确实卡住：提示并尝试自动跳下一首。
      _toast('播放失败: $message');
      final items = _ref.read(playQueueProvider);
      if (items.length > 1) {
        skip(next: true, auto: true);
      }
    });
  }

  void _reportPlayFailure(Map<String, dynamic> item, String message) {
    _handlePlayError(item, message);
  }

  Future<void> _safePlay(Map<String, dynamic> item) async {
    try {
      await playItem(item);
    } catch (_) {}
  }

  void _toast(String message) {
    final messenger = globalScaffoldMessengerKey.currentState;
    messenger?.showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  Future<ResolvedSource> _resolveUrl(
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
        return ResolvedSource(url);
      } catch (e) {
        debugPrint('[pomelo] LX 解析失败，回退 MusicFree: $e');
      }
    }

    final source = await _resolveWithMusicFree(repo, ownerId, item);
    debugPrint('[pomelo] MusicFree 解析 url=${source.url}');
    return source;
  }

  Future<ResolvedSource> _resolveWithMusicFree(
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
    final url = source['url'] as String;
    final headers =
        (source['headers'] as Map?)?.map((k, v) => MapEntry('$k', '$v'))
            .cast<String, String>();
    return ResolvedSource(url, headers);
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
  final player = ref.read(audioPlayerProvider);
  // 播放完成后按播放模式自动切歌
  player.onCompleted(() {
    actions._playNextOnComplete();
  });
  // 解码/网络错误：提示 + 自动跳下一首，避免卡死在无声的当前曲。
  player.onError((message) {
    actions._handlePlayError(ref.read(nowPlayingProvider), message);
  });
  // 系统通知栏 / 锁屏 / 蓝牙耳机 的上一首、下一首。
  player.skipCallback = (next) {
    actions.skip(next: next);
  };
  return actions;
});
