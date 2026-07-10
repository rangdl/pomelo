import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart' as dio_lib;
import 'package:dio/dio.dart' hide Response;
import 'package:drift/drift.dart' show Value;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pomelo/core/models/database/app_database.dart';
import 'package:pomelo/core/models/metadata/track.dart';
import 'package:pomelo/core/storage/music_cache_dir.dart';
import 'package:pomelo/provider/audio_player/audio_player.dart';
import 'package:pomelo/provider/database/database_provider.dart';
import 'package:pomelo/provider/server/sourced_track.dart';
import 'package:pomelo/services/audio_player/audio_player.dart';
import 'package:pomelo/services/logger/logger.dart';
import 'package:shelf/shelf.dart';

class ServerPlaybackRoutes {
  final Ref ref;
  final Dio dio;

  ServerPlaybackRoutes(this.ref) : dio = Dio();

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

  /// 判断字符串是否为本地文件路径（而非 HTTP(S) URL）
  bool _isLocalPath(String s) {
    final lower = s.toLowerCase();
    return !lower.startsWith('http://') && !lower.startsWith('https://');
  }

  Future<SourcedTrack?> _getSourcedTrack(
    Request request,
    String trackId,
  ) async {
    // 从底层播放器获取当前曲目信息
    final playlist = ref.read(audioPlayerProvider);
    final track = playlist.tracks.firstWhereOrNull((v) => v.id == trackId);
    if (track == null) {
      return null;
    }
    final activeSourcedTrack = await ref.read(
      sourcedTrackProvider(track).future,
    );
    return activeSourcedTrack;
  }

  Future<dio_lib.Response> streamTrackInformation(
    Request request,
    SourcedTrack track,
  ) async {
    // 1. 优先使用本地缓存文件
    final localPath = track.path;
    if (localPath != null && localPath.isNotEmpty) {
      final file = File(localPath);
      if (await file.exists()) {
        final stat = await file.stat();
        final extension = MusicCacheDir.extensionFromUrl(localPath);
        final contentType = MusicCacheDir.contentTypeFromExtension(extension);
        AppLogger.log.d(
          '[Playback] 命中本地缓存文件(HEAD): ${track.query.title}, path=$localPath',
        );
        return dio_lib.Response(
          requestOptions: RequestOptions(path: localPath),
          statusCode: 200,
          headers: Headers.fromMap({
            'content-type': [contentType],
            'content-length': [stat.size.toString()],
            'accept-ranges': ['bytes'],
          }),
        );
      }
    }

    // 2. 回退到 HTTP HEAD
    AppLogger.log.d(
      '[Playback] HEAD request for track: ${track.query.title}, Headers: ${request.headers}',
    );
    final url =
        track.url ??
        await ref
            .read(sourcedTrackProvider(track.query).notifier)
            .resolveValidUrl();
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
    SourcedTrack track,
    Map<String, dynamic> headers,
  ) async {
    // 1. 优先使用本地缓存文件
    final localPath = track.path;
    if (localPath != null && localPath.isNotEmpty) {
      final file = File(localPath);
      if (await file.exists()) {
        final stat = await file.stat();
        final extension = MusicCacheDir.extensionFromUrl(localPath);
        final contentType = MusicCacheDir.contentTypeFromExtension(extension);
        AppLogger.log.d(
          '[Playback] 命中本地缓存文件(GET): ${track.query.title}, path=$localPath',
        );
        return dio_lib.Response(
          requestOptions: RequestOptions(path: localPath),
          statusCode: 200,
          headers: Headers.fromMap({
            'content-type': [contentType],
            'content-length': [stat.size.toString()],
            'accept-ranges': ['bytes'],
          }),
          data: ResponseBody(
            file.openRead().map((chunk) => Uint8List.fromList(chunk)),
            stat.size,
            headers: {
              'content-type': [contentType],
              'content-length': [stat.size.toString()],
              'accept-ranges': ['bytes'],
            },
          ),
        );
      }
    }

    // 2. 回退到 HTTP GET
    AppLogger.log.d(
      '[Playback] GET request for track: ${track.query.title}, Headers: ${request.headers}',
    );
    final url =
        track.url ??
        await ref
            .read(sourcedTrackProvider(track.query).notifier)
            .resolveValidUrl();

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

    AppLogger.log.d(
      '[Playback] Response for track: ${track.query.title}, '
      'Status: ${res.statusCode}, Headers: ${res.headers.map}',
    );

    return res;
  }

  /// @head('/stream/<trackId>')
  Future<Response> headStreamTrackId(Request request, String trackId) async {
    try {
      final activeTrack = await _getSourcedTrack(request, trackId);
      if (activeTrack == null) {
        return Response.notFound('No active track or track is not streamable');
      }

      final res = await streamTrackInformation(request, activeTrack);

      return Response(
        res.statusCode!,
        headers: _sanitizeHeaders(res.headers.map),
      );
    } on Exception catch (e) {
      // 降级穷尽等业务异常，返回明确的错误信息
      AppLogger.reportError(e, null, '[Playback] ${e.toString()}');
      return Response.internalServerError(body: e.toString());
    } catch (e, stack) {
      AppLogger.reportError(e, stack, '[Playback] ${e.toString()}');
      return Response.internalServerError();
    }
  }

  /// @get('/stream/<trackId>')
  Future<Response> getStreamTrackId(Request request, String trackId) async {
    try {
      final activeTrack = await _getSourcedTrack(request, trackId);
      if (activeTrack == null) {
        return Response.notFound('Track not found in the current queue');
      }

      final res = await streamTrack(request, activeTrack, request.headers);

      if (res.data is ResponseBody) {
        final responseBody = res.data as ResponseBody;
        final sanitizedHeaders = _sanitizeHeaders(res.headers.map);

        // 本地缓存文件：直接返回文件流，无需再次缓存
        if (_isLocalPath(res.requestOptions.path)) {
          return Response(
            res.statusCode!,
            body: responseBody.stream,
            headers: sanitizedHeaders,
          );
        }

        // HTTP 流：缓存音频流到文件（异步，不阻塞响应）
        final quality = activeTrack.quality;
        final cachedStream = await _teeStreamToCache(
          responseBody.stream,
          activeTrack.query,
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
      AppLogger.reportError(e, stack, '[Playback] ${e.toString()}');
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
    final extension = track.src != null && track.src!.isNotEmpty
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
      AppLogger.log.d(
        '[Playback] 缓存写入完成: track=${track.title}, ${buffer.length} bytes → ${file.path}',
      );

      // 根据 Track 信息写入音乐标签（重点：歌词、封面）
      await _writeTagsToCacheFile(track, file.path);

      // 持久化缓存文件路径（需有音质信息）
      if (quality != null) {
        final notifier = ref.read(sourcedTrackProvider(track).notifier);
        await notifier.saveCachePathToPersistence(quality, file.path);
      }

      // 把曲目信息存入本地音乐库 LocalTrackTable（供离线查询）
      // 优先读取缓存文件的标签信息，弥补在线元数据缺失
      await _saveToLocalLibrary(track, file.path);

      // 写入完成后按缓存上限清理旧文件
      await MusicCacheDir.enforceLimit();
    } catch (e) {
      AppLogger.log.w('[Playback] 缓存文件写入失败: $e');
    }
  }

  /// 根据Track信息写入音乐标签到缓存文件
  ///
  /// 重点写入封面：
  /// - 封面：优先保留文件已有标签，缺失时从 Track.coverArt 下载
  /// - 其他字段：保留文件已有标签，缺失时用 Track 信息补全
  ///
  /// 注意：metadata_god 不支持 lyrics/bpm 字段，歌词不再写入文件标签。
  /// 歌词获取仍在播放器层通过 [MusicServer.getLyric] 提供。
  ///
  /// 写入失败仅记录日志，不影响播放和缓存。
  Future<void> _writeTagsToCacheFile(Track track, String filePath) async {
    try {
      // 读取文件已有标签
      Metadata? existing;
      try {
        existing = await MetadataGod.readMetadata(file: filePath);
      } catch (_) {
        existing = null;
      }

      final hasCover =
          existing?.picture != null && existing!.picture!.data.isNotEmpty;

      // 获取缺失的封面
      Picture? picture = existing?.picture;
      if (!hasCover && track.coverArt != null && track.coverArt!.isNotEmpty) {
        final coverBytes = await _fetchCoverBytes(track.coverArt!);
        if (coverBytes != null && coverBytes.isNotEmpty) {
          final mimeType = _inferMimeType(track.coverArt!, coverBytes);
          picture = Picture(data: coverBytes, mimeType: mimeType);
        }
      }

      // 仅当获取到新封面时才写入（metadata_god 不支持 lyrics）
      final needWriteCover = picture != null && !hasCover;
      if (!needWriteCover && existing != null) {
        AppLogger.log.d('[Playback] 标签无需补充: track=${track.title}');
        return;
      }

      final enriched = Metadata(
        title: existing?.title ?? track.title,
        artist: existing?.artist ?? track.artist,
        album: existing?.album ?? track.album,
        albumArtist: existing?.albumArtist,
        year: existing?.year ?? track.year,
        genre: existing?.genre ?? track.genre,
        trackNumber: existing?.trackNumber ?? track.track,
        trackTotal: existing?.trackTotal,
        discNumber: existing?.discNumber ?? track.discNumber,
        discTotal: existing?.discTotal,
        durationMs: existing?.durationMs,
        picture: picture,
      );

      await MetadataGod.writeMetadata(file: filePath, metadata: enriched);
      AppLogger.log.d(
        '[Playback] 标签写入完成: track=${track.title}, '
        'cover=${picture != null ? "yes" : "no"}',
      );
    } catch (e) {
      AppLogger.log.w('[Playback] 标签写入失败: $e');
    }
  }

  /// 从 URL 或本地路径获取封面字节
  Future<Uint8List?> _fetchCoverBytes(String coverArt) async {
    try {
      // 本地路径：直接读取
      if (_isLocalPath(coverArt)) {
        final file = File(coverArt);
        if (await file.exists()) {
          return await file.readAsBytes();
        }
        return null;
      }
      // HTTP(S) URL：下载
      final res = await dio.get<List<int>>(
        coverArt,
        options: Options(responseType: ResponseType.bytes),
      );
      final data = res.data;
      if (data == null || data.isEmpty) return null;
      return Uint8List.fromList(data);
    } catch (e) {
      AppLogger.log.w('[Playback] 获取封面失败: $e');
      return null;
    }
  }

  /// 根据 URL 扩展名或文件头推断图片 MIME 类型
  String _inferMimeType(String url, Uint8List bytes) {
    final lower = url.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.bmp')) return 'image/bmp';
    if (lower.endsWith('.tiff') || lower.endsWith('.tif')) {
      return 'image/tiff';
    }
    // 从文件头推断
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
      return 'image/jpeg';
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46) {
      return 'image/gif';
    }
    if (bytes.length >= 2 && bytes[0] == 0x42 && bytes[1] == 0x4D) {
      return 'image/bmp';
    }
    return 'application/octet-stream';
  }

  /// 把缓存的在线曲目信息写入本地音乐库
  ///
  /// sourceId 使用曲目的来源 id（如 'lx-server-xxx'、'subsonic-xxx'），
  /// isLocal=false（在线缓存），path 为缓存文件路径，src 为原始播放地址。
  ///
  /// 优先从缓存文件读取标签信息（title/artist/album/封面等），
  /// 弥补在线 API 返回的元数据缺失；读取失败则回退到原始 Track 信息。
  Future<void> _saveToLocalLibrary(Track track, String cachePath) async {
    try {
      final database = ref.read(databaseProvider);
      final sourceId = track.source.id;

      // 尝试从缓存文件读取标签信息
      Track enriched = track;
      try {
        final meta = await MetadataGod.readMetadata(file: cachePath);
        String? coverArt = track.coverArt;
        // 提取封面到本地 covers 目录
        final picture = meta.picture;
        if (picture != null && picture.data.isNotEmpty) {
          final savedCover = await _saveCoverToCache(track.id, picture.data);
          if (savedCover != null) coverArt = savedCover;
        }
        enriched = track.copyWith(
          title: (meta.title != null && meta.title!.isNotEmpty)
              ? meta.title!
              : track.title,
          artist: (meta.artist != null && meta.artist!.isNotEmpty)
              ? meta.artist
              : track.artist,
          album: (meta.album != null && meta.album!.isNotEmpty)
              ? meta.album
              : track.album,
          coverArt: coverArt,
          duration: (meta.durationMs != null && meta.durationMs! > 0)
              ? meta.durationMs!.toInt()
              : track.duration,
          year: meta.year ?? track.year,
          genre: meta.genre ?? track.genre,
          track: meta.trackNumber ?? track.track,
          discNumber: meta.discNumber ?? track.discNumber,
          path: cachePath,
        );
      } catch (e) {
        AppLogger.log.w('[Playback] 读取缓存文件标签失败: $e');
      }

      final companion = LocalTrackTableCompanion.insert(
        id: enriched.id,
        title: enriched.title,
        artist: Value(enriched.artist),
        album: Value(enriched.album),
        albumId: Value(enriched.albumId),
        artistId: Value(enriched.artistId),
        coverArt: Value(enriched.coverArt),
        duration: Value(enriched.duration),
        path: Value(cachePath),
        src: Value(enriched.src),
        sourceId: sourceId,
        libraryId: Value(enriched.source.libraryId),
        isLocal: const Value(false),
        trackJson: jsonEncode(enriched.toJson()),
      );
      await database.upsertLocalTrack(companion);
    } catch (e) {
      AppLogger.log.w('[Playback] 写入本地音乐库失败: $e');
    }
  }

  /// 把封面图片字节保存到 `<appSupport>/pomelo/local_covers/<id>.jpg`
  Future<String?> _saveCoverToCache(String trackId, Uint8List bytes) async {
    try {
      final appSupport = await getApplicationSupportDirectory();
      final dir = Directory(p.join(appSupport.path, 'pomelo', 'local_covers'));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final file = File(p.join(dir.path, '$trackId.jpg'));
      if (!await file.exists()) {
        await file.writeAsBytes(bytes, flush: true);
      }
      return file.path;
    } catch (e) {
      AppLogger.log.w('[Playback] 保存封面失败: $e');
      return null;
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

final serverPlaybackRoutesProvider = Provider(
  (ref) => ServerPlaybackRoutes(ref),
);
