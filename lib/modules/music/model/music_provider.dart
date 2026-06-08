import 'package:pomelo/modules/music_sdk/model/song.dart';
import 'package:pomelo/modules/music_sdk/model/album.dart';
import 'package:pomelo/modules/music_sdk/model/playlist.dart';
import 'pagination_response.dart';

/// 音乐数据提供者接口
///
/// 由各音乐平台模块实现，注册到 [MusicModule] 后统一对外提供服务。
/// 每个提供者有自己的 [sourceId] 和 [sourceName]，用于标识数据来源。
/// 可选的 [categoryId] 和 [categoryName] 用于对提供者进行二级分类分组。
abstract class MusicProvider {
  /// 提供者唯一标识，如 'local', 'netease'
  String get sourceId;

  /// 提供者显示名称，如 '本地音乐', '网易云音乐'
  String get sourceName;

  /// 分类标识，用于对提供者进行分组，如 'lx'（在线音乐平台）
  ///
  /// 相同 [categoryId] 的提供者会在 UI 上分到同一组。
  /// 未提供时归入默认分类 'default'。
  String get categoryId => 'default';

  /// 分类显示名称，如 '在线音乐'
  ///
  /// 未提供时显示 '默认'。
  String get categoryName => '默认';

  // ========== 搜索 ==========

  /// 搜索歌曲
  Future<SongPageResult> searchSongs(
    String keyword, {
    int page = 1,
    int limit = 20,
  });

  /// 搜索专辑
  Future<AlbumPageResult> searchAlbums(
    String keyword, {
    int page = 1,
    int limit = 20,
  });

  /// 搜索歌单
  Future<PlaylistPageResult> searchPlaylists(
    String keyword, {
    int page = 1,
    int limit = 20,
  });

  // ========== 歌曲 ==========

  /// 获取歌曲详情
  Future<Song?> getSong(String id);

  /// 获取歌曲列表（如最近播放、本地所有歌曲）
  Future<SongPageResult> getSongs({int page = 1, int limit = 20});

  // ========== 专辑 ==========

  /// 获取专辑详情
  Future<Album?> getAlbum(String id);

  /// 获取专辑中的歌曲
  Future<SongPageResult> getAlbumSongs(
    String albumId, {
    int page = 1,
    int limit = 20,
  });

  // ========== 歌单 ==========

  /// 获取歌单详情
  Future<Playlist?> getPlaylist(String id);

  /// 获取歌单列表（推荐/默认）
  Future<PlaylistPageResult> getPlaylists({int page = 1, int limit = 20});
}
