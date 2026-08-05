import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pomelo/core/core.dart';
import 'package:pomelo/core/models/database/app_database.dart';
import 'package:pomelo/core/models/database/local_library_table.dart';
import 'package:pomelo/core/models/metadata/metadata.dart';
import 'package:pomelo/core/models/music_server_config.dart';
import 'package:pomelo/services/logger/logger.dart';

/// 支持的音频文件扩展名
const _audioExtensions = {
  '.mp3',
  '.flac',
  '.wav',
  '.ogg',
  '.m4a',
  '.aac',
  '.wma',
};

/// 本地音乐服务
///
/// 实现 [MusicServer] 接口，提供本地音乐的查询能力。
///
/// 扫描流程：
/// 1. 用 [MetadataGod] 读取音频文件元数据标签（ID3/FLAC/MP4）
/// 2. 提取封面图片到 `<appSupport>/pomelo/local_covers/` 目录
/// 3. 完整 Track JSON 持久化到 drift [LocalTrackTable]（sourceId='local'）
/// 4. 启动时优先从 drift 加载，避免重复扫描
///
/// 播放时由调用方校验文件存在性（见 [verifyTrackExists]）。
class LocalMusicServer extends MusicServer {
  LocalMusicServer({
    String name = '本地音乐',
    AppDatabase? database,
  })  : _name = name,
        _database = database;

  final String _name;
  final AppDatabase? _database;

  /// 是否已从 drift 加载过历史数据
  bool _loadedFromDb = false;

  @override
  String get sourceId => LocalMusicConfig.configId;

  @override
  String get sourceName => _name;

  @override
  MusicSourceType get sourceType => MusicSourceType.local;

  /// 本地库无「库」概念，故 libraryId / libraryName 恒为 null
  MusicSourceRef get _source =>
      (id: sourceId, name: _name, libraryId: null, libraryName: null);

  /// 内存中的曲目列表
  final List<Track> _tracks = [];

  /// 内存中的专辑列表（按 album 字段分组）
  final List<Album> _albums = [];

  /// 内存中的艺术家列表（按 artist 字段分组）
  final List<Artist> _artists = [];

  /// 内存中的歌单列表（本地无歌单概念，保留为空）
  final List<Playlist> _playlists = [];

  /// 已配置的扫描目录列表
  final List<String> _directories = [];

  /// 已配置的扫描目录列表（只读）
  List<String> get directories => List.unmodifiable(_directories);

  /// 当前曲目总数
  int get trackCount => _tracks.length;

  /// 当前专辑总数
  int get albumCount => _albums.length;

  /// 当前艺术家总数
  int get artistCount => _artists.length;

  // ========== 目录管理 ==========

  /// 添加目录并扫描
  Future<void> addDirectory(String path) async {
    if (_directories.contains(path)) return;
    _directories.add(path);
    await scanDirectory(path);
  }

  /// 仅记录目录配置，不触发扫描
  ///
  /// 用于启动时恢复已配置目录列表，避免每次启动都全量扫描。
  Future<void> addDirectoryOnly(String path) {
    if (_directories.contains(path)) return Future.value();
    _directories.add(path);
    return Future.value();
  }

  /// 移除目录并清理对应曲目
  void removeDirectory(String path) {
    if (!_directories.contains(path)) return;
    _directories.remove(path);
    final removed = _tracks
        .where((t) => t.path != null && t.path!.startsWith(path))
        .toList();
    _tracks.removeWhere((t) => t.path != null && t.path!.startsWith(path));
    _rebuildAlbumsAndArtists();
    // drift 删除 fire-and-forget
    _deletePersistedTracks(removed);
  }

  /// 清空所有数据
  void clear() {
    final removed = List<Track>.from(_tracks);
    _tracks.clear();
    _albums.clear();
    _artists.clear();
    _playlists.clear();
    _directories.clear();
    // drift 删除 fire-and-forget
    _deletePersistedTracks(removed);
  }

  // ========== 启动加载 ==========

  /// 从 drift 加载所有本地音乐库曲目（仅加载一次）
  ///
  /// 加载范围包括：
  /// - 用户扫描的本地音乐（sourceId='local', isLocal=true）
  /// - 在线缓存音乐（sourceId 为在线来源，isLocal=false）
  ///
  /// 跳过本地文件已不存在的记录（不删除，由播放校验逻辑提示用户）。
  Future<void> loadFromDatabase() async {
    if (_database == null || _loadedFromDb) return;
    _loadedFromDb = true;
    try {
      final entities = await _database.getAllLocalTracks();
      for (final e in entities) {
        if (e.path != null && !await File(e.path!).exists()) continue;
        try {
          final json = jsonDecode(e.trackJson) as Map<String, dynamic>;
          _tracks.add(Track.fromJson(json));
        } catch (_) {}
      }
      _rebuildAlbumsAndArtists();
      AppLogger.log.i('[LocalMusic] 已从数据库加载 ${_tracks.length} 首曲目');
    } catch (e) {
      AppLogger.log.w('[LocalMusic] 从数据库加载失败: $e');
    }
  }

  // ========== 目录扫描 ==========

  /// 扫描指定目录，递归查找音频文件并加入内存
  Future<void> scanDirectory(String dirPath) async {
    await loadFromDatabase();

    final dir = Directory(dirPath);
    if (!await dir.exists()) return;

    final newTracks = <Track>[];
    await for (final entity in dir.list(recursive: true)) {
      if (entity is! File) continue;
      final ext = p.extension(entity.path).toLowerCase();
      if (!_audioExtensions.contains(ext)) continue;

      if (_tracks.any((s) => s.path == entity.path)) continue;

      final track = await _scanFile(entity);
      if (track != null) newTracks.add(track);
    }

    if (newTracks.isNotEmpty) {
      _tracks.addAll(newTracks);
      _rebuildAlbumsAndArtists();
      await _persistTracks(newTracks);
      AppLogger.log.i('[LocalMusic] 扫描目录 $dirPath 新增 ${newTracks.length} 首曲目');
    }
  }

  /// 重新扫描所有已配置的目录
  Future<void> rescanAll() async {
    final removed = List<Track>.from(_tracks);
    _tracks.clear();
    _albums.clear();
    _artists.clear();
    await _deletePersistedTracks(removed);
    _loadedFromDb = true; // 已清空，无需再加载
    for (final dir in List<String>.from(_directories)) {
      await scanDirectory(dir);
    }
  }

  /// 扫描单个文件，读取标签并构建 Track
  Future<Track?> _scanFile(File file) async {
    try {
      Metadata? meta;
      try {
        meta = await MetadataGod.readMetadata(file: file.path);
      } catch (e) {
        AppLogger.log.w('[LocalMusic] 读取标签失败 ${file.path}: $e');
        meta = null;
      }

      final fileName = p.basenameWithoutExtension(file.path);
      final tagTitle = meta?.title;
      final tagArtist = meta?.artist;
      final tagAlbum = meta?.album;
      final title = (tagTitle != null && tagTitle.isNotEmpty) ? tagTitle : fileName;
      final artist =
          (tagArtist != null && tagArtist.isNotEmpty) ? tagArtist : null;
      final album = (tagAlbum != null && tagAlbum.isNotEmpty) ? tagAlbum : null;
      final year = meta?.year;
      final trackNumber = meta?.trackNumber;
      final discNumber = meta?.discNumber;
      final genre = meta?.genre;
      final duration = meta?.durationMs?.toInt() ?? 0;

      // 提取封面图片到本地文件
      String? coverArt;
      final picture = meta?.picture;
      if (picture != null && picture.data.isNotEmpty) {
        coverArt = await _saveCover(file.path, picture.data);
      }

      final id = 'local-${_stableHash(file.path)}';
      return Track(
        id: id,
        title: title,
        artist: artist,
        album: album,
        albumId: album != null ? 'local-album-${_stableHash(album)}' : null,
        artistId: artist != null ? 'local-artist-${_stableHash(artist)}' : null,
        coverArt: coverArt,
        duration: duration,
        track: trackNumber,
        discNumber: discNumber,
        year: year,
        genre: genre,
        path: file.path,
        source: _source,
      );
    } catch (e) {
      AppLogger.log.w('[LocalMusic] 扫描文件失败 ${file.path}: $e');
      return null;
    }
  }

  /// 把封面图片字节保存到 `<appSupport>/pomelo/local_covers/<id>.jpg`
  Future<String?> _saveCover(String sourcePath, Uint8List bytes) async {
    try {
      final dir = await _coversDir();
      final fileName = '${_stableHash(sourcePath)}.jpg';
      final file = File(p.join(dir, fileName));
      if (!await file.exists()) {
        await file.writeAsBytes(bytes, flush: true);
      }
      return file.path;
    } catch (e) {
      AppLogger.log.w('[LocalMusic] 保存封面失败: $e');
      return null;
    }
  }

  /// 获取封面图存储目录
  Future<String> _coversDir() async {
    final appSupport = await getApplicationSupportDirectory();
    final dir = Directory(p.join(appSupport.path, 'pomelo', 'local_covers'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  /// 跨启动稳定的字符串哈希
  int _stableHash(String s) {
    var h = 0;
    for (var i = 0; i < s.length; i++) {
      h = (h * 31 + s.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return h;
  }

  /// 根据曲目列表重建专辑与艺术家分组
  void _rebuildAlbumsAndArtists() {
    _albums.clear();
    _artists.clear();

    // 按专辑分组
    final albumGroups = <String, List<Track>>{};
    for (final track in _tracks) {
      final key = track.album ?? '未知专辑';
      albumGroups.putIfAbsent(key, () => []).add(track);
    }
    for (final entry in albumGroups.entries) {
      final first = entry.value.first;
      _albums.add(Album(
        id: 'local-album-${_stableHash(entry.key)}',
        name: entry.key,
        artist: first.artist,
        artistId: first.artistId,
        coverArt: first.coverArt,
        songCount: entry.value.length,
        source: _source,
      ));
    }

    // 按艺术家分组
    final artistGroups = <String, List<Track>>{};
    for (final track in _tracks) {
      final key = track.artist ?? '未知艺术家';
      artistGroups.putIfAbsent(key, () => []).add(track);
    }
    final albumCountByArtist = <String, int>{};
    for (final album in _albums) {
      final key = album.artist ?? '未知艺术家';
      albumCountByArtist[key] = (albumCountByArtist[key] ?? 0) + 1;
    }
    for (final entry in artistGroups.entries) {
      _artists.add(Artist(
        id: 'local-artist-${_stableHash(entry.key)}',
        name: entry.key,
        coverArt: entry.value.first.coverArt,
        albumCount: albumCountByArtist[entry.key] ?? 0,
        source: _source,
      ));
    }
  }

  // ========== drift 持久化 ==========

  Future<void> _persistTracks(List<Track> tracks) async {
    if (_database == null || tracks.isEmpty) return;
    try {
      for (final track in tracks) {
        final companion = LocalTrackTableCompanion.insert(
          id: track.id,
          title: track.title,
          artist: Value(track.artist),
          album: Value(track.album),
          albumId: Value(track.albumId),
          artistId: Value(track.artistId),
          coverArt: Value(track.coverArt),
          duration: Value(track.duration),
          path: Value(track.path),
          src: Value(track.src),
          sourceId: sourceId,
          isLocal: const Value(true),
          trackJson: jsonEncode(track.toJson()),
        );
        await _database.upsertLocalTrack(companion);
      }
    } catch (e) {
      AppLogger.log.w('[LocalMusic] 持久化曲目失败: $e');
    }
  }

  Future<void> _deletePersistedTracks(List<Track> tracks) async {
    if (_database == null || tracks.isEmpty) return;
    try {
      for (final track in tracks) {
        await _database.deleteLocalTrack(track.id);
      }
    } catch (e) {
      AppLogger.log.w('[LocalMusic] 删除持久化曲目失败: $e');
    }
  }

  // ========== 文件校验 ==========

  /// 校验本地曲目文件是否存在
  ///
  /// 返回 true 表示可播放；false 表示文件已被删除/移动。
  /// 调用方应在 false 时弹出 toast 提示用户。
  Future<bool> verifyTrackExists(Track track) async {
    if (track.path == null) return true;
    return File(track.path!).exists();
  }

  // ========== MusicServer 接口实现 ==========

  @override
  Future<PaginationResponse<Track>> searchTracks(
    String keyword, {
    int page = 1,
    int limit = 20,
    String? libraryId,
  }) async {
    await loadFromDatabase();
    if (keyword.isEmpty) {
      return PaginationResponse.fromList(_tracks, page: page, limit: limit);
    }
    final lower = keyword.toLowerCase();
    final filtered = _tracks
        .where(
          (s) =>
              s.title.toLowerCase().contains(lower) ||
              (s.artist?.toLowerCase().contains(lower) ?? false) ||
              (s.album?.toLowerCase().contains(lower) ?? false),
        )
        .toList();
    return PaginationResponse.fromList(filtered, page: page, limit: limit);
  }

  @override
  Future<PaginationResponse<Album>> searchAlbums(
    String keyword, {
    int page = 1,
    int limit = 20,
    String? libraryId,
  }) async {
    await loadFromDatabase();
    if (keyword.isEmpty) {
      return PaginationResponse.fromList(_albums, page: page, limit: limit);
    }
    final lower = keyword.toLowerCase();
    final filtered = _albums
        .where(
          (a) =>
              a.name.toLowerCase().contains(lower) ||
              (a.artist?.toLowerCase().contains(lower) ?? false),
        )
        .toList();
    return PaginationResponse.fromList(filtered, page: page, limit: limit);
  }

  @override
  Future<PaginationResponse<Artist>> searchArtists(
    String keyword, {
    int page = 1,
    int limit = 20,
    String? libraryId,
  }) async {
    await loadFromDatabase();
    if (keyword.isEmpty) {
      return PaginationResponse.fromList(_artists, page: page, limit: limit);
    }
    final lower = keyword.toLowerCase();
    final filtered = _artists
        .where((a) => a.name.toLowerCase().contains(lower))
        .toList();
    return PaginationResponse.fromList(filtered, page: page, limit: limit);
  }

  @override
  Future<PaginationResponse<Playlist>> searchPlaylists(
    String keyword, {
    int page = 1,
    int limit = 20,
    String? libraryId,
  }) async {
    return PaginationResponse.fromList(
      _playlists,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<Track?> getTrack(String id) async {
    await loadFromDatabase();
    try {
      return _tracks.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PaginationResponse<Track>> getTracks({
    int page = 1,
    int limit = 20,
  }) async {
    await loadFromDatabase();
    return PaginationResponse.fromList(_tracks, page: page, limit: limit);
  }

  @override
  Future<Album?> getAlbum(String id) async {
    await loadFromDatabase();
    try {
      return _albums.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PaginationResponse<Track>> getAlbumTracks(
    String albumId, {
    int page = 1,
    int limit = 20,
  }) async {
    await loadFromDatabase();
    final album = _albums.where((a) => a.id == albumId).firstOrNull;
    if (album == null) {
      return PaginationResponse.empty(page: page, limit: limit);
    }
    final filtered = _tracks.where((s) => s.album == album.name).toList();
    return PaginationResponse.fromList(filtered, page: page, limit: limit);
  }

  @override
  Future<Artist?> getArtist(String id) async {
    await loadFromDatabase();
    try {
      return _artists.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Album>> getArtistAlbums(String artistId) async {
    await loadFromDatabase();
    final artist = _artists.where((a) => a.id == artistId).firstOrNull;
    if (artist == null) return [];
    return _albums.where((a) => a.artist == artist.name).toList();
  }

  @override
  Future<PaginationResponse<Track>> getArtistSongs(
    String artistId, {
    String? order,
    int page = 1,
    int limit = 20,
  }) async {
    await loadFromDatabase();
    final artist = _artists.where((a) => a.id == artistId).firstOrNull;
    if (artist == null) {
      return PaginationResponse.empty(page: page, limit: limit);
    }
    final filtered = _tracks.where((s) => s.artist == artist.name).toList();
    return PaginationResponse.fromList(filtered, page: page, limit: limit);
  }

  @override
  Future<Playlist?> getPlaylist(String id) async {
    return null;
  }

  @override
  Future<PaginationResponse<Playlist>> getPlaylists({
    int page = 1,
    int limit = 20,
  }) async {
    return PaginationResponse.fromList(
      _playlists,
      page: page,
      limit: limit,
    );
  }
}
