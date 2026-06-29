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
  /// 流程：
  /// 1. 命中 provider 已缓存的有效链接 → 直接返回
  /// 2. 从用户偏好音质开始向下逐个尝试：获取链接 → HEAD 校验
  /// 3. 全部失败则回退到 `track.src` / `track.path` 并 HEAD 校验
  /// 4. 仍失败抛出 `无法获取有效的播放链接`
  ///
  /// HEAD 校验与音质降级重试在本方法中完成，[SourcedTrackNotifier] 仅负责
  /// 提供 URL 解析能力（[SourcedTrackNotifier.getUrlForQuality] 等）。
  /// 若 provider 不可用（container 未注入），回退到 `track.src` / `track.path`。
  Future<String> _resolveValidUrl(Track track) async {
    final container = getContainer();
    if (container == null) return track.src ?? track.path ?? '';
    final notifier = container.read(sourcedTrackProvider(track).notifier);

    // 命中缓存直接返回
    final cached = container.read(sourcedTrackProvider(track)).url;
    if (cached != null && cached.isNotEmpty) return cached;

    final downgradeList = notifier.downgradeList;
    log.info('Playback', '解析开始: track=${track.title}, 降级序列=$downgradeList');

    for (final quality in downgradeList) {
      try {
        final url = await notifier.getUrlForQuality(quality);
        if (url.isEmpty) {
          log.warning('Playback', '获取链接为空 quality=$quality');
          continue;
        }
        if (await _headValidate(url)) {
          notifier.cacheUrl(url, quality);
          log.info('Playback', '解析成功: quality=$quality, track=${track.title}');
          return url;
        }
        log.warning('Playback', 'HEAD 失败 quality=$quality, url=$url');
      } catch (e) {
        log.warning('Playback', '获取链接失败 quality=$quality: $e');
      }
    }

    // 所有音质路径均失败，最后回退到 track.src / track.path
    final fallback = notifier.fallbackUrl;
    if (fallback.isNotEmpty && await _headValidate(fallback)) {
      notifier.cacheUrl(fallback, null);
      log.info('Playback', '回退成功: src/path, track=${track.title}');
      return fallback;
    }

    log.error('Playback', '所有音质均无法获取有效播放链接: ${track.title}');
    throw Exception('无法获取有效的播放链接');
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
  ) async {
    log.debug(
      'Playback',
      'HEAD request for track: ${track.title}, Headers: ${request.headers}',
    );

    // _resolveValidUrl 已完成 HEAD 校验与音质降级，这里再做一次 HEAD
    // 以获取最新的响应头（content-length、content-type、accept-ranges 等）
    final url = await _resolveValidUrl(track);
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
  ) async {
    log.debug(
      'Playback',
      'GET request for track: ${track.title}, Headers: ${request.headers}',
    );

    final url = await _resolveValidUrl(track);

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
      final res = await streamTrackInformation(request, activeTrack);

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
      final res = await streamTrack(request, activeTrack, request.headers);

      if (res.data is ResponseBody) {
        final responseBody = res.data as ResponseBody;
        final sanitizedHeaders = _sanitizeHeaders(res.headers.map);

        // 缓存音频流到文件（异步，不阻塞响应）
        final cachedStream = await _teeStreamToCache(
          responseBody.stream,
          activeTrack,
          sanitizedHeaders,
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

  /// 将流同时写入缓存文件（tee 模式）
  ///
  /// 先创建缓存文件，再返回一个同时向文件和下游传递数据的 Stream。
  /// 写入失败不影响播放，仅记录日志。
  Future<Stream<List<int>>> _teeStreamToCache(
    Stream<Uint8List> source,
    Track track,
    Map<String, List<String>> headers,
  ) async {
    // 推断文件扩展名
    final contentType = headers['content-type']?.first;
    final extension = track.src != null
        ? MusicCacheDir.extensionFromUrl(track.src!)
        : MusicCacheDir.extensionFromContentType(contentType);

    // 预先创建缓存文件
    IOSink? cacheSink;
    try {
      final file = await MusicCacheDir.getCacheFile(track.id, extension);
      cacheSink = file.openWrite();
      log.debug('Playback', '缓存写入开始: ${file.path}');
    } catch (e) {
      log.warning('Playback', '缓存文件创建失败: $e');
    }

    // tee 流：每块数据同时写入文件和传递给下游
    return source.transform(
      StreamTransformer<Uint8List, List<int>>.fromHandlers(
        handleData: (chunk, sink) {
          cacheSink?.add(chunk);
          sink.add(chunk);
        },
        handleDone: (sink) {
          cacheSink
              ?.close()
              .then((_) {
                log.debug('Playback', '缓存写入完成: track=${track.title}');
              })
              .catchError((e) {
                log.warning('Playback', '缓存文件关闭失败: $e');
              });
          sink.close();
        },
        handleError: (error, stack, sink) {
          cacheSink?.close().catchError((e) {});
          sink.addError(error, stack);
        },
      ),
    );
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
