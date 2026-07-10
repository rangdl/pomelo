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

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/toast.dart';
import 'package:pomelo/modules/music_lx/providers/lx_providers.dart';
import 'package:pomelo/services/logger/logger.dart';
import 'package:pomelo/core/models/database/app_database.dart';
import 'package:pomelo/provider/database/database_provider.dart';
import 'package:pomelo/core/preferences/user_preference_provider.dart';
import 'package:pomelo/core/models/metadata/track.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
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
  static const _unsetQuality = Object();

  final Ref ref;
  final Track query;
  final List<TrackSource> sources;
  final String? quality;

  const SourcedTrack({
    required this.ref,
    required this.query,
    required this.sources,
    this.quality,
  });

  /// [quality] 传 null = 显式清除；不传 = 保持原值
  SourcedTrack copyWith({
    Object? quality = _unsetQuality,
    List<TrackSource>? sources,
  }) {
    return SourcedTrack(
      ref: ref,
      query: query,
      sources: sources ?? this.sources,
      quality: identical(quality, _unsetQuality)
          ? this.quality
          : quality as String?,
    );
  }

  String? get url {
    // 优先使用已解析的音质，其次用用户偏好音质
    final targetQuality =
        quality ?? ref.read(userPreferenceProvider).lxServerQuality.id;
    final source = sources.cast<TrackSource?>().firstWhere(
      (v) => v?.type == targetQuality,
      orElse: () => null,
    );
    if (source == null) return null;
    return source.url.isEmpty ? null : source.url;
  }

  /// 当前音质对应的本地缓存文件路径（null 表示未缓存）
  String? get path {
    final targetQuality =
        quality ?? ref.read(userPreferenceProvider).lxServerQuality.id;
    final source = sources.cast<TrackSource?>().firstWhere(
      (v) => v?.type == targetQuality,
      orElse: () => null,
    );
    if (source == null) return null;
    return source.path.isEmpty ? null : source.path;
  }

  static Future<SourcedTrack> fetchFromTrack({
    required Ref ref,
    required Track query,
  }) async {
    final url = query.src ?? query.path ?? '';

    // 如果有在线播放链接，直接返回 [TrackSource]
    final sources = url.isNotEmpty
        ? [TrackSource(url: url, type: '', size: query.duration.toString())]
        : await resolveValidSources(ref, query);

    return SourcedTrack(ref: ref, query: query, sources: sources);
  }

  /// 交换当前音质为下一个可用音质，返回新的 [SourcedTrack] 状态
  Future<SourcedTrack?> swapWithQuality() async {
    return SourcedTrack(ref: ref, query: query, sources: sources);
  }

  static Future<List<TrackSource>> resolveValidSources(
    Ref ref,
    Track query,
  ) async {
    final meta = query.meta ?? {};
    final types = (meta['types'] as List<dynamic>?) ?? [];

    final sources = types.map((v) {
      final map = v as Map<String, dynamic>;
      return TrackSource(
        url: '',
        type: map['type'] as String? ?? '',
        size: map['size'] as String? ?? '',
      );
    }).toList();
    // 读取用户偏好音质
    final preferredQuality = ref
        .read(userPreferenceProvider)
        .lxServerQuality
        .id;

    // 仅解析偏好音质的 URL，其余留空待 Notifier 按需解析
    final List<TrackSource> resolved = [];
    for (final source in sources) {
      if (source.type == preferredQuality) {
        final url = await _getMusicUrl(ref, query, quality: preferredQuality);
        resolved.add(source.copyWith(url: url));
      } else {
        resolved.add(source);
      }
    }

    return resolved;
  }

  /// 调用对应 MusicServer 获取播放链接
  static Future<String> _getMusicUrl(
    Ref ref,
    Track track, {
    required String quality,
  }) async {
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
}

/// 已解析音源曲目 Notifier
///
/// 通过 [NotifierProvider.family] 以 [Track] 为参数构造。
/// 内部封装 [resolveValidUrl] 完成链接解析（仅校验非空，不做 HEAD 校验）。
class SourcedTrackNotifier extends AsyncNotifier<SourcedTrack> {
  SourcedTrackNotifier(this.track);

  /// 构建参数：曲目对象
  final Track track;

  @override
  Future<SourcedTrack> build() async {
    // 1. 优先从持久化加载（填充已缓存的 URL 和本地文件路径）
    final persisted = await _loadFromPersistence();
    if (persisted != null) return persisted;

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

      final urlMap = _parseStringMap(record.urlMap);
      final cachePathMap = _parseStringMap(record.cachePathMap);

      final sources = types.map((v) {
        final map = v as Map<String, dynamic>;
        final type = map['type'] as String? ?? '';
        return TrackSource(
          url: urlMap[type] ?? '',
          path: cachePathMap[type] ?? '',
          type: type,
          size: map['size'] as String? ?? '',
        );
      }).toList();

      AppLogger.log.d(
        '[SourcedTrack] 持久化加载: track=${track.title}, '
        'urls=${urlMap.length}, paths=${cachePathMap.length}',
      );
      return SourcedTrack(ref: ref, query: track, sources: sources);
    } catch (e) {
      AppLogger.log.w('[SourcedTrack] 加载持久化记录失败: $e');
      return null;
    }
  }

  Future<SourcedTrack> swapWithQuality() async {
    return await update((prev) async {
      return await prev.swapWithQuality() as SourcedTrack;
    });
  }

  /// 解析播放链接（仅校验非空）
  ///
  /// 流程：
  /// 1. 已缓存有效链接直接返回
  /// 2. 从用户偏好音质开始向下逐个尝试：获取链接 → 非空即返回
  /// 3. 全部为空则回退到 `track.src` / `track.path`
  /// 4. 仍为空抛出 `无法获取有效的播放链接`
  ///
  /// 注意：本方法不做 HEAD 校验，调用方（如 `playback.dart`）负责 HEAD 校验
  /// 与音质降级重试。
  Future<String> resolveValidUrl() async {
    // 命中缓存直接返回
    if (state.value?.url != null && state.value!.url!.isNotEmpty) {
      return state.value?.url ?? '';
    }

    final preferredQuality = ref
        .read(userPreferenceProvider)
        .lxServerQuality
        .id;
    final availableQualities = _collectAvailableQualities();
    final downgradeList = _buildDowngradeList(
      availableQualities,
      preferredQuality,
    );

    AppLogger.log.i(
      '[SourcedTrack] 解析开始: track=${track.title}, 偏好=$preferredQuality, '
      '可用=$availableQualities, 降级序列=$downgradeList',
    );

    for (final quality in downgradeList) {
      try {
        final url = await _getMusicUrl(track, quality: quality);
        if (url.isEmpty) {
          AppLogger.log.w('[SourcedTrack] 获取链接为空 quality=$quality');
          continue;
        }
        update((prev) {
          final newSources = prev.sources
              .map((s) => s.type == quality ? s.copyWith(url: url) : s)
              .toList();
          return prev.copyWith(quality: quality, sources: newSources);
        });
        AppLogger.log.i(
          '[SourcedTrack] 解析成功: quality=$quality, track=${track.title}',
        );
        return url;
      } catch (e) {
        AppLogger.log.w('[SourcedTrack] 获取链接失败 quality=$quality: $e');
      }
    }

    // 所有音质路径均返回空，最后回退到 track.src / track.path
    final fallback = track.src ?? track.path ?? '';
    if (fallback.isNotEmpty) {
      update((prev) => prev.copyWith(quality: null));
      // state = state.copyWith(url: fallback, quality: null);
      AppLogger.log.i('[SourcedTrack] 回退成功: src/path, track=${track.title}');
      return fallback;
    }

    AppLogger.log.e('[SourcedTrack] 所有音质均无法获取播放链接: ${track.title}');
    throw Exception('无法获取有效的播放链接');
  }

  /// 收集可用音质（按优先级降序）
  ///
  /// 优先级（高 → 低）：flac24bit > flac > 320k > 128k
  /// 取自 `track.meta['_types']` 中存在的音质。
  /// 全部不可用时回退到 `['128k']`。
  List<String> _collectAvailableQualities() {
    const priority = ['flac24bit', 'flac', '320k', '128k'];
    final meta = track.meta ?? {};
    final typesMap = (meta['_types'] as Map<String, dynamic>?) ?? const {};
    final available = priority.where((q) => typesMap.containsKey(q)).toList();
    if (available.isEmpty) available.add('128k');
    return available;
  }

  /// 从用户偏好音质开始向下构建降级列表
  ///
  /// 策略：
  /// - 偏好为 null 或不在可用列表中：返回全部可用列表
  /// - 否则返回从偏好位置开始（含）到末尾的所有音质
  ///
  /// 示例（可用列表 ['flac24bit','flac','320k','128k']）：
  /// - 偏好 'flac' → ['flac', '320k', '128k']
  /// - 偏好 '320k' → ['320k', '128k']
  /// - 偏好 'flac24bit' → ['flac24bit', 'flac', '320k', '128k']
  List<String> _buildDowngradeList(
    List<String> availableQualities,
    String? preferredQuality,
  ) {
    if (preferredQuality == null) return availableQualities;
    final prefIndex = availableQualities.indexOf(preferredQuality);
    if (prefIndex < 0) return availableQualities;
    return availableQualities.sublist(prefIndex);
  }

  /// 调用对应 MusicServer 获取播放链接
  Future<String> _getMusicUrl(Track track, {required String quality}) async {
    final sourceId = track.source.id;
    
    // 等待服务列表加载完成，然后查找对应服务
    await ref.read(musicServersProvider.future);
    final service = await ref.read(musicServerByProvider(sourceId).future);
    if (service == null) return track.src ?? track.path ?? '';
    if (service.useLocalAudioSource) {
      final localUrl = await _getMusicUrlLocal(track, quality);
      if (localUrl != null) return localUrl;
      AppLogger.log.d('[SourcedTrack] 本地音源未命中，回退在线解析: track=${track.title}');
    }
    return service.getMusicUrl(track, quality: quality);
  }

  /// 尝试通过本地音源脚本获取播放链接
  ///
  /// 使用 [LxSourceEngine] 调用本地音源脚本解析播放链接。
  /// 当脚本不支持指定库或解析失败时返回 null，回退到在线解析。
  Future<String?> _getMusicUrlLocal(Track track, String quality) async {
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
        if (url.isNotEmpty) return url;
      }
    } catch (e) {
      AppLogger.log.w('[LxServer] 本地音源解析失败: $e');
    }
    return null;
  }

  // ======================================================================
  // 以下为供调用方（如 playback.dart）实现 HEAD 校验 + 音质降级重试的
  // 公开 API。notifier 本身不做 HEAD 校验，仅提供解析能力。
  // ======================================================================

  /// 当前曲目构建参数
  Track get queryTrack => track;

  /// 降级序列（从用户偏好音质开始向下降级）
  ///
  /// 供调用方迭代 HEAD 校验使用。
  List<String> get downgradeList {
    final preferredQuality = ref
        .read(userPreferenceProvider)
        .lxServerQuality
        .id;
    final availableQualities = _collectAvailableQualities();
    return _buildDowngradeList(availableQualities, preferredQuality);
  }

  /// 获取指定音质的播放链接（不缓存、不校验）
  ///
  /// 返回空字符串表示该音质无可用链接。
  Future<String> getUrlForQuality(String quality) {
    return _getMusicUrl(track, quality: quality);
  }

  /// 回退 URL：`track.src` / `track.path`
  String get fallbackUrl => track.src ?? track.path ?? '';

  /// 缓存已解析的 URL 与音质
  ///
  /// 供调用方在 HEAD 校验通过后回写缓存。
  void cacheUrl(String url, String? quality) {
    update((prev) {
      if (quality == null) return prev.copyWith(quality: null);
      final newSources = prev.sources
          .map((s) => s.type == quality ? s.copyWith(url: url) : s)
          .toList();
      return prev.copyWith(quality: quality, sources: newSources);
    });
  }

  /// 失效已缓存的 URL
  ///
  /// 清空 [quality]，强制下次 [resolveValidUrl] 重新解析。
  void invalidateUrl() {
    update((prev) => prev.copyWith(quality: null));
  }

  /// 缓存本地文件路径与音质
  ///
  /// 供调用方在缓存文件写入完成后回写内存状态。
  void cacheLocalPath(String path, String quality) {
    update((prev) {
      final newSources = prev.sources
          .map((s) => s.type == quality ? s.copyWith(path: path) : s)
          .toList();
      return prev.copyWith(quality: quality, sources: newSources);
    });
  }

  // ======================================================================
  // 持久化：通过 drift 数据库缓存解析结果（URL + 缓存文件路径）
  // ======================================================================

  /// 持久化指定音质的播放链接
  Future<void> saveUrlToPersistence(String quality, String url) async {
    try {
      final db = ref.read(databaseProvider);
      final existing = await db.getSourcedTrack(track.id);

      final urlMap = _parseStringMap(existing?.urlMap);
      urlMap[quality] = url;

      await db.upsertSourcedTrack(
        SourcedTrackTableCompanion(
          trackId: Value(track.id),
          sourceId: Value(track.source.id),
          libraryId: Value(track.source.libraryId),
          qualities: Value(jsonEncode(_collectAvailableQualities())),
          urlMap: Value(jsonEncode(urlMap)),
          cachePathMap: Value(existing?.cachePathMap ?? '{}'),
          updatedAt: Value(DateTime.now()),
        ),
      );
      AppLogger.log.d(
        '[SourcedTrack] 持久化URL: quality=$quality, track=${track.title}',
      );
    } catch (e) {
      AppLogger.log.w('[SourcedTrack] 持久化URL失败: $e');
    }
  }

  /// 持久化指定音质的缓存文件路径
  ///
  /// 同时更新内存状态（sources 中对应音质的 path 字段）。
  Future<void> saveCachePathToPersistence(
    String quality,
    String cachePath,
  ) async {
    // 先更新内存状态
    cacheLocalPath(cachePath, quality);

    try {
      final db = ref.read(databaseProvider);
      final existing = await db.getSourcedTrack(track.id);

      final cachePathMap = _parseStringMap(existing?.cachePathMap);
      cachePathMap[quality] = cachePath;

      await db.upsertSourcedTrack(
        SourcedTrackTableCompanion(
          trackId: Value(track.id),
          sourceId: Value(existing?.sourceId ?? track.source.id),
          libraryId: Value(existing?.libraryId ?? track.source.libraryId),
          qualities: Value(
            existing?.qualities ?? jsonEncode(_collectAvailableQualities()),
          ),
          urlMap: Value(existing?.urlMap ?? '{}'),
          cachePathMap: Value(jsonEncode(cachePathMap)),
          updatedAt: Value(DateTime.now()),
        ),
      );
      AppLogger.log.d(
        '[SourcedTrack] 持久化缓存路径: quality=$quality, track=${track.title}',
      );
    } catch (e) {
      AppLogger.log.w('[SourcedTrack] 持久化缓存路径失败: $e');
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
/// final url = await ref.read(sourcedTrackProvider(track).notifier).resolveValidUrl();
/// ```
final sourcedTrackProvider =
    AsyncNotifierProvider.family<SourcedTrackNotifier, SourcedTrack, Track>(
      SourcedTrackNotifier.new,
    );
