/// 曲目播放链接解析 Provider
///
/// 以 [Track] 为构建参数的 Riverpod family provider。
/// 负责解析实际播放链接、HEAD 校验、以及 HEAD 失败后的音质降级重试。
///
/// 降级策略：从用户偏好音质开始向下降级（更低比特率）。
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/log.dart';
import 'package:pomelo/core/mars.dart';
import 'package:pomelo/modules/music/model/track.dart';
import 'package:pomelo/modules/music/music_module.dart';

/// 曲目 URL 解析状态
///
/// 字段说明：
/// - [query]: 原始 [Track] 查询对象
/// - [id]: 由 `query.id` 派生的标识
/// - [url]: 已校验的播放链接（解析前为 null）
/// - [quality]: 命中的音质标识（如 'flac'、'320k'）
@immutable
class TrackUrlState {
  final Track query;
  final String? url;
  final String? quality;

  const TrackUrlState({
    required this.query,
    this.url,
    this.quality,
  });

  /// 状态唯一标识，等于 `query.id`
  String get id => query.id;

  TrackUrlState copyWith({String? url, String? quality}) {
    return TrackUrlState(
      query: query,
      url: url ?? this.url,
      quality: quality ?? this.quality,
    );
  }
}

/// 曲目 URL 解析 Notifier
///
/// 通过 [NotifierProvider.family] 以 [Track] 为参数构造。
/// 内部封装 [resolveValidUrl] 完成链接解析 + HEAD 校验 + 音质降级。
class TrackUrlResolverNotifier extends Notifier<TrackUrlState> {
  TrackUrlResolverNotifier(this.track);

  /// 构建参数：曲目对象
  final Track track;

  final Dio _dio = Dio();

  @override
  TrackUrlState build() {
    ref.onDispose(() => _dio.close(force: true));
    return TrackUrlState(query: track);
  }

  /// 解析并校验播放链接
  ///
  /// 流程：
  /// 1. 已缓存有效链接直接返回
  /// 2. 从用户偏好音质开始向下逐个尝试：获取链接 → HEAD 校验
  /// 3. 全部失败则回退到 `track.src` / `track.path` 并 HEAD 校验
  /// 4. 仍失败抛出 `无法获取有效的播放链接`
  Future<String> resolveValidUrl() async {
    // 命中缓存直接返回
    if (state.url != null && state.url!.isNotEmpty) {
      return state.url!;
    }

    final preferredQuality = Settings.get(StorageKeys.musicLxServerQuality);
    final availableQualities = _collectAvailableQualities();
    final downgradeList = _buildDowngradeList(
      availableQualities,
      preferredQuality,
    );

    log.info(
      'TrackUrlResolver',
      '解析开始: track=${track.title}, 偏好=$preferredQuality, '
          '可用=$availableQualities, 降级序列=$downgradeList',
    );

    for (final quality in downgradeList) {
      try {
        final url = await _getMusicUrl(track, quality: quality);
        if (url.isEmpty) {
          log.warning('TrackUrlResolver', '获取链接为空 quality=$quality');
          continue;
        }
        if (await _headValidate(url)) {
          state = state.copyWith(url: url, quality: quality);
          log.info(
            'TrackUrlResolver',
            '解析成功: quality=$quality, track=${track.title}',
          );
          return url;
        }
        log.warning(
          'TrackUrlResolver',
          'HEAD 失败 quality=$quality, url=$url',
        );
      } catch (e) {
        log.warning(
          'TrackUrlResolver',
          '获取链接失败 quality=$quality: $e',
        );
      }
    }

    // 所有音质路径均失败，最后回退到 track.src / track.path
    final fallback = track.src ?? track.path ?? '';
    if (fallback.isNotEmpty && await _headValidate(fallback)) {
      state = state.copyWith(url: fallback, quality: null);
      log.info(
        'TrackUrlResolver',
        '回退成功: src/path, track=${track.title}',
      );
      return fallback;
    }

    log.error(
      'TrackUrlResolver',
      '所有音质均无法获取有效播放链接: ${track.title}',
    );
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

  /// 调用对应 MusicService 获取播放链接
  Future<String> _getMusicUrl(
    Track track, {
    required String quality,
  }) async {
    final musicModule = ModuleManager().find<MusicModule>('music');
    if (musicModule == null) return track.src ?? track.path ?? '';
    final sourceId = track.source?.id;
    if (sourceId == null) return track.src ?? track.path ?? '';
    final service = musicModule.service(sourceId);
    if (service == null) return track.src ?? track.path ?? '';
    return service.getMusicUrl(track, quality: quality);
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
      final res = await _dio.head(url, options: options);
      return res.statusCode != null && res.statusCode! < 400;
    } catch (e) {
      log.warning('TrackUrlResolver', 'HEAD 异常 url=$url: $e');
      return false;
    }
  }

  /// 失效已缓存的 URL
  ///
  /// 清空 [url] 和 [quality]，强制下次 [resolveValidUrl] 重新解析。
  void invalidateUrl() {
    state = TrackUrlState(query: track);
  }
}

/// 曲目 URL 解析 Provider（family）
///
/// 使用方式：
/// ```dart
/// final state = ref.watch(trackUrlResolverProvider(track));
/// final url = await ref.read(trackUrlResolverProvider(track).notifier).resolveValidUrl();
/// ```
final trackUrlResolverProvider =
    NotifierProvider.family<TrackUrlResolverNotifier, TrackUrlState, Track>(
      TrackUrlResolverNotifier.new,
    );
