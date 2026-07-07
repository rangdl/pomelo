/// 用户偏好设置实体类
///
/// 统一管理应用所有持久化设置，替代散落的 Settings + StorageKeys 调用。
/// 通过 [UserPreferenceNotifier]（Riverpod Notifier）管理状态，
/// 任何字段变更都会自动触发依赖该字段的 Provider 重建。
///
/// 序列化策略：整体序列化为 JSON 字符串存入 drift 数据库（PreferenceTable），
/// 加载时缺字段容忍（`??` 兜底），支持零迁移 schema 升级。
///
/// 注意：音乐源配置（local/lx/lxServer/subsonic）已迁移到
/// drift `music_server_configs` 表，由 [musicServerConfigsProvider] 管理。
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pomelo/core/models/database/app_database.dart';
import 'package:pomelo/core/models/log_level.dart';
import 'package:pomelo/core/models/lx_server_quality.dart';

/// Sentinel 对象，用于 [UserPreference.copyWith] 区分"不更新"与"清除为 null"。
const _unset = Object();

/// 用户偏好设置
@immutable
class UserPreference {
  // === my 模块 ===
  final String themeMode; // 'light' | 'dark' | 'system'
  final int lyricFontSize;
  final bool autoPlay;
  final String? updateProxy;

  // === music UI 选中态 ===
  final String? selectedSourceId;
  final String? selectedLibraryId;

  // === log 模块 ===
  final LogLevel logStorageLevel;

  // === 缓存设置 ===
  /// 音频流缓存目录路径，null 表示使用系统默认临时目录。
  final String? cacheDirectory;

  /// 缓存大小上限（GB），范围 1~5，默认 1。
  final int cacheSizeLimitGB;

  // === 音质偏好（全局） ===
  final LxServerQuality lxServerQuality;

  // === 播放行为 ===
  /// 点击播放时是否覆盖当前播放列表。
  ///
  /// - false（默认）：添加到当前播放列表，不覆盖
  /// - true：覆盖当前播放列表
  final bool overwritePlaylistOnPlay;

  // === 音源设置 ===
  /// 是否开启本地音源（全局总开关）。
  ///
  /// 开启后，配合各 lx_server 配置中的 `useLocalAudioSource` 开关，
  /// 在获取播放链接时优先从本地音乐库匹配，失败再回退到在线解析。
  final bool localAudioSourceEnabled;

  // === 投屏设置 ===
  /// 投屏时是否启用本地代理。
  ///
  /// - true（默认）：所有曲目（包括在线音源）均通过本地 HTTP 服务器
  ///   `/stream/<trackId>` 端点投送，便于统一缓存与控制。
  /// - false：在线音源直接投送其原始 URL；本地文件仍需通过本地服务器代理。
  final bool castLocalProxy;

  const UserPreference({
    this.themeMode = 'system',
    this.lyricFontSize = 14,
    this.autoPlay = true,
    this.updateProxy,
    this.selectedSourceId,
    this.selectedLibraryId,
    this.logStorageLevel = LogLevel.warning,
    this.cacheDirectory,
    this.cacheSizeLimitGB = 1,
    this.lxServerQuality = LxServerQuality.flac,
    this.overwritePlaylistOnPlay = false,
    this.localAudioSourceEnabled = false,
    this.castLocalProxy = true,
  });

  /// 从 JSON 构造（缺字段容忍）
  factory UserPreference.fromJson(Map<String, dynamic> json) {
    return UserPreference(
      themeMode: json['themeMode'] as String? ?? 'system',
      lyricFontSize: (json['lyricFontSize'] as num?)?.toInt() ?? 14,
      autoPlay: json['autoPlay'] as bool? ?? true,
      updateProxy: json['updateProxy'] as String?,
      selectedSourceId: json['selectedSourceId'] as String?,
      selectedLibraryId: json['selectedLibraryId'] as String?,
      logStorageLevel: LogLevel.values.firstWhere(
        (e) => e.name == json['logStorageLevel'],
        orElse: () => LogLevel.warning,
      ),
      cacheDirectory: json['cacheDirectory'] as String?,
      cacheSizeLimitGB:
          (((json['cacheSizeLimitGB'] as num?)?.toInt() ?? 1).clamp(1, 5)),
      lxServerQuality: LxServerQuality.fromIdOrDefault(
        json['lxServerQuality'] as String?,
      ),
      overwritePlaylistOnPlay: json['overwritePlaylistOnPlay'] as bool? ?? false,
      localAudioSourceEnabled:
          json['localAudioSourceEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode,
        'lyricFontSize': lyricFontSize,
        'autoPlay': autoPlay,
        'updateProxy': updateProxy,
        'selectedSourceId': selectedSourceId,
        'selectedLibraryId': selectedLibraryId,
        'logStorageLevel': logStorageLevel.name,
        'cacheDirectory': cacheDirectory,
        'cacheSizeLimitGB': cacheSizeLimitGB,
        'lxServerQuality': lxServerQuality.id,
        'overwritePlaylistOnPlay': overwritePlaylistOnPlay,
        'localAudioSourceEnabled': localAudioSourceEnabled,
      };

  /// 从 JSON 字符串构造
  static UserPreference? fromJsonString(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      return UserPreference.fromJson(
        Map<String, dynamic>.from(jsonDecode(json) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  String toJsonString() => jsonEncode(toJson());

  /// 复制并更新字段。
  ///
  /// 对于可空字段（`updateProxy`/`selectedSourceId`/`selectedLibraryId`/
  /// `cacheDirectory`），传入 `null` 表示**显式清除**，
  /// 不传表示保持原值。这是通过 sentinel 对象实现的，避免与"不更新"歧义。
  UserPreference copyWith({
    String? themeMode,
    int? lyricFontSize,
    bool? autoPlay,
    Object? updateProxy = _unset,
    Object? selectedSourceId = _unset,
    Object? selectedLibraryId = _unset,
    LogLevel? logStorageLevel,
    Object? cacheDirectory = _unset,
    int? cacheSizeLimitGB,
    LxServerQuality? lxServerQuality,
    bool? overwritePlaylistOnPlay,
    bool? localAudioSourceEnabled,
  }) {
    return UserPreference(
      themeMode: themeMode ?? this.themeMode,
      lyricFontSize: lyricFontSize ?? this.lyricFontSize,
      autoPlay: autoPlay ?? this.autoPlay,
      updateProxy:
          updateProxy == _unset ? this.updateProxy : updateProxy as String?,
      selectedSourceId: selectedSourceId == _unset
          ? this.selectedSourceId
          : selectedSourceId as String?,
      selectedLibraryId: selectedLibraryId == _unset
          ? this.selectedLibraryId
          : selectedLibraryId as String?,
      logStorageLevel: logStorageLevel ?? this.logStorageLevel,
      cacheDirectory: cacheDirectory == _unset
          ? this.cacheDirectory
          : cacheDirectory as String?,
      cacheSizeLimitGB: (cacheSizeLimitGB ?? this.cacheSizeLimitGB).clamp(1, 5),
      lxServerQuality: lxServerQuality ?? this.lxServerQuality,
      overwritePlaylistOnPlay:
          overwritePlaylistOnPlay ?? this.overwritePlaylistOnPlay,
      localAudioSourceEnabled:
          localAudioSourceEnabled ?? this.localAudioSourceEnabled,
    );
  }

  /// 从 drift 数据库静态加载（供非 Riverpod 上下文使用，如 main.dart 启动）
  static Future<UserPreference> loadFromDatabase(AppDatabase db) async {
    final json = await db.getPreference();
    return UserPreference.fromJsonString(json) ?? const UserPreference();
  }
}
