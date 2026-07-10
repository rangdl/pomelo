import 'package:flutter/foundation.dart';
import 'package:pomelo/core/extensions/date_time.dart';

/// 曲目模型
///
/// 统一的音轨数据结构，兼容在线曲目与本地曲目：
/// - [src] 非空时为在线曲目（播放地址）
/// - [path] 非空时为本地曲目（文件路径）
///
/// 字段命名遵循 Subsonic 风格 schema。
@immutable
class Track {
  /// 唯一标识
  final String id;

  /// 标题
  final String title;

  /// 艺术家名
  final String? artist;

  /// 专辑名
  final String? album;

  /// 专辑ID
  final String? albumId;

  /// 艺术家ID
  final String? artistId;

  /// 封面
  final String? coverArt;

  /// 时长（秒）
  final int duration;

  /// 音轨号
  final int? track;

  /// 碟片号
  final int? discNumber;

  /// 年份
  final int? year;

  /// 流派
  final String? genre;

  /// 比特率（Kbps）
  final int? bitRate;

  /// 播放次数
  final int? playCount;

  /// 收藏时间
  final DateTime? starred;

  /// 创建时间
  final DateTime? created;

  /// 在线曲目播放地址（非空表示在线曲目）
  final String? src;

  /// 本地曲目文件路径（非空表示本地曲目）
  final String? path;

  /// 数据来源
  ///
  /// - [id] 服务标识，如 'lx-server'、'lx-default'、'subsonic-xxx'、'local'
  /// - [name] 服务显示名
  /// - [libraryId] 库标识（如 'tx'、'kg'），无库概念时为 null
  /// - [libraryName] 库显示名，无库概念时为 null
  final ({String id, String name, String? libraryId, String? libraryName})
  source;

  /// 来源原始数据
  final Map<String, dynamic>? meta;

  const Track({
    required this.id,
    required this.title,
    this.artist,
    this.album,
    this.albumId,
    this.artistId,
    this.coverArt,
    this.duration = 0,
    this.track,
    this.discNumber,
    this.year,
    this.genre,
    this.bitRate,
    this.playCount,
    this.starred,
    this.created,
    this.src,
    this.path,
    required this.source,
    this.meta,
  });

  /// 是否为本地曲目
  bool get isLocal => path != null;

  /// 是否为在线曲目
  bool get isOnline => src != null;

  /// 格式化的时长字符串 (mm:ss)
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 从 JSON 创建
  factory Track.fromJson(Map<String, dynamic> json) {
    final source = json['source'] as Map<String, dynamic>;
    return Track(
      id: json['id'] as String,
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      artist: json['artist'] as String?,
      album: json['album'] as String?,
      albumId: json['albumId'] as String? ?? json['album_id'] as String?,
      artistId: json['artistId'] as String? ?? json['artist_id'] as String?,
      coverArt: json['coverArt'] as String? ?? json['cover_url'] as String?,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      track: (json['track'] as num?)?.toInt(),
      discNumber:
          (json['discNumber'] as num?)?.toInt() ??
          (json['disc_number'] as num?)?.toInt(),
      year: (json['year'] as num?)?.toInt(),
      genre: json['genre'] as String?,
      bitRate:
          (json['bitRate'] as num?)?.toInt() ??
          (json['bit_rate'] as num?)?.toInt(),
      playCount:
          (json['playCount'] as num?)?.toInt() ??
          (json['play_count'] as num?)?.toInt(),
      starred: tryParseDateTime(json['starred']),
      created: tryParseDateTime(json['created'] ?? json['created_at']),
      src: json['src'] as String?,
      path: json['path'] as String?,
      source: (
        id: source['id'] as String,
        name: source['name'] as String,
        libraryId: source['libraryId'] as String?,
        libraryName: source['libraryName'] as String?,
      ),
      meta: json['meta'] != null
          ? Map<String, dynamic>.from(json['meta'] as Map)
          : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (albumId != null) 'albumId': albumId,
      if (artistId != null) 'artistId': artistId,
      if (coverArt != null) 'coverArt': coverArt,
      'duration': duration,
      if (track != null) 'track': track,
      if (discNumber != null) 'discNumber': discNumber,
      if (year != null) 'year': year,
      if (genre != null) 'genre': genre,
      if (bitRate != null) 'bitRate': bitRate,
      if (playCount != null) 'playCount': playCount,
      if (starred != null) 'starred': starred!.toIso8601String(),
      if (created != null) 'created': created!.toIso8601String(),
      if (src != null) 'src': src,
      if (path != null) 'path': path,
      'source': {
        'id': source.id,
        'name': source.name,
        if (source.libraryId != null) 'libraryId': source.libraryId,
        if (source.libraryName != null) 'libraryName': source.libraryName,
      },

      if (meta != null) 'meta': meta,
    };
  }

  /// 创建副本，可选更新指定字段
  Track copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? albumId,
    String? artistId,
    String? coverArt,
    int? duration,
    int? track,
    int? discNumber,
    int? year,
    String? genre,
    int? bitRate,
    int? playCount,
    DateTime? starred,
    DateTime? created,
    String? src,
    String? path,
    ({String id, String name, String? libraryId, String? libraryName})? source,
    Map<String, dynamic>? meta,
    bool clearArtist = false,
    bool clearAlbum = false,
    bool clearAlbumId = false,
    bool clearArtistId = false,
    bool clearCoverArt = false,
    bool clearTrack = false,
    bool clearDiscNumber = false,
    bool clearYear = false,
    bool clearGenre = false,
    bool clearBitRate = false,
    bool clearPlayCount = false,
    bool clearStarred = false,
    bool clearCreated = false,
    bool clearSrc = false,
    bool clearPath = false,
    // bool clearSource = false,
    bool clearMeta = false,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: clearArtist ? null : (artist ?? this.artist),
      album: clearAlbum ? null : (album ?? this.album),
      albumId: clearAlbumId ? null : (albumId ?? this.albumId),
      artistId: clearArtistId ? null : (artistId ?? this.artistId),
      coverArt: clearCoverArt ? null : (coverArt ?? this.coverArt),
      duration: duration ?? this.duration,
      track: clearTrack ? null : (track ?? this.track),
      discNumber: clearDiscNumber ? null : (discNumber ?? this.discNumber),
      year: clearYear ? null : (year ?? this.year),
      genre: clearGenre ? null : (genre ?? this.genre),
      bitRate: clearBitRate ? null : (bitRate ?? this.bitRate),
      playCount: clearPlayCount ? null : (playCount ?? this.playCount),
      starred: clearStarred ? null : (starred ?? this.starred),
      created: clearCreated ? null : (created ?? this.created),
      src: clearSrc ? null : (src ?? this.src),
      path: clearPath ? null : (path ?? this.path),
      source: source ?? this.source,
      meta: clearMeta ? null : (meta ?? this.meta),
    );
  }

  @override
  String toString() => 'Track(id: $id, title: $title, artist: $artist)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Track &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          artist == other.artist &&
          album == other.album &&
          albumId == other.albumId &&
          artistId == other.artistId &&
          coverArt == other.coverArt &&
          duration == other.duration &&
          track == other.track &&
          discNumber == other.discNumber &&
          year == other.year &&
          genre == other.genre &&
          bitRate == other.bitRate &&
          playCount == other.playCount &&
          starred == other.starred &&
          created == other.created &&
          src == other.src &&
          path == other.path;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    artist,
    album,
    albumId,
    artistId,
    coverArt,
    duration,
    track,
    discNumber,
    year,
    genre,
    bitRate,
    playCount,
    starred,
    created,
    src,
    path,
  );
}
