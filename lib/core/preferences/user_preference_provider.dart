/// UserPreference Riverpod Provider
///
/// 通过 [UserPreferenceNotifier] 管理全局偏好设置状态。
/// 任何字段变更通过 `state = state.copyWith(...)` 更新后，
/// 依赖该字段的 Provider 会自动重建。
///
/// 用法：
/// ```dart
/// // 读取
/// final themeMode = ref.watch(userPreferenceProvider.select((p) => p.themeMode));
///
/// // 写入
/// await ref.read(userPreferenceProvider.notifier).setThemeMode('dark');
/// ```
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pomelo/core/log/log_entry.dart';
import 'package:pomelo/core/models/database/database_provider.dart';
import 'package:pomelo/modules/music_lx_server/model/lx_server_quality.dart';
import 'package:pomelo/core/preferences/user_preference.dart';

/// 全局用户偏好设置 Provider
final userPreferenceProvider =
    NotifierProvider<UserPreferenceNotifier, UserPreference>(
  UserPreferenceNotifier.new,
);

class UserPreferenceNotifier extends Notifier<UserPreference> {
  @override
  UserPreference build() {
    // 同步返回默认值，实际数据由 initialize() 异步加载
    // main.dart 会在 ProviderContainer 创建后立即调用 initialize()
    return const UserPreference();
  }

  /// 获取数据库实例
  dynamic get _db => ref.read(appDatabaseProvider);

  /// 从 drift 数据库异步加载（由 main.dart 在 ProviderContainer 创建后调用）
  Future<void> initialize() async {
    final db = _db;
    final pref = await UserPreference.loadFromDatabase(db);
    state = pref;
  }

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
      (p) => p.copyWith(selectedSourceId: sourceId, selectedLibraryId: libraryId));

  Future<void> clearSelectedSource() => update(
      (p) => p.copyWith(selectedSourceId: null, selectedLibraryId: null));

  // ==================== log 模块 ====================

  Future<void> setLogStorageLevel(LogLevel level) =>
      update((p) => p.copyWith(logStorageLevel: level));

  // ==================== music_local 模块 ====================

  Future<void> setLocalServerName(String name) =>
      update((p) => p.copyWith(localServerName: name));

  Future<void> setLocalDirectories(List<String> dirs) =>
      update((p) => p.copyWith(localDirectories: dirs));

  // ==================== 缓存设置 ====================

  Future<void> setCacheDirectory(String? path) =>
      update((p) => p.copyWith(cacheDirectory: path));

  Future<void> setCacheSizeLimitGB(int gb) =>
      update((p) => p.copyWith(cacheSizeLimitGB: gb));

  // ==================== music_lx 模块 ====================

  Future<void> setLxMetadataPluginPath(String? path) =>
      update((p) => p.copyWith(lxMetadataPluginPath: path));

  Future<void> setLxSourcePluginPaths(List<String> paths) =>
      update((p) => p.copyWith(lxSourcePluginPaths: paths));

  // ==================== music_lx_server 模块 ====================

  Future<void> setLxServerConfig(LxServerConfig? config) =>
      update((p) => p.copyWith(lxServerConfig: config));

  Future<void> setLxServerQuality(LxServerQuality quality) =>
      update((p) => p.copyWith(lxServerQuality: quality));

  // ==================== music_subsonic 模块 ====================

  Future<void> setSubsonicAccounts(List<SubsonicAccountConfig> accounts) =>
      update((p) => p.copyWith(subsonicAccounts: accounts));
}
