import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// 是否为可直接下载的远端 http(s) 地址。
///
/// 插件有时把封面写成 `data:image/svg+xml;base64,…`（占位图）或本地路径，
/// 这类地址既不能交给代理下载，也不能交给 `Image.network`，需调用方单独处理。
bool isRemoteHttpUrl(String url) =>
    url.startsWith('http://') || url.startsWith('https://');

/// 把远端封面地址换成「本地代理地址」。
///
/// 本地服务会下载并落盘缓存，避免每次列表滚动都重新请求远端；
/// 非 http(s) 地址与本地服务未启动时（如单测）原样返回。
String cachedArtworkUrl(String url) {
  if (!isRemoteHttpUrl(url)) return url;
  return MediaProxyServer.instance?.coverUrl(url) ?? url;
}

/// 媒体缓存占用（字节）。
class MediaCacheUsage {
  const MediaCacheUsage({required this.audioBytes, required this.coverBytes});

  static const empty = MediaCacheUsage(audioBytes: 0, coverBytes: 0);

  final int audioBytes;
  final int coverBytes;

  int get total => audioBytes + coverBytes;
}

/// 一条已解析出的远端播放地址（带防盗链请求头）。
class CachedMediaLink {
  const CachedMediaLink({
    required this.url,
    this.headers,
    required this.savedAt,
  });

  final String url;
  final Map<String, String>? headers;
  final DateTime savedAt;
}

/// 播放链接的短时缓存（内存 + 磁盘）。
///
/// 音源返回的播放地址通常带签名、几分钟后就失效，所以 TTL 取 10 分钟：
/// 切歌、预取下一首、重播同一首都直接命中，避免反复请求音源。
class MediaLinkCache {
  MediaLinkCache._(this._file);

  /// 由 main() 启动时注入；未初始化时为 null（单测/纯逻辑场景）。
  static MediaLinkCache? instance;

  static const Duration ttl = Duration(minutes: 10);
  static const String _fileName = 'media_links.json';

  final File _file;
  final Map<String, CachedMediaLink> _items = {};
  Timer? _writeTimer;
  bool _dirty = false;

  static Future<MediaLinkCache> open() async {
    final dir = await getApplicationSupportDirectory();
    final cache = MediaLinkCache._(
      File('${dir.path}${Platform.pathSeparator}$_fileName'),
    );
    await cache._load();
    return cache;
  }

  Future<void> _load() async {
    try {
      if (!await _file.exists()) return;
      final data = jsonDecode(await _file.readAsString());
      if (data is! Map) return;
      final now = DateTime.now();
      data.forEach((key, value) {
        if (value is! Map) return;
        final url = value['url'];
        if (url is! String || url.isEmpty) return;
        final savedAt = DateTime.tryParse('${value['savedAt'] ?? ''}');
        if (savedAt == null || now.difference(savedAt) > ttl) return;
        final headers = value['headers'];
        _items['$key'] = CachedMediaLink(
          url: url,
          headers: headers is Map
              ? {for (final e in headers.entries) '${e.key}': '${e.value}'}
              : null,
          savedAt: savedAt,
        );
      });
    } catch (e) {
      debugPrint('[pomelo] 读取播放链接缓存失败: $e');
    }
  }

  CachedMediaLink? get(String key) {
    final item = _items[key];
    if (item == null) return null;
    if (DateTime.now().difference(item.savedAt) > ttl) {
      _items.remove(key);
      return null;
    }
    return item;
  }

  void put(String key, String url, Map<String, String>? headers) {
    _items[key] = CachedMediaLink(
      url: url,
      headers: headers,
      savedAt: DateTime.now(),
    );
    _dirty = true;
    _writeTimer?.cancel();
    _writeTimer = Timer(const Duration(seconds: 2), _flush);
  }

  int get count => _items.length;

  /// 淘汰单条链接（播放失败时调用，避免反复命中同一个失效地址）。
  void remove(String key) {
    if (_items.remove(key) == null) return;
    _dirty = true;
    _writeTimer?.cancel();
    _writeTimer = Timer(const Duration(seconds: 2), _flush);
  }

  /// 清空链接缓存（内存 + 磁盘）。
  Future<void> clear() async {
    _items.clear();
    _dirty = false;
    _writeTimer?.cancel();
    try {
      if (await _file.exists()) await _file.delete();
    } catch (e) {
      debugPrint('[pomelo] 清除播放链接缓存失败: $e');
    }
  }

  Future<void> _flush() async {
    if (!_dirty) return;
    _dirty = false;
    try {
      final now = DateTime.now();
      final payload = <String, dynamic>{
        for (final entry in _items.entries)
          if (now.difference(entry.value.savedAt) <= ttl)
            entry.key: {
              'url': entry.value.url,
              if (entry.value.headers != null) 'headers': entry.value.headers,
              'savedAt': entry.value.savedAt.toIso8601String(),
            },
      };
      await _file.writeAsString(jsonEncode(payload));
    } catch (e) {
      debugPrint('[pomelo] 保存播放链接缓存失败: $e');
    }
  }
}

/// 一个登记在本地服务里的远端资源。
class _RemoteEntry {
  _RemoteEntry({required this.url, required this.cacheId, this.headers})
    : lastUsed = DateTime.now();

  final String url;

  /// 磁盘缓存文件名（音频按曲目稳定、封面按远端地址稳定）。
  final String cacheId;
  final Map<String, String>? headers;

  /// 最近一次被请求的时间（LRU 淘汰用）。
  DateTime lastUsed;
}

/// 本地媒体代理服务。
///
/// 播放器与封面统一指向 `http://127.0.0.1:<port>/...`，由服务端负责：
///   - 带上音源要求的防盗链头去远端取流（播放器不接触这些头）；
///   - 音频边播边存（完整 200 响应落盘，下次同曲直接读本地）；
///   - 支持 Range 断点/拖动，保证 seek 可用；
///   - 封面下载并落盘缓存。
class MediaProxyServer {
  MediaProxyServer._(this._server, this._root, this._secret);

  /// 由 main() 启动后注入；未启动时为 null（回退到直连远端地址）。
  static MediaProxyServer? instance;

  /// 每个进程随机生成的路径口令。
  ///
  /// 服务只监听 127.0.0.1，但本机其它程序仍可访问；URL 里带上不可猜的随机段
  /// 后，外部程序拿不到口令就无法借用代理（也无法读取缓存）。
  final String _secret;

  final HttpServer _server;
  final Directory _root;
  final Map<String, _RemoteEntry> _entries = {};

  /// 登记条目的存活时间：超过后不再复用，避免长时间运行后无限增长。
  static const Duration _entryTtl = Duration(hours: 6);

  /// 内存里最多保留的登记条目数。
  static const int _maxEntries = 256;

  /// 边播边存少于该字节数视为不可用（避免把错误页落盘当音频）。
  static const int _minAudioBytes = 1024;
  static const int _minCoverBytes = 128;

  /// 上游「多久没数据」算超时，避免连接挂在半死不活的 CDN 上。
  static const Duration _readTimeout = Duration(seconds: 20);

  String get baseUrl => 'http://127.0.0.1:${_server.port}';

  /// 缓存上限（字节），0 表示不限制。
  int maxCacheBytes = 0;

  Directory get _audioDir =>
      Directory('${_root.path}${Platform.pathSeparator}audio');
  Directory get _coverDir =>
      Directory('${_root.path}${Platform.pathSeparator}cover');

  /// 新建 HttpClient。
  ///
  /// 不再无条件放行非法证书：那会让任何中间人都能冒充音源。个别 CDN 证书
  /// 主机名不匹配时的音源问题，交由插件返回正确的直链/请求头解决。
  HttpClient _newHttpClient({int timeoutSeconds = 15}) => HttpClient()
    ..connectionTimeout = Duration(seconds: timeoutSeconds)
    ..idleTimeout = const Duration(seconds: 15);

  /// 当前缓存占用（音频 / 封面）。
  Future<MediaCacheUsage> usage() async {
    return MediaCacheUsage(
      audioBytes: await _dirSize(_audioDir),
      coverBytes: await _dirSize(_coverDir),
    );
  }

  Future<void> clearAudioCache() => _clearDir(_audioDir);

  Future<void> clearCoverCache() => _clearDir(_coverDir);

  Future<int> _dirSize(Directory dir) async {
    try {
      if (!await dir.exists()) return 0;
      var total = 0;
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          try {
            total += await entity.length();
          } catch (_) {
            // 正被写入/删除的文件跳过。
          }
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _clearDir(Directory dir) async {
    try {
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (e) {
      debugPrint('[pomelo] 清理缓存目录失败: $e');
    }
  }

  Future<void>? _enforceFuture;

  /// 超过上限时按「最久未使用」删除缓存，直到降到上限的 90%。
  ///
  /// 单飞：并发下载会同时触发清理，重复遍历+删除既慢又可能互相干扰。
  Future<void> enforceLimit() {
    final running = _enforceFuture;
    if (running != null) return running;
    final future = _doEnforceLimit().whenComplete(() => _enforceFuture = null);
    _enforceFuture = future;
    return future;
  }

  Future<void> _doEnforceLimit() async {
    if (maxCacheBytes <= 0) return;
    try {
      final infos = <({File file, int length, DateTime modified})>[];
      var total = 0;
      for (final dir in [_audioDir, _coverDir]) {
        if (!await dir.exists()) continue;
        await for (final entity in dir.list(recursive: true)) {
          if (entity is! File || entity.path.endsWith('.part')) continue;
          try {
            final length = await entity.length();
            final modified = await entity.lastModified();
            infos.add((file: entity, length: length, modified: modified));
            total += length;
          } catch (_) {
            // 忽略读取失败的文件。
          }
        }
      }
      if (total <= maxCacheBytes) return;
      infos.sort((a, b) => a.modified.compareTo(b.modified));
      final target = (maxCacheBytes * 0.9).round();
      for (final info in infos) {
        if (total <= target) break;
        try {
          await info.file.delete();
          total -= info.length;
        } catch (_) {
          // 忽略删除失败。
        }
      }
    } catch (e) {
      debugPrint('[pomelo] 清理缓存上限失败: $e');
    }
  }

  static Future<MediaProxyServer?> start() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final root = Directory('${dir.path}${Platform.pathSeparator}media_cache');
      await root.create(recursive: true);
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      // 每次启动重新生成口令：旧链接立即失效，外部程序无法长期借用代理。
      final random = Random.secure();
      final secret = base64Url
          .encode(List<int>.generate(18, (_) => random.nextInt(256)))
          .replaceAll('=', '');
      final proxy = MediaProxyServer._(server, root, secret);
      server.listen(
        proxy._handle,
        onError: (Object error) => debugPrint('[pomelo] 媒体服务异常: $error'),
      );
      debugPrint('[pomelo] 媒体服务已启动: ${proxy.baseUrl}');
      return proxy;
    } catch (e) {
      debugPrint('[pomelo] 媒体服务启动失败，回退直连: $e');
      return null;
    }
  }

  /// 登记音频源，返回本地播放地址。
  ///
  /// [cacheKey] 需按「曲目 + 音质」稳定，保证换一次签名地址仍命中同一份缓存。
  String streamUrl(
    String cacheKey,
    String remoteUrl,
    Map<String, String>? headers,
  ) {
    final token = _hash(cacheKey);
    _entries[token] = _RemoteEntry(
      url: remoteUrl,
      headers: headers,
      cacheId: _hash('audio:$cacheKey'),
    );
    _pruneEntries();
    return '$baseUrl/$_secret/stream/$token';
  }

  /// 登记封面并返回本地地址（同一远端地址复用同一缓存文件）。
  String coverUrl(String remoteUrl) {
    final token = _hash('cover:$remoteUrl');
    _entries[token] = _RemoteEntry(url: remoteUrl, cacheId: token);
    _pruneEntries();
    return '$baseUrl/$_secret/cover/$token';
  }

  /// 清理过期 / 超量的登记条目（Map 按插入顺序，头部即最久未用）。
  void _pruneEntries() {
    if (_entries.isEmpty) return;
    final now = DateTime.now();
    _entries.removeWhere(
      (_, entry) => now.difference(entry.lastUsed) > _entryTtl,
    );
    while (_entries.length > _maxEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  /// 清掉某首歌的音频缓存（播放失败重试前调用）。
  ///
  /// 上次边播边存可能因中断留下残片；不清掉会一直读到坏文件。
  Future<void> evictAudio(String cacheKey) async {
    final file = File(
      '${_audioDir.path}${Platform.pathSeparator}${_hash('audio:$cacheKey')}'
      '.audio',
    );
    try {
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('[pomelo] 清除音频缓存失败: $e');
    }
  }

  /// 预取封面到磁盘（失败静默）。
  ///
  /// 只处理 http(s)：插件可能返回 `data:` 内联图片或本地路径，无法预取。
  Future<void> prefetchCover(String remoteUrl) async {
    if (!isRemoteHttpUrl(remoteUrl)) return;
    final file = _coverFile(_hash('cover:$remoteUrl'));
    if (await _hasContent(file)) return;
    final client = _newHttpClient(timeoutSeconds: 10);
    try {
      final request = await client.getUrl(Uri.parse(remoteUrl));
      _applyHeaders(request, null);
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) return;
      final bytes = await consolidateHttpClientResponseBytes(response);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);
    } catch (e) {
      debugPrint('[pomelo] 预取封面失败: $e');
    } finally {
      client.close();
    }
  }

  // -------------------------------------------------------------------------
  // 请求处理
  // -------------------------------------------------------------------------

  Future<void> _handle(HttpRequest request) async {
    try {
      if (request.method != 'GET') {
        request.response.statusCode = HttpStatus.methodNotAllowed;
        await request.response.close();
        return;
      }
      final segments = request.uri.pathSegments;
      // 首段必须是随机口令，否则视为未授权访问（用 404 不泄露服务存在）。
      if (segments.length < 3 || segments[0] != _secret) {
        _respondNotFound(request);
        return;
      }
      final token = segments[2];
      final entry = _entries[token];
      if (entry == null) {
        _respondNotFound(request);
        return;
      }
      // 命中即更新最近使用时间，并挪到 Map 末尾（LRU 顺序）。
      entry.lastUsed = DateTime.now();
      _entries.remove(token);
      _entries[token] = entry;
      if (segments[1] == 'stream') {
        await _serveAudio(request, entry);
      } else if (segments[1] == 'cover') {
        await _serveCover(request, entry);
      } else {
        _respondNotFound(request);
      }
    } catch (e) {
      debugPrint('[pomelo] 媒体请求处理失败: $e');
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        await request.response.close();
      } catch (_) {
        // 客户端已断开，忽略。
      }
    }
  }

  Future<void> _serveAudio(HttpRequest request, _RemoteEntry entry) async {
    final file = File(
      '${_root.path}${Platform.pathSeparator}audio'
      '${Platform.pathSeparator}${entry.cacheId}.audio',
    );
    if (await _hasContent(file, minBytes: _minAudioBytes)) {
      await _serveFile(request, file, contentType: _guessAudioType(entry.url));
      return;
    }
    await _proxyAudio(request, entry, file);
  }

  /// 把远端音频边转发给播放器边写盘。
  Future<void> _proxyAudio(
    HttpRequest request,
    _RemoteEntry entry,
    File cacheFile,
  ) async {
    final client = _newHttpClient();
    IOSink? sink;
    File? part;
    try {
      final upstreamRequest = await client.getUrl(Uri.parse(entry.url));
      _applyHeaders(upstreamRequest, entry.headers);
      final rawRange = request.headers.value(HttpHeaders.rangeHeader)?.trim();
      // `bytes=0-` 就是「从头整段拉」：不转发 Range，让上游返回 200 全量，
      // 这样首次播放也能边播边存；真正的拖动（带具体区间）才原样透传。
      final fullFromStart = rawRange == null || rawRange == 'bytes=0-';
      if (!fullFromStart) {
        upstreamRequest.headers.set(HttpHeaders.rangeHeader, rawRange);
      }
      final upstream = await upstreamRequest.close();

      final response = request.response;
      response.statusCode = upstream.statusCode;
      response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
      response.headers.set(
        HttpHeaders.contentTypeHeader,
        upstream.headers.contentType?.toString() ?? _guessAudioType(entry.url),
      );
      final contentRange = upstream.headers.value(
        HttpHeaders.contentRangeHeader,
      );
      if (contentRange != null) {
        response.headers.set(HttpHeaders.contentRangeHeader, contentRange);
      }
      final length = upstream.contentLength;
      if (length >= 0) response.headers.contentLength = length;

      // 只有「完整 200、长度已知且看起来确实是音频」才落盘；
      // 拖动产生的区间请求、错误页（text/html 等）一律只透传不缓存。
      final contentType = upstream.headers.contentType?.mimeType ?? '';
      final cacheable =
          fullFromStart &&
          upstream.statusCode == HttpStatus.ok &&
          length >= _minAudioBytes &&
          _looksLikeAudio(contentType);
      if (cacheable) {
        await cacheFile.parent.create(recursive: true);
        // 每次请求用独立的 .part，避免并发写同一临时文件。
        part = File(
          '${cacheFile.path}.${DateTime.now().microsecondsSinceEpoch}.part',
        );
        sink = part.openWrite();
      }

      // 客户端中途断开（拖动、切歌）时，尽快停止拉取上游。
      var clientGone = false;
      unawaited(
        response.done.catchError((Object _) {
          clientGone = true;
        }),
      );
      var received = 0;
      await for (final chunk in upstream.timeout(_readTimeout)) {
        if (clientGone) break;
        received += chunk.length;
        response.add(chunk);
        sink?.add(chunk);
      }
      await sink?.flush();
      await sink?.close();
      sink = null;
      if (!clientGone) await response.close();

      if (part != null) {
        final usable = !clientGone && received >= _minAudioBytes;
        if (!usable) {
          // 传输不完整：丢弃残片，避免下次播放读到半个文件。
          try {
            await part.delete();
          } catch (_) {
            // 忽略。
          }
        } else if (await cacheFile.exists()) {
          await part.delete();
        } else {
          await part.rename(cacheFile.path);
        }
        part = null;
        // 新增缓存后检查上限，超了就按最久未使用淘汰。
        unawaited(enforceLimit());
      }
    } catch (e) {
      debugPrint('[pomelo] 代理音频失败: $e');
      try {
        await sink?.close();
      } catch (_) {
        // 忽略。
      }
      if (part != null) {
        try {
          if (await part.exists()) await part.delete();
        } catch (_) {
          // 忽略。
        }
      }
      try {
        await request.response.close();
      } catch (_) {
        // 忽略。
      }
    } finally {
      client.close();
    }
  }

  Future<void> _serveCover(HttpRequest request, _RemoteEntry entry) async {
    final file = _coverFile(entry.cacheId);
    if (await _hasContent(file, minBytes: _minCoverBytes)) {
      await _serveFile(request, file, contentType: _guessImageType(entry.url));
      return;
    }

    final client = _newHttpClient();
    try {
      final upstreamRequest = await client.getUrl(Uri.parse(entry.url));
      _applyHeaders(upstreamRequest, entry.headers);
      final upstream = await upstreamRequest.close();
      if (upstream.statusCode != HttpStatus.ok) {
        _respondNotFound(request);
        return;
      }
      // 逐块读取以便对「长时间没有数据」做超时判断。
      final bytes = await upstream
          .timeout(_readTimeout)
          .fold<List<int>>(<int>[], (acc, chunk) => acc..addAll(chunk));
      final contentType = upstream.headers.contentType?.mimeType ?? '';
      // 只缓存「看着像图片且不太小」的响应，防止把错误页写成封面。
      if (bytes.length >= _minCoverBytes && contentType.startsWith('image/')) {
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes, flush: true);
        unawaited(enforceLimit());
      }

      final response = request.response;
      response.statusCode = HttpStatus.ok;
      response.headers.set(
        HttpHeaders.contentTypeHeader,
        upstream.headers.contentType?.toString() ?? _guessImageType(entry.url),
      );
      if (bytes.length >= _minCoverBytes) {
        response.headers.set(
          HttpHeaders.cacheControlHeader,
          'public, max-age=86400',
        );
      }
      response.headers.contentLength = bytes.length;
      response.add(bytes);
      await response.close();
    } catch (e) {
      debugPrint('[pomelo] 代理封面失败: $e');
      _respondNotFound(request);
    } finally {
      client.close();
    }
  }

  /// 从磁盘文件响应，支持 Range 断点。
  Future<void> _serveFile(
    HttpRequest request,
    File file, {
    required String contentType,
  }) async {
    final total = await file.length();
    final range = _parseRange(
      request.headers.value(HttpHeaders.rangeHeader),
      total,
    );
    final response = request.response;
    response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
    response.headers.set(HttpHeaders.contentTypeHeader, contentType);
    response.headers.set(
      HttpHeaders.cacheControlHeader,
      'public, max-age=86400',
    );
    if (range == null) {
      response.statusCode = HttpStatus.ok;
      response.headers.contentLength = total;
      await response.addStream(file.openRead());
    } else {
      final (start, end) = range;
      response.statusCode = HttpStatus.partialContent;
      response.headers.set(
        HttpHeaders.contentRangeHeader,
        'bytes $start-$end/$total',
      );
      response.headers.contentLength = end - start + 1;
      await response.addStream(file.openRead(start, end + 1));
    }
    await response.close();
  }

  // -------------------------------------------------------------------------
  // 工具
  // -------------------------------------------------------------------------

  File _coverFile(String cacheId) => File(
    '${_root.path}${Platform.pathSeparator}cover'
    '${Platform.pathSeparator}$cacheId',
  );

  void _applyHeaders(HttpClientRequest request, Map<String, String>? headers) {
    const defaultUa =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/120.0.0.0 Safari/537.36';
    request.headers.set(
      HttpHeaders.userAgentHeader,
      headers?['User-Agent'] ?? defaultUa,
    );
    headers?.forEach((key, value) {
      final lower = key.toLowerCase();
      if (lower == 'user-agent' || lower == 'range') return;
      try {
        request.headers.set(key, value);
      } catch (_) {
        // 非法头（如 Host）忽略。
      }
    });
  }

  Future<bool> _hasContent(File file, {int minBytes = 1}) async {
    try {
      return await file.exists() && await file.length() >= minBytes;
    } catch (_) {
      return false;
    }
  }

  /// 上游响应是否可能是音频（用于决定要不要落盘）。
  ///
  /// 有些 CDN 会返回 application/octet-stream，也一并放行；html/json 等错误页
  /// 则明确排除。
  bool _looksLikeAudio(String mimeType) {
    if (mimeType.isEmpty) return true;
    final lower = mimeType.toLowerCase();
    return lower.startsWith('audio/') ||
        lower.startsWith('video/') ||
        lower == 'application/octet-stream' ||
        lower == 'binary/octet-stream';
  }

  void _respondNotFound(HttpRequest request) {
    unawaited(() async {
      try {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
      } catch (_) {
        // 忽略。
      }
    }());
  }

  (int, int)? _parseRange(String? header, int total) {
    if (header == null || !header.startsWith('bytes=')) return null;
    final spec = header.substring(6).split(',').first.trim();
    final dash = spec.indexOf('-');
    if (dash < 0) return null;
    final startText = spec.substring(0, dash).trim();
    final endText = spec.substring(dash + 1).trim();
    var start = startText.isEmpty ? -1 : int.tryParse(startText) ?? -1;
    var end = endText.isEmpty ? -1 : int.tryParse(endText) ?? -1;
    if (start < 0 && end > 0) {
      // 后缀范围：最后 end 个字节。
      start = total - end;
      end = total - 1;
    } else if (start >= 0 && end < 0) {
      end = total - 1;
    }
    if (start < 0 || start >= total) return null;
    if (end >= total) end = total - 1;
    if (end < start) return null;
    return (start, end);
  }

  String _guessAudioType(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    if (path.endsWith('.flac')) return 'audio/flac';
    if (path.endsWith('.m4a') || path.endsWith('.mp4')) return 'audio/mp4';
    if (path.endsWith('.ogg') || path.endsWith('.opus')) return 'audio/ogg';
    if (path.endsWith('.wav')) return 'audio/wav';
    return 'audio/mpeg';
  }

  String _guessImageType(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    if (path.endsWith('.png')) return 'image/png';
    if (path.endsWith('.webp')) return 'image/webp';
    if (path.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  String _hash(String input) => md5.convert(utf8.encode(input)).toString();
}
