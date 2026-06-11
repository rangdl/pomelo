import 'package:pomelo/core/mars.dart';
import 'package:pomelo/modules/music/model/models.dart';
import 'package:pomelo/modules/music_lx/providers/musicsdk_provider.dart';

/// Lx 音乐服务基类
///
/// 为 [MusicService] 提供默认的空实现（抛出 [UnimplementedError]）。
/// 各子类只需重写 [sourceId]、[sourceName]，按需实现具体方法。
abstract class LxMusicService extends MusicService {
  @override
  String get categoryId => 'lx';

  @override
  String get categoryName => '在线音乐';

  final LxJsEngine jsEngine;

  LxMusicService({required this.jsEngine});
  @override
  Future<PaginationResponse<Song>> searchSongs(
    String keyword, {
    int page = 1,
    int limit = 20,
  }) {
    return jsEngine.search(keyword, page: page, limit: limit, type: sourceId);
    // throw UnimplementedError('$sourceName(searchSongs) 尚未实现');
  }

  @override
  Future<PaginationResponse<Album>> searchAlbums(
    String keyword, {
    int page = 1,
    int limit = 20,
  }) {
    throw UnimplementedError('$sourceName(searchAlbums) 尚未实现');
  }

  @override
  Future<PaginationResponse<Playlist>> searchPlaylists(
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
  Future<PaginationResponse<Song>> getSongs({int page = 1, int limit = 20}) {
    throw UnimplementedError('$sourceName(getSongs) 尚未实现');
  }

  @override
  Future<Album?> getAlbum(String id) {
    throw UnimplementedError('$sourceName(getAlbum) 尚未实现');
  }

  @override
  Future<PaginationResponse<Song>> getAlbumSongs(
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
  Future<PaginationResponse<Playlist>> getPlaylists({int page = 1, int limit = 20}) {
    throw UnimplementedError('$sourceName(getPlaylists) 尚未实现');
  }
}
