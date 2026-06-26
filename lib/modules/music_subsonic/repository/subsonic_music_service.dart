import 'package:pomelo/core/mars.dart';
import 'package:pomelo/modules/music/model/models.dart';

import 'subsonic_client.dart';
import 'subsonic_models.dart';

/// Subsonic 音乐服务
///
/// 继承 [MusicService]，通过 [SubsonicClient] 对接 Subsonic REST API。
/// 每个 Subsonic 账号对应一个服务实例。
class SubsonicMusicService extends MusicService {
  final SubsonicClient client;
  final String _serverUrl;
  final String _username;
  final String _displayName;

  SubsonicMusicService({
    required this.client,
    required String serverUrl,
    required String username,
    String? displayName,
  })  : _serverUrl = serverUrl,
        _username = username,
        _displayName = displayName ?? username;

  @override
  MusicSourceType get sourceType => MusicSourceType.subsonic;

  @override
  int get maxServiceCount => 10;

  @override
  String get sourceId => 'subsonic-${_serverUrl.hashCode.abs()}-$_username';

  @override
  String get sourceName => _displayName;

  // ========== 搜索 ==========

  @override
  Future<PaginationResponse<Track>> searchTracks(
    String keyword, {
    int page = 1,
    int limit = 20,
    String? libraryId,
  }) async {
    if (keyword.isEmpty) {
      return PaginationResponse.empty(page: page, limit: limit);
    }
    final result = await client.search3(
      query: keyword,
      songCount: limit,
      songOffset: (page - 1) * limit,
    );
    final tracks = result.songs
        .map((s) => s.toTrack(
              sourceId: sourceId,
              sourceName: sourceName,
              serverUrl: _serverUrl,
            ))
        .toList();
    return PaginationResponse(
      page: page,
      limit: limit,
      total: result.songs.length < limit
          ? (page - 1) * limit + result.songs.length
          : page * limit + 1,
      hasMore: result.songs.length == limit,
      items: tracks,
    );
  }

  @override
  Future<PaginationResponse<Album>> searchAlbums(
    String keyword, {
    int page = 1,
    int limit = 20,
    String? libraryId,
  }) async {
    if (keyword.isEmpty) {
      return PaginationResponse.empty(page: page, limit: limit);
    }
    final result = await client.search3(
      query: keyword,
      albumCount: limit,
      albumOffset: (page - 1) * limit,
    );
    final albums = result.albums
        .map((a) => a.toAlbum(
              sourceId: sourceId,
              sourceName: sourceName,
              serverUrl: _serverUrl,
            ))
        .toList();
    return PaginationResponse(
      page: page,
      limit: limit,
      total: result.albums.length < limit
          ? (page - 1) * limit + result.albums.length
          : page * limit + 1,
      hasMore: result.albums.length == limit,
      items: albums,
    );
  }

  @override
  Future<PaginationResponse<Playlist>> searchPlaylists(
    String keyword, {
    int page = 1,
    int limit = 20,
    String? libraryId,
  }) async {
    final playlists = await client.getPlaylists();
    if (keyword.isEmpty) {
      final items = playlists
          .map((p) => p.toPlaylist(
                sourceId: sourceId,
                sourceName: sourceName,
                serverUrl: _serverUrl,
              ))
          .toList();
      return PaginationResponse.fromList(items, page: page, limit: limit);
    }
    final lower = keyword.toLowerCase();
    final filtered = playlists
        .where((p) =>
            p.name.toLowerCase().contains(lower) ||
            (p.comment?.toLowerCase().contains(lower) ?? false))
        .map((p) => p.toPlaylist(
              sourceId: sourceId,
              sourceName: sourceName,
              serverUrl: _serverUrl,
            ))
        .toList();
    return PaginationResponse.fromList(filtered, page: page, limit: limit);
  }

  // ========== 曲目 ==========

  @override
  Future<Track?> getTrack(String id) async {
    try {
      final song = await client.getSong(id);
      return song.toTrack(
        sourceId: sourceId,
        sourceName: sourceName,
        serverUrl: _serverUrl,
      );
    } on SubsonicException {
      return null;
    }
  }

  @override
  Future<PaginationResponse<Track>> getTracks({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final songs = await client.getRandomSongs(size: limit);
      final items = songs
          .map((s) => s.toTrack(
                sourceId: sourceId,
                sourceName: sourceName,
                serverUrl: _serverUrl,
              ))
          .toList();
      return PaginationResponse(
        page: page,
        limit: limit,
        total: items.length,
        hasMore: false,
        items: items,
      );
    } on SubsonicException {
      return PaginationResponse.empty(page: page, limit: limit);
    }
  }

  // ========== 专辑 ==========

  @override
  Future<Album?> getAlbum(String id) async {
    try {
      final album = await client.getAlbum(id);
      return album.toAlbum(
        sourceId: sourceId,
        sourceName: sourceName,
        serverUrl: _serverUrl,
      );
    } on SubsonicException {
      return null;
    }
  }

  @override
  Future<PaginationResponse<Track>> getAlbumTracks(
    String albumId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final album = await client.getAlbum(albumId);
      final tracks = album.songs
          .map((s) => s.toTrack(
                sourceId: sourceId,
                sourceName: sourceName,
                serverUrl: _serverUrl,
              ))
          .toList();
      return PaginationResponse.fromList(tracks, page: page, limit: limit);
    } on SubsonicException {
      return PaginationResponse.empty(page: page, limit: limit);
    }
  }

  // ========== 歌单 ==========

  @override
  Future<Playlist?> getPlaylist(String id) async {
    try {
      final playlist = await client.getPlaylist(id);
      return playlist.toPlaylist(
        sourceId: sourceId,
        sourceName: sourceName,
        serverUrl: _serverUrl,
      );
    } on SubsonicException {
      return null;
    }
  }

  @override
  Future<PaginationResponse<Playlist>> getPlaylists({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final playlists = await client.getPlaylists();
      final items = playlists
          .map((p) => p.toPlaylist(
                sourceId: sourceId,
                sourceName: sourceName,
                serverUrl: _serverUrl,
              ))
          .toList();
      return PaginationResponse.fromList(items, page: page, limit: limit);
    } on SubsonicException {
      return PaginationResponse.empty(page: page, limit: limit);
    }
  }

  // ========== 播放链接 ==========

  @override
  Future<String> getMusicUrl(Track track, {String? quality}) async {
    return client.buildStreamUrl(track.id);
  }

  // ========== Subsonic 专属方法 ==========

  /// 添加星标
  Future<void> starSong(String id) => client.star(id: id);

  /// 移除星标
  Future<void> unstarSong(String id) => client.unstar(id: id);

  /// 记录播放
  Future<void> scrobble(String id) => client.scrobble(id);

  /// 获取按类型排列的专辑列表
  Future<PaginationResponse<Album>> getAlbumListByType({
    required String type,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final albums = await client.getAlbumList2(
        type: type,
        size: limit,
        offset: (page - 1) * limit,
      );
      final items = albums
          .map((a) => a.toAlbum(
                sourceId: sourceId,
                sourceName: sourceName,
                serverUrl: _serverUrl,
              ))
          .toList();
      return PaginationResponse(
        page: page,
        limit: limit,
        total: albums.length < limit
            ? (page - 1) * limit + albums.length
            : page * limit + 1,
        hasMore: albums.length == limit,
        items: items,
      );
    } on SubsonicException {
      return PaginationResponse.empty(page: page, limit: limit);
    }
  }

  /// 获取所有艺术家列表
  Future<List<SubsonicArtist>> getArtists() => client.getArtists();
}
