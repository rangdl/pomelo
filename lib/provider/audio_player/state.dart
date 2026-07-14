import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:media_kit/media_kit.dart' hide Track;
import 'package:pomelo/core/models/metadata/track.dart';

part 'state.freezed.dart';
part 'state.g.dart';

@freezed
sealed class AudioPlayerState with _$AudioPlayerState {
  const AudioPlayerState._();

  factory AudioPlayerState({
    required bool playing,
    required PlaylistMode loopMode,
    required bool shuffled,
    required List<String> collections,
    @Default(0) int currentIndex,
    @Default([]) List<Track> tracks,
  }) = _AudioPlayerState;

  factory AudioPlayerState.fromJson(Map<String, dynamic> json) =>
      _$AudioPlayerStateFromJson(json);

  Track? get activeTrack {
    if (currentIndex < 0 || currentIndex >= tracks.length) return null;
    return tracks[currentIndex];
  }

  bool containsTrack(Track track) {
    return tracks.isNotEmpty &&
        tracks.any(
          (t) => t.path != null && track.path != null
              ? t.path == track.path
              : t.id == track.id,
        );
  }

  bool containsTracks(List<Track> tracks) {
    return this.tracks.isNotEmpty && tracks.every(containsTrack);
  }

  bool containsCollection(String collectionId) {
    return collections.contains(collectionId);
  }
}
