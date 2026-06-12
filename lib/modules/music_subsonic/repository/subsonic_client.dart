import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:pointycastle/export.dart';

import 'subsonic_models.dart';

/// Subsonic REST API HTTP 客户端
///
/// 封装认证、请求构造和响应解析。
/// 使用 token + salt 认证方式（API 1.13.0+）。
class SubsonicClient {
  /// 服务器地址（不含尾部斜杠），如 'https://music.example.com'
  final String serverUrl;

  /// 用户名
  final String username;

  /// 密码
  final String password;

  /// REST API 协议版本
  static const String _apiVersion = '1.16.1';

  /// 客户端标识
  static const String _clientName = 'pomelo';

  final Dio _dio;
  final Random _random = Random.secure();

  SubsonicClient({
    required this.serverUrl,
    required this.username,
    required this.password,
    Dio? dio,
  }) : _dio = dio ?? Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
        ));

  // ========== 认证 ==========

  /// 生成随机 salt 字符串
  String _generateSalt() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(6, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  /// 计算 MD5 哈希（返回 32 位小写十六进制字符串）
  String _md5Hex(String input) {
    final data = Uint8List.fromList(utf8.encode(input));
    final digest = MD5Digest();
    digest.update(data, 0, data.length);
    final out = Uint8List(digest.digestSize);
    digest.doFinal(out, 0);
    return out.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// 构造每次请求的公共认证参数
  Map<String, dynamic> get _authParams {
    final salt = _generateSalt();
    final token = _md5Hex(password + salt);
    return {
      'u': username,
      't': token,
      's': salt,
      'v': _apiVersion,
      'c': _clientName,
      'f': 'json',
    };
  }

  // ========== 底层请求 ==========

  /// 发送 GET 请求并返回解析后的 [SubsonicResponse]
  Future<SubsonicResponse> _get(
    String endpoint, {
    Map<String, dynamic>? params,
  }) async {
    final queryParams = {..._authParams, ...?params};
    final response = await _dio.get<Map<String, dynamic>>(
      '$serverUrl/rest/$endpoint',
      queryParameters: queryParams,
      options: Options(responseType: ResponseType.json),
    );
    final json = response.data!;
    final subsonic = SubsonicResponse.fromJson(json);
    if (!subsonic.isOk) {
      throw SubsonicException(
        subsonic.error?.code ?? 0,
        subsonic.error?.message ?? 'Unknown error',
      );
    }
    return subsonic;
  }

  // ========== System ==========

  /// 测试连接
  Future<void> ping() async {
    await _get('ping');
  }

  // ========== Browsing (ID3) ==========

  /// 获取所有艺术家（按 ID3 标签组织）
  Future<List<SubsonicArtist>> getArtists() async {
    final res = await _get('getArtists');
    final artists = res.data['artists'] as Map<String, dynamic>?;
    if (artists == null) return [];
    final indexes = artists['index'] as List<dynamic>? ?? [];
    final result = <SubsonicArtist>[];
    for (final idx in indexes) {
      final artistList =
          (idx as Map<String, dynamic>)['artist'] as List<dynamic>? ?? [];
      for (final a in artistList) {
        result.add(SubsonicArtist.fromJson(a as Map<String, dynamic>));
      }
    }
    return result;
  }

  /// 获取艺术家详情（含专辑列表）
  Future<({SubsonicArtist artist, List<SubsonicAlbum> albums})> getArtist(
      String id) async {
    final res = await _get('getArtist', params: {'id': id});
    final artistJson = res.data['artist'] as Map<String, dynamic>;
    final artist = SubsonicArtist.fromJson(artistJson);
    final albumList = (artistJson['album'] as List<dynamic>?)
            ?.map((e) => SubsonicAlbum.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return (artist: artist, albums: albumList);
  }

  /// 获取专辑详情（含歌曲列表）
  Future<SubsonicAlbum> getAlbum(String id) async {
    final res = await _get('getAlbum', params: {'id': id});
    return SubsonicAlbum.fromJson(
        res.data['album'] as Map<String, dynamic>);
  }

  /// 获取歌曲详情
  Future<SubsonicSong> getSong(String id) async {
    final res = await _get('getSong', params: {'id': id});
    return SubsonicSong.fromJson(
        res.data['song'] as Map<String, dynamic>);
  }

  // ========== Album/Song Lists ==========

  /// 获取专辑列表（ID3 模式）
  ///
  /// [type] 可选值：random, newest, frequent, recent, starred,
  /// alphabeticalByName, alphabeticalByArtist, byYear, byGenre
  Future<List<SubsonicAlbum>> getAlbumList2({
    required String type,
    int size = 20,
    int offset = 0,
    int? fromYear,
    int? toYear,
    String? genre,
  }) async {
    final params = <String, dynamic>{
      'type': type,
      'size': size,
      'offset': offset,
    };
    if (fromYear != null) params['fromYear'] = fromYear;
    if (toYear != null) params['toYear'] = toYear;
    if (genre != null) params['genre'] = genre;

    final res = await _get('getAlbumList2', params: params);
    final albumList2 = res.data['albumList2'] as Map<String, dynamic>?;
    if (albumList2 == null) return [];
    return (albumList2['album'] as List<dynamic>?)
            ?.map((e) => SubsonicAlbum.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  /// 获取随机歌曲
  Future<List<SubsonicSong>> getRandomSongs({int size = 50}) async {
    final res = await _get('getRandomSongs', params: {'size': size});
    final randomSongs = res.data['randomSongs'] as Map<String, dynamic>?;
    if (randomSongs == null) return [];
    return (randomSongs['song'] as List<dynamic>?)
            ?.map((e) => SubsonicSong.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  /// 按流派获取歌曲
  Future<List<SubsonicSong>> getSongsByGenre({
    required String genre,
    int count = 20,
    int offset = 0,
  }) async {
    final res = await _get('getSongsByGenre', params: {
      'genre': genre,
      'count': count,
      'offset': offset,
    });
    final songsByGenre = res.data['songsByGenre'] as Map<String, dynamic>?;
    if (songsByGenre == null) return [];
    return (songsByGenre['song'] as List<dynamic>?)
            ?.map((e) => SubsonicSong.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  // ========== Searching ==========

  /// 搜索（ID3 模式）
  Future<SubsonicSearchResult3> search3({
    required String query,
    int artistCount = 20,
    int artistOffset = 0,
    int albumCount = 20,
    int albumOffset = 0,
    int songCount = 20,
    int songOffset = 0,
  }) async {
    final res = await _get('search3', params: {
      'query': query,
      'artistCount': artistCount,
      'artistOffset': artistOffset,
      'albumCount': albumCount,
      'albumOffset': albumOffset,
      'songCount': songCount,
      'songOffset': songOffset,
    });
    final searchResult3 = res.data['searchResult3'] as Map<String, dynamic>?;
    if (searchResult3 == null) return SubsonicSearchResult3();
    return SubsonicSearchResult3.fromJson(searchResult3);
  }

  // ========== Playlists ==========

  /// 获取所有歌单
  Future<List<SubsonicPlaylist>> getPlaylists() async {
    final res = await _get('getPlaylists');
    final playlists = res.data['playlists'] as Map<String, dynamic>?;
    if (playlists == null) return [];
    return (playlists['playlist'] as List<dynamic>?)
            ?.map((e) =>
                SubsonicPlaylist.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  /// 获取歌单详情（含歌曲）
  Future<SubsonicPlaylist> getPlaylist(String id) async {
    final res = await _get('getPlaylist', params: {'id': id});
    return SubsonicPlaylist.fromJson(
        res.data['playlist'] as Map<String, dynamic>);
  }

  // ========== Media Retrieval ==========

  /// 构造歌曲播放 URL（带认证参数）
  String buildStreamUrl(String songId) {
    final params = {..._authParams, 'id': songId};
    final query = params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    return '$serverUrl/rest/stream?$query';
  }

  /// 构造封面图片 URL（带认证参数）
  String buildCoverArtUrl(String coverArtId, {int? size}) {
    final params = {..._authParams, 'id': coverArtId};
    if (size != null) params['size'] = size;
    final query = params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    return '$serverUrl/rest/getCoverArt?$query';
  }

  // ========== Media Annotation ==========

  /// 添加星标
  Future<void> star({String? id, String? albumId, String? artistId}) async {
    final params = <String, dynamic>{};
    if (id != null) params['id'] = id;
    if (albumId != null) params['albumId'] = albumId;
    if (artistId != null) params['artistId'] = artistId;
    await _get('star', params: params);
  }

  /// 移除星标
  Future<void> unstar({String? id, String? albumId, String? artistId}) async {
    final params = <String, dynamic>{};
    if (id != null) params['id'] = id;
    if (albumId != null) params['albumId'] = albumId;
    if (artistId != null) params['artistId'] = artistId;
    await _get('unstar', params: params);
  }

  /// 记录播放（scrobble）
  Future<void> scrobble(String id, {bool submission = true}) async {
    await _get('scrobble', params: {
      'id': id,
      'submission': submission,
    });
  }

  /// 释放资源
  void dispose() {
    _dio.close();
  }
}
