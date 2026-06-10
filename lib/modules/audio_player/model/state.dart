import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:media_kit/media_kit.dart' hide Track;
import 'package:pomelo/modules/music/model/song.dart';

part 'state.freezed.dart';
part 'state.g.dart';

@freezed
class AudioPlayerState with _$AudioPlayerState {
  const AudioPlayerState._();

  factory AudioPlayerState._inner({
    required bool playing,
    required PlaylistMode loopMode,
    required bool shuffled,
    required List<String> collections,
    @Default(0) int currentIndex,
    @Default([]) List<Song> tracks,
  }) = _AudioPlayerState;

  factory AudioPlayerState({
    required bool playing,
    required PlaylistMode loopMode,
    required bool shuffled,
    required List<String> collections,
    int currentIndex = 0,
    List<Song> tracks = const [],
  }) {
    assert(
      tracks.every((track) => track is SongFull || track is SongLocal),
      'All tracks must be either SpotubeFullTrackObject or SpotubeLocalTrackObject',
    );

    return AudioPlayerState._inner(
      playing: playing,
      loopMode: loopMode,
      shuffled: shuffled,
      currentIndex: currentIndex,
      tracks: tracks,
      collections: collections,
    );
  }

  factory AudioPlayerState.fromJson(Map<String, dynamic> json) =>
      _$AudioPlayerStateFromJson(json);

  Song? get activeTrack {
    if (currentIndex < 0 || currentIndex >= tracks.length) return null;
    return tracks[currentIndex];
  }

  bool containsTrack(Song track) {
    return tracks.isNotEmpty &&
        tracks.any(
          (t) => t is SongLocal && track is SongLocal
              ? t.path == track.path
              : t.id == track.id,
        );
  }

  bool containsTracks(List<Song> tracks) {
    return this.tracks.isNotEmpty && tracks.every(containsTrack);
  }

  bool containsCollection(String collectionId) {
    return collections.contains(collectionId);
  }
}
