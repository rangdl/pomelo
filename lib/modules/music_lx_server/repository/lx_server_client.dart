import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pomelo/services/logger/logger.dart';
import 'package:pomelo/core/toast.dart';

import 'lx_server_models.dart';

/// SSE 进度事件
///
/// 由 `/api/music/progress` 端点以 Server-Sent Events 协议返回。
class LxServerProgressEvent {
  /// 来源名称（一般为音源标识）
  final String? name;

  /// 状态：'success' | 'fail' | 其他
  final String? status;

  /// 详细信息（不为空时应该用 Toast 提示用户）
  final String? message;

  const LxServerProgressEvent({
    required this.name,
    required this.status,
    required this.message,
  });

  factory LxServerProgressEvent.fromJson(Map<String, dynamic> json) {
    return LxServerProgressEvent(
      name: json['name'] as String?,
      status: json['status'] as String?,
      message: json['message'] as String?,
    );
  }

  bool get isSuccess => status == 'success';
  bool get isFail => status == 'fail';
}

/// Lx Server HTTP 客户端
///
/// 封装登录鉴权和所有音乐 API 请求。
/// 登录后持有 [token]，后续请求通过 `x-user-token` 头鉴权。
class LxServerClient {
  /// 服务器地址（不含尾部斜杠）
  final String serverUrl;

  /// 用户名
  final String username;

  /// 密码
  final String password;

  /// 登录后获取的 Token
  String? token;

  /// 是否启用代理播放
  ///
  /// 开启后 [getMusicUrl] 返回的 URL 会被包装成
  /// `/api/music/download?url=<原始URL>&filename=<歌名 - 歌手.mp3>&inline=1`
  /// 让服务器代理获取并转发音频流。
  final bool proxyPlayback;

  final Dio _dio;

  LxServerClient({
    required this.serverUrl,
    required this.username,
    required this.password,
    this.token,
    this.proxyPlayback = false,
    Dio? dio,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 30),
             ),
           );

  /// 是否已登录
  bool get isLoggedIn => token != null && token!.isNotEmpty;

  // ========== 鉴权 ==========

  /// 登录获取 Token
  ///
  /// 调用 POST /api/user/login，成功后保存 Token。
  Future<void> login() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$serverUrl/api/user/login',
      data: {'username': username, 'password': password},
      options: Options(contentType: Headers.jsonContentType),
    );
    final data = response.data!;
    final success = data['success'] as bool? ?? false;
    if (!success) {
      throw Exception('登录失败: ${data['message'] ?? '未知错误'}');
    }
    token = data['token'] as String?;
    if (token == null || token!.isEmpty) {
      throw Exception('登录失败: 服务器未返回有效 Token');
    }
    AppLogger.log.i('[LxServer] 登录成功: $username');
  }

  /// 验证当前 Token 是否有效
  ///
  /// 调用 GET /api/user/auth/verify。
  Future<bool> verifyToken() async {
    if (!isLoggedIn) return false;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$serverUrl/api/user/auth/verify',
        options: _authOptions,
      );
      final data = response.data!;
      return data['valid'] as bool? ?? false;
    } catch (e) {
      AppLogger.log.w('[LxServer] Token 验证失败: $e');
      return false;
    }
  }

  /// 确保已登录（Token 无效则重新登录）
  Future<void> ensureLoggedIn() async {
    if (isLoggedIn && await verifyToken()) return;
    await login();
  }

  /// 构造带鉴权头的请求选项
  Options get _authOptions => Options(
    headers: {'x-user-name': username, 'x-user-token': token ?? ''},
    responseType: ResponseType.json,
  );

  // ========== 搜索 ==========

  /// 搜索音乐
  ///
  /// GET /api/music/search?source=&keyword=&page=&limit=
  /// [source] 库标识（kg/kw/tx/mg/wy）
  /// [keyword] 搜索关键词
  /// 返回分页歌曲列表。
  Future<({List<LxServerSong> list, int total, int limit, int page})>
  searchMusic({
    required String source,
    required String keyword,
    int page = 1,
    int limit = 20,
  }) async {
    await ensureLoggedIn();
    AppLogger.log.i(
      '[LxServer] 搜索: source=$source, keyword=$keyword, page=$page',
    );
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$serverUrl/api/music/search',
        queryParameters: {
          'source': source,
          'keyword': keyword,
          'page': page,
          'limit': limit,
        },
        options: _authOptions,
      );
      final data = response.data!;
      final list =
          (data['list'] as List<dynamic>?)
              ?.map((e) => LxServerSong.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      final total = (data['total'] as num?)?.toInt() ?? 0;
      final respLimit = (data['limit'] as num?)?.toInt() ?? limit;
      final respPage = (data['page'] as num?)?.toInt() ?? page;
      AppLogger.log.i(
        '[LxServer] 搜索成功: source=$source, keyword=$keyword, '
        '返回 ${list.length} 首, 总计 $total 首',
      );
      return (list: list, total: total, limit: respLimit, page: respPage);
    } catch (e, s) {
      AppLogger.reportError(
        e,
        s,
        '[LxServer] 搜索失败: source=$source, keyword=$keyword, page=$page',
      );
      rethrow;
    }
  }

  /// 搜索提示（联想词）
  ///
  /// GET /api/music/tipSearch?keyword=&source=
  /// [source] 库标识（kg/kw/tx/mg/wy）
  /// [keyword] 搜索关键词
  /// 返回联想词列表。
  Future<List<String>> tipSearch({
    required String source,
    required String keyword,
  }) async {
    await ensureLoggedIn();
    try {
      final response = await _dio.get(
        '$serverUrl/api/music/tipSearch',
        queryParameters: {'source': source, 'keyword': keyword},
        options: _authOptions,
      );
      final data = response.data;
      // 兼容 {list: [...]} 或裸数组 [...]
      final list = data is Map<String, dynamic>
          ? data['list'] as List<dynamic>?
          : data as List<dynamic>?;
      return list?.map((e) => e.toString()).toList() ?? [];
    } catch (e, s) {
      AppLogger.reportError(
        e,
        s,
        '[LxServer] 搜索提示失败: source=$source, keyword=$keyword',
      );
      rethrow;
    }
  }

  /// 热搜词列表
  ///
  /// GET /api/music/hotSearch?source=
  /// [source] 库标识（kg/kw/tx/mg/wy）
  /// 返回热搜词列表。
  Future<List<String>> hotSearch({required String source}) async {
    await ensureLoggedIn();
    try {
      final response = await _dio.get(
        '$serverUrl/api/music/hotSearch',
        queryParameters: {'source': source},
        options: _authOptions,
      );
      final data = response.data;
      // 兼容 {list: [...]} 或裸数组 [...]
      final list = data is Map<String, dynamic>
          ? data['list'] as List<dynamic>?
          : data as List<dynamic>?;
      return list?.map((e) => e.toString()).toList() ?? [];
    } catch (e, s) {
      AppLogger.reportError(e, s, '[LxServer] 热搜词获取失败: source=$source');
      rethrow;
    }
  }

  /// 通用搜索（支持 type 参数）
  ///
  /// GET /api/music/search?source=&name=&type=&page=&limit=
  /// [source] 库标识（kg/kw/tx/mg/wy）
  /// [name] 搜索关键词（对应 API 的 name 参数）
  /// [type] 搜索类型：song/singer/album/playlist
  ///
  /// 返回原始 JSON 列表，调用方根据 type 自行解析。
  /// 兼容两种响应格式：{list: [...], total, limit, page} 或裸数组 [...]。
  Future<({List<Map<String, dynamic>> list, int total, int limit, int page})>
  searchByType({
    required String source,
    required String name,
    required String type,
    int page = 1,
    int limit = 20,
  }) async {
    await ensureLoggedIn();
    AppLogger.log.i(
      '[LxServer] 搜索(type): source=$source, name=$name, type=$type, page=$page',
    );
    try {
      final response = await _dio.get(
        '$serverUrl/api/music/search',
        queryParameters: {
          'source': source,
          'name': name,
          'type': type,
          'page': page,
          'limit': limit,
        },
        options: _authOptions,
      );
      final dynamic rawData = response.data;

      // 兼容裸数组与包装对象两种格式
      List<dynamic> rawList;
      int total = 0;
      int respLimit = limit;
      int respPage = page;
      if (rawData is List) {
        rawList = rawData;
      } else if (rawData is Map<String, dynamic>) {
        rawList = rawData['list'] as List<dynamic>? ?? const [];
        total = (rawData['total'] as num?)?.toInt() ?? 0;
        respLimit = (rawData['limit'] as num?)?.toInt() ?? limit;
        respPage = (rawData['page'] as num?)?.toInt() ?? page;
      } else {
        rawList = const [];
      }

      final list = rawList
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      AppLogger.log.i(
        '[LxServer] 搜索(type)成功: source=$source, name=$name, type=$type, '
        '返回 ${list.length} 项',
      );
      return (list: list, total: total, limit: respLimit, page: respPage);
    } catch (e, s) {
      AppLogger.reportError(
        e,
        s,
        '[LxServer] 搜索(type)失败: source=$source, name=$name, type=$type, page=$page',
      );
      rethrow;
    }
  }

  /// 搜索歌手
  ///
  /// 调用 [searchByType] 并解析为 [LxServerArtist] 列表。
  Future<({List<LxServerArtist> list, int total, int limit, int page})>
  searchArtists({
    required String source,
    required String name,
    int page = 1,
    int limit = 20,
  }) async {
    final result = await searchByType(
      source: source,
      name: name,
      type: 'singer',
      page: page,
      limit: limit,
    );
    final list = result.list.map((e) => LxServerArtist.fromJson(e)).toList();
    return (
      list: list,
      total: result.total,
      limit: result.limit,
      page: result.page,
    );
  }

  /// 搜索专辑
  ///
  /// 调用 [searchByType] 并解析为 [LxServerAlbum] 列表。
  Future<({List<LxServerAlbum> list, int total, int limit, int page})>
  searchAlbums({
    required String source,
    required String name,
    int page = 1,
    int limit = 20,
  }) async {
    final result = await searchByType(
      source: source,
      name: name,
      type: 'album',
      page: page,
      limit: limit,
    );
    final list = result.list.map((e) => LxServerAlbum.fromJson(e)).toList();
    return (
      list: list,
      total: result.total,
      limit: result.limit,
      page: result.page,
    );
  }

  /// 搜索歌单
  ///
  /// 调用 [searchByType] 并解析为 [LxServerSearchPlaylist] 列表。
  Future<({List<LxServerSearchPlaylist> list, int total, int limit, int page})>
  searchPlaylistsByType({
    required String source,
    required String name,
    int page = 1,
    int limit = 20,
  }) async {
    final result = await searchByType(
      source: source,
      name: name,
      type: 'playlist',
      page: page,
      limit: limit,
    );
    final list = result.list
        .map((e) => LxServerSearchPlaylist.fromJson(e))
        .toList();
    return (
      list: list,
      total: result.total,
      limit: result.limit,
      page: result.page,
    );
  }

  // ========== 歌手与专辑详情 ==========

  /// 获取歌手详情
  ///
  /// GET /api/music/artistDetail?source=&id=
  /// 返回歌手信息（含 desc/avatar/musicSize/albumSize）。
  Future<LxServerArtist> getArtistDetail({
    required String source,
    required String id,
  }) async {
    await ensureLoggedIn();
    AppLogger.log.i('[LxServer] 获取歌手详情: source=$source, id=$id');
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$serverUrl/api/music/artistDetail',
        queryParameters: {'source': source, 'id': id},
        options: _authOptions,
      );
      final data = response.data!;
      AppLogger.log.i(
        '[LxServer] 歌手详情获取成功: source=$source, id=$id, name=${data['name']}',
      );
      return LxServerArtist.fromJson(data);
    } catch (e, s) {
      AppLogger.reportError(
        e,
        s,
        '[LxServer] 获取歌手详情失败: source=$source, id=$id',
      );
      rethrow;
    }
  }

  /// 获取歌手专辑列表
  ///
  /// GET /api/music/artistAlbums?source=&id=&page=
  /// 返回分页专辑列表。
  Future<({List<LxServerAlbum> list, int total, int limit, int page})>
  getArtistAlbums({
    required String source,
    required String id,
    int page = 1,
    int limit = 20,
  }) async {
    await ensureLoggedIn();
    AppLogger.log.i('[LxServer] 获取歌手专辑: source=$source, id=$id, page=$page');
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$serverUrl/api/music/artistAlbums',
        queryParameters: {'source': source, 'id': id, 'page': page},
        options: _authOptions,
      );
      final data = response.data!;
      final list =
          (data['list'] as List<dynamic>?)
              ?.map((e) => LxServerAlbum.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      final total = (data['total'] as num?)?.toInt() ?? 0;
      AppLogger.log.i(
        '[LxServer] 歌手专辑获取成功: source=$source, id=$id, '
        '返回 ${list.length} 张, 总计 $total 张',
      );
      return (list: list, total: total, limit: limit, page: page);
    } catch (e, s) {
      AppLogger.reportError(
        e,
        s,
        '[LxServer] 获取歌手专辑失败: source=$source, id=$id, page=$page',
      );
      rethrow;
    }
  }

  /// 获取歌手歌曲
  ///
  /// GET /api/music/artistSongs?source=&id=&order=
  /// [order] 排序方式：'hot'（热度）或 'time'（时间）。
  /// 返回裸数组的歌曲列表（API 直接返回 List，非 {list: [...]} 包装）。
  Future<List<LxServerSong>> getArtistSongs({
    required String source,
    required String id,
    String order = 'hot',
  }) async {
    await ensureLoggedIn();
    AppLogger.log.i('[LxServer] 获取歌手歌曲: source=$source, id=$id, order=$order');
    try {
      final response = await _dio.get(
        '$serverUrl/api/music/artistSongs',
        queryParameters: {'source': source, 'id': id, 'order': order},
        options: _authOptions,
      );
      final dynamic rawData = response.data;
      // 兼容裸数组与 {list: [...]} 包装两种格式
      List<dynamic> rawList;
      if (rawData is List) {
        rawList = rawData;
      } else if (rawData is Map<String, dynamic>) {
        rawList = rawData['list'] as List<dynamic>? ?? const [];
      } else {
        rawList = const [];
      }
      final list = rawList
          .map((e) => LxServerSong.fromJson(e as Map<String, dynamic>))
          .toList();
      AppLogger.log.i(
        '[LxServer] 歌手歌曲获取成功: source=$source, id=$id, order=$order, '
        '返回 ${list.length} 首',
      );
      return list;
    } catch (e, s) {
      AppLogger.reportError(
        e,
        s,
        '[LxServer] 获取歌手歌曲失败: source=$source, id=$id, order=$order',
      );
      rethrow;
    }
  }

  /// 获取专辑歌曲
  ///
  /// GET /api/music/albumSongs?source=&id=
  /// 返回专辑元信息（name/publishTime/source）及其曲目列表。
  Future<
    ({
      List<LxServerSong> list,
      int total,
      String? name,
      String? publishTime,
      String source,
    })
  >
  getAlbumSongs({required String source, required String id}) async {
    await ensureLoggedIn();
    AppLogger.log.i('[LxServer] 获取专辑歌曲: source=$source, id=$id');
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$serverUrl/api/music/albumSongs',
        queryParameters: {'source': source, 'id': id},
        options: _authOptions,
      );
      final data = response.data!;
      final list =
          (data['list'] as List<dynamic>?)
              ?.map((e) => LxServerSong.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      final total = (data['total'] as num?)?.toInt() ?? list.length;
      AppLogger.log.i(
        '[LxServer] 专辑歌曲获取成功: source=$source, id=$id, '
        '返回 ${list.length} 首, 总计 $total 首',
      );
      return (
        list: list,
        total: total,
        name: data['name'] as String?,
        publishTime: data['publishTime'] as String?,
        source: data['source'] as String? ?? source,
      );
    } catch (e, s) {
      AppLogger.reportError(
        e,
        s,
        '[LxServer] 获取专辑歌曲失败: source=$source, id=$id',
      );
      rethrow;
    }
  }

  // ========== 用户收藏 ==========

  /// 获取用户列表数据（默认列表 + 收藏列表 + 用户歌单）
  ///
  /// GET /api/user/list
  Future<LxServerUserListResponse> getUserLists() async {
    await ensureLoggedIn();
    AppLogger.log.i('[LxServer] 获取用户列表');
    final response = await _dio.get<Map<String, dynamic>>(
      '$serverUrl/api/user/list',
      options: _authOptions,
    );
    final data = response.data!;
    final success = data['success'] as bool? ?? true;
    if (!success) {
      throw Exception('获取用户列表失败: ${data['message'] ?? '未知错误'}');
    }
    AppLogger.log.i('[LxServer] 用户列表获取成功');
    return LxServerUserListResponse.fromJson(data);
  }

  /// 获取收藏的歌手列表
  ///
  /// GET /api/user/library/artists
  Future<List<LxServerArtist>> getFavoriteArtists() async {
    await ensureLoggedIn();
    AppLogger.log.i('[LxServer] 获取收藏歌手');
    final response = await _dio.get(
      '$serverUrl/api/user/library/artists',
      options: _authOptions,
    );
    final data = response.data;
    final list = data is List
        ? data
        : (data is Map<String, dynamic>
              ? (data['list'] as List<dynamic>? ?? const [])
              : const []);
    return list
        .map((e) => LxServerArtist.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 获取收藏的专辑列表
  ///
  /// GET /api/user/library/albums
  Future<List<LxServerAlbum>> getFavoriteAlbums() async {
    await ensureLoggedIn();
    AppLogger.log.i('[LxServer] 获取收藏专辑');
    final response = await _dio.get(
      '$serverUrl/api/user/library/albums',
      options: _authOptions,
    );
    final data = response.data;
    final list = data is List
        ? data
        : (data is Map<String, dynamic>
              ? (data['list'] as List<dynamic>? ?? const [])
              : const []);
    return list
        .map((e) => LxServerAlbum.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ========== 歌单 ==========

  /// 获取歌单分类标签
  ///
  /// GET /api/music/songList/tags?source=
  Future<LxServerTagsResponse> getPlaylistTags(String source) async {
    await ensureLoggedIn();
    final response = await _dio.get<Map<String, dynamic>>(
      '$serverUrl/api/music/songList/tags',
      queryParameters: {'source': source},
      options: _authOptions,
    );
    return LxServerTagsResponse.fromJson(response.data!);
  }

  /// 获取指定标签的歌单列表
  ///
  /// GET /api/music/songList/list?source=&tagId=&sortId=&page=
  Future<({List<LxServerPlaylist> list, int total, int limit, int page})>
  getPlaylists({
    required String source,
    String? tagId,
    String? sortId,
    int page = 1,
  }) async {
    await ensureLoggedIn();
    final params = <String, dynamic>{'source': source, 'page': page};
    if (tagId != null) params['tagId'] = tagId;
    if (sortId != null) params['sortId'] = sortId;
    final response = await _dio.get<Map<String, dynamic>>(
      '$serverUrl/api/music/songList/list',
      queryParameters: params,
      options: _authOptions,
    );
    final data = response.data!;
    final list =
        (data['list'] as List<dynamic>?)
            ?.map((e) => LxServerPlaylist.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return (
      list: list,
      total: (data['total'] as num?)?.toInt() ?? 0,
      limit: (data['limit'] as num?)?.toInt() ?? 20,
      page: (data['page'] as num?)?.toInt() ?? page,
    );
  }

  /// 获取歌单详情（歌曲列表）
  ///
  /// GET /api/music/songList/detail?source=&id=&page=
  Future<({List<LxServerSong> list, int limit, int page})> getPlaylistDetail({
    required String source,
    required String id,
    int page = 1,
  }) async {
    await ensureLoggedIn();
    final response = await _dio.get<Map<String, dynamic>>(
      '$serverUrl/api/music/songList/detail',
      queryParameters: {'source': source, 'id': id, 'page': page},
      options: _authOptions,
    );
    final data = response.data!;
    final list =
        (data['list'] as List<dynamic>?)
            ?.map((e) => LxServerSong.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return (
      list: list,
      limit: (data['limit'] as num?)?.toInt() ?? 20,
      page: (data['page'] as num?)?.toInt() ?? page,
    );
  }

  // ========== 排行榜 ==========

  /// 获取排行榜分类列表
  ///
  /// GET /api/music/leaderboard/boards?source=
  Future<List<LxServerLeaderboard>> getLeaderboardBoards(String source) async {
    await ensureLoggedIn();
    AppLogger.log.i('[LxServer] 获取排行榜列表: source=$source');
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$serverUrl/api/music/leaderboard/boards',
        queryParameters: {'source': source},
        options: _authOptions,
      );
      final data = response.data!;
      final list =
          (data['list'] as List<dynamic>?)
              ?.map(
                (e) => LxServerLeaderboard.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [];
      AppLogger.log.i(
        '[LxServer] 排行榜列表获取成功: source=$source, 共 ${list.length} 个榜单',
      );
      return list;
    } catch (e, s) {
      AppLogger.reportError(e, s, '[LxServer] 获取排行榜列表失败: source=$source');
      rethrow;
    }
  }

  /// 获取排行榜歌曲列表
  ///
  /// GET /api/music/leaderboard/list?source=&bangid=&page=
  Future<({List<LxServerSong> list, int total, int limit, int page})>
  getLeaderboardSongs({
    required String source,
    required String bangid,
    int page = 1,
  }) async {
    await ensureLoggedIn();
    AppLogger.log.i(
      '[LxServer] 获取排行榜歌曲: source=$source, bangid=$bangid, page=$page',
    );
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$serverUrl/api/music/leaderboard/list',
        queryParameters: {'source': source, 'bangid': bangid, 'page': page},
        options: _authOptions,
      );
      final data = response.data!;
      final list =
          (data['list'] as List<dynamic>?)
              ?.map((e) => LxServerSong.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      final total = (data['total'] as num?)?.toInt() ?? 0;
      final limit = (data['limit'] as num?)?.toInt() ?? 100;
      final respPage = (data['page'] as num?)?.toInt() ?? page;
      AppLogger.log.i(
        '[LxServer] 排行榜歌曲获取成功: source=$source, bangid=$bangid, '
        '返回 ${list.length} 首, 总计 $total 首',
      );
      return (list: list, total: total, limit: limit, page: respPage);
    } catch (e, s) {
      AppLogger.reportError(
        e,
        s,
        '[LxServer] 获取排行榜歌曲失败: source=$source, bangid=$bangid, page=$page',
      );
      rethrow;
    }
  }

  // ========== 播放链接 ==========

  /// 获取音乐播放直链
  ///
  /// POST /api/music/url
  /// [songInfo] 完整歌曲信息（含 source、hash、songmid、_types 及各平台特有字段），
  ///            服务端 normalizeSongInfo 会根据 source 选取所需字段。
  /// [quality] 质量标识，如 '128k'、'320k'、'flac'。
  /// [filename] 代理播放时使用的文件名（如 "歌名 - 歌手.mp3"）。
  ///
  /// 请求流程：
  /// 1. 生成随机 x-req-id，附加到请求头
  /// 2. 发起 POST /api/music/url 获取播放链接
  /// 3. 同时（非阻塞）调用 /api/music/progress?reqId=<> 通过 SSE 接收解析进度
  /// 4. 若 [proxyPlayback] 为 true，将返回的 URL 包装为代理下载 URL
  Future<String> getMusicUrl({
    required Map<String, dynamic> songInfo,
    String quality = '128k',
    String? filename,
  }) async {
    await ensureLoggedIn();
    final source = songInfo['source'] as String? ?? '';
    final typesMap = songInfo['_types'] as Map<String, dynamic>? ?? const {};

    // 生成随机 reqId 用于关联 SSE 进度流
    final reqId = _generateReqId();

    AppLogger.log.i(
      '[LxServer] 获取播放链接: source=$source, quality=$quality, '
      '可用质量=${typesMap.keys.toList()}, reqId=$reqId',
    );

    // 启动 SSE 进度监听（不阻塞主请求）
    _listenProgress(reqId, (attempt) {
      final songNamePrefix = attempt.name ?? songInfo['name'] as String? ?? '';
      final message =
          attempt.message ?? (attempt.status == 'success' ? '解析成功' : '解析失败');
      final msg = '[$songNamePrefix] $message';
      if (attempt.status == 'success') {
        AppToast().success(msg);
      } else {
        AppToast().error(msg);
      }
    });
    // [Fix] 给予 SSE 连接极短的建连时间，确保并发请求下后端能优先捕获到 SSE 客户端
    Future.delayed(const Duration(milliseconds: 100));

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$serverUrl/api/music/url',
        data: {
          'songInfo': songInfo, 'quality': quality,
          'enableAutoSwitchApiSource': true, // 开启自动换源
        },
        options: _authOptions.copyWith(
          contentType: Headers.jsonContentType,
          headers: {
            'x-user-name': username,
            'x-user-token': token ?? '',
            'x-req-id': reqId,
          },
        ),
      );
      final data = response.data!;
      final url = data['url'] as String?;
      if (url == null || url.isEmpty) {
        final msg = data['message'] ?? '服务器未返回有效 URL';
        throw Exception('获取播放链接失败: $msg');
      }
      AppLogger.log.i(
        '[LxServer] 获取播放链接成功: source=$source, quality=$quality, url=$url',
      );

      // 代理播放：将原始 URL 包装为 /api/music/download
      if (proxyPlayback) {
        final proxyUrl = _buildProxyDownloadUrl(url, filename);
        AppLogger.log.i(
          '[LxServer] 代理播放已启用: filename=$filename, proxyUrl=${proxyUrl.length > 100 ? '${proxyUrl.substring(0, 100)}...' : proxyUrl}',
        );
        return proxyUrl;
      }
      return url;
    } catch (e, s) {
      AppLogger.reportError(
        e,
        s,
        '[LxServer] 获取播放链接异常: source=$source, quality=$quality, songInfo=$songInfo, '
        '异常=$e',
      );
      rethrow;
    }
  }

  /// 生成随机 reqId（16 位十六进制）
  String _generateReqId() {
    final random = DateTime.now().microsecondsSinceEpoch;
    final salt = random.toRadixString(16).padLeft(8, '0');
    final randomPart = (random ^ (random << 13))
        .toUnsigned(64)
        .toRadixString(16)
        .padLeft(8, '0');
    return '$salt$randomPart'.substring(0, 16);
  }

  /// 通过 SSE 监听解析进度
  ///
  /// GET /api/music/progress?reqId=<>，使用 text/event-stream 协议。
  /// 收到事件时，若 message 不为空则通过 Toast 提示。
  Future<void> _listenProgress(
    String reqId,
    Function(LxServerProgressEvent event) onMessage,
  ) async {
    try {
      final response = await _dio.get<ResponseBody>(
        '$serverUrl/api/music/progress',
        queryParameters: {'reqId': reqId},
        options: Options(
          headers: {'x-user-name': username, 'x-user-token': token ?? ''},
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data!.stream;
      final buffer = StringBuffer();

      await for (final chunk in stream) {
        buffer.write(utf8.decode(chunk));
        // SSE 事件以空行分隔
        while (true) {
          final raw = buffer.toString();
          final sepIndex = raw.indexOf('\n\n');
          if (sepIndex < 0) break;
          final eventBlock = raw.substring(0, sepIndex);
          buffer.clear();
          // 保留分隔符之后的内容
          if (sepIndex + 2 < raw.length) {
            buffer.write(raw.substring(sepIndex + 2));
          }
          _handleSseEvent(eventBlock, onMessage);
        }
      }
    } catch (e, s) {
      // SSE 进度是辅助提示，失败不影响主流程
      AppLogger.reportError(e, s, '[LxServer] SSE 进度监听异常（可忽略）: $e');
    }
  }

  /// 解析单个 SSE 事件块
  void _handleSseEvent(
    String eventBlock,
    Function(LxServerProgressEvent event) onMessage,
  ) {
    String? dataLine;
    for (final line in eventBlock.split('\n')) {
      if (line.startsWith('data:')) {
        dataLine = line.substring(5).trim();
      }
    }
    if (dataLine == null || dataLine.isEmpty) return;
    try {
      final json = jsonDecode(dataLine) as Map<String, dynamic>;
      final event = LxServerProgressEvent.fromJson(json);
      onMessage(event);
    } catch (e, s) {
      AppLogger.reportError(
        e,
        s,
        '[LxServer] SSE 事件 JSON 解析失败: $e, raw=$dataLine',
      );
    }
  }

  /// 构造代理播放下载 URL
  ///
  /// GET /api/music/download?url=<播放链接>&filename=<歌名 - 歌手.mp3>&inline=1
  String _buildProxyDownloadUrl(String originalUrl, String? filename) {
    final params = <String, String>{
      'url': originalUrl,
      if (filename != null && filename.isNotEmpty) 'filename': filename,
      'inline': '1',
    };
    final query = params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
    return '$serverUrl/api/music/download?$query';
  }

  // ========== 歌词 ==========

  /// 获取歌词
  ///
  /// POST /api/music/lyric
  /// [songInfo] 完整歌曲信息，服务端根据 source 选取所需字段。
  /// 返回 LRC 格式歌词文本，无歌词返回 null。
  Future<String?> getLyric({required Map<String, dynamic> songInfo}) async {
    await ensureLoggedIn();
    final source = songInfo['source'] as String? ?? '';
    AppLogger.log.d('[LxServer] 获取歌词: source=$source, songInfo=$songInfo');
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$serverUrl/api/music/lyric',
        queryParameters: songInfo,
        options: _authOptions,
      );
      final data = response.data!;
      final lyric = data['lyric'] as String?;
      if (lyric == null || lyric.isEmpty) {
        AppLogger.log.d(
          '[LxServer] 获取歌词为空: source=$source, songInfo=$songInfo',
        );
        return null;
      }
      AppLogger.log.d('[LxServer] 获取歌词成功: source=$source, songInfo=$songInfo');
      return lyric;
    } catch (e, s) {
      AppLogger.reportError(
        e,
        s,
        '[LxServer] 获取歌词异常: source=$source, songInfo=$songInfo',
      );
      return null;
    }
  }

  // ========== 服务器状态 ==========

  /// 获取服务器状态（测试连接）
  Future<bool> ping() async {
    try {
      await _dio.get<Map<String, dynamic>>(
        '$serverUrl/api/status',
        options: Options(responseType: ResponseType.json),
      );
      return true;
    } catch (e, s) {
      AppLogger.reportError(e, s, '[LxServer] 服务器连接失败: $e');
      return false;
    }
  }

  /// 释放资源
  void dispose() {
    _dio.close();
  }

  /// 将配置序列化为 JSON（用于持久化）
  Map<String, dynamic> toJson() => {
    'serverUrl': serverUrl,
    'username': username,
    'password': password,
    'token': token,
    'proxyPlayback': proxyPlayback,
  };

  /// 从 JSON 反序列化
  static LxServerClient fromJson(Map<String, dynamic> json) {
    return LxServerClient(
      serverUrl: json['serverUrl'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      token: json['token'] as String?,
      proxyPlayback: json['proxyPlayback'] as bool? ?? false,
    );
  }

  /// 从 JSON 字符串解析配置（不含 client 实例）
  static Map<String, dynamic>? parseConfig(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(json) as Map);
    } catch (_) {
      return null;
    }
  }
}
