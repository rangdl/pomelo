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
