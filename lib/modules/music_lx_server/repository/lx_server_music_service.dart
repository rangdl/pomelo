import 'package:pomelo/core/mars.dart';
import 'package:pomelo/core/log.dart';
import 'package:pomelo/modules/music/model/models.dart';

import 'lx_server_client.dart';

/// Lx Server 音乐服务
///
/// 通过 [LxServerClient] 对接 lx-server HTTP API。
/// 单个实例管理所有库（kg、kw、tx、mg、wy），对外统一提供服务。
///
/// [defaultLibraryId] 默认为第一个库（kg），
/// 切换库后所有查询自动使用当前库作为 source 参数。
class LxServerMusicService extends MusicService {
  /// 共享的 HTTP 客户端
  final LxServerClient client;

  /// 服务标识
  final String _sourceId;

  /// 服务显示名称
  final String _sourceName;

  /// 所有可用库
  ///
  /// lx-server 支持 5 个来源：kg(酷狗)、kw(酷我)、tx(QQ)、mg(咪咕)、wy(网易云)
  static const List<({String id, String name})> _allLibraries = [
    (id: 'kg', name: '酷狗'),
    (id: 'kw', name: '酷我'),
    (id: 'tx', name: 'QQ'),
    (id: 'mg', name: '咪咕'),
    (id: 'wy', name: '网易云'),
  ];

  /// 当前默认使用的库标识
  String? _defaultLibraryId = _allLibraries.first.id;

  LxServerMusicService({
    required this.client,
    required String sourceId,
    required String sourceName,
  }) : _sourceId = sourceId,
       _sourceName = sourceName;

  @override
  MusicSourceType get sourceType => MusicSourceType.lxServer;

  @override
  String get sourceId => _sourceId;

  @override
  String get sourceName => _sourceName;

  @override
  int get maxServiceCount => 1;

  @override
  List<({String id, String name})> get libraries =>
      List.unmodifiable(_allLibraries);

  @override
  String? get defaultLibraryId => _defaultLibraryId;

  @override
  void setDefaultLibrary(String libraryId) {
    if (_allLibraries.any((l) => l.id == libraryId)) {
      _defaultLibraryId = libraryId;
    }
  }

  /// 当前库标识（source 参数）
  String get _currentSource => _defaultLibraryId ?? _allLibraries.first.id;

  // ========== 搜索 ==========

  @override
  Future<PaginationResponse<Song>> searchSongs(
    String keyword, {
    int page = 1,
    int limit = 20,
    String? libraryId,
  }) {
    // lx-server API 无搜索接口
    throw UnimplementedError('$sourceName(searchSongs) 尚未实现');
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
  Future<List<PlaylistCategory>> getPlaylistCategories() async {
    final tags = await client.getPlaylistTags(_currentSource);
    final categories = <PlaylistCategory>[];

    // 父分类（标签组名作为父分类）
    for (final group in tags.tagGroups) {
      categories.add(PlaylistCategory(id: group.name, name: group.name));
      // 子分类
      for (final tag in group.list) {
        categories.add(
          PlaylistCategory(id: tag.id, name: tag.name, parentId: group.name),
        );
      }
    }

    // 热门标签作为单独的父分类
    if (tags.hotTags.isNotEmpty) {
      categories.insert(0, const PlaylistCategory(id: '热门', name: '热门'));
      for (final tag in tags.hotTags) {
        categories.insert(
          1,
          PlaylistCategory(id: tag.id, name: tag.name, parentId: '热门'),
        );
      }
    }

    return categories;
  }

  @override
  Future<List<({String id, String name})>> getPlaylistSortOrders() async {
    final tags = await client.getPlaylistTags(_currentSource);
    return tags.sortList;
  }

  @override
  Future<PaginationResponse<Playlist>> getPlaylistsByCategory(
    String categoryId, {
    String? sortId,
    int page = 1,
    int limit = 20,
  }) async {
    final result = await client.getPlaylists(
      source: _currentSource,
      tagId: categoryId,
      sortId: sortId,
      page: page,
    );
    final items = result.list
        .map(
          (p) => p.toPlaylist(
            sourceId: _sourceId,
            sourceName: _sourceName,
            libraryId: _currentSource,
          ),
        )
        .toList();
    return PaginationResponse<Playlist>(
      page: result.page,
      limit: result.limit,
      total: result.total,
      hasMore: result.page * result.limit < result.total,
      items: items,
    );
  }

  @override
  Future<Playlist?> getPlaylist(String id) async {
    // 获取歌单详情并构造 Playlist（含歌曲列表）
    final result = await client.getPlaylistDetail(
      source: _currentSource,
      id: id,
    );
    final songs = result.list
        .map(
          (s) => s.toSong(
            sourceId: _sourceId,
            sourceName: _sourceName,
            libraryId: _currentSource,
          ),
        )
        .toList();
    return Playlist(
      id: id,
      name: '',
      creator: '',
      source: (id: _sourceId, name: _sourceName, libraryId: _currentSource),
      songs: songs,
    );
  }

  @override
  Future<List<Song>> getPlaylistSongs(String id) async {
    final result = await client.getPlaylistDetail(
      source: _currentSource,
      id: id,
    );
    return result.list
        .map(
          (s) => s.toSong(
            sourceId: _sourceId,
            sourceName: _sourceName,
            libraryId: _currentSource,
          ),
        )
        .toList();
  }

  @override
  Future<PaginationResponse<Playlist>> getPlaylists({
    int page = 1,
    int limit = 20,
  }) async {
    // 无 tagId 时获取默认歌单列表
    final result = await client.getPlaylists(
      source: _currentSource,
      page: page,
    );
    final items = result.list
        .map(
          (p) => p.toPlaylist(
            sourceId: _sourceId,
            sourceName: _sourceName,
            libraryId: _currentSource,
          ),
        )
        .toList();
    return PaginationResponse<Playlist>(
      page: result.page,
      limit: result.limit,
      total: result.total,
      hasMore: result.page * result.limit < result.total,
      items: items,
    );
  }

  // ========== 播放链接 ==========

  @override
  Future<String> getMusicUrl(SongFull song, {String? quality}) async {
    // song.meta 即完整的 songInfo（由 LxServerSong.toSongInfo() 构造）
    final songInfo = Map<String, dynamic>.from(song.meta);
    // 确保必要字段存在
    songInfo['source'] ??= song.source.libraryId ?? _currentSource;
    songInfo['hash'] ??= song.id;

    // 按用户偏好选择音质，不可用则降级
    final typesMap = (songInfo['_types'] as Map<String, dynamic>?) ?? const {};
    final selectedQuality = _selectQuality(typesMap, preferredQuality: quality);
    final source = songInfo['source'] as String? ?? '';
    final hash = songInfo['hash'] as String? ?? '';
    log.debug(
      'LxServer',
      'getMusicUrl: 歌曲=${song.name} - ${song.artist}, '
          'source=$source, hash=$hash, 偏好=$quality, 选中质量=$selectedQuality',
    );

    return client.getMusicUrl(songInfo: songInfo, quality: selectedQuality);
  }

  // ========== 歌词 ==========

  @override
  Future<String?> getLyric(SongFull song) async {
    final songInfo = Map<String, dynamic>.from(song.meta);
    songInfo['source'] ??= song.source.libraryId ?? _currentSource;
    songInfo['hash'] ??= song.id;
    return client.getLyric(songInfo: songInfo);
  }

  /// 选择可用音质
  ///
  /// 策略：从 [preferredQuality] 在优先级数组中的位置开始向后找第一个可用音质；
  /// 若 [preferredQuality] 为 null 或不在优先级数组中，则从最高优先级开始找。
  /// 全部不可用时回退到 '128k'。
  ///
  /// 优先级（高 → 低）：flac24bit > flac > 320k > 128k
  String _selectQuality(
    Map<String, dynamic> typesMap, {
    String? preferredQuality,
  }) {
    const priority = ['flac24bit', 'flac', '320k', '128k'];
    final startIndex = preferredQuality == null
        ? 0
        : priority.indexOf(preferredQuality);
    // 偏好不在已知列表中，从最高优先级开始
    final effectiveStart = startIndex < 0 ? 0 : startIndex;

    for (int i = effectiveStart; i < priority.length; i++) {
      if (typesMap.containsKey(priority[i])) return priority[i];
    }
    // 用户偏好过高且全部不可用，向前回退（理论上不会走到，因为 128k 通常在列表末尾）
    for (int i = effectiveStart - 1; i >= 0; i--) {
      if (typesMap.containsKey(priority[i])) return priority[i];
    }
    if (typesMap.isNotEmpty) return typesMap.keys.first;
    return '128k';
  }

  // ========== 排行榜 ==========

  @override
  Future<List<Leaderboard>> getBoards() async {
    log.debug('LxServer', 'getBoards: source=$_currentSource');
    final boards = await client.getLeaderboardBoards(_currentSource);
    final result = boards.map((b) => b.toLeaderboard()).toList();
    log.debug(
      'LxServer',
      'getBoards 完成: source=$_currentSource, 共 ${result.length} 个榜单',
    );
    return result;
  }

  @override
  Future<List<Song>> getLeaderboardSongs(String leaderboardId) async {
    log.debug(
      'LxServer',
      'getLeaderboardSongs: source=$_currentSource, bangid=$leaderboardId',
    );
    final result = await client.getLeaderboardSongs(
      source: _currentSource,
      bangid: leaderboardId,
    );
    final songs = result.list
        .map(
          (s) => s.toSong(
            sourceId: _sourceId,
            sourceName: _sourceName,
            libraryId: _currentSource,
          ),
        )
        .toList();
    log.debug(
      'LxServer',
      'getLeaderboardSongs 完成: source=$_currentSource, bangid=$leaderboardId, '
          '转换 ${songs.length} 首歌曲',
    );
    return songs;
  }
}
