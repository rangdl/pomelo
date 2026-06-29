import 'package:flutter/foundation.dart';
import 'package:pomelo/core/extensions/date_time.dart';
import 'track.dart';

/// 歌单分类
///
/// 用于对歌单进行分组浏览，如"推荐""流行""摇滚"等。
@immutable
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

  /// 从 JSON 创建
  factory PlaylistCategory.fromJson(Map<String, dynamic> json) {
    return PlaylistCategory(
      id: json['id'] as String,
      name: json['name'] as String? ?? json['id'] as String,
      parentId: json['parentId'] as String?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (parentId != null) 'parentId': parentId,
    };
  }

  /// 创建副本
  PlaylistCategory copyWith({
    String? id,
    String? name,
    String? parentId,
    bool clearParentId = false,
  }) {
    return PlaylistCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: clearParentId ? null : (parentId ?? this.parentId),
    );
  }

  @override
  String toString() => 'PlaylistCategory(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistCategory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          parentId == other.parentId;

  @override
  int get hashCode => Object.hash(id, name, parentId);
}

/// 歌单模型
@immutable
class Playlist {
  /// 歌单唯一标识
  final String id;

  /// 歌单名称
  final String name;

  /// 歌单封面
  final String? coverArt;

  /// 所有者
  final String? owner;

  /// 简介
  final String? comment;

  /// 是否公开
  final bool public;

  /// 歌曲数量
  final int songCount;

  /// 总时长（秒）
  final int duration;

  /// 创建时间
  final DateTime? created;

  /// 最后修改时间
  final DateTime? changed;

  /// 曲目列表（Pomelo 扩展，默认空列表）
  final List<Track> tracks;

  /// 数据来源
  final ({String id, String name, String? libraryId, String? libraryName})?
  source;

  /// 来源原始数据
  final Map<String, dynamic>? meta;

  const Playlist({
    required this.id,
    required this.name,
    this.coverArt,
    this.owner,
    this.comment,
    this.public = false,
    this.songCount = 0,
    this.duration = 0,
    this.created,
    this.changed,
    this.tracks = const [],
    this.source,
    this.meta,
  });

  /// 从 JSON 创建
  factory Playlist.fromJson(Map<String, dynamic> json) {
    final src = json['source'] as Map<String, dynamic>?;
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      coverArt: json['coverArt'] as String? ?? json['cover_url'] as String?,
      owner: json['owner'] as String? ?? json['creator'] as String?,
      comment: json['comment'] as String? ?? json['description'] as String?,
      public: json['public'] as bool? ?? false,
      songCount: (json['songCount'] as num?)?.toInt() ??
          (json['song_count'] as num?)?.toInt() ??
          0,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      created: tryParseDateTime(json['created'] ?? json['created_at']),
      changed: tryParseDateTime(json['changed']),
      tracks: (json['tracks'] as List<dynamic>?)
              ?.map((e) => Track.fromJson(e as Map<String, dynamic>))
              .toList() ??
          (json['songs'] as List<dynamic>?)
              ?.map((e) => Track.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      source: src != null
          ? (
              id: src['id'] as String,
              name: src['name'] as String,
              libraryId: src['libraryId'] as String?,
              libraryName: src['libraryName'] as String?,
            )
          : null,
      meta: json['meta'] != null
          ? Map<String, dynamic>.from(json['meta'] as Map)
          : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (coverArt != null) 'coverArt': coverArt,
      if (owner != null) 'owner': owner,
      if (comment != null) 'comment': comment,
      'public': public,
      'songCount': songCount,
      'duration': duration,
      if (created != null) 'created': created!.toIso8601String(),
      if (changed != null) 'changed': changed!.toIso8601String(),
      'tracks': tracks.map((t) => t.toJson()).toList(),
      if (source != null)
        'source': {
          'id': source!.id,
          'name': source!.name,
          if (source!.libraryId != null) 'libraryId': source!.libraryId,
          if (source!.libraryName != null) 'libraryName': source!.libraryName,
        },
      if (meta != null) 'meta': meta,
    };
  }

  /// 创建副本
  Playlist copyWith({
    String? id,
    String? name,
    String? coverArt,
    String? owner,
    String? comment,
    bool? public,
    int? songCount,
    int? duration,
    DateTime? created,
    DateTime? changed,
    List<Track>? tracks,
    ({String id, String name, String? libraryId, String? libraryName})? source,
    Map<String, dynamic>? meta,
    bool clearCoverArt = false,
    bool clearOwner = false,
    bool clearComment = false,
    bool clearCreated = false,
    bool clearChanged = false,
    bool clearSource = false,
    bool clearMeta = false,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      coverArt: clearCoverArt ? null : (coverArt ?? this.coverArt),
      owner: clearOwner ? null : (owner ?? this.owner),
      comment: clearComment ? null : (comment ?? this.comment),
      public: public ?? this.public,
      songCount: songCount ?? this.songCount,
      duration: duration ?? this.duration,
      created: clearCreated ? null : (created ?? this.created),
      changed: clearChanged ? null : (changed ?? this.changed),
      tracks: tracks ?? this.tracks,
      source: clearSource ? null : (source ?? this.source),
      meta: clearMeta ? null : (meta ?? this.meta),
    );
  }

  @override
  String toString() =>
      'Playlist(id: $id, name: $name, tracks: ${tracks.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Playlist &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          coverArt == other.coverArt &&
          owner == other.owner &&
          comment == other.comment &&
          public == other.public &&
          songCount == other.songCount &&
          duration == other.duration &&
          created == other.created &&
          changed == other.changed;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        coverArt,
        owner,
        comment,
        public,
        songCount,
        duration,
        created,
        changed,
      );
}
