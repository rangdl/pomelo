import 'package:pomelo/core/mars.dart';
import 'music_source.dart';
import 'song.dart';
import 'album.dart';
import 'playlist.dart';

/// 音乐服务接口
///
/// 由各音乐平台模块实现，注册到 [MusicModule] 后统一对外提供服务。
/// 每个服务有自己的 [sourceId] 和 [sourceName]，用于标识数据来源。
/// 可选的 [categoryId] 和 [categoryName] 用于对服务进行二级分类分组。
abstract class MusicService {
  /// 服务唯一标识，如 'local', 'netease'
  String get sourceId;

  /// 服务显示名称，如 '本地音乐', '网易云音乐'
  String get sourceName;

  /// 来源类型，如 [MusicSourceType.local]、[MusicSourceType.lx]
  ///
  /// 用于按类型对服务进行分组管理。
  MusicSourceType get sourceType;

  /// 分类标识，用于对服务进行二级分组，如 'lx'（在线音乐平台）
  ///
  /// 相同 [categoryId] 的服务会在 UI 上分到同一组。
  /// 默认使用 [sourceType] 的名称作为分类标识。
  String get categoryId => sourceType.name;

  /// 分类显示名称，如 '在线音乐'
  ///
  /// 默认使用 [sourceType] 的显示名称。
  String get categoryName => sourceType.displayName;

  // ========== 搜索 ==========

  /// 搜索歌曲
  Future<PaginationResponse<Song>> searchSongs(
    String keyword, {
    int page = 1,
    int limit = 20,
  });

  /// 搜索专辑
  Future<PaginationResponse<Album>> searchAlbums(
    String keyword, {
    int page = 1,
    int limit = 20,
  });

  /// 搜索歌单
  Future<PaginationResponse<Playlist>> searchPlaylists(
    String keyword, {
    int page = 1,
    int limit = 20,
  });

  // ========== 歌曲 ==========

  /// 获取歌曲详情
  Future<Song?> getSong(String id);

  /// 获取歌曲列表（如最近播放、本地所有歌曲）
  Future<PaginationResponse<Song>> getSongs({int page = 1, int limit = 20});

  // ========== 专辑 ==========

  /// 获取专辑详情
  Future<Album?> getAlbum(String id);

  /// 获取专辑中的歌曲
  Future<PaginationResponse<Song>> getAlbumSongs(
    String albumId, {
    int page = 1,
    int limit = 20,
  });

  // ========== 歌单 ==========

  /// 获取歌单详情
  Future<Playlist?> getPlaylist(String id);

  /// 获取歌单列表（推荐/默认）
  Future<PaginationResponse<Playlist>> getPlaylists({int page = 1, int limit = 20});

  /// 获取歌曲播放链接 用于音乐信息和播放链接分步获取
  Future<String> getMusicUrl(SongFull song) {
    throw UnimplementedError('$sourceName(getMusicUrl) 尚未实现');
  }
}
