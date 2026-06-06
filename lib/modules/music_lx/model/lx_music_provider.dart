import 'package:pomelo/modules/music/model/models.dart';

/// Lx 音乐提供者基类
///
/// 为 [MusicProvider] 提供默认的空实现（抛出 [UnimplementedError]）。
/// 各子类只需重写 [sourceId]、[sourceName]，按需实现具体方法。
abstract class LxMusicProvider extends MusicProvider {
  @override
  Future<SongPageResult> searchSongs(
    String keyword, {
    int page = 1,
    int limit = 20,
  }) {
    throw UnimplementedError('$sourceName(searchSongs) 尚未实现');
  }

  @override
  Future<AlbumPageResult> searchAlbums(
    String keyword, {
    int page = 1,
    int limit = 20,
  }) {
    throw UnimplementedError('$sourceName(searchAlbums) 尚未实现');
  }

  @override
  Future<PlaylistPageResult> searchPlaylists(
    String keyword, {
    int page = 1,
    int limit = 20,
  }) {
    throw UnimplementedError('$sourceName(searchPlaylists) 尚未实现');
  }

  @override
  Future<Song?> getSong(String id) {
    throw UnimplementedError('$sourceName(getSong) 尚未实现');
  }

  @override
  Future<SongPageResult> getSongs({int page = 1, int limit = 20}) {
    throw UnimplementedError('$sourceName(getSongs) 尚未实现');
  }

  @override
  Future<Album?> getAlbum(String id) {
    throw UnimplementedError('$sourceName(getAlbum) 尚未实现');
  }

  @override
  Future<SongPageResult> getAlbumSongs(
    String albumId, {
    int page = 1,
    int limit = 20,
  }) {
    throw UnimplementedError('$sourceName(getAlbumSongs) 尚未实现');
  }

  @override
  Future<Playlist?> getPlaylist(String id) {
    throw UnimplementedError('$sourceName(getPlaylist) 尚未实现');
  }

  @override
  Future<PlaylistPageResult> getPlaylists({int page = 1, int limit = 20}) {
    throw UnimplementedError('$sourceName(getPlaylists) 尚未实现');
  }
}
