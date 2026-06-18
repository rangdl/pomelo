import 'package:pomelo/core/mars.dart';
import 'music_source_type.dart';
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

  /// 该服务提供的库列表
  ///
  /// 默认返回空列表，表示该服务不区分库。
  /// 多库服务（如 Lx 在线音乐）覆写此属性返回所有可用库。
  List<({String id, String name})> get libraries => [];

  /// 默认使用的库标识
  ///
  /// 默认返回 null，表示无需选择库。
  /// 多库服务覆写此属性，在搜索/播放时使用该库。
  String? get defaultLibraryId => null;

  /// 同类型服务的最大注册数量
  ///
  /// 用于限制同一 [sourceType] 的服务注册上限。
  /// 默认 1（如本地音乐、Lx 音乐各只能注册一个），
  /// Subsonic 等支持多账号的模块可覆写为更大的值。
  int get maxServiceCount => 1;

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
  ///
  /// [libraryId] 可选，用于指定在哪个库中搜索。
  /// 对于多库服务（如 Lx 在线音乐），若未指定则使用 [defaultLibraryId]。
  Future<PaginationResponse<Song>> searchSongs(
    String keyword, {
    int page = 1,
    int limit = 20,
    String? libraryId,
  });

  /// 搜索专辑
  Future<PaginationResponse<Album>> searchAlbums(
    String keyword, {
    int page = 1,
    int limit = 20,
    String? libraryId,
  });

  /// 搜索歌单
  Future<PaginationResponse<Playlist>> searchPlaylists(
    String keyword, {
    int page = 1,
    int limit = 20,
    String? libraryId,
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

  /// 获取歌单分类列表
  ///
  /// 返回该服务支持的所有歌单分类（如“推荐”“流行”“摇滚”等）。
  /// 默认返回空列表，表示该服务不支持歌单分类。
  /// 可通过 [getPlaylistsByCategory] 获取指定分类下的歌单。
  Future<List<PlaylistCategory>> getPlaylistCategories() async => [];

  /// 获取指定分类下的歌单列表
  ///
  /// [categoryId] 来自 [PlaylistCategory.id]。
  /// 默认实现调用 [getPlaylists]，忽略分类参数。
  /// 支持分类的服务应覆写此方法。
  Future<PaginationResponse<Playlist>> getPlaylistsByCategory(
    String categoryId, {
    int page = 1,
    int limit = 20,
  }) {
    return getPlaylists(page: page, limit: limit);
  }

  /// 获取歌单详情
  Future<Playlist?> getPlaylist(String id);

  /// 获取歌单中的歌曲列表
  ///
  /// [id] 为歌单标识。
  /// 默认返回空列表，支持歌单详情的服务应覆写此方法。
  Future<List<Song>> getPlaylistSongs(String id) async => [];

  /// 获取歌单列表（推荐/默认）
  Future<PaginationResponse<Playlist>> getPlaylists({int page = 1, int limit = 20});

  /// 获取歌曲播放链接 用于音乐信息和播放链接分步获取
  Future<String> getMusicUrl(SongFull song) {
    throw UnimplementedError('$sourceName(getMusicUrl) 尚未实现');
  }
}
