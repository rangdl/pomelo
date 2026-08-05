/// 音乐服务配置基类与子类
///
/// 统一管理所有音乐源（local/lxServer/subsonic/navidrome/emby）的配置。
/// 基类 [MusicServerConfig] 定义公共字段（id/name/type），
/// 各子类继承并增加自身特定字段。
///
/// 持久化策略：drift `music_server_configs` 表，每行一个配置。
/// 基类字段（id/name/type）映射到表列，子类额外字段以 JSON 字符串存储。
library;

import 'package:flutter/foundation.dart';
import 'package:pomelo/core/models/metadata/music_source_type.dart';

/// 音乐服务配置基类
///
/// 所有音乐源的配置均继承此类。基类定义三个公共字段：
/// - [id]：配置唯一标识（如 'local'、'lx'、'lx-server-xxx'、'subsonic-xxx'）
/// - [name]：显示名称（替代原 LxServerConfig.displayName）
/// - [type]：来源类型
@immutable
sealed class MusicServerConfig {
  /// 配置唯一标识
  final String id;

  /// 显示名称
  final String name;

  /// 来源类型
  final MusicSourceType type;

  const MusicServerConfig({
    required this.id,
    required this.name,
    required this.type,
  });

  /// 子类额外字段的 JSON 字符串（用于持久化到 drift 表的 config_json 列）
  Map<String, dynamic> extraToJson();

  /// 从 JSON 构造子类实例
  ///
  /// 根据 [type] 字段路由到对应子类的 fromJson。
  static MusicServerConfig fromJson(String id, String name, MusicSourceType type, Map<String, dynamic> extra) {
    return switch (type) {
      MusicSourceType.local => LocalMusicConfig.fromJson(id: id, name: name, extra: extra),
      MusicSourceType.lxServer => LxServerConfig.fromJson(id: id, name: name, extra: extra),
      MusicSourceType.subsonic ||
      MusicSourceType.navidrome ||
      MusicSourceType.emby => SubsonicConfig.fromJson(id: id, name: name, extra: extra),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicServerConfig && id == other.id && runtimeType == other.runtimeType;

  @override
  int get hashCode => id.hashCode;
}

/// 本地音乐配置
@immutable
class LocalMusicConfig extends MusicServerConfig {
  /// 扫描目录列表
  final List<String> directories;

  const LocalMusicConfig({
    required super.id,
    required super.name,
    required this.directories,
  }) : super(type: MusicSourceType.local);

  @override
  Map<String, dynamic> extraToJson() => {'directories': directories};

  static LocalMusicConfig fromJson({
    required String id,
    required String name,
    required Map<String, dynamic> extra,
  }) {
    return LocalMusicConfig(
      id: id,
      name: name,
      directories: (extra['directories'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }
}

/// Lx Server 连接配置
@immutable
class LxServerConfig extends MusicServerConfig {
  final String serverUrl;
  final String username;
  final String password;
  final String? token;

  /// 是否启用代理播放
  final bool proxyPlayback;

  /// 是否允许换源
  final bool allowSourceSwitching;

  /// 是否使用本地音源
  ///
  /// 开启后，配合全局 [UserPreference.localAudioSourceEnabled] 开关，
  /// 在获取播放链接时优先从本地音乐库匹配（按 title + artist），
  /// 匹配失败再回退到在线解析。
  final bool useLocalAudioSource;

  const LxServerConfig({
    required super.id,
    required super.name,
    required this.serverUrl,
    required this.username,
    required this.password,
    this.token,
    this.proxyPlayback = false,
    this.allowSourceSwitching = false,
    this.useLocalAudioSource = false,
  }) : super(type: MusicSourceType.lxServer);

  @override
  Map<String, dynamic> extraToJson() => {
        'serverUrl': serverUrl,
        'username': username,
        'password': password,
        'token': token,
        'proxyPlayback': proxyPlayback,
        'allowSourceSwitching': allowSourceSwitching,
        'useLocalAudioSource': useLocalAudioSource,
      };

  static LxServerConfig fromJson({
    required String id,
    required String name,
    required Map<String, dynamic> extra,
  }) {
    return LxServerConfig(
      id: id,
      name: name,
      serverUrl: extra['serverUrl'] as String? ?? '',
      username: extra['username'] as String? ?? '',
      password: extra['password'] as String? ?? '',
      token: extra['token'] as String?,
      proxyPlayback: extra['proxyPlayback'] as bool? ?? false,
      allowSourceSwitching: extra['allowSourceSwitching'] as bool? ?? false,
      useLocalAudioSource:
          extra['useLocalAudioSource'] as bool? ?? false,
    );
  }

  LxServerConfig copyWith({
    String? id,
    String? name,
    String? serverUrl,
    String? username,
    String? password,
    String? token,
    bool? proxyPlayback,
    bool? allowSourceSwitching,
    bool? useLocalAudioSource,
  }) {
    return LxServerConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      token: token ?? this.token,
      proxyPlayback: proxyPlayback ?? this.proxyPlayback,
      allowSourceSwitching: allowSourceSwitching ?? this.allowSourceSwitching,
      useLocalAudioSource:
          useLocalAudioSource ?? this.useLocalAudioSource,
    );
  }
}

/// Subsonic 账号配置
@immutable
class SubsonicConfig extends MusicServerConfig {
  final String serverUrl;
  final String username;
  final String password;

  /// 预计算 token（与 [salt] 配对使用）
  final String? token;

  /// 预计算 salt（与 [token] 配对使用）
  final String? salt;

  /// API 版本，默认 '1.16.1'
  final String? version;

  /// API 路径前缀，默认 '/rest'
  final String? pathPrefix;

  const SubsonicConfig({
    required super.id,
    required super.name,
    required this.serverUrl,
    required this.username,
    required this.password,
    this.token,
    this.salt,
    this.version,
    this.pathPrefix,
  }) : super(type: MusicSourceType.subsonic);

  @override
  Map<String, dynamic> extraToJson() => {
        'serverUrl': serverUrl,
        'username': username,
        'password': password,
        'token': token,
        'salt': salt,
        'version': version,
        'pathPrefix': pathPrefix,
      };

  static SubsonicConfig fromJson({
    required String id,
    required String name,
    required Map<String, dynamic> extra,
  }) {
    return SubsonicConfig(
      id: id,
      name: name,
      serverUrl: extra['serverUrl'] as String? ?? '',
      username: extra['username'] as String? ?? '',
      password: extra['password'] as String? ?? '',
      token: extra['token'] as String?,
      salt: extra['salt'] as String?,
      version: extra['version'] as String?,
      pathPrefix: extra['pathPrefix'] as String?,
    );
  }

  SubsonicConfig copyWith({
    String? id,
    String? name,
    String? serverUrl,
    String? username,
    String? password,
    String? token,
    String? salt,
    String? version,
    String? pathPrefix,
  }) {
    return SubsonicConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      token: token ?? this.token,
      salt: salt ?? this.salt,
      version: version ?? this.version,
      pathPrefix: pathPrefix ?? this.pathPrefix,
    );
  }
}
