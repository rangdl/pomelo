// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchItem _$SearchItemFromJson(Map json) => SearchItem(
  id: json['id'] as String?,
  name: json['name'] as String?,
  artist: json['artist'] as String?,
  album: json['album'] as String?,
  duration: (json['duration'] as num?)?.toInt(),
  coverUrl: json['coverUrl'] as String?,
  source: json['source'] as String?,
);

Map<String, dynamic> _$SearchItemToJson(SearchItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'artist': instance.artist,
      'album': instance.album,
      'duration': instance.duration,
      'coverUrl': instance.coverUrl,
      'source': instance.source,
    };

SearchResult _$SearchResultFromJson(Map json) => SearchResult(
  list: (json['list'] as List<dynamic>)
      .map((e) => SearchItem.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$SearchResultToJson(SearchResult instance) =>
    <String, dynamic>{
      'list': instance.list.map((e) => e.toJson()).toList(),
      'total': instance.total,
    };

PlatformInfo _$PlatformInfoFromJson(Map json) =>
    PlatformInfo(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$PlatformInfoToJson(PlatformInfo instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

MusicsdkError _$MusicsdkErrorFromJson(Map json) => MusicsdkError(
  message: json['message'] as String,
  code: json['code'] as String?,
  httpStatus: (json['httpStatus'] as num?)?.toInt(),
);

Map<String, dynamic> _$MusicsdkErrorToJson(MusicsdkError instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
      'httpStatus': instance.httpStatus,
    };
