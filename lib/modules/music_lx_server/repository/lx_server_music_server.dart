import 'dart:io';

import 'package:pomelo/core/core.dart';
import 'package:pomelo/services/logger/logger.dart';
import 'package:pomelo/core/models/database/app_database.dart';
import 'package:pomelo/core/models/metadata/metadata.dart';

import 'lx_server_client.dart';
import 'lx_server_models.dart';

/// Lx Server 支持的搜索类型（全套）
const _lxServerSearchTypes = [
  SearchType.song,
  SearchType.artist,
  SearchType.album,
  SearchType.playlist,
];

/// Lx Server 音乐服务
///
/// 通过 [LxServerClient] 对接 lx-server HTTP API。
/// 单个实例管理所有库（kg、kw、tx、mg、wy），对外统一提供服务。
///
/// [defaultLibraryId] 默认为第一个库（kg），
/// 切换库后所有查询自动使用当前库作为 source 参数。
class LxServerMusicServer extends MusicServer {
  /// 共享的 HTTP 客户端
  final LxServerClient client;

  /// 服务标识
  final String _sourceId;

  /// 服务显示名称
  final String _sourceName;

  /// 是否允许换源
  ///
  /// 开启后，当当前库所有音质的播放链接获取均失败时，
  /// 自动搜索其他库并切换到匹配的新源重新获取播放链接。
  final bool allowSourceSwitching;

  /// 是否使用本地音源
  ///
  /// 开启后，获取播放链接时优先从本地音乐库匹配（按 title + artist），
  /// 匹配失败再回退到在线解析。
  ///
  /// 此标志为全局开关（[UserPreference.localAudioSourceEnabled]）与
  /// 当前服务配置开关（[LxServerConfig.useLocalAudioSource]）的「与」结果，
  /// 由 [lxServerMusicServerProvider] 计算后传入。
  final bool useLocalAudioSource;

  /// 数据库实例（用于本地音源查询）
  ///
  /// 当 [useLocalAudioSource] 为 true 时用于查询本地音乐库。
  final AppDatabase? database;

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

  LxServerMusicServer({
    required this.client,
    required String sourceId,
    required String sourceName,
    this.allowSourceSwitching = false,
    this.useLocalAudioSource = false,
    this.database,
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
  List<SearchType> get supportedSearchTypes => _lxServerSearchTypes;

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

  /// 根据 libraryId 查找库显示名
  String _libraryName(String? libraryId) {
    if (libraryId == null) return '';
    return _allLibraries
        .firstWhere(
          (l) => l.id == libraryId,
          orElse: () => (id: libraryId, name: libraryId),
        )
        .name;
  }

  /// 当前库标识（source 参数）
  String get _currentSource => _defaultLibraryId ?? _allLibraries.first.id;

  // ========== 搜索 ==========

  @override
  Future<PaginationResponse<Track>> searchTracks(
    String keyword, {
    int page = 1,
    int limit = 20,
    String? libraryId,
  }) async {
    final source = libraryId ?? _currentSource;
    final result = await client.searchMusic(
      source: source,
      keyword: keyword,
      page: page,
      limit: limit,
    );
    final items = result.list
        .map(
          (s) => s.toTrack(
            sourceId: _sourceId,
            sourceName: _sourceName,
            libraryId: source,
            libraryName: _libraryName(source),
          ),
        )
        .toList();
    return PaginationResponse<Track>(
      page: result.page,
      limit: result.limit,
      total: result.total,
      hasMore: result.page * result.limit < result.total,
      items: items,
    );
  }

  @override
  Future<PaginationResponse<Artist>> searchArtists(
    String keyword, {
    int page = 1,
    int limit = 20,
    String? libraryId,
  }) async {
    final source = libraryId ?? _currentSource;
    final result = await client.searchArtists(
      source: source,
      name: keyword,
      page: page,
      limit: limit,
    );
    final items = result.list
        .map(
          (a) => a.toArtist(
            sourceId: _sourceId,
            sourceName: _sourceName,
            libraryId: source,
            libraryName: _libraryName(source),
          ),
        )
        .toList();
    return PaginationResponse<Artist>(
      page: result.page,
      limit: result.limit,
      total: result.total,
      hasMore: result.page * result.limit < result.total,
      items: items,
    );
  }

  @override
  Future<PaginationResponse<Album>> searchAlbums(
    String keyword, {
    int page = 1,
    int limit = 20,
    String? libraryId,
  }) async {
    final source = libraryId ?? _currentSource;
    final result = await client.searchAlbums(
      source: source,
      name: keyword,
      page: page,
      limit: limit,
    );
    final items = result.list
        .map(
          (a) => a.toAlbum(
            sourceId: _sourceId,
            sourceName: _sourceName,
            libraryId: source,
            libraryName: _libraryName(source),
          ),
        )
        .toList();
    return PaginationResponse<Album>(
      page: result.page,
      limit: result.limit,
      total: result.total,
      hasMore: result.page * result.limit < result.total,
      items: items,
    );
  }

  @override
  Future<PaginationResponse<Playlist>> searchPlaylists(
    String keyword, {
    int page = 1,
    int limit = 20,
    String? libraryId,
  }) async {
    final source = libraryId ?? _currentSource;
    final result = await client.searchPlaylistsByType(
      source: source,
      name: keyword,
      page: page,
      limit: limit,
    );
    final items = result.list
        .map(
          (p) => p.toPlaylist(
            sourceId: _sourceId,
            sourceName: _sourceName,
            libraryId: source,
            libraryName: _libraryName(source),
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
  Future<List<String>> tipSearch(String keyword) {
    return client.tipSearch(source: _currentSource, keyword: keyword);
  }

  @override
  Future<List<String>> getHotSearch() {
    return client.hotSearch(source: _currentSource);
  }

  // ========== 歌曲 ==========

  @override
  Future<Track?> getTrack(String id) {
    throw UnimplementedError('$sourceName(getTrack) 尚未实现');
  }

  @override
  Future<PaginationResponse<Track>> getTracks({int page = 1, int limit = 20}) {
    throw UnimplementedError('$sourceName(getTracks) 尚未实现');
  }

  // ========== 歌手 ==========

  @override
  Future<Artist?> getArtist(String id) async {
    try {
      final artist = await client.getArtistDetail(
        source: _currentSource,
        id: id,
      );
      return artist.toArtist(
        sourceId: _sourceId,
        sourceName: _sourceName,
        libraryId: _currentSource,
        libraryName: _libraryName(_currentSource),
      );
    } catch (e) {
      AppLogger.log.w('[LxServer] 获取歌手详情失败: $e');
      return null;
    }
  }

  @override
  Future<List<Album>> getArtistAlbums(String artistId) async {
    try {
      final result = await client.getArtistAlbums(
        source: _currentSource,
        id: artistId,
      );
      return result.list
          .map(
            (a) => a.toAlbum(
              sourceId: _sourceId,
              sourceName: _sourceName,
              libraryId: _currentSource,
              libraryName: _libraryName(_currentSource),
            ),
          )
          .toList();
    } catch (e) {
      AppLogger.log.w('[LxServer] 获取歌手专辑失败: $e');
      return [];
    }
  }

  @override
  Future<PaginationResponse<Track>> getArtistSongs(
    String artistId, {
    String? order,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final songs = await client.getArtistSongs(
        source: _currentSource,
        id: artistId,
        order: order ?? 'hot',
      );
      final tracks = songs
          .map(
            (s) => s.toTrack(
              sourceId: _sourceId,
              sourceName: _sourceName,
              libraryId: _currentSource,
              libraryName: _libraryName(_currentSource),
            ),
          )
          .toList();
      // Lx Server 的 artistSongs 不分页，一次返回全部
      return PaginationResponse<Track>(
        page: 1,
        limit: tracks.length,
        total: tracks.length,
        hasMore: false,
        items: tracks,
      );
    } catch (e) {
      AppLogger.log.w('[LxServer] 获取歌手歌曲失败: $e');
      return PaginationResponse.empty(page: page, limit: limit);
    }
  }

  // ========== 专辑 ==========

  @override
  Future<Album?> getAlbum(String id) async {
    try {
      final result = await client.getAlbumSongs(source: _currentSource, id: id);
      return Album(
        id: id,
        name: result.name ?? '',
        artist: '',
        coverArt: null,
        songCount: result.total,
        source: (
          id: _sourceId,
          name: _sourceName,
          libraryId: _currentSource,
          libraryName: _libraryName(_currentSource),
        ),
        meta: {
          'id': id,
          'source': result.source,
          if (result.publishTime != null) 'publishTime': result.publishTime,
        },
      );
    } catch (e) {
      AppLogger.log.w('[LxServer] 获取专辑详情失败: $e');
      return null;
    }
  }

  @override
  Future<PaginationResponse<Track>> getAlbumTracks(
    String albumId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await client.getAlbumSongs(
        source: _currentSource,
        id: albumId,
      );
      final tracks = result.list
          .map(
            (s) => s.toTrack(
              sourceId: _sourceId,
              sourceName: _sourceName,
              libraryId: _currentSource,
              libraryName: _libraryName(_currentSource),
            ),
          )
          .toList();
      // Lx Server 的 albumSongs 不分页，一次返回全部
      return PaginationResponse<Track>(
        page: 1,
        limit: tracks.length,
        total: tracks.length,
        hasMore: false,
        items: tracks,
      );
    } catch (e) {
      AppLogger.log.w('[LxServer] 获取专辑歌曲失败: $e');
      return PaginationResponse.empty(page: page, limit: limit);
    }
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
            libraryName: _libraryName(_currentSource),
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
    final tracks = result.list
        .map(
          (s) => s.toTrack(
            sourceId: _sourceId,
            sourceName: _sourceName,
            libraryId: _currentSource,
            libraryName: _libraryName(_currentSource),
          ),
        )
        .toList();
    return Playlist(
      id: id,
      name: '',
      owner: '',
      source: (
        id: _sourceId,
        name: _sourceName,
        libraryId: _currentSource,
        libraryName: _libraryName(_currentSource),
      ),
      tracks: tracks,
    );
  }

  @override
  Future<List<Track>> getPlaylistTracks(String id) async {
    final result = await client.getPlaylistDetail(
      source: _currentSource,
      id: id,
    );
    return result.list
        .map(
          (s) => s.toTrack(
            sourceId: _sourceId,
            sourceName: _sourceName,
            libraryId: _currentSource,
            libraryName: _libraryName(_currentSource),
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
            libraryName: _libraryName(_currentSource),
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
  Future<String> getMusicUrl(Track track, {String? quality}) async {
    // 本地音源优先：当全局开关与本服务开关均开启时，先尝试从本地音乐库匹配
    if (useLocalAudioSource && database != null) {
      final localPath = await _tryLocalAudioSource(track);
      if (localPath != null) {
        AppLogger.log.i(
          '[LxServer] 命中本地音源: track=${track.title} - ${track.artist}, '
          'path=$localPath',
        );
        return localPath;
      }
      AppLogger.log.d('[LxServer] 本地音源未命中，回退在线解析: track=${track.title}');
    }

    // track.meta 即完整的 songInfo（由 LxServerSong.toSongInfo() 构造）
    final songInfo = Map<String, dynamic>.from(track.meta ?? {});
    // 确保必要字段存在
    songInfo['source'] ??= track.source?.libraryId ?? _currentSource;

    // 按用户偏好选择音质，不可用则降级
    final typesMap = (songInfo['_types'] as Map<String, dynamic>?) ?? const {};
    final selectedQuality = _selectQuality(typesMap, preferredQuality: quality);
    final source = songInfo['source'] as String? ?? '';
    AppLogger.log.d(
      '[LxServer] getMusicUrl: 歌曲=${track.title} - ${track.artist}, '
      'source=$source, 偏好=$quality, 选中质量=$selectedQuality, songInfo=$songInfo',
    );

    // 构造代理播放时使用的文件名：歌名 - 歌手.mp3
    final filename = _buildFilename(track);

    try {
      return await client.getMusicUrl(
        songInfo: songInfo,
        quality: selectedQuality,
        filename: filename,
      );
    } catch (e) {
      // 获取失败，若开启换源则尝试切换到其他库
      if (allowSourceSwitching) {
        AppLogger.log.i(
          '[LxServer] 获取播放链接失败，尝试换源: ${track.title} - ${track.artist}, '
          '原库=$source, quality=$selectedQuality, 错误=$e',
        );
        final switchedUrl = await _trySourceSwitching(track, selectedQuality);
        if (switchedUrl != null) return switchedUrl;
      }
      rethrow;
    }
  }

  /// 尝试从本地音乐库匹配曲目
  ///
  /// 匹配规则：
  /// - title 大小写不敏感精确匹配
  /// - artist 包含匹配（任一方的 artist 字段包含对方）
  ///
  /// 匹配成功且本地文件存在时返回文件路径，否则返回 null。
  Future<String?> _tryLocalAudioSource(Track track) async {
    try {
      final db = database;
      if (db == null) return null;

      final title = track.title.trim().toLowerCase();
      final artist = (track.artist ?? '').trim().toLowerCase();
      if (title.isEmpty) return null;

      final allLocalTracks = await db.getAllLocalTracks();
      for (final entity in allLocalTracks) {
        // 仅匹配本地文件型曲目（path 非空）
        final path = entity.path;
        if (path == null || path.isEmpty) continue;

        // title 大小写不敏感精确匹配
        final localTitle = (entity.title).trim().toLowerCase();
        if (localTitle != title) continue;

        // artist 包含匹配（任一方包含对方即可）
        final localArtist = (entity.artist ?? '').trim().toLowerCase();
        if (artist.isNotEmpty && localArtist.isNotEmpty) {
          if (!localArtist.contains(artist) && !artist.contains(localArtist)) {
            continue;
          }
        }

        // 校验本地文件是否存在
        final file = File(path);
        if (await file.exists()) {
          return path;
        }
      }
      return null;
    } catch (e) {
      AppLogger.log.w('[LxServer] 本地音源查询失败: $e');
      return null;
    }
  }

  /// 换源逻辑
  ///
  /// 遍历除当前库外的其他库，使用 "歌名 歌手" 搜索，
  /// 比对歌曲信息（标题 + 歌手），匹配成功则用新源的 songInfo 重新获取播放链接。
  /// 返回 null 表示所有库均未匹配或获取失败。
  Future<String?> _trySourceSwitching(Track track, String quality) async {
    final originalSource = track.source?.libraryId ?? _currentSource;
    final keyword = _buildSearchKeyword(track);
    if (keyword.isEmpty) {
      AppLogger.log.w('[LxServer] 换源跳过: 搜索关键词为空');
      return null;
    }

    AppLogger.log.i('[LxServer] 换源搜索: keyword="$keyword", 原库=$originalSource');

    for (final lib in _allLibraries) {
      if (lib.id == originalSource) continue;

      try {
        final result = await client.searchMusic(
          source: lib.id,
          keyword: keyword,
          page: 1,
          limit: 20,
        );

        final matched = _findMatchedSong(track, result.list);
        if (matched == null) {
          AppLogger.log.d('[LxServer] 换源: 库=${lib.id} 未找到匹配歌曲');
          continue;
        }

        AppLogger.log.i(
          '[LxServer] 换源匹配成功: 库=${lib.id}(${lib.name}), '
          '匹配歌曲=${matched.name} - ${matched.singer}',
        );

        // 用匹配歌曲的 songInfo 重新获取播放链接
        final newSongInfo = matched.toSongInfo();
        final typesMap =
            (newSongInfo['_types'] as Map<String, dynamic>?) ?? const {};
        final newQuality = _selectQuality(typesMap, preferredQuality: quality);
        final filename = _buildFilename(track);

        final url = await client.getMusicUrl(
          songInfo: newSongInfo,
          quality: newQuality,
          filename: filename,
        );
        AppLogger.log.i(
          '[LxServer] 换源成功: 库=${lib.id}, quality=$newQuality, track=${track.title}',
        );
        return url;
      } catch (e) {
        AppLogger.log.w('[LxServer] 换源失败: 库=${lib.id}(${lib.name}): $e');
      }
    }

    AppLogger.log.w('[LxServer] 换源结束: 所有库均未成功, track=${track.title}');
    return null;
  }

  /// 构造搜索关键词："歌名 歌手"
  String _buildSearchKeyword(Track track) {
    final title = track.title.trim();
    final artist = track.artist?.trim() ?? '';
    if (title.isEmpty && artist.isEmpty) return '';
    if (artist.isEmpty) return title;
    return '$title $artist';
  }

  /// 在搜索结果中查找与原曲匹配的歌曲
  ///
  /// 匹配规则（均忽略大小写、去除首尾空白）：
  /// - 标题完全相同
  /// - 歌手包含关系（一方包含另一方）
  LxServerSong? _findMatchedSong(Track track, List<LxServerSong> candidates) {
    final targetTitle = _normalize(track.title);
    final targetArtist = _normalize(track.artist ?? '');

    for (final song in candidates) {
      final songTitle = _normalize(song.name);
      if (songTitle != targetTitle) continue;

      final songArtist = _normalize(song.singer);
      if (targetArtist.isEmpty || songArtist.isEmpty) {
        return song;
      }
      if (songArtist.contains(targetArtist) ||
          targetArtist.contains(songArtist)) {
        return song;
      }
    }
    return null;
  }

  /// 字符串归一化：小写 + 去除首尾空白
  String _normalize(String s) => s.trim().toLowerCase();

  /// 构造代理播放文件名
  ///
  /// 格式：`歌名 - 歌手.mp3`。歌手为空时仅用歌名。
  String _buildFilename(Track track) {
    final title = track.title.isEmpty ? '未知曲目' : track.title;
    final artist = track.artist?.trim() ?? '';
    if (artist.isEmpty) {
      return '$title.mp3';
    }
    return '$title - $artist.mp3';
  }

  // ========== 歌词 ==========

  @override
  Future<String?> getLyric(Track track) async {
    final songInfo = Map<String, dynamic>.from(track.meta ?? {});
    songInfo['source'] ??= track.source?.libraryId ?? _currentSource;
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
    AppLogger.log.d('[LxServer] getBoards: source=$_currentSource');
    final boards = await client.getLeaderboardBoards(_currentSource);
    final result = boards.map((b) => b.toLeaderboard()).toList();
    AppLogger.log.d(
      '[LxServer] getBoards 完成: source=$_currentSource, 共 ${result.length} 个榜单',
    );
    return result;
  }

  @override
  Future<List<Track>> getLeaderboardTracks(String leaderboardId) async {
    AppLogger.log.d(
      '[LxServer] getLeaderboardSongs: source=$_currentSource, bangid=$leaderboardId',
    );
    final result = await client.getLeaderboardSongs(
      source: _currentSource,
      bangid: leaderboardId,
    );
    final tracks = result.list
        .map(
          (s) => s.toTrack(
            sourceId: _sourceId,
            sourceName: _sourceName,
            libraryId: _currentSource,
            libraryName: _libraryName(_currentSource),
          ),
        )
        .toList();
    AppLogger.log.d(
      '[LxServer] getLeaderboardSongs 完成: source=$_currentSource, bangid=$leaderboardId, '
      '转换 ${tracks.length} 首歌曲',
    );
    return tracks;
  }

  // ========== 用户收藏 ==========

  @override
  Future<UserListsData> getUserLists() async {
    AppLogger.log.d('[LxServer] getUserLists');
    final response = await client.getUserLists();

    final defaultTracks = response.defaultList
        .map(
          (s) => s.toTrack(
            sourceId: _sourceId,
            sourceName: _sourceName,
            libraryId: s.source,
            libraryName: _libraryName(s.source),
          ),
        )
        .toList();

    final loveTracks = response.loveList
        .map(
          (s) => s.toTrack(
            sourceId: _sourceId,
            sourceName: _sourceName,
            libraryId: s.source,
            libraryName: _libraryName(s.source),
          ),
        )
        .toList();

    final userPlaylists = response.userList
        .map(
          (p) => p.toPlaylist(
            sourceId: _sourceId,
            sourceName: _sourceName,
            libraryId: p.source,
            libraryName: _libraryName(p.source),
          ),
        )
        .toList();

    return UserListsData(
      defaultTracks: defaultTracks,
      loveTracks: loveTracks,
      userPlaylists: userPlaylists,
    );
  }

  @override
  Future<List<Artist>> getFavoriteArtists() async {
    AppLogger.log.d('[LxServer] getFavoriteArtists');
    final artists = await client.getFavoriteArtists();
    return artists
        .map(
          (a) => a.toArtist(
            sourceId: _sourceId,
            sourceName: _sourceName,
            libraryId: a.source,
            libraryName: _libraryName(a.source),
          ),
        )
        .toList();
  }

  @override
  Future<List<Album>> getFavoriteAlbums() async {
    AppLogger.log.d('[LxServer] getFavoriteAlbums');
    final albums = await client.getFavoriteAlbums();
    return albums
        .map(
          (a) => a.toAlbum(
            sourceId: _sourceId,
            sourceName: _sourceName,
            libraryId: a.source,
            libraryName: _libraryName(a.source),
          ),
        )
        .toList();
  }
}
