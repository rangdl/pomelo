import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:pomelo/core/core.dart';
import 'package:pomelo/core/models/metadata/metadata.dart';

/// 支持的音频文件扩展名
const _audioExtensions = {'.mp3', '.flac', '.wav', '.ogg', '.m4a', '.aac', '.wma'};

/// 本地音乐服务
///
/// 实现 [MusicServer] 接口，提供本地音乐的查询能力。
/// 通过扫描用户指定的目录，将音频文件信息存入内存，对外提供查询服务。
class LocalMusicServer extends MusicServer {
  LocalMusicServer({String name = '本地音乐'}) : _name = name;

  final String _name;

  @override
  String get sourceId => 'local';

  @override
  String get sourceName => _name;

  @override
  MusicSourceType get sourceType => MusicSourceType.local;

  ({String id, String name, String? libraryId, String? libraryName}) get _source =>
      (id: 'local', name: _name, libraryId: null, libraryName: null);

  /// 内存中的曲目列表
  final List<Track> _tracks = [];

  /// 内存中的专辑列表
  final List<Album> _albums = [];

  /// 内存中的歌单列表
  final List<Playlist> _playlists = [];

  /// 已配置的扫描目录列表
  final List<String> _directories = [];

  /// 已配置的扫描目录列表（只读）
  List<String> get directories => List.unmodifiable(_directories);

  /// 当前曲目总数
  int get trackCount => _tracks.length;

  /// 当前专辑总数
  int get albumCount => _albums.length;

  // ========== 目录管理 ==========

  /// 添加目录并扫描
  Future<void> addDirectory(String path) async {
    if (_directories.contains(path)) return;
    _directories.add(path);
    await scanDirectory(path);
  }

  /// 移除目录并清理对应曲目
  void removeDirectory(String path) {
    _directories.remove(path);
    _tracks.removeWhere((s) => s.path != null && s.path!.startsWith(path));
    _rebuildAlbums();
  }

  /// 清空所有数据
  void clear() {
    _tracks.clear();
    _albums.clear();
    _playlists.clear();
    _directories.clear();
  }

  // ========== 目录扫描 ==========

  /// 扫描指定目录，递归查找音频文件并加入内存
  Future<void> scanDirectory(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return;

    await for (final entity in dir.list(recursive: true)) {
      if (entity is! File) continue;
      final ext = p.extension(entity.path).toLowerCase();
      if (!_audioExtensions.contains(ext)) continue;

      if (_tracks.any((s) => s.path != null && s.path == entity.path)) continue;

      final fileName = p.basenameWithoutExtension(entity.path);
      final parts = fileName.split(' - ');
      final String artist;
      final String title;
      if (parts.length >= 2) {
        artist = parts[0].trim();
        title = parts.sublist(1).join(' - ').trim();
      } else {
        artist = '未知艺术家';
        title = fileName;
      }

      final id = 'local-${entity.path.hashCode}';
      final track = Track(
        id: id,
        title: title,
        artist: artist,
        duration: 0,
        path: entity.path,
        source: _source,
      );
      _tracks.add(track);
    }

    _rebuildAlbums();
  }

  /// 重新扫描所有已配置的目录
  Future<void> rescanAll() async {
    _tracks.clear();
    _albums.clear();
    for (final dir in List<String>.from(_directories)) {
      await scanDirectory(dir);
    }
  }

  /// 根据曲目列表重建专辑分组
  void _rebuildAlbums() {
    _albums.clear();
    final groups = <String, List<Track>>{};
    for (final track in _tracks) {
      groups.putIfAbsent(track.artist ?? '未知', () => []).add(track);
    }
    for (final entry in groups.entries) {
      _albums.add(Album(
        id: 'local-artist-${entry.key.hashCode}',
        name: entry.key,
        artist: entry.key,
        songCount: entry.value.length,
        source: _source,
      ));
    }
  }

  // ========== MusicServer 接口实现 ==========

  @override
  Future<PaginationResponse<Track>> searchTracks(
    String keyword, {
    int page = 1,
    int limit = 20,
    String? libraryId,
  }) async {
    if (keyword.isEmpty) {
      return PaginationResponse.empty(page: page, limit: limit);
    }
    final lower = keyword.toLowerCase();
    final filtered = _tracks
        .where(
          (s) =>
              s.title.toLowerCase().contains(lower) ||
              (s.artist?.toLowerCase().contains(lower) ?? false),
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
    if (keyword.isEmpty) {
      return PaginationResponse.empty(page: page, limit: limit);
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
  Future<PaginationResponse<Playlist>> searchPlaylists(
    String keyword, {
    int page = 1,
    int limit = 20,
    String? libraryId,
  }) async {
    if (keyword.isEmpty) {
      return PaginationResponse.empty(page: page, limit: limit);
    }
    final lower = keyword.toLowerCase();
    final filtered = _playlists
        .where((p) => p.name.toLowerCase().contains(lower))
        .toList();
    return PaginationResponse.fromList(filtered, page: page, limit: limit);
  }

  @override
  Future<Track?> getTrack(String id) async {
    try {
      return _tracks.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PaginationResponse<Track>> getTracks({int page = 1, int limit = 20}) async {
    return PaginationResponse.fromList(_tracks, page: page, limit: limit);
  }

  @override
  Future<Album?> getAlbum(String id) async {
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
    final album = await getAlbum(albumId);
    if (album == null) return PaginationResponse.empty(page: page, limit: limit);
    final filtered = _tracks.where((s) => s.artist == album.artist).toList();
    return PaginationResponse.fromList(filtered, page: page, limit: limit);
  }

  @override
  Future<Playlist?> getPlaylist(String id) async {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
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
