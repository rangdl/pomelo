// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SongFullImpl _$$SongFullImplFromJson(Map json) => _$SongFullImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  artist: json['artist'] as String,
  albumId: json['albumId'] as String?,
  albumName: json['albumName'] as String?,
  coverUrl: json['coverUrl'] as String?,
  duration: (json['duration'] as num?)?.toInt() ?? 0,
  source: _$recordConvertAny(
    json['source'],
    ($jsonValue) => (
      id: $jsonValue['id'] as String,
      libraryId: $jsonValue['libraryId'] as String?,
      libraryName: $jsonValue['libraryName'] as String?,
      name: $jsonValue['name'] as String,
    ),
  ),
  meta:
      (json['meta'] as Map?)?.map((k, e) => MapEntry(k as String, e)) ??
      const {},
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  src: json['src'] as String,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$SongFullImplToJson(_$SongFullImpl instance) =>
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
        'libraryId': instance.source.libraryId,
        'libraryName': instance.source.libraryName,
        'name': instance.source.name,
      },
      'meta': instance.meta,
      'createdAt': instance.createdAt?.toIso8601String(),
      'src': instance.src,
      'runtimeType': instance.$type,
    };

$Rec _$recordConvertAny<$Rec>(Object? value, $Rec Function(Map) convert) =>
    convert(value as Map);

_$SongLocalImpl _$$SongLocalImplFromJson(Map json) => _$SongLocalImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  artist: json['artist'] as String,
  albumId: json['albumId'] as String?,
  albumName: json['albumName'] as String?,
  coverUrl: json['coverUrl'] as String?,
  duration: (json['duration'] as num?)?.toInt() ?? 0,
  source: _$recordConvertAny(
    json['source'],
    ($jsonValue) => (
      id: $jsonValue['id'] as String,
      libraryId: $jsonValue['libraryId'] as String?,
      libraryName: $jsonValue['libraryName'] as String?,
      name: $jsonValue['name'] as String,
    ),
  ),
  meta:
      (json['meta'] as Map?)?.map((k, e) => MapEntry(k as String, e)) ??
      const {},
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  path: json['path'] as String,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$SongLocalImplToJson(_$SongLocalImpl instance) =>
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
        'libraryId': instance.source.libraryId,
        'libraryName': instance.source.libraryName,
        'name': instance.source.name,
      },
      'meta': instance.meta,
      'createdAt': instance.createdAt?.toIso8601String(),
      'path': instance.path,
      'runtimeType': instance.$type,
    };
