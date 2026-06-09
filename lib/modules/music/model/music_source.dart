import 'package:json_annotation/json_annotation.dart';

part 'music_source.g.dart';

/// 音乐数据来源
///
/// 标识歌曲/专辑/歌单来自哪个平台。
@JsonSerializable()
class MusicSource {
  /// 来源标识，如 'netease', 'local', 'full'
  final String id;

  /// 来源显示名称，如 '网易云音乐', '本地', '完整版'
  final String name;

  const MusicSource({required this.id, required this.name});

  factory MusicSource.fromJson(Map<String, dynamic> json) =>
      _$MusicSourceFromJson(json);

  Map<String, dynamic> toJson() => _$MusicSourceToJson(this);

  @override
  bool operator ==(Object other) =>
      other is MusicSource && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'MusicSource(id: $id, name: $name)';
}

/// 常用来源常量
const localSource = MusicSource(id: 'local', name: '本地');
const fullSource = MusicSource(id: 'full', name: '完整版');

/// MusicSource 的 JsonConverter，供 Freezed/json_serializable 使用
class MusicSourceConverter
    implements JsonConverter<MusicSource, Map<String, dynamic>> {
  const MusicSourceConverter();

  @override
  MusicSource fromJson(Map<String, dynamic> json) => MusicSource.fromJson(json);

  @override
  Map<String, dynamic> toJson(MusicSource source) => source.toJson();
}
