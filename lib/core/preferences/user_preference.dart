/// 用户偏好设置实体类
///
/// 统一管理应用所有持久化设置，替代散落的 [Settings] + [StorageKeys] 调用。
/// 通过 [UserPreferenceNotifier]（Riverpod Notifier）管理状态，
/// 任何字段变更都会自动触发依赖该字段的 Provider 重建。
///
/// 序列化策略：整体序列化为 JSON 字符串存入 Hive Box（key = `user_preference`），
/// 加载时缺字段容忍（`??` 兜底），支持零迁移 schema 升级。
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:pomelo/core/log/log_entry.dart';
import 'package:pomelo/modules/music_lx_server/model/lx_server_quality.dart';

/// Sentinel 对象，用于 [UserPreference.copyWith] 区分"不更新"与"清除为 null"。
const _unset = Object();

/// Lx Server 连接配置
@immutable
class LxServerConfig {
  final String serverUrl;
  final String username;
  final String password;
  final String? displayName;
  final String? token;

  const LxServerConfig({
    required this.serverUrl,
    required this.username,
    required this.password,
    this.displayName,
    this.token,
  });

  Map<String, dynamic> toJson() => {
        'serverUrl': serverUrl,
        'username': username,
        'password': password,
        'displayName': displayName,
        'token': token,
      };

  factory LxServerConfig.fromJson(Map<String, dynamic> json) {
    return LxServerConfig(
      serverUrl: json['serverUrl'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      displayName: json['displayName'] as String?,
      token: json['token'] as String?,
    );
  }

  LxServerConfig copyWith({
    String? serverUrl,
    String? username,
    String? password,
    String? displayName,
    String? token,
  }) {
    return LxServerConfig(
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      token: token ?? this.token,
    );
  }
}

/// Subsonic 账号配置
@immutable
class SubsonicAccountConfig {
  final String serverUrl;
  final String username;
  final String password;
  final String? displayName;

  const SubsonicAccountConfig({
    required this.serverUrl,
    required this.username,
    required this.password,
    this.displayName,
  });

  Map<String, dynamic> toJson() => {
        'serverUrl': serverUrl,
        'username': username,
        'password': password,
        'displayName': displayName,
      };

  factory SubsonicAccountConfig.fromJson(Map<String, dynamic> json) {
    return SubsonicAccountConfig(
      serverUrl: json['serverUrl'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      displayName: json['displayName'] as String?,
    );
  }
}

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

  // === music_local 模块 ===
  final List<String> localDirectories;

  // === music_lx 模块 ===
  final String? lxMetadataPluginPath;
  final List<String> lxSourcePluginPaths;

  // === music_lx_server 模块 ===
  final LxServerConfig? lxServerConfig;
  final LxServerQuality lxServerQuality;

  // === music_subsonic 模块 ===
  final List<SubsonicAccountConfig> subsonicAccounts;

  const UserPreference({
    this.themeMode = 'system',
    this.lyricFontSize = 14,
    this.autoPlay = true,
    this.updateProxy,
    this.selectedSourceId,
    this.selectedLibraryId,
    this.logStorageLevel = LogLevel.warning,
    this.localDirectories = const [],
    this.lxMetadataPluginPath,
    this.lxSourcePluginPaths = const [],
    this.lxServerConfig,
    this.lxServerQuality = LxServerQuality.flac,
    this.subsonicAccounts = const [],
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
      localDirectories: (json['localDirectories'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lxMetadataPluginPath: json['lxMetadataPluginPath'] as String?,
      lxSourcePluginPaths: (json['lxSourcePluginPaths'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lxServerConfig: json['lxServerConfig'] != null
          ? LxServerConfig.fromJson(
              Map<String, dynamic>.from(json['lxServerConfig'] as Map))
          : null,
      lxServerQuality: LxServerQuality.fromIdOrDefault(
        json['lxServerQuality'] as String?,
      ),
      subsonicAccounts: (json['subsonicAccounts'] as List?)
              ?.map((e) => SubsonicAccountConfig.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
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
        'localDirectories': localDirectories,
        'lxMetadataPluginPath': lxMetadataPluginPath,
        'lxSourcePluginPaths': lxSourcePluginPaths,
        'lxServerConfig': lxServerConfig?.toJson(),
        'lxServerQuality': lxServerQuality.id,
        'subsonicAccounts': subsonicAccounts.map((e) => e.toJson()).toList(),
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
  /// `lxMetadataPluginPath`/`lxServerConfig`），传入 `null` 表示**显式清除**，
  /// 不传表示保持原值。这是通过 sentinel 对象实现的，避免与"不更新"歧义。
  ///
  /// 其余字段（非空类型或集合）遵循常规 `?? this.x` 语义：传 null 视为不更新。
  UserPreference copyWith({
    String? themeMode,
    int? lyricFontSize,
    bool? autoPlay,
    Object? updateProxy = _unset,
    Object? selectedSourceId = _unset,
    Object? selectedLibraryId = _unset,
    LogLevel? logStorageLevel,
    List<String>? localDirectories,
    Object? lxMetadataPluginPath = _unset,
    List<String>? lxSourcePluginPaths,
    Object? lxServerConfig = _unset,
    LxServerQuality? lxServerQuality,
    List<SubsonicAccountConfig>? subsonicAccounts,
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
      localDirectories: localDirectories ?? this.localDirectories,
      lxMetadataPluginPath: lxMetadataPluginPath == _unset
          ? this.lxMetadataPluginPath
          : lxMetadataPluginPath as String?,
      lxSourcePluginPaths: lxSourcePluginPaths ?? this.lxSourcePluginPaths,
      lxServerConfig: lxServerConfig == _unset
          ? this.lxServerConfig
          : lxServerConfig as LxServerConfig?,
      lxServerQuality: lxServerQuality ?? this.lxServerQuality,
      subsonicAccounts: subsonicAccounts ?? this.subsonicAccounts,
    );
  }

  /// 从 Hive Box 静态加载（供非 Riverpod 上下文使用，如 Module.onInit）
  static UserPreference loadFromBox() {
    final box = Hive.box<String>('app_settings');
    return UserPreference.fromJsonString(box.get('user_preference')) ??
        const UserPreference();
  }
}
