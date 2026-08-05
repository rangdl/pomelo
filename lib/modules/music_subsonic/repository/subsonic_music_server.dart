import 'package:pomelo/core/core.dart';
import 'package:pomelo/core/models/metadata/metadata.dart';

import 'subsonic_client.dart';
import 'subsonic_models.dart';

/// Subsonic 音乐服务
///
/// 继承 [MusicServer]，通过 [SubsonicClient] 对接 Subsonic REST API。
/// 每个 Subsonic 账号对应一个服务实例。
class SubsonicMusicServer extends MusicServer {
  final SubsonicClient client;
  final String _serverUrl;
  final String _sourceId;
  final String _displayName;

  /// [sourceId] 必须传入对应 SubsonicConfig 的 id
  ///
  /// 曲目的 `source.id` 取自此处，播放与取歌词时会用它反查
  /// `musicServerProvider(configId)`；该 provider 按 config.id 索引，
  /// 因此二者必须同源，不能各自拼串。
  SubsonicMusicServer({
    required this.client,
    required String sourceId,
    required String serverUrl,
    required String username,
    String? displayName,
  }) : _sourceId = sourceId,
       _serverUrl = serverUrl,
       _displayName = displayName ?? username;

  @override
  MusicSourceType get sourceType => MusicSourceType.subsonic;

  @override
  int get maxServiceCount => 10;

  @override
  String get sourceId => _sourceId;

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
    return PaginationResponse.fromPageSize(
      items: tracks,
      page: page,
      limit: limit,
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
    return PaginationResponse.fromPageSize(
      items: albums,
      page: page,
      limit: limit,
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
    final song = await client.getSong(id);
    return song.toTrack(
      sourceId: sourceId,
      sourceName: sourceName,
      serverUrl: _serverUrl,
    );
  }

  @override
  Future<PaginationResponse<Track>> getTracks({
    int page = 1,
    int limit = 20,
  }) async {
    final songs = await client.getRandomSongs(size: limit);
    final items = songs
        .map((s) => s.toTrack(
              sourceId: sourceId,
              sourceName: sourceName,
              serverUrl: _serverUrl,
            ))
        .toList();
    return PaginationResponse.complete(items, page: page, limit: limit);
  }

  // ========== 专辑 ==========

  @override
  Future<Album?> getAlbum(String id) async {
    final album = await client.getAlbum(id);
    return album.toAlbum(
      sourceId: sourceId,
      sourceName: sourceName,
      serverUrl: _serverUrl,
    );
  }

  @override
  Future<PaginationResponse<Track>> getAlbumTracks(
    String albumId, {
    int page = 1,
    int limit = 20,
  }) async {
    final album = await client.getAlbum(albumId);
    final tracks = album.songs
        .map((s) => s.toTrack(
              sourceId: sourceId,
              sourceName: sourceName,
              serverUrl: _serverUrl,
            ))
        .toList();
    return PaginationResponse.fromList(tracks, page: page, limit: limit);
  }

  // ========== 歌手 ==========

  @override
  Future<Artist?> getArtist(String id) async {
    final result = await client.getArtist(id);
    return result.artist.toArtist(
      sourceId: sourceId,
      sourceName: sourceName,
      serverUrl: _serverUrl,
    );
  }

  @override
  Future<List<Album>> getArtistAlbums(String artistId) async {
    final result = await client.getArtist(artistId);
    return result.albums
        .map((a) => a.toAlbum(
              sourceId: sourceId,
              sourceName: sourceName,
              serverUrl: _serverUrl,
            ))
        .toList();
  }

  // ========== 歌单 ==========

  @override
  Future<Playlist?> getPlaylist(String id) async {
    final playlist = await client.getPlaylist(id);
    return playlist.toPlaylist(
      sourceId: sourceId,
      sourceName: sourceName,
      serverUrl: _serverUrl,
    );
  }

  @override
  Future<PaginationResponse<Playlist>> getPlaylists({
    int page = 1,
    int limit = 20,
  }) async {
    final playlists = await client.getPlaylists();
    final items = playlists
        .map((p) => p.toPlaylist(
              sourceId: sourceId,
              sourceName: sourceName,
              serverUrl: _serverUrl,
            ))
        .toList();
    return PaginationResponse.fromList(items, page: page, limit: limit);
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
    return PaginationResponse.fromPageSize(
      items: items,
      page: page,
      limit: limit,
    );
  }

  /// 获取所有艺术家列表
  Future<List<SubsonicArtist>> getArtists() => client.getArtists();
}
