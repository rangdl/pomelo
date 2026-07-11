/// 已解析音源曲目 Provider
///
/// 以 [Track] 为构建参数的 Riverpod family provider。
/// 负责解析实际播放链接（按音质降级序列逐个尝试），返回首个非空 URL。
///
/// 降级策略：从用户偏好音质开始向下降级（更低比特率）。
/// HEAD 校验由调用方（如 `playback.dart`）负责。
///
/// 持久化：解析结果（URL + 缓存文件路径）通过 drift 数据库持久化，
/// 下次播放时优先使用本地缓存文件，次选缓存的播放链接。
library;

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/models/database/app_database.dart';
import 'package:pomelo/core/models/metadata/track.dart';
import 'package:pomelo/core/preferences/user_preference_provider.dart';
import 'package:pomelo/core/storage/music_cache_dir.dart';
import 'package:pomelo/core/toast.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/modules/music_lx/providers/lx_providers.dart';
import 'package:pomelo/provider/database/database_provider.dart';
import 'package:pomelo/services/dio/dio.dart';
import 'package:pomelo/services/logger/logger.dart';
import 'package:pomelo/services/rate_limiter.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

@immutable
class TrackSource {
  final String url;

  /// 本地缓存文件路径（空字符串表示未缓存）
  final String path;
  final String type;
  final String size;
  const TrackSource({
    required this.url,
    this.path = '',
    required this.type,
    required this.size,
  });

  TrackSource copyWith({String? url, String? path}) {
    return TrackSource(
      url: url ?? this.url,
      path: path ?? this.path,
      type: type,
      size: size,
    );
  }
}

/// 已解析音源曲目状态
///
/// 字段说明：
/// - [query]: 原始 [Track] 查询对象
/// - [id]: 由 `query.id` 派生的标识
/// - [url]: 已解析的播放链接（解析前为 null）
/// - [quality]: 命中的音质标识（如 'flac'、'320k'）
@immutable
class SourcedTrack {
  final Ref ref;
  final Track query;
  final List<TrackSource> sources;
  final String quality;

  const SourcedTrack({
    required this.ref,
    required this.query,
    required this.sources,
    required this.quality,
  });

  /// [quality] 传 null = 显式清除；不传 = 保持原值
  SourcedTrack copyWith({String? quality, List<TrackSource>? sources}) {
    return SourcedTrack(
      ref: ref,
      query: query,
      sources: sources ?? this.sources,
      quality: quality ?? this.quality,
    );
  }

  String? get url {
    // 如果 query.src 有值，直接返回
    if (query.src != null && query.src!.isNotEmpty) return query.src;
    // 使用解析的音质 URL 如果此处返回为空,调用方会处理
    final targetQuality = quality;
    return sources.firstWhereOrNull((v) => v.type == targetQuality)?.url;
  }

  /// 当前音质对应的本地缓存文件路径（空字符串表示未缓存）
  String get path {
    final targetQuality = quality;
    final source = sources.firstWhereOrNull((v) => v.type == targetQuality);
    return source?.path ?? '';
  }

  static Future<SourcedTrack> fetchFromTrack({
    required Ref ref,
    required Track query,
  }) async {
    // 不考虑 query.path, 在添加到播放列表时已经处理过
    final url = query.src ?? '';
    final List<TrackSource> resolved = [];
    String targetQuality = '';
    if (url.isNotEmpty) {
      resolved.add(
        TrackSource(url: url, type: '', size: query.duration.toString()),
      );
    } else {
      const qualitys = ['flac24bit', 'flac', '320k', '128k'];
      // 读取用户偏好音质
      targetQuality = ref.read(userPreferenceProvider).lxServerQuality.id;
      List<TrackSource> sources = _resolveSources(ref, query);
      // 按音质排序
      sources.sort(
        (a, b) => qualitys.indexOf(a.type).compareTo(qualitys.indexOf(b.type)),
      );
      // 构建音质降级列表
      final downgradeSources = _buildDowngradeSources(sources, targetQuality);
      // 可用音质 从高到低解析
      bool success = false;
      for (final source in sources) {
        if (!success && downgradeSources.contains(source)) {
          // 存在降级列表中，尝试解析targetQuality的URL
          final resolvedSource = await _resolveSource(ref, query, source);
          if (resolvedSource.url.isNotEmpty) {
            success = true;
            // 解析成功之后，更新目标音质
            targetQuality = source.type;
            resolved.add(resolvedSource);
          } else {
            resolved.add(source);
          }
        } else {
          // 不存在降级列表中，直接添加
          resolved.add(source);
        }
      }
      if (!success) {
        // TODO 如果没有解析成功的音质，尝试换源解析
      }
    }

    return SourcedTrack(
      ref: ref,
      query: query,
      sources: resolved,
      quality: targetQuality,
    );
  }

  /// 构建音质降级列表
  static List<TrackSource> _buildDowngradeSources(
    List<TrackSource> availableQualities,
    String preferredQuality,
  ) {
    final prefIndex = availableQualities.indexWhereOrNull(
      (v) => v.type == preferredQuality,
    );
    if (prefIndex == null) return availableQualities;
    return availableQualities.sublist(prefIndex);
  }

  /// 解析 [TrackSource] 的播放链接和缓存路径，返回新的 [TrackSource] 状态
  static Future<TrackSource> _resolveSource(
    Ref ref,
    Track query,
    TrackSource source,
  ) async {
    final url = await _getMusicUrl(ref, query, quality: source.type);
    if (url.isEmpty) return source.copyWith(url: '');
    // 校验URL是否可用
    final options = Options(
      headers: {
        'Cache-Control': 'max-age=3600',
        'Connection': 'keep-alive',
        'host': Uri.parse(url).host,
      },
      validateStatus: (status) => true,
    );
    final res = await globalDio.head(url, options: options);
    final isValid = res.statusCode != null && res.statusCode! < 400;

    if (!isValid) {
      return source.copyWith(url: '');
    }
    // 推断文件扩展名
    final extension = MusicCacheDir.extensionFromContentType(
      res.headers.map['content-type']?.first,
    );
    // 生成缓存文件路径
    final filePath = await MusicCacheDir.getCacheFilePath(query.id, extension);
    return source.copyWith(url: url, path: filePath);
  }

  /// 解析 [Track.meta] 中的 [types] 字段，返回 [TrackSource] 列表
  static List<TrackSource> _resolveSources(Ref ref, Track query) {
    final meta = query.meta ?? {};
    final types = (meta['types'] as List<dynamic>?) ?? [];

    return types.map((v) {
      final map = v as Map<String, dynamic>;
      return TrackSource(
        url: '',
        type: map['type'] as String? ?? '',
        size: map['size'] as String? ?? '',
      );
    }).toList();
  }

  /// 调用对应 MusicServer 获取播放链接
  static Future<String> _getMusicUrl(
    Ref ref,
    Track track, {
    required String quality,
  }) async {
    // 限流：每秒最多 3 次
    await musicUrlRateLimiter.acquire();

    final sourceId = track.source.id;

    // 等待服务列表加载完成，然后查找对应服务
    await ref.read(musicServersProvider.future);
    final service = await ref.read(musicServerByProvider(sourceId).future);
    if (service == null) return track.src ?? track.path ?? '';
    if (service.useLocalAudioSource) {
      final localUrl = await _getMusicUrlLocal(ref, track, quality);
      if (localUrl != null) return localUrl;
      AppLogger.log.d('[SourcedTrack] 本地音源未命中，回退在线解析: track=${track.title}');
    }
    return service.getMusicUrl(track, quality: quality);
  }

  /// 尝试通过本地音源脚本获取播放链接
  ///
  /// 使用 [LxSourceEngine] 调用本地音源脚本解析播放链接。
  /// 当脚本不支持指定库或解析失败时返回 null，回退到在线解析。
  static Future<String?> _getMusicUrlLocal(
    Ref ref,
    Track track,
    String quality,
  ) async {
    try {
      final libraryId = track.source.libraryId;
      if (libraryId != null && libraryId.isNotEmpty) {
        final engine = await ref.read(lxSourceEngineProvider.future);
        if (!engine.hasLibrary(libraryId)) {
          AppLogger.log.d('[LxServer] 本地音源脚本不支持库 $libraryId，跳过');
          return null;
        }
        final url = await engine.getMusicUrl(
          libraryId,
          track,
          quality: quality,
        );
        if (url.isNotEmpty) {
          AppToast().success('本地音源插件解析成功: ${track.title}');
          return url;
        }
      }
    } catch (e, s) {
      AppLogger.reportError(e, s, '[LxServer] 本地音源解析失败: $e');
    }
    return null;
  }

  /// 刷新当前quality对应的URL，返回新的 [SourcedTrack] 状态
  Future<SourcedTrack> refreshStream() async {
    String targetQuality = ref.read(userPreferenceProvider).lxServerQuality.id;
    // 构建音质降级列表
    final downgradeSources = _buildDowngradeSources(sources, targetQuality);
    final List<TrackSource> resolved = [];
    bool success = false;
    for (final source in sources) {
      if (downgradeSources.contains(source)) {
        // 存在降级列表中，尝试解析targetQuality的URL
        final resolvedSource = await _resolveSource(ref, query, source);
        if (!success && resolvedSource.url.isNotEmpty) {
          success = true;
          // 解析成功之后，更新目标音质
          targetQuality = source.type;
          resolved.add(resolvedSource);
        } else {
          resolved.add(source);
        }
      } else {
        // 不存在降级列表中，直接添加
        resolved.add(source);
      }
    }
    if (!success) {
      // TODO 如果没有解析成功的音质，尝试换源解析
    }
    return SourcedTrack(
      ref: ref,
      query: query,
      sources: resolved,
      quality: targetQuality,
    );
  }

  /// 交换当前音质为下一个可用音质，返回新的 [SourcedTrack] 状态
  Future<SourcedTrack?> swapWithQuality() async {
    return SourcedTrack(
      ref: ref,
      query: query,
      sources: sources,
      quality: quality,
    );
  }
}

/// 已解析音源曲目 Notifier
///
/// 通过 [NotifierProvider.family] 以 [Track] 为参数构造。
class SourcedTrackNotifier extends AsyncNotifier<SourcedTrack> {
  SourcedTrackNotifier(this.track);

  /// 构建参数：曲目对象
  final Track track;

  @override
  Future<SourcedTrack> build() async {
    // 1. 优先从持久化加载（填充已缓存的 URL 和本地文件路径）
    final persisted = await _loadFromPersistence();
    if (persisted != null) return persisted;
    listenSelf((prev, next) {
      next.whenData((track) {
        saveCachePathToPersistence(track);
      });
    });
    // 2. 回退到实时解析
    return SourcedTrack.fetchFromTrack(ref: ref, query: track);
  }

  /// 从数据库加载持久化记录，构建带缓存 URL 和本地路径的 [SourcedTrack]
  ///
  /// 仅当 DB 中有记录且 track 有音质类型（meta['types']）时返回非 null。
  /// 直接 URL 曲目（无音质类型）不使用持久化。
  Future<SourcedTrack?> _loadFromPersistence() async {
    try {
      final db = ref.read(databaseProvider);
      final record = await db.getSourcedTrack(track.id);
      if (record == null) return null;

      final meta = track.meta ?? {};
      final types = (meta['types'] as List<dynamic>?) ?? [];
      if (types.isEmpty) return null;

      final qualities = record.qualities.isEmpty
          ? []
          : List<String>.from(jsonDecode(record.qualities) as List);
      final urlMap = _parseStringMap(record.urlMap);
      final cachePathMap = _parseStringMap(record.cachePathMap);

      String quality = '';
      final sources = types
          .map((v) {
            final map = v as Map<String, dynamic>;
            final type = map['type'] as String? ?? '';
            if (quality.isEmpty &&
                (urlMap[type]?.isNotEmpty == true ||
                    cachePathMap[type]?.isNotEmpty == true)) {
              quality = type;
            }
            return TrackSource(
              url: urlMap[type] ?? '',
              path: cachePathMap[type] ?? '',
              type: type,
              size: map['size'] as String? ?? '',
            );
          })
          .where((v) => qualities.contains(v.type))
          .toList();
      sources.sort(
        (a, b) =>
            qualities.indexOf(a.type).compareTo(qualities.indexOf(b.type)),
      );

      AppLogger.log.d(
        '[SourcedTrack] 持久化加载: track=${track.title}, '
        'urls=${urlMap.length}, paths=${cachePathMap.length}',
      );
      return SourcedTrack(
        ref: ref,
        query: track,
        sources: sources,
        quality: quality,
      );
    } catch (e) {
      AppLogger.log.w('[SourcedTrack] 加载持久化记录失败: $e');
      return null;
    }
  }

  /// 刷新播放列表，返回新的 [SourcedTrack] 状态
  Future<SourcedTrack> refreshStreamingUrl() async {
    return await update((prev) async {
      return await prev.refreshStream();
    });
  }

  Future<SourcedTrack> swapWithQuality() async {
    return await update((prev) async {
      return await prev.swapWithQuality() as SourcedTrack;
    });
  }

  /// 持久化指定音质的缓存文件路径
  ///
  /// 同时更新内存状态（sources 中对应音质的 path 字段）。
  Future<void> saveCachePathToPersistence(SourcedTrack track) async {
    try {
      final db = ref.read(databaseProvider);
      final List<String> qualities = [];
      final Map<String, String> urlMap = {};
      final Map<String, String> cachePathMap = {};
      for (final source in track.sources) {
        qualities.add(source.type);
        urlMap[source.type] = source.url;
        cachePathMap[source.type] = source.path;
      }

      await db.upsertSourcedTrack(
        SourcedTrackTableCompanion(
          trackId: Value(track.query.id),
          sourceId: Value(track.query.source.id),
          libraryId: Value(track.query.source.libraryId),
          qualities: Value(jsonEncode(qualities)),
          urlMap: Value(jsonEncode(urlMap)),
          cachePathMap: Value(jsonEncode(cachePathMap)),
          updatedAt: Value(DateTime.now()),
        ),
      );
      AppLogger.log.d('[SourcedTrack] 持久化: track=${track.query.title}');
    } catch (e) {
      AppLogger.log.w('[SourcedTrack] 持久化失败: $e');
    }
  }

  /// 解析 JSON 字符串为 Map<String, String>
  Map<String, String> _parseStringMap(String? json) {
    if (json == null || json.isEmpty) return {};
    try {
      return Map<String, String>.from(jsonDecode(json) as Map);
    } catch (_) {
      return {};
    }
  }
}

/// 已解析音源曲目 Provider（family）
///
/// 使用方式：
/// ```dart
/// final state = ref.watch(sourcedTrackProvider(track));
/// ```
final sourcedTrackProvider =
    AsyncNotifierProvider.family<SourcedTrackNotifier, SourcedTrack, Track>(
      SourcedTrackNotifier.new,
    );
