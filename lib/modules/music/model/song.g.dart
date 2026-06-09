// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SongImpl _$$SongImplFromJson(Map json) => _$SongImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  artist: json['artist'] as String,
  albumId: json['albumId'] as String?,
  albumName: json['albumName'] as String?,
  coverUrl: json['coverUrl'] as String?,
  duration: (json['duration'] as num?)?.toInt() ?? 0,
  source: _$recordConvertAny(
    json['source'],
    ($jsonValue) =>
        (id: $jsonValue['id'] as String, name: $jsonValue['name'] as String),
  ),
  meta:
      (json['meta'] as Map?)?.map((k, e) => MapEntry(k as String, e)) ??
      const {},
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  path: json['path'] as String,
);

Map<String, dynamic> _$$SongImplToJson(_$SongImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'artist': instance.artist,
      'albumId': instance.albumId,
      'albumName': instance.albumName,
      'coverUrl': instance.coverUrl,
      'duration': instance.duration,
      'source': <String, dynamic>{
        'id': instance.source.id,
        'name': instance.source.name,
      },
      'meta': instance.meta,
      'createdAt': instance.createdAt?.toIso8601String(),
      'path': instance.path,
    };

$Rec _$recordConvertAny<$Rec>(Object? value, $Rec Function(Map) convert) =>
    convert(value as Map);
