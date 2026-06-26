import 'dart:async';

import 'package:dio/dio.dart' hide Response;
import 'package:dio/dio.dart' as dio_lib;
import 'package:pomelo/core/log.dart';
import 'package:pomelo/modules/audio_player/service/audio_player_service.dart';
import 'package:pomelo/modules/music/model/track.dart';
import 'package:shelf/shelf.dart';
// import 'package:pomelo/models/metadata/metadata.dart';
// import 'package:pomelo/models/parser/range_headers.dart';
// import 'package:pomelo/provider/audio_player/audio_player.dart';
// import 'package:pomelo/provider/audio_player/state.dart';

// import 'package:pomelo/provider/server/active_track_sources.dart';
// import 'package:pomelo/provider/server/sourced_track_provider.dart';
// import 'package:pomelo/provider/user_preferences/user_preferences_provider.dart';
// import 'package:pomelo/services/audio_player/audio_player.dart';
// import 'package:pomelo/services/logger/logger.dart';
// import 'package:pomelo/services/sourced_track/sourced_track.dart';
// import 'package:pomelo/utils/service_utils.dart';
// import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// final _deviceClients = Set.unmodifiable({
//   YoutubeApiClient.ios,
//   YoutubeApiClient.android,
//   YoutubeApiClient.mweb,
//   YoutubeApiClient.safari,
// });

// String? get _randomUserAgent => _deviceClients
//     .elementAt(Random().nextInt(_deviceClients.length))
//     .payload["context"]["client"]["userAgent"];

class ServerPlaybackRoutes {
  final AudioPlayerService audioPlayer;
  final Dio dio;

  /// 获取当前活跃曲目（由外部注入，避免对 Riverpod Ref 的依赖）
  final Track? Function() getActiveTrack;

  /// 根据歌曲信息解析实际播放链接
  ///
  /// 由外部注入，内部调用对应 [MusicService.getMusicUrl]。
  /// 若未注入或解析失败，回退到 `track.src`。
  final Future<String> Function(Track track)? getTrackUrl;

  ServerPlaybackRoutes({
    required this.audioPlayer,
    required this.getActiveTrack,
    this.getTrackUrl,
  }) : dio = Dio();

  /// 已解析的播放链接缓存（key: track.id）
  ///
  /// 保证同一首歌曲的 URL 仅解析一次，
  /// HEAD 和 GET 请求共享缓存结果。
  final Map<String, String> _urlCache = {};

  /// 解析曲目的实际播放链接
  ///
  /// 优先返回缓存，未缓存时通过 [getTrackUrl] 回调获取，
  /// 若回调未注入或返回空则回退到 `track.src`。
  Future<String> _resolveUrl(Track track) async {
    final cached = _urlCache[track.id];
    if (cached != null && cached.isNotEmpty) return cached;

    String url = track.src ?? track.path ?? '';
    if (getTrackUrl != null) {
      try {
        final resolved = await getTrackUrl!(track);
        if (resolved.isNotEmpty) url = resolved;
      } catch (e) {
        log.error('Playback', 'getMusicUrl 失败: $e', error: e);
      }
    }
    _urlCache[track.id] = url;
    return url;
  }

  /// 清除指定曲目的 URL 缓存
  void clearUrlCache(String trackId) => _urlCache.remove(trackId);

  /// 清除所有 URL 缓存
  void clearAllUrlCache() => _urlCache.clear();

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

  // Future<String> _getTrackCacheFilePath(SourcedTrack track) async {
  //   String filePath = join(
  //     await UserPreferencesNotifier.getMusicCacheDir(),
  //     ServiceUtils.sanitizeFilename(
  //       // '${track.query.name} - ${track.query.artists.map((d) => d.name).join(",")} (${track.info.id}).${track.qualityPreset!.getFileExtension()}',
  //       '${track.query.name} - ${track.query.artists.map((d) => d.name).join(",")} (${track.info.id}).${track.getFileExtension()}',
  //     ),
  //   );
  //   if (!await File(filePath).exists()) {
  //     final exts = ['mp3', 'm4a'];
  //     for (final ext in exts) {
  //       String filePath2 = path.setExtension(filePath, '.$ext');
  //       if (await File(filePath2).exists()) {
  //         return filePath2;
  //       }
  //     }
  //   }
  //   return filePath;
  // }

  // Future<SourcedTrack?> _getSourcedTrack(
  //   Request request,
  //   String trackId,
  // ) async {
  //   final track = playlist.tracks.firstWhere(
  //     (element) => element.id == trackId,
  //   );

  //   final activeSourcedTrack = await ref.read(
  //     activeTrackSourcesProvider.future,
  //   );

  //   final media = audioPlayer.playlist.medias.firstWhere(
  //     (e) => e.uri == request.requestedUri.toString(),
  //   );
  //   final spotubeMedia = media is SpotubeMedia
  //       ? media
  //       : SpotubeMedia.media(media);
  //   final sourcedTrack = activeSourcedTrack?.track.id == track.id
  //       ? activeSourcedTrack?.source
  //       : await ref.read(
  //           sourcedTrackProvider(
  //             spotubeMedia.track as SpotubeFullTrackObject,
  //           ).future,
  //         );

  //   return sourcedTrack;
  // }

  Future<dio_lib.Response> streamTrackInformation(
    Request request,
    Track track,
  ) async {
    log.debug(
      'Playback',
      'HEAD request for track: ${track.title}, Headers: ${request.headers}',
    );
    // AppLogger.log.i(
    //   "HEAD request for track: ${track.query.name}\n"
    //   "Headers: ${request.headers}",
    // );

    // final trackCacheFile = File(await _getTrackCacheFilePath(track));

    // if (await trackCacheFile.exists() && userPreferences.cacheMusic) {
    //   final fileLength = await trackCacheFile.length();
    //   String ext = path
    //       .extension(trackCacheFile.path)
    //       .substring(1); // 包含点：".txt"

    //   return dio_lib.Response(
    //     statusCode: 200,
    //     headers: Headers.fromMap({
    //       // "content-type": ["audio/${track.qualityPreset!.name}"],
    //       "content-type": ["audio/$ext"],
    //       "content-length": ["$fileLength"],
    //       "accept-ranges": ["bytes"],
    //       "content-range": ["bytes 0-$fileLength/$fileLength"],
    //     }),
    //     requestOptions: RequestOptions(path: request.requestedUri.toString()),
    //   );
    // }

    String url = await _resolveUrl(track);

    final options = Options(
      headers: {
        // "user-agent": _randomUserAgent,
        "Cache-Control": "max-age=3600",
        "Connection": "keep-alive",
        "host": Uri.parse(url).host,
      },
      validateStatus: (status) => status! < 400,
    );

    final res = await dio.head(url, options: options);

    return res;
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
    // AppLogger.log.i(
    //   "GET request for track: ${track.query.name}\n"
    //   "Headers: ${request.headers}",
    // );

    // final trackCacheFile = File(await _getTrackCacheFilePath(track));

    // if (await trackCacheFile.exists() && userPreferences.cacheMusic) {
    //   final bytes = await trackCacheFile.readAsBytes();
    //   final cachedFileLength = bytes.length;
    //   String ext = path.extension(trackCacheFile.path).substring(1);
    //   return dio_lib.Response<Uint8List>(
    //     statusCode: 200,
    //     headers: Headers.fromMap({
    //       // "content-type": ["audio/${track.qualityPreset!.name}"],
    //       "content-type": ["audio/$ext"],
    //       "content-length": ["${cachedFileLength - 1}"],
    //       "accept-ranges": ["bytes"],
    //       "content-range": [
    //         "bytes 0-${cachedFileLength - 1}/$cachedFileLength",
    //       ],
    //       "connection": ["close"],
    //     }),
    //     requestOptions: RequestOptions(path: request.requestedUri.toString()),
    //     data: bytes,
    //   );
    // }
    String url = await _resolveUrl(track);

    final options = Options(
      headers: {
        ...headers,
        // "user-agent": _randomUserAgent,
        "Cache-Control": "max-age=3600",
        "Connection": "keep-alive",
        "host": Uri.parse(url).host,
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

    // if (!userPreferences.cacheMusic) {
    //   return res;
    // }

    // final resStream = res.data!.stream.asBroadcastStream();

    // final trackPartialCacheFile = File("${trackCacheFile.path}.part");
    // if (!await trackPartialCacheFile.exists()) {
    //   await trackPartialCacheFile.create(recursive: true);
    // }

    // // Write the stream to the file based on the range
    // final partialCacheFileSink = trackPartialCacheFile.openWrite(
    //   mode: FileMode.writeOnlyAppend,
    // );
    // final contentRange = res.headers.value("content-range") != null
    //     ? ContentRangeHeader.parse(res.headers.value("content-range") ?? "")
    //     : ContentRangeHeader(0, 0, 0);

    // resStream.listen(
    //   (data) {
    //     partialCacheFileSink.add(data);
    //   },
    //   onError: (e, stack) {
    //     partialCacheFileSink.close();
    //   },
    //   onDone: () async {
    //     await partialCacheFileSink.close();

    //     final fileLength = await trackPartialCacheFile.length();
    //     if (fileLength != contentRange.total) return;
    //     String filePath = trackCacheFile.path;

    //     if (track.getFileExtension() != "flac") {
    //       final result = FileType.fromBuffer(
    //         await trackPartialCacheFile.readAsBytes(),
    //       );
    //       if (result != null) {
    //         filePath = path.setExtension(trackCacheFile.path, '.${result.ext}');
    //       }
    //     }
    //     await trackPartialCacheFile.rename(filePath);
    //     // if (track.qualityPreset!.getFileExtension() == "weba") return;
    //     final imageBytes = await ServiceUtils.downloadImage(
    //       track.query.album.images.asUrlString(
    //         placeholder: ImagePlaceholder.albumArt,
    //         index: 1,
    //       ),
    //     );
    //     // final aaa = MetadataGod.readMetadata(file: trackPartialCacheFile.path);

    //     await MetadataGod.writeMetadata(
    //       file: filePath,
    //       metadata: track.query.toMetadata(
    //         imageBytes: imageBytes,
    //         fileLength: fileLength,
    //       ),
    //     ).catchError((e, stackTrace) {
    //       AppLogger.reportError(e, stackTrace);
    //     });
    //   },
    //   cancelOnError: true,
    // );

    // res.data?.stream =
    //     resStream; // To avoid Stream has been already listened to exception
    return res;
  }

  /// @head('/stream/<trackId>')
  Future<Response> headStreamTrackId(Request request, String trackId) async {
    try {
      // final sourcedTrack = await _getSourcedTrack(request, trackId);

      // if (sourcedTrack == null) {
      //   return Response.notFound("Track not found in the current queue");
      // }

      final activeTrack = getActiveTrack();
      if (activeTrack == null || activeTrack.src == null) {
        return Response.notFound('No active track or track is not streamable');
      }
      final res = await streamTrackInformation(request, activeTrack);

      return Response(
        res.statusCode!,
        headers: _sanitizeHeaders(res.headers.map),
      );
    } catch (e, stack) {
      log.error('Playback', e.toString(), error: e, stackTrace: stack);
      // AppLogger.reportError(e, stack);
      return Response.internalServerError();
    }
  }

  /// @get('/stream/<trackId>')
  Future<Response> getStreamTrackId(Request request, String trackId) async {
    try {
      // final sourcedTrack = await _getSourcedTrack(request, trackId);

      // if (sourcedTrack == null) {
      //   return Response.notFound("Track not found in the current queue");
      // }

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
      // AppLogger.reportError(e, stack);
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
