import 'package:flutter/foundation.dart';
import 'package:pomelo/core/extensions/date_time.dart';
import 'track.dart';

/// 专辑模型
@immutable
class Album {
  /// 专辑唯一标识
  final String id;

  /// 专辑名称
  final String name;

  /// 艺术家
  final String? artist;

  /// 艺术家ID
  final String? artistId;

  /// 封面
  final String? coverArt;

  /// 发行年份
  final int? year;

  /// 歌曲数量
  final int songCount;

  /// 总时长（秒）
  final int duration;

  /// 播放次数
  final int playCount;

  /// 流派
  final String? genre;

  /// 简介
  final String? comment;

  /// 收藏时间
  final DateTime? starred;

  /// 创建时间
  final DateTime? created;

  /// 数据来源
  final ({String id, String name, String? libraryId, String? libraryName})?
  source;

  /// 来源原始数据
  final Map<String, dynamic>? meta;

  const Album({
    required this.id,
    required this.name,
    this.artist,
    this.artistId,
    this.coverArt,
    this.year,
    this.songCount = 0,
    this.duration = 0,
    this.playCount = 0,
    this.genre,
    this.comment,
    this.starred,
    this.created,
    this.source,
    this.meta,
  });

  /// 从 JSON 创建
  factory Album.fromJson(Map<String, dynamic> json) {
    final src = json['source'] as Map<String, dynamic>?;
    return Album(
      id: json['id'] as String,
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      artist: json['artist'] as String?,
      artistId: json['artistId'] as String? ?? json['artist_id'] as String?,
      coverArt: json['coverArt'] as String? ?? json['cover_url'] as String?,
      year: (json['year'] as num?)?.toInt(),
      songCount: (json['songCount'] as num?)?.toInt() ??
          (json['song_count'] as num?)?.toInt() ??
          0,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      playCount: (json['playCount'] as num?)?.toInt() ??
          (json['play_count'] as num?)?.toInt() ??
          0,
      genre: json['genre'] as String?,
      comment: json['comment'] as String? ?? json['description'] as String?,
      starred: tryParseDateTime(json['starred']),
      created: tryParseDateTime(json['created'] ?? json['created_at']),
      source: src != null
          ? (
              id: src['id'] as String,
              name: src['name'] as String,
              libraryId: src['libraryId'] as String?,
              libraryName: src['libraryName'] as String?,
            )
          : null,
      meta: json['meta'] != null
          ? Map<String, dynamic>.from(json['meta'] as Map)
          : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (artist != null) 'artist': artist,
      if (artistId != null) 'artistId': artistId,
      if (coverArt != null) 'coverArt': coverArt,
      if (year != null) 'year': year,
      'songCount': songCount,
      'duration': duration,
      'playCount': playCount,
      if (genre != null) 'genre': genre,
      if (comment != null) 'comment': comment,
      if (starred != null) 'starred': starred!.toIso8601String(),
      if (created != null) 'created': created!.toIso8601String(),
      if (source != null)
        'source': {
          'id': source!.id,
          'name': source!.name,
          if (source!.libraryId != null) 'libraryId': source!.libraryId,
          if (source!.libraryName != null) 'libraryName': source!.libraryName,
        },
      if (meta != null) 'meta': meta,
    };
  }

  /// 创建副本
  Album copyWith({
    String? id,
    String? name,
    String? artist,
    String? artistId,
    String? coverArt,
    int? year,
    int? songCount,
    int? duration,
    int? playCount,
    String? genre,
    String? comment,
    DateTime? starred,
    DateTime? created,
    ({String id, String name, String? libraryId, String? libraryName})? source,
    Map<String, dynamic>? meta,
    bool clearArtist = false,
    bool clearArtistId = false,
    bool clearCoverArt = false,
    bool clearYear = false,
    bool clearGenre = false,
    bool clearComment = false,
    bool clearStarred = false,
    bool clearCreated = false,
    bool clearSource = false,
    bool clearMeta = false,
  }) {
    return Album(
      id: id ?? this.id,
      name: name ?? this.name,
      artist: clearArtist ? null : (artist ?? this.artist),
      artistId: clearArtistId ? null : (artistId ?? this.artistId),
      coverArt: clearCoverArt ? null : (coverArt ?? this.coverArt),
      year: clearYear ? null : (year ?? this.year),
      songCount: songCount ?? this.songCount,
      duration: duration ?? this.duration,
      playCount: playCount ?? this.playCount,
      genre: clearGenre ? null : (genre ?? this.genre),
      comment: clearComment ? null : (comment ?? this.comment),
      starred: clearStarred ? null : (starred ?? this.starred),
      created: clearCreated ? null : (created ?? this.created),
      source: clearSource ? null : (source ?? this.source),
      meta: clearMeta ? null : (meta ?? this.meta),
    );
  }

  @override
  String toString() => 'Album(id: $id, name: $name, artist: $artist)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Album &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          artist == other.artist &&
          artistId == other.artistId &&
          coverArt == other.coverArt &&
          year == other.year &&
          songCount == other.songCount &&
          duration == other.duration &&
          playCount == other.playCount &&
          genre == other.genre &&
          comment == other.comment &&
          starred == other.starred &&
          created == other.created;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        artist,
        artistId,
        coverArt,
        year,
        songCount,
        duration,
        playCount,
        genre,
        comment,
        starred,
        created,
      );
}

/// 带曲目列表的专辑
@immutable
class AlbumWithTracks extends Album {
  /// 曲目列表
  final List<Track> tracks;

  const AlbumWithTracks({
    required super.id,
    required super.name,
    super.artist,
    super.artistId,
    super.coverArt,
    super.year,
    super.songCount,
    super.duration,
    super.playCount,
    super.genre,
    super.comment,
    super.starred,
    super.created,
    super.source,
    super.meta,
    this.tracks = const [],
  });

  /// 从 JSON 创建
  factory AlbumWithTracks.fromJson(Map<String, dynamic> json) {
    final src = json['source'] as Map<String, dynamic>?;
    return AlbumWithTracks(
      id: json['id'] as String,
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      artist: json['artist'] as String?,
      artistId: json['artistId'] as String? ?? json['artist_id'] as String?,
      coverArt: json['coverArt'] as String? ?? json['cover_url'] as String?,
      year: (json['year'] as num?)?.toInt(),
      songCount: (json['songCount'] as num?)?.toInt() ??
          (json['song_count'] as num?)?.toInt() ??
          0,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      playCount: (json['playCount'] as num?)?.toInt() ??
          (json['play_count'] as num?)?.toInt() ??
          0,
      genre: json['genre'] as String?,
      comment: json['comment'] as String? ?? json['description'] as String?,
      starred: tryParseDateTime(json['starred']),
      created: tryParseDateTime(json['created'] ?? json['created_at']),
      source: src != null
          ? (
              id: src['id'] as String,
              name: src['name'] as String,
              libraryId: src['libraryId'] as String?,
              libraryName: src['libraryName'] as String?,
            )
          : null,
      meta: json['meta'] != null
          ? Map<String, dynamic>.from(json['meta'] as Map)
          : null,
      tracks: (json['tracks'] as List<dynamic>?)
              ?.map((e) => Track.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final base = super.toJson();
    return {
      ...base,
      'tracks': tracks.map((t) => t.toJson()).toList(),
    };
  }

  @override
  AlbumWithTracks copyWith({
    String? id,
    String? name,
    String? artist,
    String? artistId,
    String? coverArt,
    int? year,
    int? songCount,
    int? duration,
    int? playCount,
    String? genre,
    String? comment,
    DateTime? starred,
    DateTime? created,
    ({String id, String name, String? libraryId, String? libraryName})? source,
    Map<String, dynamic>? meta,
    List<Track>? tracks,
    bool clearArtist = false,
    bool clearArtistId = false,
    bool clearCoverArt = false,
    bool clearYear = false,
    bool clearGenre = false,
    bool clearComment = false,
    bool clearStarred = false,
    bool clearCreated = false,
    bool clearSource = false,
    bool clearMeta = false,
  }) {
    return AlbumWithTracks(
      id: id ?? this.id,
      name: name ?? this.name,
      artist: clearArtist ? null : (artist ?? this.artist),
      artistId: clearArtistId ? null : (artistId ?? this.artistId),
      coverArt: clearCoverArt ? null : (coverArt ?? this.coverArt),
      year: clearYear ? null : (year ?? this.year),
      songCount: songCount ?? this.songCount,
      duration: duration ?? this.duration,
      playCount: playCount ?? this.playCount,
      genre: clearGenre ? null : (genre ?? this.genre),
      comment: clearComment ? null : (comment ?? this.comment),
      starred: clearStarred ? null : (starred ?? this.starred),
      created: clearCreated ? null : (created ?? this.created),
      source: clearSource ? null : (source ?? this.source),
      meta: clearMeta ? null : (meta ?? this.meta),
      tracks: tracks ?? this.tracks,
    );
  }

  @override
  String toString() =>
      'AlbumWithTracks(id: $id, name: $name, tracks: ${tracks.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlbumWithTracks &&
          runtimeType == other.runtimeType &&
          super == other &&
          _listEquals(tracks, other.tracks);

  @override
  int get hashCode => Object.hash(super.hashCode, Object.hashAll(tracks));

  static bool _listEquals(List<Track> a, List<Track> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
