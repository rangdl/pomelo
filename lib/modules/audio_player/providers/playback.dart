import 'dart:async';

import 'package:dio/dio.dart' hide Response;
import 'package:dio/dio.dart' as dio_lib;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:pomelo/modules/audio_player/service/audio_player_service.dart';
import 'package:pomelo/modules/music/model/song.dart';
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
  final Song? Function() getActiveTrack;

  ServerPlaybackRoutes({
    required this.audioPlayer,
    required this.getActiveTrack,
  }) : dio = Dio();

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
    SongFull track,
  ) async {
    print(
      "HEAD request for track: ${track.name}\n"
      "Headers: ${request.headers}",
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

    String url = track.src;
    // track.url ??
    // await ref
    //     .read(sourcedTrackProvider(track.query).notifier)
    //     .swapWithNextSibling()
    //     .then((track) => track.url!);

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
    SongFull track,
    Map<String, dynamic> headers,
  ) async {
    print(
      "GET request for track: ${track.name}\n"
      "Headers: ${request.headers}",
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

    String url = track.src;
    if (url.isEmpty) {
      // url = await ref
      //     .read(sourcedTrackProvider(track.query).notifier)
      //     .refreshStreamingUrl()
      //     .then((track) => track.url!);
    }

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

    final contentLengthRes =
        await Future<dio_lib.Response?>.value(
          dio.head(
            url,
            options: options.copyWith(responseType: ResponseType.bytes),
          ),
        ).catchError((e, stack) async {
          print(e.toString());
          // AppLogger.reportError(e, stack);

          // final sourcedTrack = await ref
          //     .read(sourcedTrackProvider(track.query).notifier)
          //     .refreshStreamingUrl();

          url = track.src;

          return dio.head(url, options: options);
        });

    // Redirect to m3u8 link directly as it handles range requests internally
    if (contentLengthRes?.headers.value("content-type") ==
        "application/vnd.apple.mpegurl") {
      return dio_lib.Response<Uint8List>(
        statusCode: 301,
        statusMessage: "M3U8 Redirect",
        headers: Headers.fromMap({
          "location": [url],
          "content-type": ["application/vnd.apple.mpegurl"],
        }),
        requestOptions: RequestOptions(path: request.requestedUri.toString()),
        isRedirect: true,
      );
    }

    final res = await dio.get<ResponseBody>(url, options: options);

    print(
      "Response for track: ${track.name}\n"
      "Status Code: ${res.statusCode}\n"
      "Headers: ${res.headers.map}",
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
      if (activeTrack == null || activeTrack is! SongFull) {
        return Response.notFound('No active track or track is not streamable');
      }
      final res = await streamTrackInformation(request, activeTrack);

      return Response(res.statusCode!, headers: res.headers.map);
    } catch (e, stack) {
      print(e.toString());
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
      if (activeTrack == null || activeTrack is! SongFull) {
        return Response.notFound('No active track or track is not streamable');
      }
      final res = await streamTrack(
        request,
        activeTrack,
        request.headers,
      );

      if (res.data is ResponseBody) {
        return Response(
          res.statusCode!,
          body: (res.data as ResponseBody).stream,
          headers: res.headers.map,
        );
      }

      return Response(
        res.statusCode!,
        body: res.data,
        headers: res.headers.map,
      );
    } catch (e, stack) {
      print(e.toString());
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
