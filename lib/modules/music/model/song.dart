import 'package:freezed_annotation/freezed_annotation.dart';

part 'song.freezed.dart';
part 'song.g.dart';

/// 歌曲模型
@freezed
class Song with _$Song {
  /// 创建本地歌曲
  ///
  /// [path] 为本地文件路径，自动设为 [audioUrl] 的值。
  factory Song({
    required String id, // 歌曲唯一标识
    required String name, // 歌曲标题
    required String artist, // 艺术家
    String? albumId, // 专辑ID
    String? albumName, // 专辑名称
    String? coverUrl, // 封面图片URL
    @Default(0) int duration, // 时长（秒）
    /// 数据来源
    ///
    /// 如 `(id: 'netease', name: '网易云音乐')`、
    /// `(id: 'local', name: '本地')`
    required ({String id, String name}) source,

    /// 来源原始数据
    ///
    /// 由提供数据的模块自定义，可存储来源特有的元信息。
    /// 例如网易云模块可存 `{'song_id': 123456, 'quality': 'lossless'}`。
    @Default({}) Map<String, dynamic> meta,
    DateTime? createdAt, // 创建时间
    required String path, // 音频文件URL/路径
  }) = _Song;

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);
}

extension SongExtension on Song {
  /// 格式化的时长字符串 (mm:ss)
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
