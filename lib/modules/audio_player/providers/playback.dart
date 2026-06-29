import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart' hide Response;
import 'package:dio/dio.dart' as dio_lib;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/log.dart';
import 'package:pomelo/core/storage/music_cache_dir.dart';
import 'package:pomelo/modules/audio_player/providers/sourced_track.dart';
import 'package:pomelo/modules/audio_player/service/audio_player_service.dart';
import 'package:pomelo/core/models/metadata/track.dart';
import 'package:shelf/shelf.dart';

class ServerPlaybackRoutes {
  final AudioPlayerService audioPlayer;
  final Dio dio;

  /// 获取当前活跃曲目（由外部注入，避免对 Riverpod Ref 的依赖）
  final Track? Function() getActiveTrack;

  /// 获取 Riverpod ProviderContainer（由外部注入）
  ///
  /// 用于访问 [sourcedTrackProvider]，将 URL 解析责任委托给 provider。
  /// HEAD 校验与音质降级重试由本类负责。
  final ProviderContainer? Function() getContainer;

  ServerPlaybackRoutes({
    required this.audioPlayer,
    required this.getActiveTrack,
    required this.getContainer,
  }) : dio = Dio();

  /// Hop-by-hop 头部集合
  ///
  /// 这些头部属于传输层，不应原样转发给 shelf。
  /// 尤其 `transfer-encoding`：Dio/dart:io 已在传输层解码 chunked，
  /// body 为原始字节；shelf 看到该头会再次尝试解码导致 FormatException。
  static const _hopByHopHeaders = {
    'transfer-encoding',
    'content-length',
    'connection',
    'keep-alive',
    'proxy-authenticate',
    'proxy-authorization',
    'te',
    'trailer',
    'upgrade',
  };

  /// 过滤 hop-by-hop 头部，由 shelf/dart:io 自行决定分块方式
  Map<String, List<String>> _sanitizeHeaders(
    Map<String, List<String>> headers,
  ) {
    return Map.fromEntries(
      headers.entries.where(
        (e) => !_hopByHopHeaders.contains(e.key.toLowerCase()),
      ),
    );
  }

  /// 解析并 HEAD 校验播放链接
  ///
  /// 流程（优先级从高到低）：
  /// 1. 命中 provider 内存缓存 → 直接返回（可能是 URL 或本地文件路径）
  /// 2. 持久化的本地缓存文件（按降级序列匹配首个存在的文件）→ 返回文件路径
  /// 3. 持久化的播放链接 + HEAD 校验 → 返回 URL
  /// 4. 重新获取链接（按降级序列逐个 getUrlForQuality + HEAD 校验）+ 持久化 URL
  /// 5. 回退到 `track.src` / `track.path` + HEAD 校验
  /// 6. 仍失败抛出 `无法获取有效的播放链接`
  ///
  /// 返回值可能是 HTTP(S) URL，也可能是本地文件绝对路径，调用方需通过
  /// [_isLocalPath] 判断后再决定使用 [dio] 请求或 [File] 读取。
  Future<String> _resolveValidUrl(Track track) async {
    final container = getContainer();
    if (container == null) return track.src ?? track.path ?? '';
    final notifier = container.read(sourcedTrackProvider(track).notifier);

    // 1. 命中内存缓存直接返回
    final cached = container.read(sourcedTrackProvider(track)).url;
    if (cached != null && cached.isNotEmpty) return cached;

    final downgradeList = notifier.downgradeList;
    log.info('Playback', '解析开始: track=${track.title}, 降级序列=$downgradeList');

    // 2. 优先使用持久化的本地缓存文件
    try {
      final cachedFile = await notifier.findCachedFile(downgradeList);
      if (cachedFile != null) {
        notifier.cacheUrl(cachedFile.path, cachedFile.quality);
        log.info(
          'Playback',
          '命中本地缓存文件: quality=${cachedFile.quality}, track=${track.title}',
        );
        return cachedFile.path;
      }
    } catch (e) {
      log.warning('Playback', '查找本地缓存文件失败: $e');
    }

    // 3. 次选持久化的播放链接（需 HEAD 校验）
    try {
      final cachedUrl = await notifier.findCachedUrl(downgradeList);
      if (cachedUrl != null) {
        if (await _headValidate(cachedUrl.url)) {
          notifier.cacheUrl(cachedUrl.url, cachedUrl.quality);
          log.info(
            'Playback',
            '命中缓存URL: quality=${cachedUrl.quality}, track=${track.title}',
          );
          return cachedUrl.url;
        } else {
          log.warning(
            'Playback',
            '缓存URL失效: quality=${cachedUrl.quality}, url=${cachedUrl.url}',
          );
        }
      }
    } catch (e) {
      log.warning('Playback', '查找缓存URL失败: $e');
    }

    // 4. 全部未命中或 URL 失效，重新获取播放链接
    for (final quality in downgradeList) {
      try {
        final url = await notifier.getUrlForQuality(quality);
        if (url.isEmpty) {
          log.warning('Playback', '获取链接为空 quality=$quality');
          continue;
        }
        if (await _headValidate(url)) {
          notifier.cacheUrl(url, quality);
          // 持久化 URL，便于下次直接命中
          await notifier.saveUrlToPersistence(quality, url);
          log.info('Playback', '解析成功: quality=$quality, track=${track.title}');
          return url;
        }
        log.warning('Playback', 'HEAD 失败 quality=$quality, url=$url');
      } catch (e) {
        log.warning('Playback', '获取链接失败 quality=$quality: $e');
      }
    }

    // 5. 所有音质路径均失败，最后回退到 track.src / track.path
    final fallback = notifier.fallbackUrl;
    if (fallback.isNotEmpty && await _headValidate(fallback)) {
      notifier.cacheUrl(fallback, null);
      log.info('Playback', '回退成功: src/path, track=${track.title}');
      return fallback;
    }

    log.error('Playback', '所有音质均无法获取有效播放链接: ${track.title}');
    throw Exception('无法获取有效的播放链接');
  }

  /// 判断字符串是否为本地文件路径（而非 HTTP(S) URL）
  bool _isLocalPath(String s) {
    final lower = s.toLowerCase();
    return !lower.startsWith('http://') && !lower.startsWith('https://');
  }

  /// HEAD 校验
  ///
  /// 返回 true 表示链接有效（2xx/3xx），false 表示无效或异常。
  Future<bool> _headValidate(String url) async {
    try {
      final options = Options(
        headers: {
          'Cache-Control': 'max-age=3600',
          'Connection': 'keep-alive',
          'host': Uri.parse(url).host,
        },
        validateStatus: (status) => true,
      );
      final res = await dio.head(url, options: options);
      return res.statusCode != null && res.statusCode! < 400;
    } catch (e) {
      log.warning('Playback', 'HEAD 异常 url=$url: $e');
      return false;
    }
  }

  Future<dio_lib.Response> streamTrackInformation(
    Request request,
    Track track,
    String url,
  ) async {
    log.debug(
      'Playback',
      'HEAD request for track: ${track.title}, Headers: ${request.headers}',
    );

    // _resolveValidUrl 已完成 HEAD 校验与音质降级，这里再做一次 HEAD
    // 以获取最新的响应头（content-length、content-type、accept-ranges 等）
    final options = Options(
      headers: {
        'Cache-Control': 'max-age=3600',
        'Connection': 'keep-alive',
        'host': Uri.parse(url).host,
      },
      validateStatus: (status) => true,
    );
    return dio.head(url, options: options);
  }

  Future<dio_lib.Response> streamTrack(
    Request request,
    Track track,
    Map<String, dynamic> headers,
    String url,
  ) async {
    log.debug(
      'Playback',
      'GET request for track: ${track.title}, Headers: ${request.headers}',
    );

    final options = Options(
      headers: {
        ...headers,
        'Cache-Control': 'max-age=3600',
        'Connection': 'keep-alive',
        'host': Uri.parse(url).host,
      },
      responseType: ResponseType.stream,
      validateStatus: (status) => status! < 400,
    );

    final res = await dio.get<ResponseBody>(url, options: options);

    log.debug(
      'Playback',
      'Response for track: ${track.title}, '
          'Status: ${res.statusCode}, Headers: ${res.headers.map}',
    );

    return res;
  }

  /// @head('/stream/<trackId>')
  Future<Response> headStreamTrackId(Request request, String trackId) async {
    try {
      final activeTrack = getActiveTrack();
      if (activeTrack == null || activeTrack.src == null) {
        return Response.notFound('No active track or track is not streamable');
      }
      final url = await _resolveValidUrl(activeTrack);

      // 本地缓存文件：直接返回文件元信息
      if (_isLocalPath(url)) {
        final file = File(url);
        if (!await file.exists()) {
          return Response.notFound('Cache file not found');
        }
        final stat = await file.stat();
        final extension = MusicCacheDir.extensionFromUrl(url);
        return Response(
          200,
          headers: {
            'content-type': [MusicCacheDir.contentTypeFromExtension(extension)],
            'content-length': [stat.size.toString()],
            'accept-ranges': ['bytes'],
          },
        );
      }

      final res = await streamTrackInformation(request, activeTrack, url);

      return Response(
        res.statusCode!,
        headers: _sanitizeHeaders(res.headers.map),
      );
    } on Exception catch (e) {
      // 降级穷尽等业务异常，返回明确的错误信息
      log.error('Playback', e.toString(), error: e);
      return Response.internalServerError(body: e.toString());
    } catch (e, stack) {
      log.error('Playback', e.toString(), error: e, stackTrace: stack);
      return Response.internalServerError();
    }
  }

  /// @get('/stream/<trackId>')
  Future<Response> getStreamTrackId(Request request, String trackId) async {
    try {
      final activeTrack = getActiveTrack();
      if (activeTrack == null || activeTrack.src == null) {
        return Response.notFound('No active track or track is not streamable');
      }
      final url = await _resolveValidUrl(activeTrack);

      // 本地缓存文件：直接以文件流响应（无需再次缓存）
      if (_isLocalPath(url)) {
        final file = File(url);
        if (!await file.exists()) {
          return Response.notFound('Cache file not found');
        }
        final stat = await file.stat();
        final extension = MusicCacheDir.extensionFromUrl(url);
        return Response(
          200,
          body: file.openRead(),
          headers: {
            'content-type': [MusicCacheDir.contentTypeFromExtension(extension)],
            'content-length': [stat.size.toString()],
            'accept-ranges': ['bytes'],
          },
        );
      }

      final res = await streamTrack(request, activeTrack, request.headers, url);

      if (res.data is ResponseBody) {
        final responseBody = res.data as ResponseBody;
        final sanitizedHeaders = _sanitizeHeaders(res.headers.map);

        // 读取当前解析命中的音质（用于持久化缓存路径）
        final container = getContainer();
        final quality = container
            ?.read(sourcedTrackProvider(activeTrack))
            .quality;

        // 缓存音频流到文件（异步，不阻塞响应）
        final cachedStream = await _teeStreamToCache(
          responseBody.stream,
          activeTrack,
          sanitizedHeaders,
          quality: quality,
        );

        return Response(
          res.statusCode!,
          body: cachedStream,
          headers: sanitizedHeaders,
        );
      }

      return Response(
        res.statusCode!,
        body: res.data,
        headers: _sanitizeHeaders(res.headers.map),
      );
    } catch (e, stack) {
      log.error('Playback', e.toString(), error: e, stackTrace: stack);
      return Response.internalServerError();
    }
  }

  /// 将流缓存到文件（流完成后写入）
  ///
  /// 在流传输过程中将数据同时传递给下游（不阻塞播放），
  /// 并在内存中缓冲所有数据。流完成后将完整缓冲写入缓存文件，
  /// 并将缓存路径持久化到数据库（关联 [quality]）。
  /// 写入失败不影响播放，仅记录日志。
  Future<Stream<List<int>>> _teeStreamToCache(
    Stream<Uint8List> source,
    Track track,
    Map<String, List<String>> headers, {
    String? quality,
  }) async {
    // 推断文件扩展名
    final contentType = headers['content-type']?.first;
    final extension = track.src != null
        ? MusicCacheDir.extensionFromUrl(track.src!)
        : MusicCacheDir.extensionFromContentType(contentType);

    // 内存缓冲：流完成后写入文件
    final buffer = <int>[];

    return source.transform(
      StreamTransformer<Uint8List, List<int>>.fromHandlers(
        handleData: (chunk, sink) {
          buffer.addAll(chunk);
          sink.add(chunk);
        },
        handleDone: (sink) {
          sink.close();
          // 流完成后写入缓存文件
          _writeBufferToCache(buffer, track, extension, quality: quality);
        },
        handleError: (error, stack, sink) {
          sink.addError(error, stack);
        },
      ),
    );
  }

  /// 将内存缓冲写入缓存文件，并将路径持久化到数据库
  Future<void> _writeBufferToCache(
    List<int> buffer,
    Track track,
    String extension, {
    String? quality,
  }) async {
    try {
      final file = await MusicCacheDir.getCacheFile(track.id, extension);
      await file.writeAsBytes(buffer);
      log.debug(
        'Playback',
        '缓存写入完成: track=${track.title}, ${buffer.length} bytes → ${file.path}',
      );

      // 持久化缓存文件路径（需有音质信息）
      if (quality != null) {
        final container = getContainer();
        if (container != null) {
          final notifier = container.read(sourcedTrackProvider(track).notifier);
          await notifier.saveCachePathToPersistence(quality, file.path);
        }
      }

      // 写入完成后按缓存上限清理旧文件
      await MusicCacheDir.enforceLimit();
    } catch (e) {
      log.warning('Playback', '缓存文件写入失败: $e');
    }
  }

  /// @get('/playback/toggle-playback')
  Future<Response> togglePlayback(Request request) async {
    if (audioPlayer.isPlaying) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.resume();
    }
    return Response.ok('Playback toggled');
  }

  /// @get('/playback/previous')
  Future<Response> previousTrack(Request request) async {
    await audioPlayer.skipToPrevious();
    return Response.ok('Previous track');
  }

  /// @get('/playback/next')
  Future<Response> nextTrack(Request request) async {
    await audioPlayer.skipToNext();
    return Response.ok('Next track');
  }
}
