import 'dart:math';

import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart' hide Track;
import 'package:pomelo/core/extensions/list.dart';
import 'package:pomelo/core/models/metadata/track.dart';
import 'package:pomelo/services/audio_player/audio_player.dart';
import 'package:pomelo/services/logger/logger.dart';

import '../../services/audio_player/media.dart';
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
    await ref.read(audioPlayerRepositoryProvider).persist(companion);
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

          await _updatePlayerState(
            state,
            // AudioPlayerStateTableCompanion(
            //   currentIndex: Value(state.currentIndex),
            //   tracks: Value(state.tracks),
            // ),
          );
        } catch (e, stack) {
          AppLogger.reportError(e, stack, '[audioPlayerState] ${e.toString()}');
        }
      }),
    ];

    _syncSavedState();

    ref.onDispose(() {
      for (final subscription in subscriptions) {
        subscription.cancel();
      }
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

    // Giving the initial track a boost so MediaKit won't skip
    // because of timeout
    final intendedActiveTrack = medias.elementAt(initialIndex);
    if (intendedActiveTrack.track.path == null) {
      // ref.read(
      //   sourcedTrackProvider(intendedActiveTrack.track as SongFull).future,
      // );
    }

    if (medias.isEmpty) return;

    state = state.copyWith(
      tracks: medias.map((media) => media.track).toList(),
      currentIndex: initialIndex,
      collections: [],
    );

    _batchDepth++;
    try {
      await audioPlayer.openPlaylist(
        medias,
        initialIndex: initialIndex,
        autoPlay: autoPlay,
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

    final oldState = state;
    await audioPlayer.stop();

    await load(
      oldState.tracks,
      initialIndex: oldState.currentIndex,
      autoPlay: true,
    );
    state = state.copyWith(
      collections: oldState.collections,
      loopMode: oldState.loopMode,
      playing: oldState.playing,
      shuffled: false,
    );
    await audioPlayer.setLoopMode(oldState.loopMode);
    await _updatePlayerState(
      state,
      // AudioPlayerStateTableCompanion(
      //   tracks: Value(state.tracks),
      //   currentIndex: Value(state.currentIndex),
      //   collections: Value(state.collections),
      //   loopMode: Value(state.loopMode),
      //   playing: Value(state.playing),
      //   shuffled: Value(state.shuffled),
      // ),
    );
  }

  Future<void> jumpToTrack(Track track) async {
    final index = state.tracks.toList().indexWhere(
      (element) => element.id == track.id,
    );
    if (index == -1) return;
    await audioPlayer.jumpTo(index);
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
