/// 音乐数据的来源标识
///
/// [Track]、[Album]、[Artist]、[Playlist] 的 `source` 字段统一使用此结构，
/// 用于回答「这条数据来自哪个服务的哪个库」，进而在播放、取流、查歌词时
/// 反查对应的 MusicServer 实例。
///
/// - [id] 服务标识，如 'lx-server'、'subsonic-xxx'、'local'
/// - [name] 服务显示名
/// - [libraryId] 库标识（如 'tx'、'kg'），无库概念的音源为 null
/// - [libraryName] 库显示名，无库概念的音源为 null
///
/// 这是一个 record 类型别名，与各模型中展开写法结构等价，可直接互相赋值。
typedef MusicSourceRef = ({
  String id,
  String name,
  String? libraryId,
  String? libraryName,
});
