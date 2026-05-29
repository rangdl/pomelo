/// musicsdk_flutter - 类型定义（统一基础模型）
/// 对应 JS SDK: src/types.ts

import 'package:json_annotation/json_annotation.dart';

part 'types.g.dart';

/// 搜索结果项
@JsonSerializable()
class SearchItem {
  final String? id;
  final String? name;
  final String? artist;
  final String? album;
  final int? duration;
  final String? coverUrl;
  final String? source;

  SearchItem({
    this.id,
    this.name,
    this.artist,
    this.album,
    this.duration,
    this.coverUrl,
    this.source,
  });

  factory SearchItem.fromJson(Map<String, dynamic> json) => _$SearchItemFromJson(json);
  Map<String, dynamic> toJson() => _$SearchItemToJson(this);
}

/// 搜索结果列表
@JsonSerializable()
class SearchResult {
  final List<SearchItem> list;
  final int total;

  SearchResult({
    required this.list,
    required this.total,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) => _$SearchResultFromJson(json);
  Map<String, dynamic> toJson() => _$SearchResultToJson(this);
}

/// 平台信息（用于 Registry.all()）
@JsonSerializable()
class PlatformInfo {
  final String id;
  final String name;

  PlatformInfo({
    required this.id,
    required this.name,
  });

  factory PlatformInfo.fromJson(Map<String, dynamic> json) => _$PlatformInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PlatformInfoToJson(this);
}

/// 错误信息包装
@JsonSerializable()
class MusicsdkError {
  final String message;
  final String? code;
  final int? httpStatus;

  MusicsdkError({
    required this.message,
    this.code,
    this.httpStatus,
  });

  factory MusicsdkError.fromJson(Map<String, dynamic> json) => _$MusicsdkErrorFromJson(json);
  Map<String, dynamic> toJson() => _$MusicsdkErrorToJson(this);
}