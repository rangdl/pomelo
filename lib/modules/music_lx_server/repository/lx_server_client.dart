import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pomelo/core/log.dart';
import 'package:pomelo/core/toast.dart';

import 'lx_server_models.dart';

/// SSE 进度事件
///
/// 由 `/api/music/progress` 端点以 Server-Sent Events 协议返回。
class LxServerProgressEvent {
  /// 来源名称（一般为音源标识）
  final String name;

  /// 状态：'success' | 'fail' | 其他
  final String status;

  /// 详细信息（不为空时应该用 Toast 提示用户）
  final String message;

  const LxServerProgressEvent({
    required this.name,
    required this.status,
    required this.message,
  });

  factory LxServerProgressEvent.fromJson(Map<String, dynamic> json) {
    return LxServerProgressEvent(
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
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
    log.info('LxServer', '搜索: source=$source, keyword=$keyword, page=$page');
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
      log.info(
        'LxServer',
        '搜索成功: source=$source, keyword=$keyword, '
            '返回 ${list.length} 首, 总计 $total 首',
      );
      return (list: list, total: total, limit: respLimit, page: respPage);
    } catch (e, s) {
      log.error(
        'LxServer',
        '搜索失败: source=$source, keyword=$keyword, page=$page',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
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

    log.info(
      'LxServer',
      '获取播放链接: source=$source, quality=$quality, '
          '可用质量=${typesMap.keys.toList()}, reqId=$reqId',
    );

    // 启动 SSE 进度监听（不阻塞主请求）
    final progressFuture = _listenProgress(reqId);

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$serverUrl/api/music/url',
        data: {'songInfo': songInfo, 'quality': quality},
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
        log.error(
          'LxServer',
          '获取播放链接失败: source=$source, quality=$quality, '
              '原因=$msg',
        );
        throw Exception('获取播放链接失败: $msg');
      }
      log.info(
        'LxServer',
        '获取播放链接成功: source=$source, quality=$quality, url=$url',
      );

      // 等待 SSE 流结束（进度已通过 Toast 实时提示）
      // 添加 3 秒超时，避免服务器未正确关闭 SSE 流时阻塞播放
      try {
        await progressFuture.timeout(const Duration(seconds: 3));
      } catch (_) {
        // 超时或异常都不影响主流程
      }

      // 代理播放：将原始 URL 包装为 /api/music/download
      if (proxyPlayback) {
        final proxyUrl = _buildProxyDownloadUrl(url, filename);
        log.info(
          'LxServer',
          '代理播放已启用: filename=$filename, proxyUrl=${proxyUrl.length > 100 ? '${proxyUrl.substring(0, 100)}...' : proxyUrl}',
        );
        return proxyUrl;
      }
      return url;
    } catch (e, s) {
      // 已记录过日志的 Exception 直接 rethrow
      if (e is Exception && e.toString().startsWith('Exception: 获取播放链接失败')) {
        rethrow;
      }
      log.error(
        'LxServer',
        '获取播放链接异常: source=$source, quality=$quality, songInfo=$songInfo, '
            '异常=$e',
        error: e,
        stackTrace: s,
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
  Future<void> _listenProgress(String reqId) async {
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
          _handleSseEvent(eventBlock);
        }
      }
    } catch (e) {
      // SSE 进度是辅助提示，失败不影响主流程
      log.debug('LxServer', 'SSE 进度监听异常（可忽略）: $e');
    }
  }

  /// 解析单个 SSE 事件块
  void _handleSseEvent(String eventBlock) {
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
      log.debug(
        'LxServer',
        'SSE 进度事件: name=${event.name}, status=${event.status}, '
            'message=${event.message}',
      );
      // message 不为空时通过 Toast 提示
      if (event.message.isNotEmpty) {
        if (event.isFail) {
          AppToast().error(event.message);
        } else if (event.isSuccess) {
          AppToast().success(event.message);
        } else {
          AppToast().info(event.message);
        }
      } else {
        if (event.isSuccess) {
          AppToast().info('${event.name} 解析成功');
        }
      }
    } catch (e) {
      log.debug('LxServer', 'SSE 事件 JSON 解析失败: $e, raw=$dataLine');
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
    log.debug('LxServer', '获取歌词: source=$source, songInfo=$songInfo');
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$serverUrl/api/music/lyric',
        queryParameters: songInfo,
        options: _authOptions,
      );
      final data = response.data!;
      final lyric = data['lyric'] as String?;
      if (lyric == null || lyric.isEmpty) {
        log.debug('LxServer', '获取歌词为空: source=$source, songInfo=$songInfo');
        return null;
      }
      log.debug('LxServer', '获取歌词成功: source=$source, songInfo=$songInfo');
      return lyric;
    } catch (e, s) {
      log.error(
        'LxServer',
        '获取歌词异常: source=$source, songInfo=$songInfo',
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
