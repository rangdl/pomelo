import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/models/database/app_database.dart';
import 'package:pomelo/provider/audio_player/audio_player.dart';
import 'package:pomelo/provider/database/database_provider.dart';
import 'package:pomelo/provider/history/play_history_provider.dart';
import 'package:pomelo/provider/lyric/lyric.dart';
import 'package:pomelo/services/audio_player/audio_player.dart';
import 'package:pomelo/provider/audio_player/state.dart';
import 'package:pomelo/services/audio_services/audio_services.dart';
import 'package:pomelo/services/logger/logger.dart';
import 'package:pomelo/ui/player/lyric_parser.dart';

import '../../core/models/metadata/metadata.dart';

class AudioPlayerStreamListeners {
  final Ref ref;
  late final AudioServices notificationService;
  AudioPlayerStreamListeners(this.ref) {
    AudioServices.create(
      ref,
      ref.read(audioPlayerProvider.notifier),
    ).then((value) => notificationService = value);

    final subscriptions = [
      subscribeToPlaylist(),
      subscribeToSkipSponsor(),
      subscribeToScrobbleChanged(),
      subscribeToPosition(),
      subscribeToPlayerError(),
      subscribeLyric(),
    ];

    ref.onDispose(() {
      for (final subscription in subscriptions) {
        subscription.cancel();
      }
    });
  }

  // ScrobblerNotifier get scrobbler => ref.read(scrobblerProvider.notifier);
  // UserPreferences get preferences => ref.read(userPreferencesProvider);
  // DiscordNotifier get discord => ref.read(discordProvider.notifier);
  AudioPlayerState get audioPlayerState => ref.read(audioPlayerProvider);
  // PlaybackHistoryActions get history =>
  //     ref.read(playbackHistoryActionsProvider);

  // 监听播放列表变化，同步元数据到系统媒体控制
  StreamSubscription subscribeToPlaylist() {
    return audioPlayer.playlistStream.listen((mpvPlaylist) {
      try {
        if (audioPlayerState.activeTrack == null) return;
        notificationService.addTrack(audioPlayerState.activeTrack!);
      } catch (e, stack) {
        AppLogger.reportError(e, stack);
      }
    });
  }

  StreamSubscription subscribeToSkipSponsor() {
    return audioPlayer.positionStream.listen((position) async {
      try {
        // final currentSegments = await ref.read(segmentProvider.future);

        // if (currentSegments?.segments.isNotEmpty != true ||
        //     position < const Duration(seconds: 3)) {
        //   return;
        // }

        // for (final segment in currentSegments!.segments) {
        //   final seconds = position.inSeconds;

        //   if (seconds < segment.start || seconds >= segment.end) continue;

        //   await audioPlayer.seek(Duration(seconds: segment.end + 1));
        // }
      } catch (e, stack) {
        AppLogger.reportError(e, stack);
      }
    });
  }

  StreamSubscription subscribeToScrobbleChanged() {
    String? lastScrobbled;
    return audioPlayer.positionStream.listen((position) async {
      try {
        final uid = audioPlayerState.activeTrack is Track
            ? (audioPlayerState.activeTrack as Track).path
            : audioPlayerState.activeTrack?.id;

        /// According to Listenbrainz and Last.fm, a scrobble should be sent
        /// after 4 minutes of listening or 50% of the track duration,
        /// whichever is less.
        final minimumListenTime = min(audioPlayer.duration.inSeconds ~/ 2, 240);

        if (audioPlayerState.activeTrack == null ||
            lastScrobbled == uid ||
            position.inSeconds < minimumListenTime ||
            audioPlayer.duration == Duration.zero ||
            position == Duration.zero) {
          return;
        }

        // scrobbler.scrobble(audioPlayerState.activeTrack!);
        // ref
        //     .read(metadataPluginScrobbleProvider.notifier)
        //     .scrobble(audioPlayerState.activeTrack!);
        lastScrobbled = uid;

        // /// The [Track] from Playlist.getTracks doesn't contain artist images
        // /// so we need to fetch them from the API
        var activeTrack = audioPlayerState.activeTrack!;

        // 记录播放历史（upsert 语义，重复播放时 playCount 递增）
        // 仅在满足 scrobble 条件（听完 4 分钟或 50% 时长）后记录
        try {
          final db = ref.read(databaseProvider);
          await db.addPlayHistory(
            PlayHistoryTableCompanion.insert(
              trackId: activeTrack.id,
              trackJson: jsonEncode(activeTrack.toJson()),
              sourceId: activeTrack.source.id,
              sourceName: Value(activeTrack.source.name),
              title: activeTrack.title,
              artist: Value(activeTrack.artist),
              coverArt: Value(activeTrack.coverArt),
              duration: Value(activeTrack.duration),
            ),
          );
          ref.invalidate(playHistoryProvider);
        } catch (e, stack) {
          AppLogger.reportError(e, stack, '[playHistory] ${e.toString()}');
        }

        // if (activeTrack.artists.any((a) => a.images == null)) {
        //   final metadataPlugin = await ref.read(metadataPluginProvider.future);
        //   final artists = await Future.wait(
        //     activeTrack.artists
        //         .map((artist) => metadataPlugin!.artist.getArtist(artist.id)),
        //   );
        //   activeTrack = activeTrack.copyWith(
        //     artists: artists
        //         .map((e) => SpotubeSimpleArtistObject.fromJson(e.toJson()))
        //         .toList(),
        //   );
        // }

        // await history.addTrack(activeTrack);
      } catch (e, stack) {
        AppLogger.reportError(e, stack);
      }
    });
  }

  StreamSubscription subscribeToPosition() {
    String lastTrack = ""; // used to prevent multiple calls to the same track
    return audioPlayer.positionStream.listen((event) async {
      final percentProgress =
          (event.inSeconds / max(audioPlayer.duration.inSeconds, 1)) * 100;
      try {
        if (percentProgress < 80 ||
            audioPlayerState.currentIndex == -1 ||
            audioPlayerState.currentIndex ==
                audioPlayerState.tracks.length - 1) {
          return;
        }
        final nextTrack = audioPlayerState.tracks.elementAtOrNull(
          audioPlayerState.currentIndex + 1,
        );

        if (nextTrack == null || lastTrack == nextTrack.id) {
          return;
        }

        try {
          // await ref.read(
          //   sourcedTrackProvider(nextTrack as SpotubeFullTrackObject).future,
          // );
        } finally {
          lastTrack = nextTrack.id;
        }
      } catch (e, stack) {
        AppLogger.reportError(e, stack);
      }
    });
  }

  StreamSubscription subscribeToPlayerError() {
    return audioPlayer.errorStream.listen((event) {});
  }

  // 监听当前歌词行，同步到系统媒体控制的 artist 展示位置
  StreamSubscription subscribeLyric() {
    // 监听位置流，输出当前歌词行
    String? lastLine;
    return audioPlayer.positionStream.listen((position) async {
      try {
        final track = audioPlayerState.activeTrack;
        if (track == null || track.src == null) return;
        final lines = await ref.read(lyricLinesProvider(track).future);
        if (lines.isEmpty) {
          return;
        }
        final index = LyricParser.findCurrentIndex(lines, position);
        final line = index >= 0 ? lines[index].text : null;

        // 去重：仅在歌词行变化时输出
        if (line != lastLine) {
          lastLine = line;
          notificationService.updateLyric(line);
        }
      } catch (e, stack) {
        AppLogger.reportError(e, stack);
      }
    });
  }
}

final audioPlayerStreamListenersProvider = Provider<AudioPlayerStreamListeners>(
  AudioPlayerStreamListeners.new,
);
