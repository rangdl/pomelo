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

  /// 是否启用代理播放
  ///
  /// 开启后获取到播放链接后，调用 GET `/api/music/download?url=<播放链接>`
  /// 让服务器代理获取并转发音频流，适用于 CDN 直链无法直接访问的场景。
  final bool proxyPlayback;

  const LxServerConfig({
    required this.serverUrl,
    required this.username,
    required this.password,
    this.displayName,
    this.token,
    this.proxyPlayback = false,
  });

  Map<String, dynamic> toJson() => {
        'serverUrl': serverUrl,
        'username': username,
        'password': password,
        'displayName': displayName,
        'token': token,
        'proxyPlayback': proxyPlayback,
      };

  factory LxServerConfig.fromJson(Map<String, dynamic> json) {
    return LxServerConfig(
      serverUrl: json['serverUrl'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      displayName: json['displayName'] as String?,
      token: json['token'] as String?,
      proxyPlayback: json['proxyPlayback'] as bool? ?? false,
    );
  }

  LxServerConfig copyWith({
    String? serverUrl,
    String? username,
    String? password,
    String? displayName,
    String? token,
    bool? proxyPlayback,
  }) {
    return LxServerConfig(
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      token: token ?? this.token,
      proxyPlayback: proxyPlayback ?? this.proxyPlayback,
    );
  }
}

/// Subsonic 账号配置
///
/// 参考接口：
/// ```ts
/// interface SubsonicConfig {
///   url: string;          // serverUrl
///   username: string;     // username
///   password?: string;    // password（与 token/salt 二选一）
///   token?: string;       // 预计算 token（与 salt 配对使用）
///   salt?: string;        // 预计算 salt（与 token 配对使用）
///   name: string;         // displayName
///   version?: string;     // API 版本，默认 '1.16.1'
///   pathPrefix?: string;  // API 路径前缀，默认 '/rest'，部分服务器需设为空
/// }
/// ```
@immutable
class SubsonicAccountConfig {
  final String serverUrl;
  final String username;

  /// 密码（明文）。与 [token]+[salt] 二选一：
  /// - 若提供 [token] + [salt]，则使用 token+salt 认证
  /// - 否则使用 password + 随机 salt + MD5 生成 token
  final String password;

  /// 预计算 token（与 [salt] 配对使用）
  final String? token;

  /// 预计算 salt（与 [token] 配对使用）
  final String? salt;

  final String? displayName;

  /// API 版本，默认 '1.16.1'
  final String? version;

  /// API 路径前缀，默认 '/rest'；LX Music Sync Server 等需设为空字符串
  final String? pathPrefix;

  const SubsonicAccountConfig({
    required this.serverUrl,
    required this.username,
    required this.password,
    this.token,
    this.salt,
    this.displayName,
    this.version,
    this.pathPrefix,
  });

  Map<String, dynamic> toJson() => {
        'serverUrl': serverUrl,
        'username': username,
        'password': password,
        'token': token,
        'salt': salt,
        'displayName': displayName,
        'version': version,
        'pathPrefix': pathPrefix,
      };

  factory SubsonicAccountConfig.fromJson(Map<String, dynamic> json) {
    return SubsonicAccountConfig(
      serverUrl: json['serverUrl'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      token: json['token'] as String?,
      salt: json['salt'] as String?,
      displayName: json['displayName'] as String?,
      version: json['version'] as String?,
      pathPrefix: json['pathPrefix'] as String?,
    );
  }

  SubsonicAccountConfig copyWith({
    String? serverUrl,
    String? username,
    String? password,
    String? token,
    String? salt,
    String? displayName,
    String? version,
    String? pathPrefix,
  }) {
    return SubsonicAccountConfig(
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      token: token ?? this.token,
      salt: salt ?? this.salt,
      displayName: displayName ?? this.displayName,
      version: version ?? this.version,
      pathPrefix: pathPrefix ?? this.pathPrefix,
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
  final String localServerName;
  final List<String> localDirectories;

  // === 缓存设置 ===
  /// 音频流缓存目录路径，null 表示使用系统默认临时目录。
  final String? cacheDirectory;

  /// 缓存大小上限（GB），范围 1~5，默认 1。
  final int cacheSizeLimitGB;

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
    this.localServerName = '本地音乐',
    this.localDirectories = const [],
    this.cacheDirectory,
    this.cacheSizeLimitGB = 1,
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
      localServerName: json['localServerName'] as String? ?? '本地音乐',
      localDirectories: (json['localDirectories'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      cacheDirectory: json['cacheDirectory'] as String?,
      cacheSizeLimitGB: (((json['cacheSizeLimitGB'] as num?)?.toInt() ?? 1)
              .clamp(1, 5)),
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
        'localServerName': localServerName,
        'localDirectories': localDirectories,
        'cacheDirectory': cacheDirectory,
        'cacheSizeLimitGB': cacheSizeLimitGB,
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
  /// `lxMetadataPluginPath`/`lxServerConfig`/`cacheDirectory`），传入 `null` 表示**显式清除**，
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
    String? localServerName,
    List<String>? localDirectories,
    Object? cacheDirectory = _unset,
    int? cacheSizeLimitGB,
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
      localServerName: localServerName ?? this.localServerName,
      localDirectories: localDirectories ?? this.localDirectories,
      cacheDirectory: cacheDirectory == _unset
          ? this.cacheDirectory
          : cacheDirectory as String?,
      cacheSizeLimitGB: (cacheSizeLimitGB ?? this.cacheSizeLimitGB).clamp(1, 5),
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
