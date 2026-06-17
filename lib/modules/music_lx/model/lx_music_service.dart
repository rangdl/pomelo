import 'package:pomelo/core/mars.dart';
import 'package:pomelo/modules/music/model/models.dart';
import 'package:pomelo/modules/music_lx/model/lx_js_source_engine.dart';
import 'package:pomelo/modules/music_lx/providers/musicsdk_provider.dart';

/// Lx 音乐服务
///
/// 通过 JS 脚本动态加载的音乐平台服务。
/// 每个实例对应一个脚本中的一个平台（如 tx、kg、wy 等）。
///
/// [scriptId] 用于区分不同脚本提供的同平台服务，
/// 确保多脚本场景下 sourceId 不冲突。
/// [platform] 和 [platformName] 来自 JS 端 `registry.all()` 返回的 id 和 name。
class LxMusicService extends MusicService {
  @override
  MusicSourceType get sourceType => MusicSourceType.lx;

  final LxJsEngine jsEngine;

  /// 音乐源引擎（用于获取播放链接），可选
  final LxJsSourceEngine? sourceEngine;

  /// 脚本标识，用于区分不同脚本来源
  final String scriptId;

  /// 平台标识（如 'tx', 'kg', 'wy', 'kw', 'mg'）
  final String platform;

  /// 平台显示名称（如 '腾讯音乐', '酷狗音乐'）
  final String platformName;

  LxMusicService({
    required this.jsEngine,
    this.sourceEngine,
    required this.scriptId,
    required this.platform,
    required this.platformName,
  });

  @override
  String get sourceId => platform;

  @override
  String get sourceName => platformName;

  @override
  Future<PaginationResponse<Song>> searchSongs(
    String keyword, {
    int page = 1,
    int limit = 20,
  }) {
    return jsEngine.search(keyword, page: page, limit: limit, type: platform);
  }

  @override
  Future<PaginationResponse<Album>> searchAlbums(
    String keyword, {
    int page = 1,
    int limit = 20,
  }) {
    throw UnimplementedError('$sourceName(searchAlbums) 尚未实现');
  }

  @override
  Future<PaginationResponse<Playlist>> searchPlaylists(
    String keyword, {
    int page = 1,
    int limit = 20,
  }) {
    throw UnimplementedError('$sourceName(searchPlaylists) 尚未实现');
  }

  @override
  Future<Song?> getSong(String id) {
    throw UnimplementedError('$sourceName(getSong) 尚未实现');
  }

  @override
  Future<PaginationResponse<Song>> getSongs({int page = 1, int limit = 20}) {
    throw UnimplementedError('$sourceName(getSongs) 尚未实现');
  }

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

  @override
  Future<Playlist?> getPlaylist(String id) {
    throw UnimplementedError('$sourceName(getPlaylist) 尚未实现');
  }

  @override
  Future<PaginationResponse<Playlist>> getPlaylists(
      {int page = 1, int limit = 20}) {
    throw UnimplementedError('$sourceName(getPlaylists) 尚未实现');
  }

  // ========== 播放链接 ==========

  @override
  Future<String> getMusicUrl(SongFull song) async {
    if (sourceEngine == null || !sourceEngine!.hasPlatform(platform)) {
      throw UnimplementedError(
          '$sourceName(getMusicUrl) 未加载源脚本，无法获取播放链接');
    }
    return sourceEngine!.getMusicUrl(platform, song);
  }
}
