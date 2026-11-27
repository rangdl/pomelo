import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/app_keys.dart';
import '../../../shared/settings/audio_quality.dart';
import '../../../shared/settings/theme_mode.dart';
import '../../plugins/data/plugin_repository.dart';
import '../../plugins/domain/plugin_record.dart';
import '../../plugins/domain/source_keys.dart';
import '../../plugins/domain/track_origin.dart';
import '../../plugins/presentation/library_providers.dart';
import '../../plugins/presentation/plugin_providers.dart';
import '../../search/presentation/search_providers.dart';
import '../data/audio_player_service.dart';
import '../data/media_proxy_server.dart';
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

  /// 搜索代次：只接受最后一次搜索的结果，避免旧请求晚到覆盖新结果。
  int _searchGeneration = 0;

  Future<void> search(
    PluginRecord plugin,
    String query, {
    int page = 1,
    String type = 'music',
  }) async {
    final generation = ++_searchGeneration;
    final results = _ref.read(searchResultsProvider.notifier);
    // 第一页显示 loading，加载更多时保留旧结果、追加展示。
    if (page <= 1) {
      results.set(const AsyncValue.loading());
    }
    try {
      final rt = await _ref.read(pluginRuntimeProvider(plugin.id).future);
      final result = await rt.search(query, page: page, type: type);
      // 期间又发起了新的搜索，丢弃这次结果。
      if (generation != _searchGeneration) return;
      final data = (result['data'] as List).cast<dynamic>();
      final mapped = [
        for (final e in data)
          type == 'music'
              ? tagTrackOrigin(Map<String, dynamic>.from(e as Map), plugin)
              : {
                  ...Map<String, dynamic>.from(e as Map),
                  '_pluginId': plugin.id,
                },
      ];
      // 记录是否还有下一页，供「加载更多」判断。
      _searchHasMore = result['isEnd'] != true && mapped.isNotEmpty;
      if (page <= 1) {
        results.set(AsyncValue.data(mapped));
      } else {
        final prev = _ref.read(searchResultsProvider).value ?? const [];
        results.set(AsyncValue.data([...prev, ...mapped]));
      }
    } catch (e, st) {
      if (generation != _searchGeneration) return;
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

  /// 播放代次：每次发起播放 +1。
  ///
  /// 取链、打开都是异步的；快速连点/自动切歌时，旧请求晚到会覆盖新曲目。
  /// 每次 await 之后比对代次，过期请求直接丢弃。
  int _playGeneration = 0;

  /// 解析并播放一首歌（不改变队列）。
  Future<void> playItem(Map<String, dynamic> item) async {
    // 同步自增，保证「后点的歌」代次更高（不能放在 await 之后）。
    final generation = ++_playGeneration;
    // 点击即切换图标：取链还没开始就把 UI 先置为「播放中」，避免不跟手。
    _ref.read(playbackIntentProvider.notifier).setOptimistic(true);
    _ref.read(playbackStageProvider.notifier).set(PlaybackStage.resolving);
    final repo = await _ref.read(pluginRepositoryProvider.future);
    if (generation != _playGeneration) return;
    final player = _ref.read(audioPlayerProvider);
    _ref.read(nowPlayingProvider.notifier).set(item);
    // 同步通知栏的队列位置（高亮当前曲）。
    player.updateQueueIndex(_ref.read(playQueueProvider.notifier).index);

    void reportStage(PlaybackStage stage) {
      if (generation != _playGeneration) return;
      _ref.read(playbackStageProvider.notifier).set(stage);
    }

    final cacheKey = _mediaKey(item);
    ResolvedSource source;
    try {
      source = await _resolveUrl(repo, item, onStage: reportStage);
    } catch (e) {
      if (generation != _playGeneration) return;
      // 取链失败：可能命中了已失效的缓存链接，淘汰后重试一次。
      MediaLinkCache.instance?.remove(cacheKey);
      try {
        source = await _resolveUrl(
          repo,
          item,
          forceRefresh: true,
          onStage: reportStage,
        );
      } catch (e2) {
        if (generation != _playGeneration) return;
        // 取链失败说明「这首放不了」，不是播放器的瞬时错误：直接反馈一次，
        // 不进入 3 秒探测 + 自动跳下一首的流程，否则一首失败会连环跳完整队列。
        _markPlaybackFailed();
        _toast('播放失败: ${item['title'] ?? ''}（$e2）');
        return;
      }
    }
    if (generation != _playGeneration) return;

    try {
      await _openSource(item, source);
      if (generation != _playGeneration) return;
      _ref.read(playbackStageProvider.notifier).reset();
      _recordHistory(item);
      // 预取下一首的音源，切歌时无需再等取链。
      unawaited(prefetchNext());
      final art = '${item['artwork'] ?? ''}';
      final proxy = MediaProxyServer.instance;
      if (proxy != null && art.isNotEmpty && _canProxy(source.url)) {
        unawaited(proxy.prefetchCover(art));
      }
    } catch (e) {
      if (generation != _playGeneration) return;
      // 播放失败可能是「签名过期」或「之前的音频缓存是残片」：清掉后重试一次。
      MediaLinkCache.instance?.remove(cacheKey);
      await MediaProxyServer.instance?.evictAudio(cacheKey);
      if (generation != _playGeneration) return;
      try {
        final retry = await _resolveUrl(
          repo,
          item,
          forceRefresh: true,
          onStage: reportStage,
        );
        if (generation != _playGeneration) return;
        await _openSource(item, retry);
        if (generation != _playGeneration) return;
        _ref.read(playbackStageProvider.notifier).reset();
        _recordHistory(item);
        unawaited(prefetchNext());
      } catch (e2) {
        if (generation != _playGeneration) return;
        _reportPlayFailure(item, '$e2');
      }
    }
  }

  /// 用已解析出的地址打开播放器（含本地代理登记与封面地址改写）。
  Future<void> _openSource(
    Map<String, dynamic> item,
    ResolvedSource source,
  ) async {
    final player = _ref.read(audioPlayerProvider);
    final proxy = _canProxy(source.url) ? MediaProxyServer.instance : null;
    // 有本地服务就让播放器只连 127.0.0.1：取链、防盗链头、边播边存都在服务端。
    final streamUrl = proxy == null
        ? source.url
        : proxy.streamUrl(_mediaKey(item), source.url, source.headers);
    final art = '${item['artwork'] ?? ''}';
    // 封面只接受 http(s)：data: 内联图与本地路径交给系统媒体控件会取不到。
    final coverUri = isRemoteHttpUrl(art)
        ? Uri.tryParse(cachedArtworkUrl(art))
        : null;
    await player.open(
      streamUrl,
      headers: proxy == null ? source.headers : null,
      meta: MediaMeta(
        id: '${item['id'] ?? source.url}',
        title: '${item['title'] ?? '未知歌曲'}',
        artist: '${item['artist'] ?? ''}',
        album: '${item['album'] ?? ''}',
        artUri: coverUri,
        duration: _durationOf(item),
      ),
    );
  }

  void _recordHistory(Map<String, dynamic> item) {
    try {
      // 延迟读取，避免引入硬循环依赖；失败静默。
      _ref.read(historyProvider.notifier).record(item);
    } catch (e) {
      debugPrint('[pomelo] 记录播放历史失败: $e');
    }
  }

  Duration? _durationOf(Map<String, dynamic> item) {
    final raw = item['duration'];
    final secs = raw is int ? raw : int.tryParse('${raw ?? ''}');
    if (secs == null || secs <= 0) return null;
    return Duration(seconds: secs);
  }

  /// 歌词缓存（曲目 id → LRC 文本，null 表示「确认无歌词」避免重复拉取）。
  final Map<String, String?> _lyricCache = {};

  /// 获取歌词原文（LRC 文本）。
  ///
  /// 先问来源插件，再按音源 key 找其它声明了 `getLyric` 的插件兜底。
  /// 拿不到返回 null。
  Future<String?> fetchLyric(Map<String, dynamic> item) async {
    final cacheKey =
        '${item['_pluginId'] ?? ''}:${item['id'] ?? item['title'] ?? ''}';
    if (_lyricCache.containsKey(cacheKey)) return _lyricCache[cacheKey];
    final repo = await _ref.read(pluginRepositoryProvider.future);

    final ownerId = item['_pluginId'] as String?;
    final sourceKey = _sourceKeyOf(repo, item);
    final payload = stripTrackOrigin(item);

    final candidates = <PluginRecord>[];
    final owner = repo.plugins.where((p) => p.id == ownerId).firstOrNull;
    if (owner != null &&
        owner.enabled &&
        owner.supportedMethods.contains('getLyric')) {
      candidates.add(owner);
    }
    if (sourceKey != null) {
      for (final p in repo.plugins) {
        if (p.id == ownerId || !p.enabled) continue;
        if (!p.supportedMethods.contains('getLyric')) continue;
        if (!p.sourceKeys.contains(sourceKey)) continue;
        candidates.add(p);
      }
    }

    for (final plugin in candidates) {
      try {
        final rt = await _ref.read(pluginRuntimeProvider(plugin.id).future);
        final raw = await rt.invoke('getLyric', [
          payload,
          sourceKey,
        ], timeout: const Duration(seconds: 30));
        final lyric = _extractLyric(raw);
        if (lyric != null && lyric.isNotEmpty) {
          _lyricCache[cacheKey] = lyric;
          return lyric;
        }
      } catch (e) {
        debugPrint('[pomelo] 歌词获取失败(${plugin.platform}): $e');
      }
    }

    _lyricCache[cacheKey] = null; // 确认无歌词，避免重复拉取
    return null;
  }

  /// 单曲详情（来源插件实现了 getMusicInfo 才有值）。
  Future<Map<String, dynamic>?> fetchMusicInfo(
    Map<String, dynamic> item,
  ) async {
    final plugin = await _ownerPlugin(item);
    if (plugin == null || !plugin.supportedMethods.contains('getMusicInfo')) {
      return null;
    }
    try {
      final rt = await _ref.read(pluginRuntimeProvider(plugin.id).future);
      return await rt.getMusicInfo(stripTrackOrigin(item));
    } catch (e) {
      debugPrint('[pomelo] 获取歌曲详情失败: $e');
      return null;
    }
  }

  /// 评论列表（来源插件实现了 getMusicComments 才有值）。
  Future<List<Map<String, dynamic>>> fetchMusicComments(
    Map<String, dynamic> item, {
    int page = 1,
    String sort = 'hot',
  }) async {
    final plugin = await _ownerPlugin(item);
    if (plugin == null ||
        !plugin.supportedMethods.contains('getMusicComments')) {
      return const [];
    }
    try {
      final rt = await _ref.read(pluginRuntimeProvider(plugin.id).future);
      return await rt.getMusicComments(
        stripTrackOrigin(item),
        page: page,
        sort: sort,
      );
    } catch (e) {
      debugPrint('[pomelo] 获取评论失败: $e');
      return const [];
    }
  }

  /// 导入分享链接（歌单/单曲），依次尝试支持导入的插件。
  ///
  /// 返回带来源标记的曲目列表；没有插件能处理时返回空列表。
  Future<List<Map<String, dynamic>>> importShared(String url) async {
    final repo = await _ref.read(pluginRepositoryProvider.future);
    for (final plugin in repo.enabledPlugins) {
      final canSheet = plugin.supportedMethods.contains('importMusicSheet');
      final canItem = plugin.supportedMethods.contains('importMusicItem');
      if (!canSheet && !canItem) continue;
      try {
        final rt = await _ref.read(pluginRuntimeProvider(plugin.id).future);
        if (canSheet) {
          final tracks = await rt.importMusicSheet(url);
          if (tracks.isNotEmpty) {
            return tracks.map((t) => tagTrackOrigin(t, plugin)).toList();
          }
        }
        if (canItem) {
          final track = await rt.importMusicItem(url);
          if (track != null) {
            return [tagTrackOrigin(track, plugin)];
          }
        }
      } catch (e) {
        debugPrint('[pomelo] ${plugin.platform} 导入失败: $e');
      }
    }
    return const [];
  }

  /// 推荐歌单标签。返回的每个标签都带 `_pluginId`，便于后续按插件拉歌单。
  Future<List<Map<String, dynamic>>> fetchRecommendSheetTags(
    PluginRecord plugin,
  ) async {
    try {
      final rt = await _ref.read(pluginRuntimeProvider(plugin.id).future);
      final tags = await rt.getRecommendSheetTags();
      return [
        for (final t in tags) {...t, '_pluginId': plugin.id},
      ];
    } catch (e) {
      debugPrint('[pomelo] 获取推荐歌单标签失败: $e');
      return const [];
    }
  }

  /// 按标签分页获取推荐歌单（[tag] 为标签对象）。
  Future<({List<Map<String, dynamic>> data, bool isEnd})> fetchRecommendSheets(
    PluginRecord plugin,
    Map<String, dynamic> tag, {
    int page = 1,
  }) async {
    final rt = await _ref.read(pluginRuntimeProvider(plugin.id).future);
    final res = await rt.getRecommendSheetsByTag(
      stripTrackOrigin(tag),
      page: page,
    );
    return (
      data: [
        for (final s in res.data) {...s, '_pluginId': plugin.id},
      ],
      isEnd: res.isEnd,
    );
  }

  /// 歌单详情（歌曲列表）。
  Future<({List<Map<String, dynamic>> data, bool isEnd})> fetchSheetSongs(
    PluginRecord plugin,
    Map<String, dynamic> sheet, {
    int page = 1,
  }) async {
    final rt = await _ref.read(pluginRuntimeProvider(plugin.id).future);
    final res = await rt.getMusicSheetInfo(stripTrackOrigin(sheet), page: page);
    return (
      data: [for (final s in res.data) tagTrackOrigin(s, plugin)],
      isEnd: res.isEnd,
    );
  }

  /// 歌手作品（单曲 / 专辑）。
  Future<({List<Map<String, dynamic>> data, bool isEnd})> fetchArtistWorks(
    PluginRecord plugin,
    Map<String, dynamic> artist, {
    int page = 1,
    String type = 'music',
  }) async {
    final rt = await _ref.read(pluginRuntimeProvider(plugin.id).future);
    final res = await rt.getArtistWorks(
      stripTrackOrigin(artist),
      page: page,
      type: type,
    );
    return (
      data: [
        for (final s in res.data)
          type == 'music'
              ? tagTrackOrigin(s, plugin)
              : {...s, '_pluginId': plugin.id},
      ],
      isEnd: res.isEnd,
    );
  }

  /// 专辑详情（歌曲列表）。
  Future<({List<Map<String, dynamic>> data, bool isEnd})> fetchAlbumSongs(
    PluginRecord plugin,
    Map<String, dynamic> album, {
    int page = 1,
  }) async {
    final rt = await _ref.read(pluginRuntimeProvider(plugin.id).future);
    final res = await rt.getAlbumInfo(stripTrackOrigin(album), page: page);
    return (
      data: [for (final s in res.data) tagTrackOrigin(s, plugin)],
      isEnd: res.isEnd,
    );
  }

  Future<PluginRecord?> _ownerPlugin(Map<String, dynamic> item) async {
    final repo = await _ref.read(pluginRepositoryProvider.future);
    final ownerId = item['_pluginId'] as String?;
    if (ownerId == null) return null;
    return repo.plugins.where((p) => p.id == ownerId).firstOrNull;
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

  /// 只有 http(s) 源才走本地代理；其它协议（如本地文件）保持直连。
  bool _canProxy(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }

  /// 一首歌的稳定缓存键：来源插件 + 曲目 id + 音质。
  ///
  /// 播放地址会变（带签名），但同一首歌应复用同一份链接缓存与音频缓存。
  String _mediaKey(Map<String, dynamic> item, [AudioQuality? quality]) {
    final AudioQuality q = quality ?? _ref.read(audioQualityProvider);
    final owner = '${item['_pluginId'] ?? ''}';
    final id = '${item['id'] ?? item['title'] ?? ''}';
    final artist = '${item['artist'] ?? ''}';
    return '$owner:$id:$artist:${q.musicFreeValue}';
  }

  /// 预取队列里下一首的播放源（静默，不改队列、不发声）。
  Future<void> prefetchNext() async {
    final items = _ref.read(playQueueProvider);
    if (items.length < 2) return;
    final mode = _ref.read(playModeProvider);
    if (mode == PlayMode.singleLoop) return;
    var next = _ref.read(playQueueProvider.notifier).index + 1;
    if (next >= items.length) {
      if (mode == PlayMode.sequential) return;
      next = 0;
    }
    final item = items[next];
    try {
      final repo = await _ref.read(pluginRepositoryProvider.future);
      final source = await _resolveUrl(repo, item);
      // 同时登记到本地服务，切歌时地址已就绪。
      final proxy = _canProxy(source.url) ? MediaProxyServer.instance : null;
      proxy?.streamUrl(_mediaKey(item), source.url, source.headers);
      final art = '${item['artwork'] ?? ''}';
      if (proxy != null && art.isNotEmpty) {
        await proxy.prefetchCover(art);
      }
    } catch (e) {
      debugPrint('[pomelo] 预取下一首失败: $e');
    }
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

  /// 播放全部：替换队列并从第一首开始。
  Future<void> playAll(List<Map<String, dynamic>> items) =>
      playFromList(items, 0);

  /// 随机播放：打乱后从第一首开始。
  Future<void> shufflePlay(List<Map<String, dynamic>> items) async {
    if (items.isEmpty) return;
    final queue = _ref.read(playQueueProvider.notifier);
    queue.setAll(items);
    queue.shuffle();
    final shuffled = _ref.read(playQueueProvider);
    if (shuffled.isEmpty) return;
    await safePlay(shuffled.first);
  }

  /// 加入队列末尾（不打断当前播放）。
  void enqueue(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return;
    _ref.read(playQueueProvider.notifier).appendAll(items);
    _toast('已加入播放队列（${items.length} 首）');
  }

  /// 设为下一首播放。
  void playNext(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return;
    _ref.read(playQueueProvider.notifier).insertNext(items);
    _toast(items.length > 1 ? '已将 ${items.length} 首设为下一首播放' : '已设为下一首播放');
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
    if (target == null) return;
    final currentId = '${target['id'] ?? ''}';

    // 以「用户看到的状态」为准：点击后图标已乐观切换，不能被播放器尚未
    // 更新的真实状态误判成同向重复点击。
    final displayedPlaying =
        _ref.read(playbackIntentProvider) ?? player.playing;

    // 暂停：图标立即切回，真实暂停在后台完成。
    if (displayedPlaying) {
      _ref.read(playbackIntentProvider.notifier).setOptimistic(false);
      if (player.hasLoaded(currentId)) {
        await player.pause();
      } else {
        // 还在解析 / 未加载：取消这次播放请求即可。
        _playGeneration++;
        _ref.read(playbackStageProvider.notifier).reset();
      }
      return;
    }

    // 播放：图标立即切到暂停，取链在后台继续（失败会回滚并提示）。
    _ref.read(playbackIntentProvider.notifier).setOptimistic(true);
    if (player.hasLoaded(currentId)) {
      await player.play();
      return;
    }
    // 尚未加载（如重启后恢复的快照、或点的是队列里另一首）：重新解析并播放。
    await safePlay(target);
  }

  /// 上一首 / 下一首。[auto] 表示由「播放完成」触发，需遵守播放模式。
  Future<void> skip({required bool next, bool auto = false}) async {
    final queue = _ref.read(playQueueProvider.notifier);
    final items = _ref.read(playQueueProvider);
    if (items.isEmpty) return;

    final mode = _ref.read(playModeProvider);
    if (auto && mode == PlayMode.singleLoop) {
      await safePlay(items[queue.index]);
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
    await safePlay(items[nextIndex]);
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
      // 用户主动暂停导致的「不推进」不是故障，不能据此跳歌。
      if (player.userPaused) return;
      // 确实卡住：提示并尝试自动跳下一首。
      _toast('播放失败: $message');
      final items = _ref.read(playQueueProvider);
      if (items.length > 1) {
        skip(next: true, auto: true);
      }
    });
  }

  void _reportPlayFailure(Map<String, dynamic> item, String message) {
    _markPlaybackFailed();
    _handlePlayError(item, message);
  }

  /// 本次播放确定失败：回滚乐观播放态，并在控件上展示失败文案。
  void _markPlaybackFailed() {
    _ref.read(playbackIntentProvider.notifier).clear();
    _ref.read(playbackStageProvider.notifier).set(PlaybackStage.failed);
  }

  Future<void> safePlay(Map<String, dynamic> item) async {
    try {
      await playItem(item);
    } catch (_) {
      // 失败提示已在 playItem 内给出，这里只负责不让异常继续外抛。
    }
  }

  /// 手动刷新当前曲目的播放链接：丢弃缓存，强制重新向音源取链。
  ///
  /// 适用场景：链接过期 / 卡顿 / 换音源后想重新解析。会保留队列与当前曲目，
  /// 从当前进度继续（取链成功后 seek 回原位置；失败则回到开头）。
  /// 返回 true 表示刷新成功。
  Future<bool> refreshCurrent() async {
    final item = _ref.read(nowPlayingProvider);
    if (item == null) return false;

    final player = _ref.read(audioPlayerProvider);
    final position = player.position;
    final cacheKey = _mediaKey(item);
    // 先淘汰可能已失效的缓存链接，确保 _resolveUrl 真正重新请求音源。
    MediaLinkCache.instance?.remove(cacheKey);

    final repo = await _ref.read(pluginRepositoryProvider.future);
    final generation = ++_playGeneration;
    _ref.read(playbackStageProvider.notifier).set(PlaybackStage.resolving);

    void reportStage(PlaybackStage stage) {
      if (generation != _playGeneration) return;
      _ref.read(playbackStageProvider.notifier).set(stage);
    }

    ResolvedSource source;
    try {
      source = await _resolveUrl(repo, item, forceRefresh: true, onStage: reportStage);
    } catch (e) {
      if (generation != _playGeneration) return false;
      _markPlaybackFailed();
      _toast('刷新播放链接失败: ${item['title'] ?? ''}（$e）');
      return false;
    }
    if (generation != _playGeneration) return false;

    try {
      await _openSource(item, source);
      if (generation != _playGeneration) return false;
      // 尽量回到刷新前的位置；接近结尾则从头开始。
      final total = _durationOf(item);
      if (position > Duration.zero &&
          total != null &&
          position < total - const Duration(seconds: 2)) {
        await player.seek(position);
      }
      _ref.read(playbackStageProvider.notifier).reset();
      _toast('已刷新播放链接');
      return true;
    } catch (e) {
      if (generation != _playGeneration) return false;
      _reportPlayFailure(item, '$e');
      return false;
    }
  }

  void _toast(String message) {
    final messenger = globalScaffoldMessengerKey.currentState;
    messenger?.showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  /// 解析播放地址：**先来源插件自带取链 → 失败再按音源 key 找其它插件兜底**。
  ///
  /// 兜底只在目标插件开启了「允许被兜底调用」时参与；全部失败统一报
  /// 「无法获取有效的播放链接」。
  Future<ResolvedSource> _resolveUrl(
    PluginRepository repo,
    Map<String, dynamic> item, {
    bool forceRefresh = false,
    void Function(PlaybackStage stage)? onStage,
  }) async {
    final ownerId = item['_pluginId'] as String?;
    final quality = _ref.read(audioQualityProvider);
    final payload = stripTrackOrigin(item);

    // 命中链接缓存（10 分钟内）直接复用，避免每次切歌都请求音源。
    // 播放失败后的重试传 forceRefresh，跳过缓存重新向音源要地址。
    final cacheKey = _mediaKey(item, quality);
    final cached = forceRefresh ? null : MediaLinkCache.instance?.get(cacheKey);
    if (cached != null) {
      debugPrint('[pomelo] 命中播放链接缓存: ${item['title']}');
      return ResolvedSource(cached.url, cached.headers);
    }

    onStage?.call(PlaybackStage.resolving);
    Object? primaryError;

    // 1) 来源插件自带取链（用户可对该插件勾选「禁用取链」直接走兜底）。
    final owner = repo.plugins.where((p) => p.id == ownerId).firstOrNull;
    if (owner != null && owner.enabled && owner.canProvideMediaSource) {
      if (owner.disableResolve) {
        debugPrint('[pomelo] 来源插件已禁用取链，直接走兜底: ${owner.platform}');
      } else {
        try {
          final source = await _resolveWith(owner, payload, quality);
          debugPrint(
            '[pomelo] 插件解析成功 quality=${quality.musicFreeValue} url=${source.url}',
          );
          _remember(cacheKey, source);
          return source;
        } catch (e) {
          primaryError = e;
          debugPrint('[pomelo] 插件解析失败，尝试兜底: $e');
        }
      }
    }

    // 2) 跨插件兜底：同音源 key 的其它插件。
    final sourceKey = _sourceKeyOf(repo, item);
    final candidates = sourceKey == null
        ? const <PluginRecord>[]
        : repo
              .fallbackCandidates(sourceKey, excludeId: ownerId)
              .toList(growable: false);
    if (candidates.isNotEmpty) {
      // 主插件已失败（或被禁用），接下来换插件兜底：同步进度文案。
      onStage?.call(PlaybackStage.fallback);
      for (final candidate in candidates) {
        try {
          final source = await _resolveWith(
            candidate,
            payload,
            quality,
            sourceKey: sourceKey,
          );
          debugPrint(
            '[pomelo] 兜底成功 plugin=${candidate.platform} '
            'source=$sourceKey url=${source.url}',
          );
          _remember(cacheKey, source);
          return source;
        } catch (e) {
          primaryError ??= e;
          debugPrint('[pomelo] 兜底失败(${candidate.platform}): $e');
        }
      }
    }

    if (primaryError != null) {
      debugPrint('[pomelo] 全部取链方式失败: $primaryError');
    }
    final ownerDisabled = owner != null && owner.disableResolve;
    throw StateError(ownerDisabled ? '来源插件已禁用取链，且没有可用的兜底插件' : '无法获取有效的播放链接');
  }

  /// 把解析结果写入链接缓存（失败静默）。
  void _remember(String cacheKey, ResolvedSource source) {
    MediaLinkCache.instance?.put(cacheKey, source.url, source.headers);
  }

  /// 条目所属的音源 key：自身标记 → 旧数据的 lxSource → 来源插件推断。
  String? _sourceKeyOf(PluginRepository repo, Map<String, dynamic> item) {
    final tagged = item['_sourceKey'];
    if (tagged is String && tagged.isNotEmpty) return tagged;

    final legacy = item['lxSource'];
    if (legacy is String && legacy.isNotEmpty) return legacy;

    // 老数据没有 _sourceKey，但条目里可能带平台标识（如 gd 的 source）。
    final rawSource = item['source'];
    if (rawSource is String && rawSource.isNotEmpty) {
      final key = inferSourceKeyFromPlatform(rawSource);
      if (key != null) return key;
    }

    final ownerId = item['_pluginId'] as String?;
    final owner = repo.plugins.where((p) => p.id == ownerId).firstOrNull;
    return owner == null ? null : primarySourceKey(owner);
  }

  Future<ResolvedSource> _resolveWith(
    PluginRecord plugin,
    Map<String, dynamic> payload,
    AudioQuality quality, {
    String? sourceKey,
  }) async {
    final rt = await _ref.read(pluginRuntimeProvider(plugin.id).future);
    final source = await rt.getMediaSource(
      payload,
      quality.musicFreeValue,
      sourceKey: sourceKey,
    );
    if (source == null || source['url'] is! String) {
      throw StateError('插件未返回可播放地址');
    }
    final url = (source['url'] as String).trim();
    // 插件可能"成功"返回空串（上游临时无链），同样视为失败。
    if (url.isEmpty) {
      throw StateError('插件返回空播放地址');
    }
    final headers = (source['headers'] as Map?)
        ?.map((k, v) => MapEntry('$k', '$v'))
        .cast<String, String>();
    return ResolvedSource(url, headers);
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
