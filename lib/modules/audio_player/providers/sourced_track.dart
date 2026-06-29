/// 已解析音源曲目 Provider
///
/// 以 [Track] 为构建参数的 Riverpod family provider。
/// 负责解析实际播放链接（按音质降级序列逐个尝试），返回首个非空 URL。
///
/// 降级策略：从用户偏好音质开始向下降级（更低比特率）。
/// HEAD 校验由调用方（如 `playback.dart`）负责。
library;

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/log.dart';
import 'package:pomelo/core/preferences/user_preference_provider.dart';
import 'package:pomelo/core/models/metadata/track.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';

/// 已解析音源曲目状态
///
/// 字段说明：
/// - [query]: 原始 [Track] 查询对象
/// - [id]: 由 `query.id` 派生的标识
/// - [url]: 已解析的播放链接（解析前为 null）
/// - [quality]: 命中的音质标识（如 'flac'、'320k'）
@immutable
class SourcedTrackState {
  final Track query;
  final String? url;
  final String? quality;

  const SourcedTrackState({
    required this.query,
    this.url,
    this.quality,
  });

  /// 状态唯一标识，等于 `query.id`
  String get id => query.id;

  SourcedTrackState copyWith({String? url, String? quality}) {
    return SourcedTrackState(
      query: query,
      url: url ?? this.url,
      quality: quality ?? this.quality,
    );
  }
}

/// 已解析音源曲目 Notifier
///
/// 通过 [NotifierProvider.family] 以 [Track] 为参数构造。
/// 内部封装 [resolveValidUrl] 完成链接解析（仅校验非空，不做 HEAD 校验）。
class SourcedTrackNotifier extends Notifier<SourcedTrackState> {
  SourcedTrackNotifier(this.track);

  /// 构建参数：曲目对象
  final Track track;

  @override
  SourcedTrackState build() {
    return SourcedTrackState(query: track);
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
    if (state.url != null && state.url!.isNotEmpty) {
      return state.url!;
    }

    final preferredQuality = ref.read(userPreferenceProvider).lxServerQuality.id;
    final availableQualities = _collectAvailableQualities();
    final downgradeList = _buildDowngradeList(
      availableQualities,
      preferredQuality,
    );

    log.info(
      'SourcedTrack',
      '解析开始: track=${track.title}, 偏好=$preferredQuality, '
          '可用=$availableQualities, 降级序列=$downgradeList',
    );

    for (final quality in downgradeList) {
      try {
        final url = await _getMusicUrl(track, quality: quality);
        if (url.isEmpty) {
          log.warning('SourcedTrack', '获取链接为空 quality=$quality');
          continue;
        }
        state = state.copyWith(url: url, quality: quality);
        log.info(
          'SourcedTrack',
          '解析成功: quality=$quality, track=${track.title}',
        );
        return url;
      } catch (e) {
        log.warning(
          'SourcedTrack',
          '获取链接失败 quality=$quality: $e',
        );
      }
    }

    // 所有音质路径均返回空，最后回退到 track.src / track.path
    final fallback = track.src ?? track.path ?? '';
    if (fallback.isNotEmpty) {
      state = state.copyWith(url: fallback, quality: null);
      log.info(
        'SourcedTrack',
        '回退成功: src/path, track=${track.title}',
      );
      return fallback;
    }

    log.error(
      'SourcedTrack',
      '所有音质均无法获取播放链接: ${track.title}',
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

  /// 调用对应 MusicServer 获取播放链接
  Future<String> _getMusicUrl(
    Track track, {
    required String quality,
  }) async {
    final sourceId = track.source?.id;
    if (sourceId == null) return track.src ?? track.path ?? '';

    // 等待服务列表加载完成，然后查找对应服务
    await ref.read(musicServersProvider.future);
    final service = ref.read(musicServerBySourceProvider(sourceId));
    if (service == null) return track.src ?? track.path ?? '';
    return service.getMusicUrl(track, quality: quality);
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
    final preferredQuality = ref.read(userPreferenceProvider).lxServerQuality.id;
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
    state = state.copyWith(url: url, quality: quality);
  }

  /// 失效已缓存的 URL
  ///
  /// 清空 [url] 和 [quality]，强制下次 [resolveValidUrl] 重新解析。
  void invalidateUrl() {
    state = SourcedTrackState(query: track);
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
    NotifierProvider.family<SourcedTrackNotifier, SourcedTrackState, Track>(
      SourcedTrackNotifier.new,
    );
