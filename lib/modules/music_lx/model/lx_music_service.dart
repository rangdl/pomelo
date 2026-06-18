import 'package:pomelo/core/mars.dart';
import 'package:pomelo/modules/music/model/models.dart';
import 'package:pomelo/modules/music_lx/model/lx_source_engine.dart';
import 'package:pomelo/modules/music_lx/providers/musicsdk_provider.dart';

/// Lx 音乐服务
///
/// 通过元数据插件动态加载的音乐平台服务。
/// 单个实例管理所有库（如 tx、kg、wy 等），对外统一提供服务。
///
/// [metadataEngine] 用于音乐搜索和元信息查询，
/// [sourceEngine] 用于获取播放链接（可选）。
///
/// 库列表由元数据插件加载后通过构造函数传入，
/// [defaultLibraryId] 默认为第一个库的 id，
/// 搜索和播放时若未指定库则使用默认库。
class LxMusicService extends MusicService {
  @override
  MusicSourceType get sourceType => MusicSourceType.lx;

  /// 共享的元数据引擎
  final LxMetadataEngine metadataEngine;

  /// 音源插件引擎（用于获取播放链接），可选
  LxSourceEngine? sourceEngine;

  /// 插件标识，用于区分不同插件来源
  final String pluginId;

  /// 所有可用库信息列表
  final List<({String id, String name})> _libraries;

  /// 当前默认使用的库标识
  String? _defaultLibraryId;

  LxMusicService({
    required this.metadataEngine,
    this.sourceEngine,
    required this.pluginId,
    required List<({String id, String name})> libraries,
  }) : _libraries = List.from(libraries) {
    _defaultLibraryId = _libraries.isNotEmpty ? _libraries.first.id : null;
  }

  @override
  String get sourceId => 'lx-$pluginId';

  @override
  String get sourceName => '在线音乐';

  @override
  int get maxServiceCount => 1;

  @override
  List<({String id, String name})> get libraries =>
      List.unmodifiable(_libraries);

  @override
  String? get defaultLibraryId => _defaultLibraryId;

  /// 设置默认库
  void setDefaultLibrary(String libraryId) {
    if (_libraries.any((l) => l.id == libraryId)) {
      _defaultLibraryId = libraryId;
    }
  }

  /// 更新库列表（元数据插件替换后调用）
  void updateLibraries(List<({String id, String name})> libraries) {
    _libraries
      ..clear()
      ..addAll(libraries);
    // 如果当前默认库不在新列表中，重置为第一个
    if (_defaultLibraryId == null ||
        !_libraries.any((l) => l.id == _defaultLibraryId)) {
      _defaultLibraryId = _libraries.isNotEmpty ? _libraries.first.id : null;
    }
  }

  // ========== 搜索 ==========

  @override
  Future<PaginationResponse<Song>> searchSongs(
    String keyword, {
    int page = 1,
    int limit = 20,
    String? libraryId,
  }) {
    final libId = libraryId ?? _defaultLibraryId;
    if (libId == null) {
      return Future.value(PaginationResponse.empty(page: page, limit: limit));
    }
    return metadataEngine.search(keyword, page: page, limit: limit, type: libId);
  }

  @override
  Future<PaginationResponse<Album>> searchAlbums(
    String keyword, {
    int page = 1,
    int limit = 20,
    String? libraryId,
  }) {
    throw UnimplementedError('$sourceName(searchAlbums) 尚未实现');
  }

  @override
  Future<PaginationResponse<Playlist>> searchPlaylists(
    String keyword, {
    int page = 1,
    int limit = 20,
    String? libraryId,
  }) {
    throw UnimplementedError('$sourceName(searchPlaylists) 尚未实现');
  }

  // ========== 歌曲 ==========

  @override
  Future<Song?> getSong(String id) {
    throw UnimplementedError('$sourceName(getSong) 尚未实现');
  }

  @override
  Future<PaginationResponse<Song>> getSongs({int page = 1, int limit = 20}) {
    throw UnimplementedError('$sourceName(getSongs) 尚未实现');
  }

  // ========== 专辑 ==========

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

  // ========== 歌单 ==========

  @override
  Future<List<PlaylistCategory>> getPlaylistCategories() {
    final libId = _defaultLibraryId;
    if (libId == null) return Future.value([]);
    return metadataEngine.getPlaylistCategories(type: libId);
  }

  @override
  Future<PaginationResponse<Playlist>> getPlaylistsByCategory(
    String categoryId, {
    int page = 1,
    int limit = 20,
  }) async {
    final libId = _defaultLibraryId;
    if (libId == null) {
      return PaginationResponse.empty(page: page, limit: limit);
    }
    final items = await metadataEngine.getPlaylistsByCategory(
      categoryId,
      type: libId,
    );
    return PaginationResponse<Playlist>(
      page: page,
      limit: limit,
      total: items.length,
      hasMore: false,
      items: items,
    );
  }

  @override
  Future<Playlist?> getPlaylist(String id) {
    throw UnimplementedError('$sourceName(getPlaylist) 尚未实现');
  }

  @override
  Future<List<Song>> getPlaylistSongs(String id) {
    final libId = _defaultLibraryId;
    if (libId == null) return Future.value([]);
    return metadataEngine.getPlaylistsDetail(id, type: libId);
  }

  @override
  Future<PaginationResponse<Playlist>> getPlaylists(
      {int page = 1, int limit = 20}) {
    throw UnimplementedError('$sourceName(getPlaylists) 尚未实现');
  }

  // ========== 播放链接 ==========

  @override
  Future<String> getMusicUrl(SongFull song) async {
    if (sourceEngine == null) {
      throw UnimplementedError(
          '$sourceName(getMusicUrl) 未加载音源插件，无法获取播放链接');
    }
    // 根据 song.source.id 路由到对应库获取播放链接
    final libraryId = song.source.id;
    if (!sourceEngine!.hasLibrary(libraryId)) {
      // 回退到默认库
      final fallback = _defaultLibraryId;
      if (fallback == null || !sourceEngine!.hasLibrary(fallback)) {
        throw UnimplementedError(
            '$sourceName(getMusicUrl) 音源插件不支持库 $libraryId，且无可用回退库');
      }
      return sourceEngine!.getMusicUrl(fallback, song);
    }
    return sourceEngine!.getMusicUrl(libraryId, song);
  }
}
