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

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import 'package:pomelo/core/log/log_entry.dart';
import 'package:pomelo/modules/music_lx_server/model/lx_server_quality.dart';
import 'package:pomelo/core/preferences/user_preference.dart';

/// Hive Box 中存储 UserPreference JSON 的 key
const _kUserPreferenceKey = 'user_preference';

/// 全局用户偏好设置 Provider
final userPreferenceProvider =
    NotifierProvider<UserPreferenceNotifier, UserPreference>(
  UserPreferenceNotifier.new,
);

class UserPreferenceNotifier extends Notifier<UserPreference> {
  late Box<String> _box;

  @override
  UserPreference build() {
    _box = Hive.box<String>('app_settings');
    return _load();
  }

  /// 从 Hive Box 加载（缺字段容忍）
  UserPreference _load() {
    final json = _box.get(_kUserPreferenceKey);
    return UserPreference.fromJsonString(json) ?? const UserPreference();
  }

  /// 持久化到 Hive Box
  Future<void> _persist() async {
    await _box.put(_kUserPreferenceKey, state.toJsonString());
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

  // ==================== 旧数据迁移 ====================

  /// 从旧的散落 Settings key 迁移到统一的 UserPreference
  ///
  /// 在 [main.dart] 中 `Hive.init()` + `Settings.init()` 之后、
  /// ProviderContainer 创建之前调用一次。
  /// 如果检测到 `user_preference` key 不存在但旧 key 存在，则读取旧数据并写入新格式。
  static Future<void> migrateFromLegacySettings() async {
    final box = Hive.box<String>('app_settings');
    // 如果已有新格式数据，跳过迁移
    if (box.containsKey(_kUserPreferenceKey)) return;

    // 读取旧 key
    final oldThemeMode = box.get('my_theme_mode');
    final oldLyricFontSize = box.get('my_lyric_font_size');
    final oldAutoPlay = box.get('my_auto_play');
    final oldUpdateProxy = box.get('my_update_proxy');
    final oldSelectedSource = box.get('music_selected_source');
    final oldSelectedLibrary = box.get('music_selected_library');
    final oldLogStorageLevel = box.get('log_storage_level');
    final oldLocalDirs = box.get('music_local_directories');
    final oldLxMetadataPluginPath = box.get('music_lx_metadata_plugin_path');
    final oldLxSourcePluginPaths = box.get('music_lx_source_plugin_paths');
    final oldLxServerConfig = box.get('music_lx_server_config');
    final oldLxServerQuality = box.get('music_lx_server_quality');
    final oldSubsonicAccounts = box.get('music_subsonic_accounts');

    // 没有任何旧数据，无需迁移
    if (oldThemeMode == null &&
        oldLyricFontSize == null &&
        oldAutoPlay == null &&
        oldUpdateProxy == null &&
        oldSelectedSource == null &&
        oldSelectedLibrary == null &&
        oldLogStorageLevel == null &&
        oldLocalDirs == null &&
        oldLxMetadataPluginPath == null &&
        oldLxSourcePluginPaths == null &&
        oldLxServerConfig == null &&
        oldLxServerQuality == null &&
        oldSubsonicAccounts == null) {
      return;
    }

    // 构造并持久化（直接写 Box，无需 Riverpod state）
    final pref = UserPreference(
      themeMode: oldThemeMode ?? 'system',
      lyricFontSize: int.tryParse(oldLyricFontSize ?? '') ?? 14,
      autoPlay: oldAutoPlay == 'true' || oldAutoPlay == null,
      updateProxy: oldUpdateProxy,
      selectedSourceId: oldSelectedSource,
      selectedLibraryId: oldSelectedLibrary,
      logStorageLevel: LogLevel.values.firstWhere(
        (e) => e.name == oldLogStorageLevel,
        orElse: () => LogLevel.warning,
      ),
      localDirectories: _parseStringList(oldLocalDirs),
      lxMetadataPluginPath: oldLxMetadataPluginPath,
      lxSourcePluginPaths: _parseStringList(oldLxSourcePluginPaths),
      lxServerConfig: oldLxServerConfig != null && oldLxServerConfig.isNotEmpty
          ? _tryParseLxServerConfig(oldLxServerConfig)
          : null,
      lxServerQuality: LxServerQuality.fromIdOrDefault(oldLxServerQuality),
      subsonicAccounts: _parseSubsonicAccounts(oldSubsonicAccounts),
    );
    await box.put(_kUserPreferenceKey, pref.toJsonString());
  }

  static List<String> _parseStringList(String? json) {
    if (json == null || json.isEmpty) return const [];
    try {
      return (jsonDecode(json) as List).map((e) => e as String).toList();
    } catch (_) {
      return const [];
    }
  }

  static LxServerConfig? _tryParseLxServerConfig(String json) {
    try {
      final map = Map<String, dynamic>.from(jsonDecode(json) as Map);
      return LxServerConfig.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static List<SubsonicAccountConfig> _parseSubsonicAccounts(String? json) {
    if (json == null || json.isEmpty) return const [];
    try {
      return (jsonDecode(json) as List)
          .map((e) => SubsonicAccountConfig.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
