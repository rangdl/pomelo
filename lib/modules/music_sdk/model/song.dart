/// 歌曲模型
class Song {
  /// 歌曲唯一标识
  final String id;

  /// 歌曲标题
  final String title;

  /// 艺术家
  final String artist;

  /// 专辑ID
  final String? albumId;

  /// 专辑名称
  final String? albumName;

  /// 封面图片URL
  final String? coverUrl;

  /// 音频文件URL/路径
  final String audioUrl;

  /// 时长（秒）
  final int duration;

  /// 播放次数
  final int playCount;

  /// 数据来源 (标识, 名称)
  ///
  /// 如 `(id: 'netease', name: '网易云音乐')`、`(id: 'local', name: '本地')`
  final ({String id, String name}) source;

  /// 来源原始数据
  ///
  /// 由提供数据的模块自定义，可存储来源特有的元信息。
  /// 例如网易云模块可存 `{'song_id': 123456, 'quality': 'lossless'}`。
  final Map<String, dynamic>? meta;

  /// 创建时间
  final DateTime createdAt;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    this.albumId,
    this.albumName,
    this.coverUrl,
    required this.audioUrl,
    this.duration = 0,
    this.playCount = 0,
    required this.source,
    this.meta,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 从JSON创建
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      albumId: json['album_id'] as String?,
      albumName: json['album_name'] as String?,
      coverUrl: json['cover_url'] as String?,
      audioUrl: json['audio_url'] as String,
      duration: json['duration'] as int? ?? 0,
      playCount: json['play_count'] as int? ?? 0,
      source: json['source'] != null
          ? (
              id: (json['source'] as Map<String, dynamic>)['id'] as String,
              name: (json['source'] as Map<String, dynamic>)['name'] as String,
            )
          : (id: 'local', name: '本地'),
      meta: json['meta'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album_id': albumId,
      'album_name': albumName,
      'cover_url': coverUrl,
      'audio_url': audioUrl,
      'duration': duration,
      'play_count': playCount,
      'source': {'id': source.id, 'name': source.name},
      'meta': meta,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 格式化的时长字符串 (mm:ss)
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  String toString() => 'Song(id: $id, title: $title, artist: $artist)';
}
