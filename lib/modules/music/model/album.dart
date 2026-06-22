/// 专辑模型
class Album {
  /// 专辑唯一标识
  final String id;

  /// 专辑标题
  final String title;

  /// 艺术家
  final String artist;

  /// 封面图片URL
  final String? coverUrl;

  /// 发行年份
  final int? year;

  /// 歌曲数量
  final int songCount;

  /// 简介
  final String? description;

  /// 数据来源 (服务标识, 名称, 库标识)
  final ({String id, String name, String? libraryId}) source;

  /// 来源原始数据
  final Map<String, dynamic>? meta;

  /// 创建时间
  final DateTime createdAt;

  Album({
    required this.id,
    required this.title,
    required this.artist,
    this.coverUrl,
    this.year,
    this.songCount = 0,
    this.description,
    required this.source,
    this.meta,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 从JSON创建
  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      coverUrl: json['cover_url'] as String?,
      year: json['year'] as int?,
      songCount: json['song_count'] as int? ?? 0,
      description: json['description'] as String?,
      source: json['source'] != null
          ? (
              id: (json['source'] as Map<String, dynamic>)['id'] as String,
              name: (json['source'] as Map<String, dynamic>)['name'] as String,
              libraryId: (json['source'] as Map<String, dynamic>)['libraryId'] as String?,
            )
          : (id: 'local', name: '本地', libraryId: null),
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
      'cover_url': coverUrl,
      'year': year,
      'song_count': songCount,
      'description': description,
      'source': {'id': source.id, 'name': source.name, if (source.libraryId != null) 'libraryId': source.libraryId},
      'meta': meta,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'Album(id: $id, title: $title, artist: $artist)';
}
