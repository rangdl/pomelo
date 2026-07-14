// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AudioPlayerState _$AudioPlayerStateFromJson(Map json) => _AudioPlayerState(
  playing: json['playing'] as bool,
  loopMode: $enumDecode(_$PlaylistModeEnumMap, json['loopMode']),
  shuffled: json['shuffled'] as bool,
  collections: (json['collections'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  currentIndex: (json['currentIndex'] as num?)?.toInt() ?? 0,
  tracks:
      (json['tracks'] as List<dynamic>?)
          ?.map((e) => Track.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
);

Map<String, dynamic> _$AudioPlayerStateToJson(_AudioPlayerState instance) =>
    <String, dynamic>{
      'playing': instance.playing,
      'loopMode': _$PlaylistModeEnumMap[instance.loopMode]!,
      'shuffled': instance.shuffled,
      'collections': instance.collections,
      'currentIndex': instance.currentIndex,
      'tracks': instance.tracks.map((e) => e.toJson()).toList(),
    };

const _$PlaylistModeEnumMap = {
  PlaylistMode.none: 'none',
  PlaylistMode.single: 'single',
  PlaylistMode.loop: 'loop',
};
