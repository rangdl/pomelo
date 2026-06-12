import 'music_service.dart';

/// 音乐来源类型
enum MusicSourceType {
  /// 本地音乐
  local,

  /// Lx 在线音乐平台（通过 JS 脚本）
  lx,

  /// Subsonic 兼容服务
  subsonic,

  /// Navidrome 服务
  navidrome,

  /// Emby 服务
  emby,
}

/// 音乐来源类型的显示信息
extension MusicSourceTypeX on MusicSourceType {
  /// 显示名称
  String get displayName => switch (this) {
        MusicSourceType.local => '本地音乐',
        MusicSourceType.lx => '在线音乐',
        MusicSourceType.subsonic => 'Subsonic',
        MusicSourceType.navidrome => 'Navidrome',
        MusicSourceType.emby => 'Emby',
      };

  /// 默认分类标识（兼容旧 categoryId 体系）
  String get categoryId => name;
}

/// 音乐来源抽象基类
///
/// 代表一个已配置的音乐来源实例。
/// 每个来源在初始化后可提供 1..N 个 [MusicService] 查询服务。
///
/// 具体实现示例：
/// - [LocalMusicSource]：本地音乐目录，提供 1 个服务
/// - [LxScriptSource]：一个 Lx JS 脚本，提供若干平台服务
/// - SubsonicSource：一个 Subsonic 账号，提供 1 个服务
abstract class MusicSource {
  /// 来源唯一标识
  String get id;

  /// 来源显示名称
  String get name;

  /// 来源类型
  MusicSourceType get type;

  /// 该来源提供的所有音乐查询服务（只读）
  List<MusicService> get services;

  /// 初始化来源（创建服务实例、加载数据等）
  Future<void> init();

  /// 销毁来源，释放资源
  Future<void> dispose();
}
