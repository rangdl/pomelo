import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audiotags/audiotags.dart';
import 'package:dio/dio.dart' as dio_lib;
import 'package:dio/dio.dart' hide Response;
import 'package:drift/drift.dart' show Value;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pomelo/core/models/database/app_database.dart';
import 'package:pomelo/core/models/metadata/track.dart';
import 'package:pomelo/core/storage/music_cache_dir.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/provider/database/database_provider.dart';
import 'package:pomelo/provider/server/sourced_track.dart';
import 'package:pomelo/services/audio_player/audio_player.dart';
import 'package:pomelo/services/audio_player/media.dart';
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
    final notifier = ref.read(sourcedTrackProvider(track).notifier);

    // 1. 命中内存缓存直接返回
    final cached = ref.read(sourcedTrackProvider(track)).url;
    if (cached != null && cached.isNotEmpty) return cached;

    final downgradeList = notifier.downgradeList;
    AppLogger.log.i(
      '[Playback] 解析开始: track=${track.title}, 降级序列=$downgradeList',
    );

    // 2. 优先使用持久化的本地缓存文件
    try {
      final cachedFile = await notifier.findCachedFile(downgradeList);
      if (cachedFile != null) {
        notifier.cacheUrl(cachedFile.path, cachedFile.quality);
        AppLogger.log.i(
          '[Playback] 命中本地缓存文件: quality=${cachedFile.quality}, track=${track.title}',
        );
        return cachedFile.path;
      }
    } catch (e) {
      AppLogger.log.w('[Playback] 查找本地缓存文件失败: $e');
    }

    // 3. 次选持久化的播放链接（需 HEAD 校验）
    try {
      final cachedUrl = await notifier.findCachedUrl(downgradeList);
      if (cachedUrl != null) {
        if (await _headValidate(cachedUrl.url)) {
          notifier.cacheUrl(cachedUrl.url, cachedUrl.quality);
          AppLogger.log.i(
            '[Playback] 命中缓存URL: quality=${cachedUrl.quality}, track=${track.title}',
          );
          return cachedUrl.url;
        } else {
          AppLogger.log.w(
            '[Playback] 缓存URL失效: quality=${cachedUrl.quality}, url=${cachedUrl.url}',
          );
        }
      }
    } catch (e) {
      AppLogger.log.w('[Playback] 查找缓存URL失败: $e');
    }

    // 4. 全部未命中或 URL 失效，重新获取播放链接
    for (final quality in downgradeList) {
      try {
        final url = await notifier.getUrlForQuality(quality);
        if (url.isEmpty) {
          AppLogger.log.w('[Playback] 获取链接为空 quality=$quality');
          continue;
        }
        if (await _headValidate(url)) {
          notifier.cacheUrl(url, quality);
          // 持久化 URL，便于下次直接命中
          await notifier.saveUrlToPersistence(quality, url);
          AppLogger.log.i(
            '[Playback] 解析成功: quality=$quality, track=${track.title}',
          );
          return url;
        }
        AppLogger.log.w('[Playback] HEAD 失败 quality=$quality, url=$url');
      } catch (e) {
        AppLogger.log.w('[Playback] 获取链接失败 quality=$quality: $e');
      }
    }

    // 5. 所有音质路径均失败，最后回退到 track.src / track.path
    final fallback = notifier.fallbackUrl;
    if (fallback.isNotEmpty && await _headValidate(fallback)) {
      notifier.cacheUrl(fallback, null);
      AppLogger.log.i('[Playback] 回退成功: src/path, track=${track.title}');
      return fallback;
    }

    AppLogger.log.e('[Playback] 所有音质均无法获取有效播放链接: ${track.title}');
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
  ///
  /// 对于本地文件路径（非 http(s)），改为校验文件是否存在。
  Future<bool> _headValidate(String url) async {
    // 本地文件路径：校验文件存在性
    if (_isLocalPath(url)) {
      try {
        return File(url).existsSync();
      } catch (e) {
        AppLogger.log.w('[Playback] 本地文件校验异常 path=$url: $e');
        return false;
      }
    }
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
      AppLogger.log.w('[Playback] HEAD 异常 url=$url: $e');
      return false;
    }
  }

  Future<Track?> _getSourcedTrack() async {
    // 从底层播放器获取当前曲目信息
    final playlist = audioPlayer.playlist;
    if (playlist.index < 0 || playlist.medias.isEmpty) return null;
    final media = playlist.medias.elementAtOrNull(playlist.index);
    if (media == null) return null;
    return PomeloMedia.media(media).track;
  }

  Future<dio_lib.Response> streamTrackInformation(
    Request request,
    Track track,
    String url,
  ) async {
    AppLogger.log.d(
      '[Playback] HEAD request for track: ${track.title}, Headers: ${request.headers}',
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
    AppLogger.log.d(
      '[Playback] GET request for track: ${track.title}, Headers: ${request.headers}',
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

    AppLogger.log.d(
      '[Playback] Response for track: ${track.title}, '
      'Status: ${res.statusCode}, Headers: ${res.headers.map}',
    );

    return res;
  }

  /// @head('/stream/<trackId>')
  Future<Response> headStreamTrackId(Request request, String trackId) async {
    try {
      final activeTrack = await _getSourcedTrack();
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
      final activeTrack = await _getSourcedTrack();
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
        final quality = ref.read(sourcedTrackProvider(activeTrack)).quality;

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
  /// 重点写入歌词与封面：
  /// - 歌词：优先保留文件已有标签，缺失时从 MusicServer 获取
  /// - 封面：优先保留文件已有标签，缺失时从 Track.coverArt 下载
  /// - 其他字段：保留文件已有标签，缺失时用 Track 信息补全
  ///
  /// 写入失败仅记录日志，不影响播放和缓存。
  Future<void> _writeTagsToCacheFile(Track track, String filePath) async {
    try {
      // 读取文件已有标签
      Tag? existing = await AudioTags.read(filePath);

      final existingLyrics = existing?.lyrics;
      final hasCover = (existing?.pictures.length ?? 0) > 0;

      // 获取缺失的歌词
      String? lyrics = existingLyrics;
      if (lyrics == null || lyrics.isEmpty) {
        lyrics = await _fetchLyrics(track);
      }

      // 获取缺失的封面
      List<Picture> pictures = existing?.pictures ?? const [];
      if (!hasCover && track.coverArt != null && track.coverArt!.isNotEmpty) {
        final coverBytes = await _fetchCoverBytes(track.coverArt!);
        if (coverBytes != null && coverBytes.isNotEmpty) {
          final mimeType = _inferMimeType(track.coverArt!, coverBytes);
          pictures = [
            Picture(
              pictureType: PictureType.coverFront,
              mimeType: mimeType,
              bytes: coverBytes,
            ),
          ];
        }
      }

      // 仅当获取到新信息时才写入
      final needWriteLyrics =
          lyrics != null && lyrics.isNotEmpty && (existingLyrics == null || existingLyrics.isEmpty);
      final needWriteCover = pictures.isNotEmpty && !hasCover;
      if (!needWriteLyrics && !needWriteCover && existing != null) {
        AppLogger.log.d('[Playback] 标签无需补充: track=${track.title}');
        return;
      }

      final enrichedTag = Tag(
        title: existing?.title ?? track.title,
        trackArtist: existing?.trackArtist ?? track.artist,
        album: existing?.album ?? track.album,
        albumArtist: existing?.albumArtist,
        year: existing?.year ?? track.year,
        genre: existing?.genre ?? track.genre,
        trackNumber: existing?.trackNumber ?? track.track,
        trackTotal: existing?.trackTotal,
        discNumber: existing?.discNumber ?? track.discNumber,
        discTotal: existing?.discTotal,
        lyrics: (lyrics != null && lyrics.isNotEmpty) ? lyrics : existingLyrics,
        duration: existing?.duration,
        pictures: pictures,
        bpm: existing?.bpm,
      );

      await AudioTags.write(filePath, enrichedTag);
      AppLogger.log.d(
        '[Playback] 标签写入完成: track=${track.title}, '
        'lyrics=${lyrics != null && lyrics.isNotEmpty ? "yes" : "no"}, '
        'cover=${pictures.isNotEmpty ? "yes" : "no"}',
      );
    } catch (e) {
      AppLogger.log.w('[Playback] 标签写入失败: $e');
    }
  }

  /// 从 MusicServer 获取歌词
  Future<String?> _fetchLyrics(Track track) async {
    try {
      final sourceId = track.source?.id;
      if (sourceId == null) return null;
      await ref.read(musicServersProvider.future);
      final service = await ref.read(musicServerByProvider(sourceId).future);
      if (service == null) return null;
      return await service.getLyric(track);
    } catch (e) {
      AppLogger.log.w('[Playback] 获取歌词失败: $e');
      return null;
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
  MimeType? _inferMimeType(String url, Uint8List bytes) {
    final lower = url.toLowerCase();
    if (lower.endsWith('.png')) return MimeType.png;
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return MimeType.jpeg;
    if (lower.endsWith('.gif')) return MimeType.gif;
    if (lower.endsWith('.bmp')) return MimeType.bmp;
    if (lower.endsWith('.tiff') || lower.endsWith('.tif')) {
      return MimeType.tiff;
    }
    // 从文件头推断
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return MimeType.png;
    }
    if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
      return MimeType.jpeg;
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46) {
      return MimeType.gif;
    }
    if (bytes.length >= 2 && bytes[0] == 0x42 && bytes[1] == 0x4D) {
      return MimeType.bmp;
    }
    return null;
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
      final sourceId = track.source?.id ?? 'unknown';

      // 尝试从缓存文件读取标签信息
      Track enriched = track;
      try {
        final tag = await AudioTags.read(cachePath);
        if (tag != null) {
          String? coverArt = track.coverArt;
          // 提取封面到本地 covers 目录
          final pictures = tag.pictures;
          if (pictures.isNotEmpty) {
            final savedCover = await _saveCoverToCache(
              track.id,
              pictures.first.bytes,
            );
            if (savedCover != null) coverArt = savedCover;
          }
          enriched = track.copyWith(
            title: (tag.title != null && tag.title!.isNotEmpty)
                ? tag.title!
                : track.title,
            artist: (tag.trackArtist != null && tag.trackArtist!.isNotEmpty)
                ? tag.trackArtist
                : track.artist,
            album: (tag.album != null && tag.album!.isNotEmpty)
                ? tag.album
                : track.album,
            coverArt: coverArt,
            duration: (tag.duration != null && tag.duration! > 0)
                ? tag.duration!
                : track.duration,
            year: tag.year ?? track.year,
            genre: tag.genre ?? track.genre,
            track: tag.trackNumber ?? track.track,
            discNumber: tag.discNumber ?? track.discNumber,
            path: cachePath,
          );
        }
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
        libraryId: Value(enriched.source?.libraryId),
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
