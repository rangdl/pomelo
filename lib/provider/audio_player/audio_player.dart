import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart' hide Track;
import 'package:pomelo/core/extensions/list.dart';
import 'package:pomelo/core/models/metadata/track.dart';
import 'package:pomelo/services/audio_player/audio_player.dart';
import 'package:pomelo/services/logger/logger.dart';

import '../../services/audio_player/media.dart';
import '../server/sourced_track.dart';
import '../cast/cast_provider.dart';
import 'state.dart';
import 'audio_player_repository.dart';

class AudioPlayerNotifier extends Notifier<AudioPlayerState> {
  // BlackListNotifier get _blacklist => ref.read(blacklistProvider.notifier);

  /// 批量操作标志：非零时跳过 [playlistStream] 的冗余状态同步。
  ///
  /// [load] / [addTracks] / [addTracksAtFirst] 等方法会直接更新 state，
  /// 此时 media_kit 的 playlistStream 可能发出多次中间事件，
  /// 导致 UI 出现「逐条加入」的视觉效果。通过此标志抑制这些中间事件。
  int _batchDepth = 0;

  /// 曲目表落库防抖定时器。
  ///
  /// [persistTracks] 是整表替换（千首队列 = 数千行写），频繁触发代价高，
  /// 因此轨迹类变更统一走防抖，合并一次连续操作内的多次写。
  Timer? _tracksPersistTimer;

  /// 已预热（已解析真实播放 URL）的曲目 id，避免重复预热。
  final Set<String> _preloadedIds = {};

  /// 是否正在投屏（本地播放应让位给 DLNA 设备，避免双重音频）
  bool get _isCasting => ref.read(castProvider).isCasting;

  void _assertAllowedTracks(Iterable<Track> tracks) {
    // 扁平化后所有 Track 都合法，无需断言
  }

  void _assertAllowedTrack(Track tracks) {
    // 扁平化后所有 Track 都合法，无需断言
  }

  Future<void> _syncSavedState() async {
    // final database = ref.read(databaseProvider);
    final repository = ref.read(audioPlayerRepositoryProvider);
    var playerState = await repository.restore();

    if (playerState == null) {
      playerState = AudioPlayerState(
        playing: audioPlayer.isPlaying,
        loopMode: audioPlayer.loopMode,
        shuffled: audioPlayer.isShuffled,
        collections: [],
      );
      repository.persist(
        AudioPlayerState(
          playing: audioPlayer.isPlaying,
          loopMode: audioPlayer.loopMode,
          shuffled: audioPlayer.isShuffled,
          collections: [],
        ),
      );
    } else {
      await audioPlayer.setLoopMode(playerState.loopMode);
      await audioPlayer.setShuffle(playerState.shuffled);
    }

    final tracks = playerState.tracks;
    final currentIndex = playerState.currentIndex;

    if (tracks.isEmpty && state.tracks.isNotEmpty) {
      await _updatePlayerState(
        // AudioPlayerStateTableCompanion(
        //   tracks: Value(state.tracks),
        //   currentIndex: Value(currentIndex),
        // ),
        state.copyWith(tracks: state.tracks, currentIndex: currentIndex),
      );
    } else if (tracks.isNotEmpty) {
      state = state.copyWith(tracks: tracks, currentIndex: currentIndex);
      _batchDepth++;
      try {
        await audioPlayer.openPlaylist(
          tracks.asMediaList(),
          initialIndex: currentIndex,
          autoPlay: false,
        );
      } finally {
        _batchDepth--;
      }
    }

    if (playerState.collections.isNotEmpty) {
      state = state.copyWith(collections: playerState.collections);
    }
  }

  Future<void> _updatePlayerState(AudioPlayerState companion) async {
    // 轻量状态（playing/loop/shuffle/index/collections）立即写；
    // 曲目表（整表替换，开销高）走防抖合并，避免每次状态/轨迹变更
    // 都重写整张曲目表（千首队列 = 数千行写）。
    await ref.read(audioPlayerRepositoryProvider).persistState(companion);
    _scheduleTracksPersist();
  }

  /// 防抖调度 [AudioPlayerRepository.persistTracks]。
  ///
  /// 连续多次轨迹变更（如「播放全部」一次性加入上千首）会被合并为
  /// 一次整表替换，避免每个动作都重写整张曲目表。
  void _scheduleTracksPersist() {
    _tracksPersistTimer?.cancel();
    _tracksPersistTimer = Timer(
      const Duration(milliseconds: 600),
      () async {
        try {
          await ref
              .read(audioPlayerRepositoryProvider)
              .persistTracks(state.tracks);
        } catch (e, s) {
          AppLogger.reportError(e, s, '[audioPlayer] persistTracks 失败');
        }
      },
    );
  }

  /// 立即落库曲目表（取消挂起的防抖定时器）。
  Future<void> _flushTracksPersist() async {
    _tracksPersistTimer?.cancel();
    _tracksPersistTimer = null;
    try {
      await ref.read(audioPlayerRepositoryProvider).persistTracks(state.tracks);
    } catch (e, s) {
      AppLogger.reportError(e, s, '[audioPlayer] flush persistTracks 失败');
    }
  }

  /// 预热曲目：把真实播放 URL 的解析（Subsonic/Lx 的网络 HEAD）提前触发，
  /// 使其在播放关键路径之外完成。已预热或未需解析（本地/直链）的曲目跳过。
  void _preloadTrack(Track track) {
    if (track.path != null) return;
    final src = track.src;
    if (src != null && src.isNotEmpty) return;
    if (_preloadedIds.contains(track.id)) return;
    _preloadedIds.add(track.id);
    unawaited(
      ref
          .read(sourcedTrackProvider(track).future)
          .then((_) {}, onError: (_, __) {}),
    );
  }

  @override
  build() {
    final subscriptions = [
      audioPlayer.playingStream.listen((playing) async {
        try {
          state = state.copyWith(playing: playing);

          await _updatePlayerState(
            // AudioPlayerStateTableCompanion(playing: Value(playing)),
            state,
          );
        } catch (e, stack) {
          AppLogger.reportError(e, stack, '[audioPlayerState] ${e.toString()}');
        }
      }),
      audioPlayer.loopModeStream.listen((loopMode) async {
        try {
          state = state.copyWith(loopMode: loopMode);

          await _updatePlayerState(
            state,
            // AudioPlayerStateTableCompanion(loopMode: Value(loopMode)),
          );
        } catch (e, stack) {
          AppLogger.reportError(e, stack, '[audioPlayerState] ${e.toString()}');
        }
      }),
      audioPlayer.shuffledStream.listen((shuffled) async {
        try {
          state = state.copyWith(shuffled: shuffled);

          await _updatePlayerState(
            state,
            // AudioPlayerStateTableCompanion(shuffled: Value(shuffled)),
          );
        } catch (e, stack) {
          AppLogger.reportError(e, stack, '[audioPlayerState] ${e.toString()}');
        }
      }),
      audioPlayer.playlistStream.listen((playlist) async {
        // 批量操作期间跳过，state 已由调用方直接更新
        if (_batchDepth > 0) return;
        try {
          final tracks = playlist.medias
              .map((e) => PomeloMedia.media(e).track)
              .toList();

          state = state.copyWith(tracks: tracks, currentIndex: playlist.index);

          // 轻量状态立即写；曲目表（整表替换）由 _updatePlayerState 走防抖
          await _updatePlayerState(state);
        } catch (e, stack) {
          AppLogger.reportError(e, stack, '[audioPlayerState] ${e.toString()}');
        }
      }),
      // O3：当前曲播放过半时，提前解析随后 1~2 首的真实播放 URL，
      // 把 Subsonic/Lx 的网络解析移出切歌关键路径，近似无缝切歌。
      audioPlayer.positionStream.listen((position) {
        final duration = audioPlayer.duration;
        if (duration == Duration.zero) return;
        if (position.inMilliseconds < duration.inMilliseconds * 0.5) return;
        final nextIndex = state.currentIndex + 1;
        if (nextIndex >= state.tracks.length) return;
        for (var i = nextIndex;
            i < state.tracks.length && i < nextIndex + 2;
            i++) {
          _preloadTrack(state.tracks[i]);
        }
      }),
    ];

    _syncSavedState();

    ref.onDispose(() {
      for (final subscription in subscriptions) {
        subscription.cancel();
      }
      // 退出前尽量把挂起的曲目表落库刷盘
      unawaited(_flushTracksPersist());
      audioPlayer.stop();
    });

    return AudioPlayerState(
      loopMode: audioPlayer.loopMode,
      playing: audioPlayer.isPlaying,
      shuffled: audioPlayer.isShuffled,
      tracks: [],
      collections: [],
    );
  }

  // Collection related methods
  Future<void> addCollections(List<String> collectionIds) async {
    state = state.copyWith(
      collections: [...state.collections, ...collectionIds],
    );

    await _updatePlayerState(
      // AudioPlayerStateTableCompanion(collections: Value(state.collections)),
      state,
    );
  }

  Future<void> addCollection(String collectionId) async {
    await addCollections([collectionId]);
  }

  Future<void> removeCollections(List<String> collectionIds) async {
    state = state.copyWith(
      collections: state.collections
          .where((element) => !collectionIds.contains(element))
          .toList(),
    );

    await _updatePlayerState(
      state,
      // AudioPlayerStateTableCompanion(collections: Value(state.collections)),
    );
  }

  Future<void> removeCollection(String collectionId) async {
    await removeCollections([collectionId]);
  }

  Future<void> addTracksAtFirst(
    Iterable<Track> tracks, {
    bool allowDuplicates = false,
  }) async {
    _assertAllowedTracks(tracks);
    if (state.tracks.length == 1) {
      return addTracks(tracks);
    }

    final addableTracks = tracks.toList();
    if (addableTracks.isEmpty) return;

    // 在当前曲目之后插入（「下一首播放」）
    final insertIndex = max(state.currentIndex + 1, 0);
    final newTracks = [...state.tracks];
    newTracks.insertAll(insertIndex, addableTracks);
    state = state.copyWith(tracks: newTracks);

    _batchDepth++;
    try {
      final medias = addableTracks.asMediaList();
      await audioPlayer.addTracksAt(medias, insertIndex);
    } finally {
      _batchDepth--;
    }

    await _updatePlayerState(state);
  }

  Future<void> addTrack(Track track) async {
    _assertAllowedTrack(track);

    // if (_blacklist.contains(track)) return;
    if (state.tracks.any((element) => _compareTracks(element, track))) return;

    state = state.copyWith(tracks: [...state.tracks, track]);

    await audioPlayer.addTrack(PomeloMedia(track));

    await _updatePlayerState(
      state,
      // AudioPlayerStateTableCompanion(
      //   tracks: Value(state.tracks),
      //   currentIndex: Value(max(state.currentIndex, 0)),
      // ),
    );
  }

  Future<void> addTracks(Iterable<Track> tracks) async {
    _assertAllowedTracks(tracks);

    final addableTracks = tracks.toList();
    if (addableTracks.isEmpty) return;

    state = state.copyWith(tracks: [...state.tracks, ...addableTracks]);

    _batchDepth++;
    try {
      await audioPlayer.addTracks(addableTracks.asMediaList());
    } finally {
      _batchDepth--;
    }

    await _updatePlayerState(state);
  }

  Future<void> removeTrack(String trackId) async {
    final index = state.tracks.indexWhere((element) => element.id == trackId);

    if (index == -1) return;

    state = state.copyWith(tracks: List.of(state.tracks)..removeAt(index));

    await audioPlayer.removeTrack(index);

    await _updatePlayerState(
      state,
      // AudioPlayerStateTableCompanion(
      //   tracks: Value(state.tracks),
      //   currentIndex: Value(max(state.currentIndex, 0)),
      // ),
    );
  }

  Future<void> removeTracks(Iterable<String> trackIds) async {
    final trackIndexes = state.tracks
        .where((element) => trackIds.any((trackId) => trackId == element.id))
        .mapIndexed((index, element) => index);

    final tracks = state.tracks.where(
      (element) => !trackIds.contains(element.id),
    );

    state = state.copyWith(tracks: tracks.toList());

    for (final index in trackIndexes) {
      await audioPlayer.removeTrack(index);
    }

    await _updatePlayerState(
      state,
      // AudioPlayerStateTableCompanion(
      //   tracks: Value(state.tracks),
      //   currentIndex: Value(max(state.currentIndex, 0)),
      // ),
    );
  }

  bool _compareTracks(Track a, Track b) {
    if (a.runtimeType != b.runtimeType) {
      return false;
    }

    return a.path != null && b.path != null ? a.path == b.path : a.id == b.id;
  }

  Future<void> load(
    List<Track> tracks, {
    int initialIndex = 0,
    bool autoPlay = false,
  }) async {
    _assertAllowedTracks(tracks);

    final medias = tracks.asMediaList().unique((a, b) => a.uri == b.uri);

    if (medias.isEmpty) return;

    // O1：先更新 UI 状态，确保点击播放立刻有反馈（正在加载/播放中），
    // 避免被随后的网络解析 await 阻塞导致「点击无反应」。
    state = state.copyWith(
      tracks: medias.map((media) => media.track).toList(),
      currentIndex: initialIndex,
      collections: [],
    );

    // 随后尽量在开播前预解析 active 曲的真实播放 URL（带超时），
    // 把 Subsonic/Lx 的网络解析从开播关键路径移开，避免 media_kit 因
    // 流迟迟不就绪而跳过曲目；超时/失败则退回原始懒解析（/stream 请求时
    // 再解析），但 UI 已先行响应，不会出现「点击无反应」。
    // 本地文件 / 直链无需解析，直接跳过。
    final preloadStart = initialIndex.clamp(0, medias.length - 1);
    final activeTrack = medias[preloadStart].track;
    if (activeTrack.path == null &&
        (activeTrack.src == null || activeTrack.src!.isEmpty)) {
      _preloadedIds.add(activeTrack.id);
      try {
        await ref
            .read(sourcedTrackProvider(activeTrack).future)
            .timeout(const Duration(seconds: 3));
      } catch (e, s) {
        AppLogger.reportError(
          e,
          s,
          '[audioPlayer] 预解析 active 曲超时/失败，退回懒解析',
        );
      }
    }

    // 预热随后 1~2 首（不阻塞开播），近似无缝切歌（O3）。
    for (var i = preloadStart + 1;
        i < medias.length && i < preloadStart + 3;
        i++) {
      _preloadTrack(medias[i].track);
    }

    // 投屏中不开本地播放（本地保持暂停），改由 cast 监听 activeTrack
    // 变化后自动重投，避免本地与设备同时出声（双重音频）。
    final actuallyPlay = autoPlay && !_isCasting;
    _batchDepth++;
    try {
      await audioPlayer.openPlaylist(
        medias,
        initialIndex: initialIndex,
        autoPlay: actuallyPlay,
      );
    } finally {
      _batchDepth--;
    }

    await _updatePlayerState(state);
  }

  Future<void> swapActiveSource() async {
    if (state.tracks.isEmpty || state.activeTrack?.src == null) {
      return;
    }

    final idx = state.currentIndex;
    final track = state.tracks[idx];
    // 仅重载当前曲：移除旧 Media 并在同位置插入新 Media（URL 按当前
    // track.src 重算），再跳回当前曲，避免 stop + 整列表重建（O9）。
    // 同时让服务端重新解析该曲的真实播放链接（src 可能已切换）。
    ref.invalidate(sourcedTrackProvider(track));
    _batchDepth++;
    try {
      await audioPlayer.removeTrack(idx);
      await audioPlayer.addTrackAt(PomeloMedia(track), idx);
    } finally {
      _batchDepth--;
    }
    await audioPlayer.jumpTo(idx);
    // 投屏中本地保持暂停，避免与设备双重音频
    if (!_isCasting && !audioPlayer.isPlaying) await audioPlayer.resume();
    await _updatePlayerState(state);
  }

  Future<void> jumpToTrack(Track track) async {
    final index = state.tracks.toList().indexWhere(
      (element) => element.id == track.id,
    );
    if (index == -1) return;
    await audioPlayer.jumpTo(index);
  }

  /// 播放单曲：添加到当前播放列表末尾（不覆盖）并跳转播放。
  ///
  /// 若曲目已在队列中，直接跳转并播放。用于「点击卡片即播放」场景
  /// （`overwritePlaylistOnPlay=false` 时的默认行为）。
  Future<void> playTrack(Track track) async {
    var index = state.tracks.indexWhere((t) => t.id == track.id);
    if (index == -1) {
      // 不在队列：添加到末尾
      await addTrack(track);
      index = state.tracks.indexWhere((t) => t.id == track.id);
    }
    if (index == -1) return;
    await audioPlayer.jumpTo(index);
    // 投屏中不要恢复本地播放，避免双重音频
    if (!_isCasting && !audioPlayer.isPlaying) await audioPlayer.resume();
  }

  /// 播放曲目列表：批量添加到当前播放列表末尾（不覆盖）并跳转到 [initialIndex] 播放。
  ///
  /// 已在队列中的曲目会跳过添加。用于「播放全部」场景
  /// （`overwritePlaylistOnPlay=false` 时的默认行为）。
  Future<void> playTracks(List<Track> tracks, {int initialIndex = 0}) async {
    if (tracks.isEmpty) return;
    final target = tracks[initialIndex.clamp(0, tracks.length - 1)];
    final existingIds = state.tracks.map((t) => t.id).toSet();
    final newTracks =
        tracks.where((t) => !existingIds.contains(t.id)).toList();
    if (newTracks.isNotEmpty) {
      await addTracks(newTracks);
    }
    var targetIndex = state.tracks.indexWhere((t) => t.id == target.id);
    if (targetIndex == -1) return;
    await audioPlayer.jumpTo(targetIndex);
    // 投屏中不要恢复本地播放，避免双重音频
    if (!_isCasting && !audioPlayer.isPlaying) await audioPlayer.resume();
  }

  Future<void> moveTrack(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex ||
        newIndex < 0 ||
        oldIndex < 0 ||
        newIndex > state.tracks.length - 1 ||
        oldIndex > state.tracks.length - 1) {
      return;
    }

    await audioPlayer.moveTrack(oldIndex, newIndex);
  }

  /// 校验本地曲目文件是否仍存在。
  ///
  /// 把 `File(...).exists()` 这层文件 IO 从 UI 回调收口到 provider 层，
  /// UI 仅根据返回结果提示或继续播放，不再直接触达文件系统。
  Future<bool> localTrackFileExists(Track track) async {
    if (!track.isLocal || track.path == null) return true;
    return File(track.path!).exists();
  }

  // ---- 透传底层播放器能力 ----
  // UI 通过这些成员访问，而非直接持有全局 `audioPlayer` 单例，
  // 让播放控制统一收敛在 provider 层（3.7 UI 越界整改）。

  /// 当前播放进度流
  Stream<Duration> get positionStream => audioPlayer.positionStream;

  /// 当前播放进度
  Duration get position => audioPlayer.position;

  /// 总时长流
  Stream<Duration> get durationStream => audioPlayer.durationStream;

  /// 总时长
  Duration get duration => audioPlayer.duration;

  /// 当前音量（0~1）
  double get volume => audioPlayer.volume;

  /// 是否正在播放
  bool get isPlaying => audioPlayer.isPlaying;

  /// 暂停
  Future<void> pause() => audioPlayer.pause();

  /// 恢复播放
  Future<void> resume() => audioPlayer.resume();

  /// 跳转到指定进度
  Future<void> seek(Duration position) => audioPlayer.seek(position);

  /// 上一首
  Future<void> skipToPrevious() => audioPlayer.skipToPrevious();

  /// 下一首
  Future<void> skipToNext() => audioPlayer.skipToNext();

  /// 设置音量（0~1）
  Future<void> setVolume(double volume) => audioPlayer.setVolume(volume);

  Future<void> stop() async {
    state = state.copyWith(
      tracks: [],
      currentIndex: 0,
      collections: [],
      loopMode: PlaylistMode.none,
      playing: false,
      shuffled: false,
    );
    await audioPlayer.stop();
    await _updatePlayerState(
      state,
      // AudioPlayerStateTableCompanion(
      //   tracks: Value(state.tracks),
      //   currentIndex: const Value(0),
      //   collections: const Value(<String>[]),
      //   loopMode: const Value(PlaylistMode.none),
      //   playing: const Value(false),
      //   shuffled: const Value(false),
      // ),
    );
    // ref.read(discordProvider.notifier).clear();
  }
}

/// 音频播放器状态 state Provider
final audioPlayerProvider =
    NotifierProvider<AudioPlayerNotifier, AudioPlayerState>(
      () => AudioPlayerNotifier(),
    );
