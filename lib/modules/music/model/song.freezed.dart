// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Song _$SongFromJson(Map<String, dynamic> json) {
  return _Song.fromJson(json);
}

/// @nodoc
mixin _$Song {
  String get id => throw _privateConstructorUsedError; // 歌曲唯一标识
  String get name => throw _privateConstructorUsedError; // 歌曲标题
  String get artist => throw _privateConstructorUsedError; // 艺术家
  String? get albumId => throw _privateConstructorUsedError; // 专辑ID
  String? get albumName => throw _privateConstructorUsedError; // 专辑名称
  String? get coverUrl => throw _privateConstructorUsedError; // 封面图片URL
  int get duration => throw _privateConstructorUsedError; // 时长（秒）
  /// 数据来源
  ///
  /// 如 `(id: 'netease', name: '网易云音乐')`、
  /// `(id: 'local', name: '本地')`
  ({String id, String name}) get source => throw _privateConstructorUsedError;

  /// 来源原始数据
  ///
  /// 由提供数据的模块自定义，可存储来源特有的元信息。
  /// 例如网易云模块可存 `{'song_id': 123456, 'quality': 'lossless'}`。
  Map<String, dynamic> get meta => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError; // 创建时间
  String get path => throw _privateConstructorUsedError;

  /// Serializes this Song to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SongCopyWith<Song> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SongCopyWith<$Res> {
  factory $SongCopyWith(Song value, $Res Function(Song) then) =
      _$SongCopyWithImpl<$Res, Song>;
  @useResult
  $Res call({
    String id,
    String name,
    String artist,
    String? albumId,
    String? albumName,
    String? coverUrl,
    int duration,
    ({String id, String name}) source,
    Map<String, dynamic> meta,
    DateTime? createdAt,
    String path,
  });
}

/// @nodoc
class _$SongCopyWithImpl<$Res, $Val extends Song>
    implements $SongCopyWith<$Res> {
  _$SongCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? artist = null,
    Object? albumId = freezed,
    Object? albumName = freezed,
    Object? coverUrl = freezed,
    Object? duration = null,
    Object? source = null,
    Object? meta = null,
    Object? createdAt = freezed,
    Object? path = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            artist: null == artist
                ? _value.artist
                : artist // ignore: cast_nullable_to_non_nullable
                      as String,
            albumId: freezed == albumId
                ? _value.albumId
                : albumId // ignore: cast_nullable_to_non_nullable
                      as String?,
            albumName: freezed == albumName
                ? _value.albumName
                : albumName // ignore: cast_nullable_to_non_nullable
                      as String?,
            coverUrl: freezed == coverUrl
                ? _value.coverUrl
                : coverUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as ({String id, String name}),
            meta: null == meta
                ? _value.meta
                : meta // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            path: null == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SongImplCopyWith<$Res> implements $SongCopyWith<$Res> {
  factory _$$SongImplCopyWith(
    _$SongImpl value,
    $Res Function(_$SongImpl) then,
  ) = __$$SongImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String artist,
    String? albumId,
    String? albumName,
    String? coverUrl,
    int duration,
    ({String id, String name}) source,
    Map<String, dynamic> meta,
    DateTime? createdAt,
    String path,
  });
}

/// @nodoc
class __$$SongImplCopyWithImpl<$Res>
    extends _$SongCopyWithImpl<$Res, _$SongImpl>
    implements _$$SongImplCopyWith<$Res> {
  __$$SongImplCopyWithImpl(_$SongImpl _value, $Res Function(_$SongImpl) _then)
    : super(_value, _then);

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? artist = null,
    Object? albumId = freezed,
    Object? albumName = freezed,
    Object? coverUrl = freezed,
    Object? duration = null,
    Object? source = null,
    Object? meta = null,
    Object? createdAt = freezed,
    Object? path = null,
  }) {
    return _then(
      _$SongImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        artist: null == artist
            ? _value.artist
            : artist // ignore: cast_nullable_to_non_nullable
                  as String,
        albumId: freezed == albumId
            ? _value.albumId
            : albumId // ignore: cast_nullable_to_non_nullable
                  as String?,
        albumName: freezed == albumName
            ? _value.albumName
            : albumName // ignore: cast_nullable_to_non_nullable
                  as String?,
        coverUrl: freezed == coverUrl
            ? _value.coverUrl
            : coverUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as ({String id, String name}),
        meta: null == meta
            ? _value._meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SongImpl implements _Song {
  _$SongImpl({
    required this.id,
    required this.name,
    required this.artist,
    this.albumId,
    this.albumName,
    this.coverUrl,
    this.duration = 0,
    required this.source,
    final Map<String, dynamic> meta = const {},
    this.createdAt,
    required this.path,
  }) : _meta = meta;

  factory _$SongImpl.fromJson(Map<String, dynamic> json) =>
      _$$SongImplFromJson(json);

  @override
  final String id;
  // 歌曲唯一标识
  @override
  final String name;
  // 歌曲标题
  @override
  final String artist;
  // 艺术家
  @override
  final String? albumId;
  // 专辑ID
  @override
  final String? albumName;
  // 专辑名称
  @override
  final String? coverUrl;
  // 封面图片URL
  @override
  @JsonKey()
  final int duration;
  // 时长（秒）
  /// 数据来源
  ///
  /// 如 `(id: 'netease', name: '网易云音乐')`、
  /// `(id: 'local', name: '本地')`
  @override
  final ({String id, String name}) source;

  /// 来源原始数据
  ///
  /// 由提供数据的模块自定义，可存储来源特有的元信息。
  /// 例如网易云模块可存 `{'song_id': 123456, 'quality': 'lossless'}`。
  final Map<String, dynamic> _meta;

  /// 来源原始数据
  ///
  /// 由提供数据的模块自定义，可存储来源特有的元信息。
  /// 例如网易云模块可存 `{'song_id': 123456, 'quality': 'lossless'}`。
  @override
  @JsonKey()
  Map<String, dynamic> get meta {
    if (_meta is EqualUnmodifiableMapView) return _meta;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_meta);
  }

  @override
  final DateTime? createdAt;
  // 创建时间
  @override
  final String path;

  @override
  String toString() {
    return 'Song(id: $id, name: $name, artist: $artist, albumId: $albumId, albumName: $albumName, coverUrl: $coverUrl, duration: $duration, source: $source, meta: $meta, createdAt: $createdAt, path: $path)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SongImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.artist, artist) || other.artist == artist) &&
            (identical(other.albumId, albumId) || other.albumId == albumId) &&
            (identical(other.albumName, albumName) ||
                other.albumName == albumName) &&
            (identical(other.coverUrl, coverUrl) ||
                other.coverUrl == coverUrl) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.source, source) || other.source == source) &&
            const DeepCollectionEquality().equals(other._meta, _meta) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.path, path) || other.path == path));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    artist,
    albumId,
    albumName,
    coverUrl,
    duration,
    source,
    const DeepCollectionEquality().hash(_meta),
    createdAt,
    path,
  );

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SongImplCopyWith<_$SongImpl> get copyWith =>
      __$$SongImplCopyWithImpl<_$SongImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SongImplToJson(this);
  }
}

abstract class _Song implements Song {
  factory _Song({
    required final String id,
    required final String name,
    required final String artist,
    final String? albumId,
    final String? albumName,
    final String? coverUrl,
    final int duration,
    required final ({String id, String name}) source,
    final Map<String, dynamic> meta,
    final DateTime? createdAt,
    required final String path,
  }) = _$SongImpl;

  factory _Song.fromJson(Map<String, dynamic> json) = _$SongImpl.fromJson;

  @override
  String get id; // 歌曲唯一标识
  @override
  String get name; // 歌曲标题
  @override
  String get artist; // 艺术家
  @override
  String? get albumId; // 专辑ID
  @override
  String? get albumName; // 专辑名称
  @override
  String? get coverUrl; // 封面图片URL
  @override
  int get duration; // 时长（秒）
  /// 数据来源
  ///
  /// 如 `(id: 'netease', name: '网易云音乐')`、
  /// `(id: 'local', name: '本地')`
  @override
  ({String id, String name}) get source;

  /// 来源原始数据
  ///
  /// 由提供数据的模块自定义，可存储来源特有的元信息。
  /// 例如网易云模块可存 `{'song_id': 123456, 'quality': 'lossless'}`。
  @override
  Map<String, dynamic> get meta;
  @override
  DateTime? get createdAt; // 创建时间
  @override
  String get path;

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SongImplCopyWith<_$SongImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
