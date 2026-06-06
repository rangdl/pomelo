import 'package:pomelo/modules/music/model/models.dart';

/// 本地音乐提供者
///
/// 实现 [MusicProvider] 接口，提供本地音乐的查询能力。
/// 当前使用模拟数据，实际应用可替换为本地数据库查询。
class LocalMusicProvider extends MusicProvider {
  @override
  String get sourceId => 'local';

  @override
  String get sourceName => '本地音乐';

  final _source = (id: 'local', name: '本地音乐');

  /// 模拟数据
  late final List<Song> _mockSongs;
  late final List<Album> _mockAlbums;
  late final List<Playlist> _mockPlaylists;

  LocalMusicProvider() {
    _initMockData();
  }

  void _initMockData() {
    _mockAlbums = List.generate(5, (i) {
      return Album(
        id: 'local_album_$i',
        title: '本地专辑 ${i + 1}',
        artist: '艺术家 ${i + 1}',
        year: 2020 + i,
        songCount: 10 + i,
        source: _source,
      );
    });

    _mockSongs = List.generate(20, (i) {
      return Song(
        id: 'local_song_$i',
        title: '本地歌曲 ${i + 1}',
        artist: '艺术家 ${(i % 5) + 1}',
        albumId: 'local_album_${i % 5}',
        albumName: '本地专辑 ${(i % 5) + 1}',
        duration: Duration(seconds: 180 + i * 10).inSeconds,
        audioUrl: 'file:///local/songs/song_$i.mp3',
        source: _source,
      );
    });

    _mockPlaylists = [
      Playlist(
        id: 'local_playlist_0',
        name: '最近播放',
        creator: '我',
        description: '最近播放的歌曲',
        songs: _mockSongs.take(5).toList(),
        source: _source,
      ),
      Playlist(
        id: 'local_playlist_1',
        name: '我的最爱',
        creator: '我',
        description: '收藏的歌曲',
        songs: _mockSongs.where((s) => s.playCount > 0).toList(),
        source: _source,
      ),
    ];
  }

  @override
  Future<SongPageResult> searchSongs(
    String keyword, {
    int page = 1,
    int limit = 20,
  }) async {
    if (keyword.isEmpty)
      return PaginationResponse.empty(page: page, limit: limit);
    final lower = keyword.toLowerCase();
    final filtered = _mockSongs
        .where(
          (s) =>
              s.title.toLowerCase().contains(lower) ||
              s.artist.toLowerCase().contains(lower),
        )
        .toList();
    return PaginationResponse.fromList(filtered, page: page, limit: limit);
  }

  @override
  Future<AlbumPageResult> searchAlbums(
    String keyword, {
    int page = 1,
    int limit = 20,
  }) async {
    if (keyword.isEmpty)
      return PaginationResponse.empty(page: page, limit: limit);
    final lower = keyword.toLowerCase();
    final filtered = _mockAlbums
        .where(
          (a) =>
              a.title.toLowerCase().contains(lower) ||
              a.artist.toLowerCase().contains(lower),
        )
        .toList();
    return PaginationResponse.fromList(filtered, page: page, limit: limit);
  }

  @override
  Future<PlaylistPageResult> searchPlaylists(
    String keyword, {
    int page = 1,
    int limit = 20,
  }) async {
    if (keyword.isEmpty)
      return PaginationResponse.empty(page: page, limit: limit);
    final lower = keyword.toLowerCase();
    final filtered = _mockPlaylists
        .where((p) => p.name.toLowerCase().contains(lower))
        .toList();
    return PaginationResponse.fromList(filtered, page: page, limit: limit);
  }

  @override
  Future<Song?> getSong(String id) async {
    try {
      return _mockSongs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<SongPageResult> getSongs({int page = 1, int limit = 20}) async {
    return PaginationResponse.fromList(_mockSongs, page: page, limit: limit);
  }

  @override
  Future<Album?> getAlbum(String id) async {
    try {
      return _mockAlbums.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<SongPageResult> getAlbumSongs(
    String albumId, {
    int page = 1,
    int limit = 20,
  }) async {
    final filtered = _mockSongs.where((s) => s.albumId == albumId).toList();
    return PaginationResponse.fromList(filtered, page: page, limit: limit);
  }

  @override
  Future<Playlist?> getPlaylist(String id) async {
    try {
      return _mockPlaylists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PlaylistPageResult> getPlaylists({
    int page = 1,
    int limit = 20,
  }) async {
    return PaginationResponse.fromList(
      _mockPlaylists,
      page: page,
      limit: limit,
    );
  }
}
