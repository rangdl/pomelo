import 'package:pomelo/modules/music/model/models.dart';

/// Subsonic REST API 顶层响应包装
///
/// 所有 API 调用的响应根节点均为 `subsonic-response`。
class SubsonicResponse {
  /// 响应状态：'ok' 或 'failed'
  final String status;

  /// 服务端 REST API 版本
  final String version;

  /// 错误信息（仅 status == 'failed' 时存在）
  final SubsonicError? error;

  /// 原始 JSON 数据（去除 subsonic-response 包装后的内容）
  final Map<String, dynamic> data;

  SubsonicResponse({
    required this.status,
    required this.version,
    this.error,
    required this.data,
  });

  bool get isOk => status == 'ok';

  factory SubsonicResponse.fromJson(Map<String, dynamic> json) {
    final root = json['subsonic-response'] as Map<String, dynamic>;
    return SubsonicResponse(
      status: root['status'] as String,
      version: root['version'] as String? ?? '',
      error: root['error'] != null
          ? SubsonicError.fromJson(root['error'] as Map<String, dynamic>)
          : null,
      data: root,
    );
  }
}

/// Subsonic API 错误
class SubsonicError {
  final int code;
  final String message;

  SubsonicError({required this.code, required this.message});

  factory SubsonicError.fromJson(Map<String, dynamic> json) {
    return SubsonicError(
      code: json['code'] as int,
      message: json['message'] as String? ?? '',
    );
  }

  @override
  String toString() => 'SubsonicError($code: $message)';
}

/// Subsonic API 异常
class SubsonicException implements Exception {
  final int code;
  final String message;

  SubsonicException(this.code, this.message);

  @override
  String toString() => 'SubsonicException($code: $message)';
}

/// Subsonic 歌曲（child 元素）
class SubsonicSong {
  final String id;
  final String title;
  final String? album;
  final String? artist;
  final String? albumId;
  final String? artistId;
  final String? coverArt;
  final int duration; // 秒
  final int? track;
  final int? year;
  final String? genre;
  final String? type;
  final int? size;
  final String? contentType;
  final String? suffix;
  final String? path;

  SubsonicSong({
    required this.id,
    required this.title,
    this.album,
    this.artist,
    this.albumId,
    this.artistId,
    this.coverArt,
    this.duration = 0,
    this.track,
    this.year,
    this.genre,
    this.type,
    this.size,
    this.contentType,
    this.suffix,
    this.path,
  });

  factory SubsonicSong.fromJson(Map<String, dynamic> json) {
    return SubsonicSong(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      album: json['album'] as String?,
      artist: json['artist'] as String?,
      albumId: json['albumId'] as String?,
      artistId: json['artistId'] as String?,
      coverArt: json['coverArt'] as String?,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      track: json['track'] as int?,
      year: json['year'] as int?,
      genre: json['genre'] as String?,
      type: json['type'] as String?,
      size: (json['size'] as num?)?.toInt(),
      contentType: json['contentType'] as String?,
      suffix: json['suffix'] as String?,
      path: json['path'] as String?,
    );
  }

  /// 转换为项目统一的 [Song] 模型
  Song toSong({required String sourceId, required String sourceName, required String serverUrl}) {
    final coverUrl = coverArt != null
        ? '$serverUrl/rest/getCoverArt?id=$coverArt&size=300&f=json'
        : null;
    final streamUrl = '$serverUrl/rest/stream?id=$id&f=json';
    return Song.full(
      id: id,
      name: title,
      artist: artist ?? 'Unknown',
      albumId: albumId,
      albumName: album,
      coverUrl: coverUrl,
      duration: duration,
      source: (id: sourceId, name: sourceName),
      meta: {
        'genre': genre,
        'track': track,
        'year': year,
        'size': size,
        'suffix': suffix,
        'path': path,
      },
      src: streamUrl,
    );
  }
}

/// Subsonic 专辑（ID3 模式）
class SubsonicAlbum {
  final String id;
  final String name;
  final String? artist;
  final String? artistId;
  final int songCount;
  final int? duration; // 秒
  final String? coverArt;
  final int? year;
  final String? genre;
  final List<SubsonicSong> songs;

  SubsonicAlbum({
    required this.id,
    required this.name,
    this.artist,
    this.artistId,
    this.songCount = 0,
    this.duration,
    this.coverArt,
    this.year,
    this.genre,
    this.songs = const [],
  });

  factory SubsonicAlbum.fromJson(Map<String, dynamic> json) {
    final songList = (json['song'] as List<dynamic>?)
            ?.map((e) => SubsonicSong.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return SubsonicAlbum(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      artist: json['artist'] as String?,
      artistId: json['artistId'] as String?,
      songCount: (json['songCount'] as num?)?.toInt() ?? songList.length,
      duration: (json['duration'] as num?)?.toInt(),
      coverArt: json['coverArt'] as String?,
      year: json['year'] as int?,
      genre: json['genre'] as String?,
      songs: songList,
    );
  }

  /// 转换为项目统一的 [Album] 模型
  Album toAlbum({required String sourceId, required String sourceName, required String serverUrl}) {
    final coverUrl = coverArt != null
        ? '$serverUrl/rest/getCoverArt?id=$coverArt&size=300&f=json'
        : null;
    return Album(
      id: id,
      title: name,
      artist: artist ?? 'Unknown',
      coverUrl: coverUrl,
      year: year,
      songCount: songCount,
      source: (id: sourceId, name: sourceName),
      meta: {
        'genre': genre,
        'duration': duration,
      },
    );
  }
}

/// Subsonic 艺术家（ID3 模式）
class SubsonicArtist {
  final String id;
  final String name;
  final int albumCount;
  final String? coverArt;

  SubsonicArtist({
    required this.id,
    required this.name,
    this.albumCount = 0,
    this.coverArt,
  });

  factory SubsonicArtist.fromJson(Map<String, dynamic> json) {
    return SubsonicArtist(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      albumCount: (json['albumCount'] as num?)?.toInt() ?? 0,
      coverArt: json['coverArt'] as String?,
    );
  }
}

/// Subsonic 歌单
class SubsonicPlaylist {
  final String id;
  final String name;
  final String? comment;
  final String? owner;
  final bool public;
  final int songCount;
  final int? duration; // 秒
  final String? coverArt;
  final DateTime? created;
  final List<SubsonicSong> entries;

  SubsonicPlaylist({
    required this.id,
    required this.name,
    this.comment,
    this.owner,
    this.public = false,
    this.songCount = 0,
    this.duration,
    this.coverArt,
    this.created,
    this.entries = const [],
  });

  factory SubsonicPlaylist.fromJson(Map<String, dynamic> json) {
    final entryList = (json['entry'] as List<dynamic>?)
            ?.map((e) => SubsonicSong.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return SubsonicPlaylist(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      comment: json['comment'] as String?,
      owner: json['owner'] as String?,
      public: json['public'] as bool? ?? false,
      songCount: (json['songCount'] as num?)?.toInt() ?? entryList.length,
      duration: (json['duration'] as num?)?.toInt(),
      coverArt: json['coverArt'] as String?,
      created: json['created'] != null
          ? DateTime.tryParse(json['created'] as String)
          : null,
      entries: entryList,
    );
  }

  /// 转换为项目统一的 [Playlist] 模型
  Playlist toPlaylist({required String sourceId, required String sourceName, required String serverUrl}) {
    final coverUrl = coverArt != null
        ? '$serverUrl/rest/getCoverArt?id=$coverArt&size=300&f=json'
        : null;
    return Playlist(
      id: id,
      name: name,
      coverUrl: coverUrl,
      creator: owner ?? '',
      description: comment,
      songs: entries
          .map((s) => s.toSong(
                sourceId: sourceId,
                sourceName: sourceName,
                serverUrl: serverUrl,
              ))
          .toList(),
      source: (id: sourceId, name: sourceName),
      meta: {
        'duration': duration,
        'public': public,
      },
      createdAt: created,
    );
  }
}

/// Subsonic search3 搜索结果
class SubsonicSearchResult3 {
  final List<SubsonicArtist> artists;
  final List<SubsonicAlbum> albums;
  final List<SubsonicSong> songs;

  SubsonicSearchResult3({
    this.artists = const [],
    this.albums = const [],
    this.songs = const [],
  });

  factory SubsonicSearchResult3.fromJson(Map<String, dynamic> json) {
    return SubsonicSearchResult3(
      artists: (json['artist'] as List<dynamic>?)
              ?.map((e) => SubsonicArtist.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      albums: (json['album'] as List<dynamic>?)
              ?.map((e) => SubsonicAlbum.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      songs: (json['song'] as List<dynamic>?)
              ?.map((e) => SubsonicSong.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
