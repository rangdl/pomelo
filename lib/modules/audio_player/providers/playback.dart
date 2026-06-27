import 'dart:async';

import 'package:dio/dio.dart' hide Response;
import 'package:dio/dio.dart' as dio_lib;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/log.dart';
import 'package:pomelo/modules/audio_player/providers/track_url_resolver.dart';
import 'package:pomelo/modules/audio_player/service/audio_player_service.dart';
import 'package:pomelo/modules/music/model/track.dart';
import 'package:shelf/shelf.dart';

class ServerPlaybackRoutes {
  final AudioPlayerService audioPlayer;
  final Dio dio;

  /// 获取当前活跃曲目（由外部注入，避免对 Riverpod Ref 的依赖）
  final Track? Function() getActiveTrack;

  /// 获取 Riverpod ProviderContainer（由外部注入）
  ///
  /// 用于访问 [trackUrlResolverProvider]，将 URL 解析、HEAD 校验和音质降级
  /// 的责任完全委托给 provider。
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

  /// 通过 provider 解析得到已校验的播放链接
  ///
  /// 委托给 [trackUrlResolverProvider] 完成解析、HEAD 校验、音质降级。
  /// 若 provider 不可用（container 未注入），回退到 `track.src` / `track.path`。
  Future<String> _resolveValidUrl(Track track) async {
    final container = getContainer();
    if (container == null) return track.src ?? track.path ?? '';
    final notifier = container.read(
      trackUrlResolverProvider(track).notifier,
    );
    return notifier.resolveValidUrl();
  }

  Future<dio_lib.Response> streamTrackInformation(
    Request request,
    Track track,
  ) async {
    log.debug(
      'Playback',
      'HEAD request for track: ${track.title}, Headers: ${request.headers}',
    );

    // provider 已完成 HEAD 校验与降级，这里直接用解析得到的 URL 做一次 HEAD
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
        return Response(
          res.statusCode!,
          body: (res.data as ResponseBody).stream,
          headers: _sanitizeHeaders(res.headers.map),
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
