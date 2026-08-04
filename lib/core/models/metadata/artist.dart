import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pomelo/core/extensions/date_time.dart';
import 'album.dart';

part 'artist.g.dart';

/// 来源引用（Pomelo 扩展字段，记录数据来自哪个服务/库）
typedef _ArtistSourceRef = ({
  String id,
  String name,
  String? libraryId,
  String? libraryName,
});

/// [_ArtistSourceRef] 的 JSON 编解码器
class _ArtistSourceRefConverter
    implements JsonConverter<_ArtistSourceRef?, Map<String, dynamic>?> {
  const _ArtistSourceRefConverter();

  @override
  _ArtistSourceRef? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return (
      id: json['id'] as String,
      name: json['name'] as String,
      libraryId: json['libraryId'] as String?,
      libraryName: json['libraryName'] as String?,
    );
  }

  @override
  Map<String, dynamic>? toJson(_ArtistSourceRef? source) {
    if (source == null) return null;
    return {
      'id': source.id,
      'name': source.name,
      if (source.libraryId != null) 'libraryId': source.libraryId,
      if (source.libraryName != null) 'libraryName': source.libraryName,
    };
  }
}

/// [DateTime] 编解码器，复用 [tryParseDateTime] 以保持对多种格式的兼容
class _StarredDateTimeConverter implements JsonConverter<DateTime?, dynamic> {
  const _StarredDateTimeConverter();

  @override
  DateTime? fromJson(dynamic json) => tryParseDateTime(json);

  @override
  dynamic toJson(DateTime? value) => value?.toIso8601String();
}

/// 来源原始数据（meta）编解码器，保证返回可修改的 Map 副本
class _MetaMapConverter
    implements JsonConverter<Map<String, dynamic>?, dynamic> {
  const _MetaMapConverter();

  @override
  Map<String, dynamic>? fromJson(dynamic json) =>
      json is Map ? Map<String, dynamic>.from(json) : null;

  @override
  dynamic toJson(Map<String, dynamic>? value) => value;
}

/// 艺术家模型
@immutable
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Artist {
  /// 唯一标识
  final String id;

  /// 名称
  final String name;

  /// 封面
  final String? coverArt;

  /// 艺术家图片URL
  final String? artistImageUrl;

  /// 专辑数量
  @JsonKey(defaultValue: 0)
  final int albumCount;

  /// 收藏时间
  @_StarredDateTimeConverter()
  final DateTime? starred;

  /// 数据来源（Pomelo 扩展）
  @_ArtistSourceRefConverter()
  final _ArtistSourceRef? source;

  /// 来源原始数据（Pomelo 扩展）
  @_MetaMapConverter()
  final Map<String, dynamic>? meta;

  const Artist({
    required this.id,
    required this.name,
    this.coverArt,
    this.artistImageUrl,
    this.albumCount = 0,
    this.starred,
    this.source,
    this.meta,
  });

  /// 从 JSON 创建
  factory Artist.fromJson(Map<String, dynamic> json) =>
      _$ArtistFromJson(json);

  /// 转换为 JSON
  Map<String, dynamic> toJson() => _$ArtistToJson(this);

  /// 创建副本
  Artist copyWith({
    String? id,
    String? name,
    String? coverArt,
    String? artistImageUrl,
    int? albumCount,
    DateTime? starred,
    _ArtistSourceRef? source,
    Map<String, dynamic>? meta,
    bool clearCoverArt = false,
    bool clearArtistImageUrl = false,
    bool clearStarred = false,
    bool clearSource = false,
    bool clearMeta = false,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      coverArt: clearCoverArt ? null : (coverArt ?? this.coverArt),
      artistImageUrl:
          clearArtistImageUrl ? null : (artistImageUrl ?? this.artistImageUrl),
      albumCount: albumCount ?? this.albumCount,
      starred: clearStarred ? null : (starred ?? this.starred),
      source: clearSource ? null : (source ?? this.source),
      meta: clearMeta ? null : (meta ?? this.meta),
    );
  }

  @override
  String toString() => 'Artist(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Artist &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          coverArt == other.coverArt &&
          artistImageUrl == other.artistImageUrl &&
          albumCount == other.albumCount &&
          starred == other.starred;

  @override
  int get hashCode =>
      Object.hash(id, name, coverArt, artistImageUrl, albumCount, starred);
}

/// 带专辑列表的艺术家
@immutable
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ArtistWithAlbums extends Artist {
  /// 专辑列表
  final List<Album> albums;

  const ArtistWithAlbums({
    required super.id,
    required super.name,
    super.coverArt,
    super.artistImageUrl,
    super.albumCount,
    super.starred,
    super.source,
    super.meta,
    this.albums = const [],
  });

  /// 从 JSON 创建
  factory ArtistWithAlbums.fromJson(Map<String, dynamic> json) =>
      _$ArtistWithAlbumsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ArtistWithAlbumsToJson(this);

  @override
  ArtistWithAlbums copyWith({
    String? id,
    String? name,
    String? coverArt,
    String? artistImageUrl,
    int? albumCount,
    DateTime? starred,
    _ArtistSourceRef? source,
    Map<String, dynamic>? meta,
    List<Album>? albums,
    bool clearCoverArt = false,
    bool clearArtistImageUrl = false,
    bool clearStarred = false,
    bool clearSource = false,
    bool clearMeta = false,
  }) {
    return ArtistWithAlbums(
      id: id ?? this.id,
      name: name ?? this.name,
      coverArt: clearCoverArt ? null : (coverArt ?? this.coverArt),
      artistImageUrl:
          clearArtistImageUrl ? null : (artistImageUrl ?? this.artistImageUrl),
      albumCount: albumCount ?? this.albumCount,
      starred: clearStarred ? null : (starred ?? this.starred),
      source: clearSource ? null : (source ?? this.source),
      meta: clearMeta ? null : (meta ?? this.meta),
      albums: albums ?? this.albums,
    );
  }

  @override
  String toString() =>
      'ArtistWithAlbums(id: $id, name: $name, albums: ${albums.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArtistWithAlbums &&
          runtimeType == other.runtimeType &&
          super == other &&
          _listEquals(albums, other.albums);

  @override
  int get hashCode => Object.hash(super.hashCode, Object.hashAll(albums));

  static bool _listEquals(List<Album> a, List<Album> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
