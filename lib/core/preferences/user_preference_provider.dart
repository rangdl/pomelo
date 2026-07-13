/// UserPreference Riverpod Provider
///
/// 通过 [UserPreferenceNotifier] 管理全局偏好设置状态。
/// 任何字段变更通过 `state = state.copyWith(...)` 更新后，
/// 依赖该字段的 Provider 会自动重建。
///
/// 注意：音乐源配置已迁移到 [musicServerConfigsProvider]，
/// 此 Provider 仅管理用户偏好设置（主题、缓存、音质等）。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pomelo/provider/database/database_provider.dart';
import 'package:pomelo/core/models/log_level.dart';
import 'package:pomelo/core/models/lx_server_quality.dart';
import 'package:pomelo/core/preferences/user_preference.dart';

final userPreferencesProvider = Provider<UserPreference>((ref) {
  // 同步返回默认值，实际数据由 overrideWithValue 注入
  return const UserPreference();
});

/// 全局用户偏好设置 Provider
final userPreferenceProvider =
    NotifierProvider<UserPreferenceNotifier, UserPreference>(
      UserPreferenceNotifier.new,
    );

class UserPreferenceNotifier extends Notifier<UserPreference> {
  @override
  UserPreference build() {
    return ref.watch(userPreferencesProvider);
  }

  /// 获取数据库实例
  dynamic get _db => ref.read(databaseProvider);

  /// 持久化到 drift 数据库
  Future<void> _persist() async {
    await _db.upsertPreference(state.toJsonString());
  }

  /// 通用更新方法
  Future<void> update(UserPreference Function(UserPreference) updater) async {
    state = updater(state);
    await _persist();
  }

  // ==================== my 模块 ====================

  Future<void> setThemeMode(String mode) =>
      update((p) => p.copyWith(themeMode: mode));

  Future<void> setLyricFontSize(int size) =>
      update((p) => p.copyWith(lyricFontSize: size));

  Future<void> setAutoPlay(bool value) =>
      update((p) => p.copyWith(autoPlay: value));

  Future<void> setUpdateProxy(String? proxy) =>
      update((p) => p.copyWith(updateProxy: proxy));

  // ==================== music UI 选中态 ====================

  Future<void> selectSource(String? sourceId, {String? libraryId}) => update(
    (p) => p.copyWith(selectedSourceId: sourceId, selectedLibraryId: libraryId),
  );

  Future<void> clearSelectedSource() => update(
    (p) => p.copyWith(selectedSourceId: null, selectedLibraryId: null),
  );

  // ==================== log 模块 ====================

  Future<void> setLogStorageLevel(LogLevel level) =>
      update((p) => p.copyWith(logStorageLevel: level));

  // ==================== 缓存设置 ====================

  Future<void> setCacheDirectory(String? path) =>
      update((p) => p.copyWith(cacheDirectory: path));

  Future<void> setCacheSizeLimitGB(int gb) =>
      update((p) => p.copyWith(cacheSizeLimitGB: gb));

  // ==================== 音质偏好（全局） ====================

  Future<void> setLxServerQuality(LxServerQuality quality) =>
      update((p) => p.copyWith(lxServerQuality: quality));

  // ==================== 播放行为 ====================

  Future<void> setOverwritePlaylistOnPlay(bool value) =>
      update((p) => p.copyWith(overwritePlaylistOnPlay: value));

  // ==================== 音源设置 ====================

  Future<void> setLocalAudioSourceEnabled(bool value) =>
      update((p) => p.copyWith(localAudioSourceEnabled: value));

  // ==================== 投屏设置 ====================

  Future<void> setCastLocalProxy(bool value) =>
      update((p) => p.copyWith(castLocalProxy: value));

  // ==================== 搜索历史 ====================

  /// 添加搜索关键词到历史记录。
  ///
  /// 已存在的关键词会移到最前，最多保留 20 条。
  Future<void> addSearchKeyword(String keyword) {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return Future.value();
    return update((p) {
      final list = List<String>.from(p.searchKeywords);
      list.remove(trimmed);
      list.insert(0, trimmed);
      if (list.length > 20) list.removeRange(20, list.length);
      return p.copyWith(searchKeywords: list);
    });
  }

  /// 移除指定搜索关键词
  Future<void> removeSearchKeyword(String keyword) =>
      update((p) => p.copyWith(
        searchKeywords: p.searchKeywords.where((k) => k != keyword).toList(),
      ));

  /// 清空搜索历史
  Future<void> clearSearchKeywords() =>
      update((p) => p.copyWith(searchKeywords: const []));
}
