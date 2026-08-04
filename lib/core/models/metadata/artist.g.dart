// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Artist _$ArtistFromJson(Map json) => Artist(
  id: json['id'] as String,
  name: json['name'] as String,
  coverArt: json['coverArt'] as String?,
  artistImageUrl: json['artistImageUrl'] as String?,
  albumCount: (json['albumCount'] as num?)?.toInt() ?? 0,
  starred: const _StarredDateTimeConverter().fromJson(json['starred']),
  source: const _ArtistSourceRefConverter().fromJson(
    json['source'] as Map<String, dynamic>?,
  ),
  meta: const _MetaMapConverter().fromJson(json['meta']),
);

Map<String, dynamic> _$ArtistToJson(Artist instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  if (instance.coverArt case final value?) 'coverArt': value,
  if (instance.artistImageUrl case final value?) 'artistImageUrl': value,
  'albumCount': instance.albumCount,
  if (const _StarredDateTimeConverter().toJson(instance.starred)
      case final value?)
    'starred': value,
  if (const _ArtistSourceRefConverter().toJson(instance.source)
      case final value?)
    'source': value,
  if (const _MetaMapConverter().toJson(instance.meta) case final value?)
    'meta': value,
};

ArtistWithAlbums _$ArtistWithAlbumsFromJson(Map json) => ArtistWithAlbums(
  id: json['id'] as String,
  name: json['name'] as String,
  coverArt: json['coverArt'] as String?,
  artistImageUrl: json['artistImageUrl'] as String?,
  albumCount: (json['albumCount'] as num?)?.toInt() ?? 0,
  starred: const _StarredDateTimeConverter().fromJson(json['starred']),
  source: const _ArtistSourceRefConverter().fromJson(
    json['source'] as Map<String, dynamic>?,
  ),
  meta: const _MetaMapConverter().fromJson(json['meta']),
  albums:
      (json['albums'] as List<dynamic>?)
          ?.map((e) => Album.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ArtistWithAlbumsToJson(ArtistWithAlbums instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      if (instance.coverArt case final value?) 'coverArt': value,
      if (instance.artistImageUrl case final value?) 'artistImageUrl': value,
      'albumCount': instance.albumCount,
      if (const _StarredDateTimeConverter().toJson(instance.starred)
          case final value?)
        'starred': value,
      if (const _ArtistSourceRefConverter().toJson(instance.source)
          case final value?)
        'source': value,
      if (const _MetaMapConverter().toJson(instance.meta) case final value?)
        'meta': value,
      'albums': instance.albums.map((e) => e.toJson()).toList(),
    };
