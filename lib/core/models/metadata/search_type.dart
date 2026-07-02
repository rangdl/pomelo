/// 搜索类型枚举
///
/// 对应 lx-server 搜索 API 的 `type` 参数。
/// 各 MusicServer 通过 [MusicServer.supportedSearchTypes] 声明支持的搜索类型。
enum SearchType {
  /// 歌曲
  song,

  /// 歌手
  artist,

  /// 专辑
  album,

  /// 歌单
  playlist;

  /// 对应 lx-server API 的 type 参数值
  String get apiValue {
    switch (this) {
      case SearchType.song:
        return 'song';
      case SearchType.artist:
        return 'singer';
      case SearchType.album:
        return 'album';
      case SearchType.playlist:
        return 'playlist';
    }
  }

  /// 中文显示名称
  String get label {
    switch (this) {
      case SearchType.song:
        return '歌曲';
      case SearchType.artist:
        return '歌手';
      case SearchType.album:
        return '专辑';
      case SearchType.playlist:
        return '歌单';
    }
  }
}
