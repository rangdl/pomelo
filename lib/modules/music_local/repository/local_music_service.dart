import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:pomelo/core/mars.dart';
import 'package:pomelo/modules/music/model/models.dart';

/// 支持的音频文件扩展名
const _audioExtensions = {'.mp3', '.flac', '.wav', '.ogg', '.m4a', '.aac', '.wma'};

/// 本地音乐服务
///
/// 实现 [MusicService] 接口，提供本地音乐的查询能力。
/// 通过扫描用户指定的目录，将音频文件信息存入内存，对外提供查询服务。
class LocalMusicService extends MusicService {
  @override
  String get sourceId => 'local';

  @override
  String get sourceName => '本地音乐';

  @override
  MusicSourceType get sourceType => MusicSourceType.local;

  final _source = (id: 'local', name: '本地音乐');

  /// 内存中的歌曲列表
  final List<Song> _songs = [];

  /// 内存中的专辑列表
  final List<Album> _albums = [];

  /// 内存中的歌单列表
  final List<Playlist> _playlists = [];

  /// 已配置的扫描目录列表
  final List<String> _directories = [];

  /// 已配置的扫描目录列表（只读）
  List<String> get directories => List.unmodifiable(_directories);

  /// 当前歌曲总数
  int get songCount => _songs.length;

  /// 当前专辑总数
  int get albumCount => _albums.length;

  // ========== 目录管理 ==========

  /// 添加目录并扫描
  Future<void> addDirectory(String path) async {
    if (_directories.contains(path)) return;
    _directories.add(path);
    await scanDirectory(path);
  }

  /// 移除目录并清理对应歌曲
  void removeDirectory(String path) {
    _directories.remove(path);
    // 移除来自该目录的所有歌曲
    _songs.removeWhere((s) => s is SongLocal && s.path.startsWith(path));
    // 重建专辑列表
    _rebuildAlbums();
  }

  /// 清空所有数据
  void clear() {
    _songs.clear();
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

      // 避免重复添加
      if (_songs.any((s) => s is SongLocal && s.path == entity.path)) continue;

      final fileName = p.basenameWithoutExtension(entity.path);
      // 尝试解析 "艺术家 - 歌名" 格式
      final parts = fileName.split(' - ');
      final String artist;
      final String name;
      if (parts.length >= 2) {
        artist = parts[0].trim();
        name = parts.sublist(1).join(' - ').trim();
      } else {
        artist = '未知艺术家';
        name = fileName;
      }

      final id = 'local-${entity.path.hashCode}';
      final song = Song.local(
        id: id,
        name: name,
        artist: artist,
        albumId: null,
        albumName: null,
        duration: 0, // 不解析 tag，时长设为 0
        path: entity.path,
        source: _source,
      );
      _songs.add(song);
    }

    // 扫描完成后重建专辑列表
    _rebuildAlbums();
  }

  /// 重新扫描所有已配置的目录
  Future<void> rescanAll() async {
    _songs.clear();
    _albums.clear();
    for (final dir in List<String>.from(_directories)) {
      await scanDirectory(dir);
    }
  }

  /// 根据歌曲列表重建专辑分组
  void _rebuildAlbums() {
    _albums.clear();
    // 按艺术家分组作为"专辑"
    final groups = <String, List<Song>>{};
    for (final song in _songs) {
      groups.putIfAbsent(song.artist, () => []).add(song);
    }
    for (final entry in groups.entries) {
      _albums.add(Album(
        id: 'local-artist-${entry.key.hashCode}',
        title: entry.key,
        artist: entry.key,
        songCount: entry.value.length,
        source: _source,
      ));
    }
  }

  // ========== MusicService 接口实现 ==========

  @override
  Future<PaginationResponse<Song>> searchSongs(
    String keyword, {
    int page = 1,
    int limit = 20,
  }) async {
    if (keyword.isEmpty) {
      return PaginationResponse.empty(page: page, limit: limit);
    }
    final lower = keyword.toLowerCase();
    final filtered = _songs
        .where(
          (s) =>
              s.name.toLowerCase().contains(lower) ||
              s.artist.toLowerCase().contains(lower),
        )
        .toList();
    return PaginationResponse.fromList(filtered, page: page, limit: limit);
  }

  @override
  Future<PaginationResponse<Album>> searchAlbums(
    String keyword, {
    int page = 1,
    int limit = 20,
  }) async {
    if (keyword.isEmpty) {
      return PaginationResponse.empty(page: page, limit: limit);
    }
    final lower = keyword.toLowerCase();
    final filtered = _albums
        .where(
          (a) =>
              a.title.toLowerCase().contains(lower) ||
              a.artist.toLowerCase().contains(lower),
        )
        .toList();
    return PaginationResponse.fromList(filtered, page: page, limit: limit);
  }

  @override
  Future<PaginationResponse<Playlist>> searchPlaylists(
    String keyword, {
    int page = 1,
    int limit = 20,
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
  Future<Song?> getSong(String id) async {
    try {
      return _songs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PaginationResponse<Song>> getSongs({int page = 1, int limit = 20}) async {
    return PaginationResponse.fromList(_songs, page: page, limit: limit);
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
  Future<PaginationResponse<Song>> getAlbumSongs(
    String albumId, {
    int page = 1,
    int limit = 20,
  }) async {
    final album = await getAlbum(albumId);
    if (album == null) return PaginationResponse.empty(page: page, limit: limit);
    // 专辑按艺术家分组，查找该艺术家的所有歌曲
    final filtered = _songs.where((s) => s.artist == album.artist).toList();
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
