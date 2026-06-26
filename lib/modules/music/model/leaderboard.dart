import 'package:flutter/foundation.dart';

/// 排行榜模型
///
/// 表示音乐平台的排行榜（如热歌榜、新歌榜等）。
@immutable
class Leaderboard {
  /// 排行榜唯一标识
  final String id;

  /// 排行榜名称
  final String name;

  const Leaderboard({
    required this.id,
    required this.name,
  });

  /// 从 JSON 创建
  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    return Leaderboard(
      id: json['id'] as String,
      name: json['name'] as String? ?? json['id'] as String,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  /// 创建副本
  Leaderboard copyWith({
    String? id,
    String? name,
  }) {
    return Leaderboard(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  String toString() => 'Leaderboard(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Leaderboard &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, name);
}
