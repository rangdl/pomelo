import 'package:pomelo/core/mars.dart';
import '../model/song.dart';
import '../model/album.dart';
import '../model/playlist.dart';

/// Music SDK 数据仓储
///
/// 音乐播放最底层仓储，负责统一的数据访问。
/// 上层平台模块（如网易云、QQ音乐）通过此仓储注册数据。
///
/// 当前使用 [InMemoryRepository] 作为内存实现，
/// 后续可替换为 API/数据库实现。
class MusicSdkRepository {
  /// 歌曲仓储
  final InMemoryRepository<Song> songs;

  /// 专辑仓储
  final InMemoryRepository<Album> albums;

  /// 歌单仓储
  final InMemoryRepository<Playlist> playlists;

  MusicSdkRepository()
    : songs = InMemoryRepository<Song>(
        id: 'music_sdk_songs',
        idSelector: (song) => song.id,
      ),
      albums = InMemoryRepository<Album>(
        id: 'music_sdk_albums',
        idSelector: (album) => album.id,
      ),
      playlists = InMemoryRepository<Playlist>(
        id: 'music_sdk_playlists',
        idSelector: (playlist) => playlist.id,
      );

  /// 初始化仓储
  Future<void> onInit() async {
    await songs.onInit();
    await albums.onInit();
    await playlists.onInit();
  }

  /// 销毁仓储
  Future<void> onDispose() async {
    await songs.onDispose();
    await albums.onDispose();
    await playlists.onDispose();
  }

  // ========== 歌曲查询 ==========

  /// 按关键词搜索歌曲
  Future<List<Song>> searchSongs(String keyword) async {
    final all = await songs.fetchAll();
    final lower = keyword.toLowerCase();
    return all
        .where(
          (s) =>
              s.name.toLowerCase().contains(lower) ||
              s.artist.toLowerCase().contains(lower),
        )
        .toList();
  }

  // ========== 专辑查询 ==========

  /// 获取某个专辑的所有歌曲
  Future<List<Song>> getSongsByAlbum(String albumId) async {
    final all = await songs.fetchAll();
    return all.where((s) => s.albumId == albumId).toList();
  }

  // ========== 歌单查询 ==========

  /// 获取预设的默认歌单列表
  Future<List<Playlist>> getDefaultPlaylists() async {
    return playlists.fetchAll();
  }
}
