import 'song.dart';

/// 歌单分类
///
/// 用于对歌单进行分组浏览，如“推荐”“流行”“摇滚”等。
class PlaylistCategory {
  /// 分类唯一标识
  final String id;

  /// 分类显示名称
  final String name;

  /// 可选的父分类标识（用于二级分类）
  final String? parentId;

  const PlaylistCategory({
    required this.id,
    required this.name,
    this.parentId,
  });

  @override
  String toString() => 'PlaylistCategory(id: $id, name: $name)';
}

/// 歌单模型
class Playlist {
  /// 歌单唯一标识
  final String id;

  /// 歌单名称
  final String name;

  /// 歌单封面URL
  final String? coverUrl;

  /// 创建者
  final String creator;

  /// 描述
  final String? description;

  /// 歌曲列表
  final List<Song> songs;

  /// 数据来源 (标识, 名称)
  final ({String id, String name}) source;

  /// 来源原始数据
  final Map<String, dynamic>? meta;

  /// 创建时间
  final DateTime createdAt;

  Playlist({
    required this.id,
    required this.name,
    this.coverUrl,
    required this.creator,
    this.description,
    this.songs = const [],
    required this.source,
    this.meta,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 歌曲数量
  int get songCount => songs.length;

  /// 总时长（秒）
  int get totalDuration =>
      songs.fold<int>(0, (sum, song) => sum + song.duration);

  /// 从JSON创建
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      coverUrl: json['cover_url'] as String?,
      creator: json['creator'] as String,
      description: json['description'] as String?,
      songs:
          (json['songs'] as List<dynamic>?)
              ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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
      'name': name,
      'cover_url': coverUrl,
      'creator': creator,
      'description': description,
      'songs': songs.map((s) => s.toJson()).toList(),
      'source': {'id': source.id, 'name': source.name},
      'meta': meta,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'Playlist(id: $id, name: $name, songs: ${songs.length})';
}
