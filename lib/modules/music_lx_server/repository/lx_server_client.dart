import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pomelo/core/log.dart';

import 'lx_server_models.dart';

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

  final Dio _dio;

  LxServerClient({
    required this.serverUrl,
    required this.username,
    required this.password,
    this.token,
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
    log.info('LxServer', '登录成功: $username');
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
      log.warning('LxServer', 'Token 验证失败: $e');
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
    log.info('LxServer', '获取排行榜列表: source=$source');
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
      log.info('LxServer', '排行榜列表获取成功: source=$source, 共 ${list.length} 个榜单');
      return list;
    } catch (e, s) {
      log.error(
        'LxServer',
        '获取排行榜列表失败: source=$source',
        error: e,
        stackTrace: s,
      );
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
    log.info('LxServer', '获取排行榜歌曲: source=$source, bangid=$bangid, page=$page');
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
      log.info(
        'LxServer',
        '排行榜歌曲获取成功: source=$source, bangid=$bangid, '
            '返回 ${list.length} 首, 总计 $total 首',
      );
      return (list: list, total: total, limit: limit, page: respPage);
    } catch (e, s) {
      log.error(
        'LxServer',
        '获取排行榜歌曲失败: source=$source, bangid=$bangid, page=$page',
        error: e,
        stackTrace: s,
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
  Future<String> getMusicUrl({
    required Map<String, dynamic> songInfo,
    String quality = '128k',
  }) async {
    await ensureLoggedIn();
    final source = songInfo['source'] as String? ?? '';
    final hash = songInfo['hash'] as String? ?? '';
    final typesMap = songInfo['_types'] as Map<String, dynamic>? ?? const {};
    log.info(
      'LxServer',
      '获取播放链接: source=$source, hash=$hash, quality=$quality, '
          '可用质量=${typesMap.keys.toList()}',
    );
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$serverUrl/api/music/url',
        data: {
          'songInfo': songInfo,
          'quality': quality,
        },
        options: _authOptions.copyWith(contentType: Headers.jsonContentType),
      );
      final data = response.data!;
      final url = data['url'] as String?;
      if (url == null || url.isEmpty) {
        final msg = data['message'] ?? '服务器未返回有效 URL';
        log.error(
          'LxServer',
          '获取播放链接失败: source=$source, hash=$hash, quality=$quality, '
              '原因=$msg',
        );
        throw Exception('获取播放链接失败: $msg');
      }
      log.info(
        'LxServer',
        '获取播放链接成功: source=$source, hash=$hash, quality=$quality, '
            'url=${url.length > 80 ? '${url.substring(0, 80)}...' : url}',
      );
      return url;
    } catch (e, s) {
      // 已记录过日志的 Exception 直接 rethrow
      if (e is Exception && e.toString().startsWith('Exception: 获取播放链接失败')) {
        rethrow;
      }
      log.error(
        'LxServer',
        '获取播放链接异常: source=$source, hash=$hash, quality=$quality',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  // ========== 歌词 ==========

  /// 获取歌词
  ///
  /// POST /api/music/lyric
  /// [songInfo] 完整歌曲信息，服务端根据 source 选取所需字段。
  /// 返回 LRC 格式歌词文本，无歌词返回 null。
  Future<String?> getLyric({
    required Map<String, dynamic> songInfo,
  }) async {
    await ensureLoggedIn();
    final source = songInfo['source'] as String? ?? '';
    final hash = songInfo['hash'] as String? ?? '';
    log.debug('LxServer', '获取歌词: source=$source, hash=$hash');
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$serverUrl/api/music/lyric',
        data: {'songInfo': songInfo},
        options: _authOptions.copyWith(contentType: Headers.jsonContentType),
      );
      final data = response.data!;
      final lyric = data['lyric'] as String?;
      if (lyric == null || lyric.isEmpty) {
        log.debug('LxServer', '获取歌词为空: source=$source, hash=$hash');
        return null;
      }
      log.debug('LxServer', '获取歌词成功: source=$source, hash=$hash');
      return lyric;
    } catch (e, s) {
      log.error(
        'LxServer',
        '获取歌词异常: source=$source, hash=$hash',
        error: e,
        stackTrace: s,
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
    } catch (e) {
      log.warning('LxServer', '服务器连接失败: $e');
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
  };

  /// 从 JSON 反序列化
  static LxServerClient fromJson(Map<String, dynamic> json) {
    return LxServerClient(
      serverUrl: json['serverUrl'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      token: json['token'] as String?,
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
