// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PlayerStateTableTable extends PlayerStateTable
    with TableInfo<$PlayerStateTableTable, PlayerStateEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerStateTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _playingMeta = const VerificationMeta(
    'playing',
  );
  @override
  late final GeneratedColumn<bool> playing = GeneratedColumn<bool>(
    'playing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("playing" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _loopModeMeta = const VerificationMeta(
    'loopMode',
  );
  @override
  late final GeneratedColumn<String> loopMode = GeneratedColumn<String>(
    'loop_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _shuffledMeta = const VerificationMeta(
    'shuffled',
  );
  @override
  late final GeneratedColumn<bool> shuffled = GeneratedColumn<bool>(
    'shuffled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("shuffled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _currentIndexMeta = const VerificationMeta(
    'currentIndex',
  );
  @override
  late final GeneratedColumn<int> currentIndex = GeneratedColumn<int>(
    'current_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _collectionsMeta = const VerificationMeta(
    'collections',
  );
  @override
  late final GeneratedColumn<String> collections = GeneratedColumn<String>(
    'collections',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    playing,
    loopMode,
    shuffled,
    currentIndex,
    collections,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_state_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerStateEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('playing')) {
      context.handle(
        _playingMeta,
        playing.isAcceptableOrUnknown(data['playing']!, _playingMeta),
      );
    }
    if (data.containsKey('loop_mode')) {
      context.handle(
        _loopModeMeta,
        loopMode.isAcceptableOrUnknown(data['loop_mode']!, _loopModeMeta),
      );
    }
    if (data.containsKey('shuffled')) {
      context.handle(
        _shuffledMeta,
        shuffled.isAcceptableOrUnknown(data['shuffled']!, _shuffledMeta),
      );
    }
    if (data.containsKey('current_index')) {
      context.handle(
        _currentIndexMeta,
        currentIndex.isAcceptableOrUnknown(
          data['current_index']!,
          _currentIndexMeta,
        ),
      );
    }
    if (data.containsKey('collections')) {
      context.handle(
        _collectionsMeta,
        collections.isAcceptableOrUnknown(
          data['collections']!,
          _collectionsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerStateEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerStateEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      playing: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}playing'],
      )!,
      loopMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loop_mode'],
      )!,
      shuffled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}shuffled'],
      )!,
      currentIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_index'],
      )!,
      collections: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collections'],
      )!,
    );
  }

  @override
  $PlayerStateTableTable createAlias(String alias) {
    return $PlayerStateTableTable(attachedDatabase, alias);
  }
}

class PlayerStateEntity extends DataClass
    implements Insertable<PlayerStateEntity> {
  /// 固定为 0，确保单行
  final int id;

  /// 是否正在播放
  final bool playing;

  /// 循环模式：'none' | 'loop' | 'loopOne'
  final String loopMode;

  /// 是否随机播放
  final bool shuffled;

  /// 当前曲目索引
  final int currentIndex;

  /// 收藏集合 ID 列表（JSON 数组字符串）
  final String collections;
  const PlayerStateEntity({
    required this.id,
    required this.playing,
    required this.loopMode,
    required this.shuffled,
    required this.currentIndex,
    required this.collections,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['playing'] = Variable<bool>(playing);
    map['loop_mode'] = Variable<String>(loopMode);
    map['shuffled'] = Variable<bool>(shuffled);
    map['current_index'] = Variable<int>(currentIndex);
    map['collections'] = Variable<String>(collections);
    return map;
  }

  PlayerStateTableCompanion toCompanion(bool nullToAbsent) {
    return PlayerStateTableCompanion(
      id: Value(id),
      playing: Value(playing),
      loopMode: Value(loopMode),
      shuffled: Value(shuffled),
      currentIndex: Value(currentIndex),
      collections: Value(collections),
    );
  }

  factory PlayerStateEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerStateEntity(
      id: serializer.fromJson<int>(json['id']),
      playing: serializer.fromJson<bool>(json['playing']),
      loopMode: serializer.fromJson<String>(json['loopMode']),
      shuffled: serializer.fromJson<bool>(json['shuffled']),
      currentIndex: serializer.fromJson<int>(json['currentIndex']),
      collections: serializer.fromJson<String>(json['collections']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playing': serializer.toJson<bool>(playing),
      'loopMode': serializer.toJson<String>(loopMode),
      'shuffled': serializer.toJson<bool>(shuffled),
      'currentIndex': serializer.toJson<int>(currentIndex),
      'collections': serializer.toJson<String>(collections),
    };
  }

  PlayerStateEntity copyWith({
    int? id,
    bool? playing,
    String? loopMode,
    bool? shuffled,
    int? currentIndex,
    String? collections,
  }) => PlayerStateEntity(
    id: id ?? this.id,
    playing: playing ?? this.playing,
    loopMode: loopMode ?? this.loopMode,
    shuffled: shuffled ?? this.shuffled,
    currentIndex: currentIndex ?? this.currentIndex,
    collections: collections ?? this.collections,
  );
  PlayerStateEntity copyWithCompanion(PlayerStateTableCompanion data) {
    return PlayerStateEntity(
      id: data.id.present ? data.id.value : this.id,
      playing: data.playing.present ? data.playing.value : this.playing,
      loopMode: data.loopMode.present ? data.loopMode.value : this.loopMode,
      shuffled: data.shuffled.present ? data.shuffled.value : this.shuffled,
      currentIndex: data.currentIndex.present
          ? data.currentIndex.value
          : this.currentIndex,
      collections: data.collections.present
          ? data.collections.value
          : this.collections,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerStateEntity(')
          ..write('id: $id, ')
          ..write('playing: $playing, ')
          ..write('loopMode: $loopMode, ')
          ..write('shuffled: $shuffled, ')
          ..write('currentIndex: $currentIndex, ')
          ..write('collections: $collections')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, playing, loopMode, shuffled, currentIndex, collections);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerStateEntity &&
          other.id == this.id &&
          other.playing == this.playing &&
          other.loopMode == this.loopMode &&
          other.shuffled == this.shuffled &&
          other.currentIndex == this.currentIndex &&
          other.collections == this.collections);
}

class PlayerStateTableCompanion extends UpdateCompanion<PlayerStateEntity> {
  final Value<int> id;
  final Value<bool> playing;
  final Value<String> loopMode;
  final Value<bool> shuffled;
  final Value<int> currentIndex;
  final Value<String> collections;
  const PlayerStateTableCompanion({
    this.id = const Value.absent(),
    this.playing = const Value.absent(),
    this.loopMode = const Value.absent(),
    this.shuffled = const Value.absent(),
    this.currentIndex = const Value.absent(),
    this.collections = const Value.absent(),
  });
  PlayerStateTableCompanion.insert({
    this.id = const Value.absent(),
    this.playing = const Value.absent(),
    this.loopMode = const Value.absent(),
    this.shuffled = const Value.absent(),
    this.currentIndex = const Value.absent(),
    this.collections = const Value.absent(),
  });
  static Insertable<PlayerStateEntity> custom({
    Expression<int>? id,
    Expression<bool>? playing,
    Expression<String>? loopMode,
    Expression<bool>? shuffled,
    Expression<int>? currentIndex,
    Expression<String>? collections,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playing != null) 'playing': playing,
      if (loopMode != null) 'loop_mode': loopMode,
      if (shuffled != null) 'shuffled': shuffled,
      if (currentIndex != null) 'current_index': currentIndex,
      if (collections != null) 'collections': collections,
    });
  }

  PlayerStateTableCompanion copyWith({
    Value<int>? id,
    Value<bool>? playing,
    Value<String>? loopMode,
    Value<bool>? shuffled,
    Value<int>? currentIndex,
    Value<String>? collections,
  }) {
    return PlayerStateTableCompanion(
      id: id ?? this.id,
      playing: playing ?? this.playing,
      loopMode: loopMode ?? this.loopMode,
      shuffled: shuffled ?? this.shuffled,
      currentIndex: currentIndex ?? this.currentIndex,
      collections: collections ?? this.collections,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (playing.present) {
      map['playing'] = Variable<bool>(playing.value);
    }
    if (loopMode.present) {
      map['loop_mode'] = Variable<String>(loopMode.value);
    }
    if (shuffled.present) {
      map['shuffled'] = Variable<bool>(shuffled.value);
    }
    if (currentIndex.present) {
      map['current_index'] = Variable<int>(currentIndex.value);
    }
    if (collections.present) {
      map['collections'] = Variable<String>(collections.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerStateTableCompanion(')
          ..write('id: $id, ')
          ..write('playing: $playing, ')
          ..write('loopMode: $loopMode, ')
          ..write('shuffled: $shuffled, ')
          ..write('currentIndex: $currentIndex, ')
          ..write('collections: $collections')
          ..write(')'))
        .toString();
  }
}

class $PlayerTrackTableTable extends PlayerTrackTable
    with TableInfo<$PlayerTrackTableTable, PlayerTrackEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerTrackTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackJsonMeta = const VerificationMeta(
    'trackJson',
  );
  @override
  late final GeneratedColumn<String> trackJson = GeneratedColumn<String>(
    'track_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, orderIndex, trackId, trackJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_track_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerTrackEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('track_json')) {
      context.handle(
        _trackJsonMeta,
        trackJson.isAcceptableOrUnknown(data['track_json']!, _trackJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_trackJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerTrackEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerTrackEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      trackJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_json'],
      )!,
    );
  }

  @override
  $PlayerTrackTableTable createAlias(String alias) {
    return $PlayerTrackTableTable(attachedDatabase, alias);
  }
}

class PlayerTrackEntity extends DataClass
    implements Insertable<PlayerTrackEntity> {
  /// 自增主键
  final int id;

  /// 在播放列表中的顺序
  final int orderIndex;

  /// 曲目 ID（用于快速查找）
  final String trackId;

  /// 完整曲目 JSON
  final String trackJson;
  const PlayerTrackEntity({
    required this.id,
    required this.orderIndex,
    required this.trackId,
    required this.trackJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_index'] = Variable<int>(orderIndex);
    map['track_id'] = Variable<String>(trackId);
    map['track_json'] = Variable<String>(trackJson);
    return map;
  }

  PlayerTrackTableCompanion toCompanion(bool nullToAbsent) {
    return PlayerTrackTableCompanion(
      id: Value(id),
      orderIndex: Value(orderIndex),
      trackId: Value(trackId),
      trackJson: Value(trackJson),
    );
  }

  factory PlayerTrackEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerTrackEntity(
      id: serializer.fromJson<int>(json['id']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      trackId: serializer.fromJson<String>(json['trackId']),
      trackJson: serializer.fromJson<String>(json['trackJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'trackId': serializer.toJson<String>(trackId),
      'trackJson': serializer.toJson<String>(trackJson),
    };
  }

  PlayerTrackEntity copyWith({
    int? id,
    int? orderIndex,
    String? trackId,
    String? trackJson,
  }) => PlayerTrackEntity(
    id: id ?? this.id,
    orderIndex: orderIndex ?? this.orderIndex,
    trackId: trackId ?? this.trackId,
    trackJson: trackJson ?? this.trackJson,
  );
  PlayerTrackEntity copyWithCompanion(PlayerTrackTableCompanion data) {
    return PlayerTrackEntity(
      id: data.id.present ? data.id.value : this.id,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      trackJson: data.trackJson.present ? data.trackJson.value : this.trackJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerTrackEntity(')
          ..write('id: $id, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('trackId: $trackId, ')
          ..write('trackJson: $trackJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, orderIndex, trackId, trackJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerTrackEntity &&
          other.id == this.id &&
          other.orderIndex == this.orderIndex &&
          other.trackId == this.trackId &&
          other.trackJson == this.trackJson);
}

class PlayerTrackTableCompanion extends UpdateCompanion<PlayerTrackEntity> {
  final Value<int> id;
  final Value<int> orderIndex;
  final Value<String> trackId;
  final Value<String> trackJson;
  const PlayerTrackTableCompanion({
    this.id = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.trackId = const Value.absent(),
    this.trackJson = const Value.absent(),
  });
  PlayerTrackTableCompanion.insert({
    this.id = const Value.absent(),
    required int orderIndex,
    required String trackId,
    required String trackJson,
  }) : orderIndex = Value(orderIndex),
       trackId = Value(trackId),
       trackJson = Value(trackJson);
  static Insertable<PlayerTrackEntity> custom({
    Expression<int>? id,
    Expression<int>? orderIndex,
    Expression<String>? trackId,
    Expression<String>? trackJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderIndex != null) 'order_index': orderIndex,
      if (trackId != null) 'track_id': trackId,
      if (trackJson != null) 'track_json': trackJson,
    });
  }

  PlayerTrackTableCompanion copyWith({
    Value<int>? id,
    Value<int>? orderIndex,
    Value<String>? trackId,
    Value<String>? trackJson,
  }) {
    return PlayerTrackTableCompanion(
      id: id ?? this.id,
      orderIndex: orderIndex ?? this.orderIndex,
      trackId: trackId ?? this.trackId,
      trackJson: trackJson ?? this.trackJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (trackJson.present) {
      map['track_json'] = Variable<String>(trackJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerTrackTableCompanion(')
          ..write('id: $id, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('trackId: $trackId, ')
          ..write('trackJson: $trackJson')
          ..write(')'))
        .toString();
  }
}

class $PlayHistoryTableTable extends PlayHistoryTable
    with TableInfo<$PlayHistoryTableTable, PlayHistoryEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackJsonMeta = const VerificationMeta(
    'trackJson',
  );
  @override
  late final GeneratedColumn<String> trackJson = GeneratedColumn<String>(
    'track_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceNameMeta = const VerificationMeta(
    'sourceName',
  );
  @override
  late final GeneratedColumn<String> sourceName = GeneratedColumn<String>(
    'source_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverArtMeta = const VerificationMeta(
    'coverArt',
  );
  @override
  late final GeneratedColumn<String> coverArt = GeneratedColumn<String>(
    'cover_art',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trackId,
    trackJson,
    sourceId,
    sourceName,
    title,
    artist,
    coverArt,
    duration,
    playedAt,
    playCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'play_history_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayHistoryEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('track_json')) {
      context.handle(
        _trackJsonMeta,
        trackJson.isAcceptableOrUnknown(data['track_json']!, _trackJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_trackJsonMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('source_name')) {
      context.handle(
        _sourceNameMeta,
        sourceName.isAcceptableOrUnknown(data['source_name']!, _sourceNameMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('cover_art')) {
      context.handle(
        _coverArtMeta,
        coverArt.isAcceptableOrUnknown(data['cover_art']!, _coverArtMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayHistoryEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayHistoryEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      trackJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_json'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      sourceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_name'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      coverArt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art'],
      ),
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}played_at'],
      )!,
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
    );
  }

  @override
  $PlayHistoryTableTable createAlias(String alias) {
    return $PlayHistoryTableTable(attachedDatabase, alias);
  }
}

class PlayHistoryEntity extends DataClass
    implements Insertable<PlayHistoryEntity> {
  /// 自增主键
  final int id;

  /// 曲目 ID
  final String trackId;

  /// 完整曲目 JSON（用于恢复完整信息）
  final String trackJson;

  /// 来源 ID
  final String sourceId;

  /// 来源名称
  final String sourceName;

  /// 曲目标题
  final String title;

  /// 艺术家
  final String? artist;

  /// 封面
  final String? coverArt;

  /// 时长（秒）
  final int duration;

  /// 播放时间（最后一次播放）
  final DateTime playedAt;

  /// 播放次数
  final int playCount;
  const PlayHistoryEntity({
    required this.id,
    required this.trackId,
    required this.trackJson,
    required this.sourceId,
    required this.sourceName,
    required this.title,
    this.artist,
    this.coverArt,
    required this.duration,
    required this.playedAt,
    required this.playCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['track_id'] = Variable<String>(trackId);
    map['track_json'] = Variable<String>(trackJson);
    map['source_id'] = Variable<String>(sourceId);
    map['source_name'] = Variable<String>(sourceName);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || coverArt != null) {
      map['cover_art'] = Variable<String>(coverArt);
    }
    map['duration'] = Variable<int>(duration);
    map['played_at'] = Variable<DateTime>(playedAt);
    map['play_count'] = Variable<int>(playCount);
    return map;
  }

  PlayHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return PlayHistoryTableCompanion(
      id: Value(id),
      trackId: Value(trackId),
      trackJson: Value(trackJson),
      sourceId: Value(sourceId),
      sourceName: Value(sourceName),
      title: Value(title),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      coverArt: coverArt == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArt),
      duration: Value(duration),
      playedAt: Value(playedAt),
      playCount: Value(playCount),
    );
  }

  factory PlayHistoryEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayHistoryEntity(
      id: serializer.fromJson<int>(json['id']),
      trackId: serializer.fromJson<String>(json['trackId']),
      trackJson: serializer.fromJson<String>(json['trackJson']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      sourceName: serializer.fromJson<String>(json['sourceName']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String?>(json['artist']),
      coverArt: serializer.fromJson<String?>(json['coverArt']),
      duration: serializer.fromJson<int>(json['duration']),
      playedAt: serializer.fromJson<DateTime>(json['playedAt']),
      playCount: serializer.fromJson<int>(json['playCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'trackId': serializer.toJson<String>(trackId),
      'trackJson': serializer.toJson<String>(trackJson),
      'sourceId': serializer.toJson<String>(sourceId),
      'sourceName': serializer.toJson<String>(sourceName),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String?>(artist),
      'coverArt': serializer.toJson<String?>(coverArt),
      'duration': serializer.toJson<int>(duration),
      'playedAt': serializer.toJson<DateTime>(playedAt),
      'playCount': serializer.toJson<int>(playCount),
    };
  }

  PlayHistoryEntity copyWith({
    int? id,
    String? trackId,
    String? trackJson,
    String? sourceId,
    String? sourceName,
    String? title,
    Value<String?> artist = const Value.absent(),
    Value<String?> coverArt = const Value.absent(),
    int? duration,
    DateTime? playedAt,
    int? playCount,
  }) => PlayHistoryEntity(
    id: id ?? this.id,
    trackId: trackId ?? this.trackId,
    trackJson: trackJson ?? this.trackJson,
    sourceId: sourceId ?? this.sourceId,
    sourceName: sourceName ?? this.sourceName,
    title: title ?? this.title,
    artist: artist.present ? artist.value : this.artist,
    coverArt: coverArt.present ? coverArt.value : this.coverArt,
    duration: duration ?? this.duration,
    playedAt: playedAt ?? this.playedAt,
    playCount: playCount ?? this.playCount,
  );
  PlayHistoryEntity copyWithCompanion(PlayHistoryTableCompanion data) {
    return PlayHistoryEntity(
      id: data.id.present ? data.id.value : this.id,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      trackJson: data.trackJson.present ? data.trackJson.value : this.trackJson,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      sourceName: data.sourceName.present
          ? data.sourceName.value
          : this.sourceName,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      coverArt: data.coverArt.present ? data.coverArt.value : this.coverArt,
      duration: data.duration.present ? data.duration.value : this.duration,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayHistoryEntity(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('trackJson: $trackJson, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourceName: $sourceName, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('coverArt: $coverArt, ')
          ..write('duration: $duration, ')
          ..write('playedAt: $playedAt, ')
          ..write('playCount: $playCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    trackId,
    trackJson,
    sourceId,
    sourceName,
    title,
    artist,
    coverArt,
    duration,
    playedAt,
    playCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayHistoryEntity &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.trackJson == this.trackJson &&
          other.sourceId == this.sourceId &&
          other.sourceName == this.sourceName &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.coverArt == this.coverArt &&
          other.duration == this.duration &&
          other.playedAt == this.playedAt &&
          other.playCount == this.playCount);
}

class PlayHistoryTableCompanion extends UpdateCompanion<PlayHistoryEntity> {
  final Value<int> id;
  final Value<String> trackId;
  final Value<String> trackJson;
  final Value<String> sourceId;
  final Value<String> sourceName;
  final Value<String> title;
  final Value<String?> artist;
  final Value<String?> coverArt;
  final Value<int> duration;
  final Value<DateTime> playedAt;
  final Value<int> playCount;
  const PlayHistoryTableCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.trackJson = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.duration = const Value.absent(),
    this.playedAt = const Value.absent(),
    this.playCount = const Value.absent(),
  });
  PlayHistoryTableCompanion.insert({
    this.id = const Value.absent(),
    required String trackId,
    required String trackJson,
    required String sourceId,
    this.sourceName = const Value.absent(),
    required String title,
    this.artist = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.duration = const Value.absent(),
    this.playedAt = const Value.absent(),
    this.playCount = const Value.absent(),
  }) : trackId = Value(trackId),
       trackJson = Value(trackJson),
       sourceId = Value(sourceId),
       title = Value(title);
  static Insertable<PlayHistoryEntity> custom({
    Expression<int>? id,
    Expression<String>? trackId,
    Expression<String>? trackJson,
    Expression<String>? sourceId,
    Expression<String>? sourceName,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? coverArt,
    Expression<int>? duration,
    Expression<DateTime>? playedAt,
    Expression<int>? playCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (trackJson != null) 'track_json': trackJson,
      if (sourceId != null) 'source_id': sourceId,
      if (sourceName != null) 'source_name': sourceName,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (coverArt != null) 'cover_art': coverArt,
      if (duration != null) 'duration': duration,
      if (playedAt != null) 'played_at': playedAt,
      if (playCount != null) 'play_count': playCount,
    });
  }

  PlayHistoryTableCompanion copyWith({
    Value<int>? id,
    Value<String>? trackId,
    Value<String>? trackJson,
    Value<String>? sourceId,
    Value<String>? sourceName,
    Value<String>? title,
    Value<String?>? artist,
    Value<String?>? coverArt,
    Value<int>? duration,
    Value<DateTime>? playedAt,
    Value<int>? playCount,
  }) {
    return PlayHistoryTableCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      trackJson: trackJson ?? this.trackJson,
      sourceId: sourceId ?? this.sourceId,
      sourceName: sourceName ?? this.sourceName,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      coverArt: coverArt ?? this.coverArt,
      duration: duration ?? this.duration,
      playedAt: playedAt ?? this.playedAt,
      playCount: playCount ?? this.playCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (trackJson.present) {
      map['track_json'] = Variable<String>(trackJson.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (sourceName.present) {
      map['source_name'] = Variable<String>(sourceName.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (coverArt.present) {
      map['cover_art'] = Variable<String>(coverArt.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('trackJson: $trackJson, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourceName: $sourceName, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('coverArt: $coverArt, ')
          ..write('duration: $duration, ')
          ..write('playedAt: $playedAt, ')
          ..write('playCount: $playCount')
          ..write(')'))
        .toString();
  }
}

class $SourcedTrackTableTable extends SourcedTrackTable
    with TableInfo<$SourcedTrackTableTable, SourcedTrackEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourcedTrackTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _libraryIdMeta = const VerificationMeta(
    'libraryId',
  );
  @override
  late final GeneratedColumn<String> libraryId = GeneratedColumn<String>(
    'library_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qualitiesMeta = const VerificationMeta(
    'qualities',
  );
  @override
  late final GeneratedColumn<String> qualities = GeneratedColumn<String>(
    'qualities',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _urlMapMeta = const VerificationMeta('urlMap');
  @override
  late final GeneratedColumn<String> urlMap = GeneratedColumn<String>(
    'url_map',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _cachePathMapMeta = const VerificationMeta(
    'cachePathMap',
  );
  @override
  late final GeneratedColumn<String> cachePathMap = GeneratedColumn<String>(
    'cache_path_map',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    trackId,
    sourceId,
    libraryId,
    qualities,
    urlMap,
    cachePathMap,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sourced_track_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SourcedTrackEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('library_id')) {
      context.handle(
        _libraryIdMeta,
        libraryId.isAcceptableOrUnknown(data['library_id']!, _libraryIdMeta),
      );
    }
    if (data.containsKey('qualities')) {
      context.handle(
        _qualitiesMeta,
        qualities.isAcceptableOrUnknown(data['qualities']!, _qualitiesMeta),
      );
    }
    if (data.containsKey('url_map')) {
      context.handle(
        _urlMapMeta,
        urlMap.isAcceptableOrUnknown(data['url_map']!, _urlMapMeta),
      );
    }
    if (data.containsKey('cache_path_map')) {
      context.handle(
        _cachePathMapMeta,
        cachePathMap.isAcceptableOrUnknown(
          data['cache_path_map']!,
          _cachePathMapMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  SourcedTrackEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SourcedTrackEntity(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      libraryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}library_id'],
      ),
      qualities: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qualities'],
      )!,
      urlMap: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url_map'],
      )!,
      cachePathMap: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_path_map'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SourcedTrackTableTable createAlias(String alias) {
    return $SourcedTrackTableTable(attachedDatabase, alias);
  }
}

class SourcedTrackEntity extends DataClass
    implements Insertable<SourcedTrackEntity> {
  /// 曲目 ID（主键）
  final String trackId;

  /// 来源服务 ID
  final String sourceId;

  /// 库 ID（可空）
  final String? libraryId;

  /// 可用音质列表（JSON 数组字符串，如 `["flac","320k","128k"]`）
  final String qualities;

  /// 音质 → 播放链接映射（JSON 对象，如 `{"flac":"https://...","320k":"https://..."}`)
  final String urlMap;

  /// 音质 → 本地缓存文件路径映射（JSON 对象）
  final String cachePathMap;

  /// 最后更新时间
  final DateTime updatedAt;
  const SourcedTrackEntity({
    required this.trackId,
    required this.sourceId,
    this.libraryId,
    required this.qualities,
    required this.urlMap,
    required this.cachePathMap,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['source_id'] = Variable<String>(sourceId);
    if (!nullToAbsent || libraryId != null) {
      map['library_id'] = Variable<String>(libraryId);
    }
    map['qualities'] = Variable<String>(qualities);
    map['url_map'] = Variable<String>(urlMap);
    map['cache_path_map'] = Variable<String>(cachePathMap);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SourcedTrackTableCompanion toCompanion(bool nullToAbsent) {
    return SourcedTrackTableCompanion(
      trackId: Value(trackId),
      sourceId: Value(sourceId),
      libraryId: libraryId == null && nullToAbsent
          ? const Value.absent()
          : Value(libraryId),
      qualities: Value(qualities),
      urlMap: Value(urlMap),
      cachePathMap: Value(cachePathMap),
      updatedAt: Value(updatedAt),
    );
  }

  factory SourcedTrackEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SourcedTrackEntity(
      trackId: serializer.fromJson<String>(json['trackId']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      libraryId: serializer.fromJson<String?>(json['libraryId']),
      qualities: serializer.fromJson<String>(json['qualities']),
      urlMap: serializer.fromJson<String>(json['urlMap']),
      cachePathMap: serializer.fromJson<String>(json['cachePathMap']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'sourceId': serializer.toJson<String>(sourceId),
      'libraryId': serializer.toJson<String?>(libraryId),
      'qualities': serializer.toJson<String>(qualities),
      'urlMap': serializer.toJson<String>(urlMap),
      'cachePathMap': serializer.toJson<String>(cachePathMap),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SourcedTrackEntity copyWith({
    String? trackId,
    String? sourceId,
    Value<String?> libraryId = const Value.absent(),
    String? qualities,
    String? urlMap,
    String? cachePathMap,
    DateTime? updatedAt,
  }) => SourcedTrackEntity(
    trackId: trackId ?? this.trackId,
    sourceId: sourceId ?? this.sourceId,
    libraryId: libraryId.present ? libraryId.value : this.libraryId,
    qualities: qualities ?? this.qualities,
    urlMap: urlMap ?? this.urlMap,
    cachePathMap: cachePathMap ?? this.cachePathMap,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SourcedTrackEntity copyWithCompanion(SourcedTrackTableCompanion data) {
    return SourcedTrackEntity(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      libraryId: data.libraryId.present ? data.libraryId.value : this.libraryId,
      qualities: data.qualities.present ? data.qualities.value : this.qualities,
      urlMap: data.urlMap.present ? data.urlMap.value : this.urlMap,
      cachePathMap: data.cachePathMap.present
          ? data.cachePathMap.value
          : this.cachePathMap,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SourcedTrackEntity(')
          ..write('trackId: $trackId, ')
          ..write('sourceId: $sourceId, ')
          ..write('libraryId: $libraryId, ')
          ..write('qualities: $qualities, ')
          ..write('urlMap: $urlMap, ')
          ..write('cachePathMap: $cachePathMap, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    trackId,
    sourceId,
    libraryId,
    qualities,
    urlMap,
    cachePathMap,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SourcedTrackEntity &&
          other.trackId == this.trackId &&
          other.sourceId == this.sourceId &&
          other.libraryId == this.libraryId &&
          other.qualities == this.qualities &&
          other.urlMap == this.urlMap &&
          other.cachePathMap == this.cachePathMap &&
          other.updatedAt == this.updatedAt);
}

class SourcedTrackTableCompanion extends UpdateCompanion<SourcedTrackEntity> {
  final Value<String> trackId;
  final Value<String> sourceId;
  final Value<String?> libraryId;
  final Value<String> qualities;
  final Value<String> urlMap;
  final Value<String> cachePathMap;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SourcedTrackTableCompanion({
    this.trackId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.libraryId = const Value.absent(),
    this.qualities = const Value.absent(),
    this.urlMap = const Value.absent(),
    this.cachePathMap = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SourcedTrackTableCompanion.insert({
    required String trackId,
    required String sourceId,
    this.libraryId = const Value.absent(),
    this.qualities = const Value.absent(),
    this.urlMap = const Value.absent(),
    this.cachePathMap = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId),
       sourceId = Value(sourceId);
  static Insertable<SourcedTrackEntity> custom({
    Expression<String>? trackId,
    Expression<String>? sourceId,
    Expression<String>? libraryId,
    Expression<String>? qualities,
    Expression<String>? urlMap,
    Expression<String>? cachePathMap,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (sourceId != null) 'source_id': sourceId,
      if (libraryId != null) 'library_id': libraryId,
      if (qualities != null) 'qualities': qualities,
      if (urlMap != null) 'url_map': urlMap,
      if (cachePathMap != null) 'cache_path_map': cachePathMap,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SourcedTrackTableCompanion copyWith({
    Value<String>? trackId,
    Value<String>? sourceId,
    Value<String?>? libraryId,
    Value<String>? qualities,
    Value<String>? urlMap,
    Value<String>? cachePathMap,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SourcedTrackTableCompanion(
      trackId: trackId ?? this.trackId,
      sourceId: sourceId ?? this.sourceId,
      libraryId: libraryId ?? this.libraryId,
      qualities: qualities ?? this.qualities,
      urlMap: urlMap ?? this.urlMap,
      cachePathMap: cachePathMap ?? this.cachePathMap,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (libraryId.present) {
      map['library_id'] = Variable<String>(libraryId.value);
    }
    if (qualities.present) {
      map['qualities'] = Variable<String>(qualities.value);
    }
    if (urlMap.present) {
      map['url_map'] = Variable<String>(urlMap.value);
    }
    if (cachePathMap.present) {
      map['cache_path_map'] = Variable<String>(cachePathMap.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourcedTrackTableCompanion(')
          ..write('trackId: $trackId, ')
          ..write('sourceId: $sourceId, ')
          ..write('libraryId: $libraryId, ')
          ..write('qualities: $qualities, ')
          ..write('urlMap: $urlMap, ')
          ..write('cachePathMap: $cachePathMap, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlayerStateTableTable playerStateTable = $PlayerStateTableTable(
    this,
  );
  late final $PlayerTrackTableTable playerTrackTable = $PlayerTrackTableTable(
    this,
  );
  late final $PlayHistoryTableTable playHistoryTable = $PlayHistoryTableTable(
    this,
  );
  late final $SourcedTrackTableTable sourcedTrackTable =
      $SourcedTrackTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    playerStateTable,
    playerTrackTable,
    playHistoryTable,
    sourcedTrackTable,
  ];
}

typedef $$PlayerStateTableTableCreateCompanionBuilder =
    PlayerStateTableCompanion Function({
      Value<int> id,
      Value<bool> playing,
      Value<String> loopMode,
      Value<bool> shuffled,
      Value<int> currentIndex,
      Value<String> collections,
    });
typedef $$PlayerStateTableTableUpdateCompanionBuilder =
    PlayerStateTableCompanion Function({
      Value<int> id,
      Value<bool> playing,
      Value<String> loopMode,
      Value<bool> shuffled,
      Value<int> currentIndex,
      Value<String> collections,
    });

class $$PlayerStateTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerStateTableTable> {
  $$PlayerStateTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get playing => $composableBuilder(
    column: $table.playing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loopMode => $composableBuilder(
    column: $table.loopMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shuffled => $composableBuilder(
    column: $table.shuffled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collections => $composableBuilder(
    column: $table.collections,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayerStateTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerStateTableTable> {
  $$PlayerStateTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get playing => $composableBuilder(
    column: $table.playing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loopMode => $composableBuilder(
    column: $table.loopMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shuffled => $composableBuilder(
    column: $table.shuffled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collections => $composableBuilder(
    column: $table.collections,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayerStateTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerStateTableTable> {
  $$PlayerStateTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get playing =>
      $composableBuilder(column: $table.playing, builder: (column) => column);

  GeneratedColumn<String> get loopMode =>
      $composableBuilder(column: $table.loopMode, builder: (column) => column);

  GeneratedColumn<bool> get shuffled =>
      $composableBuilder(column: $table.shuffled, builder: (column) => column);

  GeneratedColumn<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collections => $composableBuilder(
    column: $table.collections,
    builder: (column) => column,
  );
}

class $$PlayerStateTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayerStateTableTable,
          PlayerStateEntity,
          $$PlayerStateTableTableFilterComposer,
          $$PlayerStateTableTableOrderingComposer,
          $$PlayerStateTableTableAnnotationComposer,
          $$PlayerStateTableTableCreateCompanionBuilder,
          $$PlayerStateTableTableUpdateCompanionBuilder,
          (
            PlayerStateEntity,
            BaseReferences<
              _$AppDatabase,
              $PlayerStateTableTable,
              PlayerStateEntity
            >,
          ),
          PlayerStateEntity,
          PrefetchHooks Function()
        > {
  $$PlayerStateTableTableTableManager(
    _$AppDatabase db,
    $PlayerStateTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerStateTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerStateTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerStateTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> playing = const Value.absent(),
                Value<String> loopMode = const Value.absent(),
                Value<bool> shuffled = const Value.absent(),
                Value<int> currentIndex = const Value.absent(),
                Value<String> collections = const Value.absent(),
              }) => PlayerStateTableCompanion(
                id: id,
                playing: playing,
                loopMode: loopMode,
                shuffled: shuffled,
                currentIndex: currentIndex,
                collections: collections,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> playing = const Value.absent(),
                Value<String> loopMode = const Value.absent(),
                Value<bool> shuffled = const Value.absent(),
                Value<int> currentIndex = const Value.absent(),
                Value<String> collections = const Value.absent(),
              }) => PlayerStateTableCompanion.insert(
                id: id,
                playing: playing,
                loopMode: loopMode,
                shuffled: shuffled,
                currentIndex: currentIndex,
                collections: collections,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayerStateTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayerStateTableTable,
      PlayerStateEntity,
      $$PlayerStateTableTableFilterComposer,
      $$PlayerStateTableTableOrderingComposer,
      $$PlayerStateTableTableAnnotationComposer,
      $$PlayerStateTableTableCreateCompanionBuilder,
      $$PlayerStateTableTableUpdateCompanionBuilder,
      (
        PlayerStateEntity,
        BaseReferences<
          _$AppDatabase,
          $PlayerStateTableTable,
          PlayerStateEntity
        >,
      ),
      PlayerStateEntity,
      PrefetchHooks Function()
    >;
typedef $$PlayerTrackTableTableCreateCompanionBuilder =
    PlayerTrackTableCompanion Function({
      Value<int> id,
      required int orderIndex,
      required String trackId,
      required String trackJson,
    });
typedef $$PlayerTrackTableTableUpdateCompanionBuilder =
    PlayerTrackTableCompanion Function({
      Value<int> id,
      Value<int> orderIndex,
      Value<String> trackId,
      Value<String> trackJson,
    });

class $$PlayerTrackTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerTrackTableTable> {
  $$PlayerTrackTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackJson => $composableBuilder(
    column: $table.trackJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayerTrackTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerTrackTableTable> {
  $$PlayerTrackTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackJson => $composableBuilder(
    column: $table.trackJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayerTrackTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerTrackTableTable> {
  $$PlayerTrackTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get trackJson =>
      $composableBuilder(column: $table.trackJson, builder: (column) => column);
}

class $$PlayerTrackTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayerTrackTableTable,
          PlayerTrackEntity,
          $$PlayerTrackTableTableFilterComposer,
          $$PlayerTrackTableTableOrderingComposer,
          $$PlayerTrackTableTableAnnotationComposer,
          $$PlayerTrackTableTableCreateCompanionBuilder,
          $$PlayerTrackTableTableUpdateCompanionBuilder,
          (
            PlayerTrackEntity,
            BaseReferences<
              _$AppDatabase,
              $PlayerTrackTableTable,
              PlayerTrackEntity
            >,
          ),
          PlayerTrackEntity,
          PrefetchHooks Function()
        > {
  $$PlayerTrackTableTableTableManager(
    _$AppDatabase db,
    $PlayerTrackTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerTrackTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerTrackTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerTrackTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<String> trackJson = const Value.absent(),
              }) => PlayerTrackTableCompanion(
                id: id,
                orderIndex: orderIndex,
                trackId: trackId,
                trackJson: trackJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int orderIndex,
                required String trackId,
                required String trackJson,
              }) => PlayerTrackTableCompanion.insert(
                id: id,
                orderIndex: orderIndex,
                trackId: trackId,
                trackJson: trackJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayerTrackTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayerTrackTableTable,
      PlayerTrackEntity,
      $$PlayerTrackTableTableFilterComposer,
      $$PlayerTrackTableTableOrderingComposer,
      $$PlayerTrackTableTableAnnotationComposer,
      $$PlayerTrackTableTableCreateCompanionBuilder,
      $$PlayerTrackTableTableUpdateCompanionBuilder,
      (
        PlayerTrackEntity,
        BaseReferences<
          _$AppDatabase,
          $PlayerTrackTableTable,
          PlayerTrackEntity
        >,
      ),
      PlayerTrackEntity,
      PrefetchHooks Function()
    >;
typedef $$PlayHistoryTableTableCreateCompanionBuilder =
    PlayHistoryTableCompanion Function({
      Value<int> id,
      required String trackId,
      required String trackJson,
      required String sourceId,
      Value<String> sourceName,
      required String title,
      Value<String?> artist,
      Value<String?> coverArt,
      Value<int> duration,
      Value<DateTime> playedAt,
      Value<int> playCount,
    });
typedef $$PlayHistoryTableTableUpdateCompanionBuilder =
    PlayHistoryTableCompanion Function({
      Value<int> id,
      Value<String> trackId,
      Value<String> trackJson,
      Value<String> sourceId,
      Value<String> sourceName,
      Value<String> title,
      Value<String?> artist,
      Value<String?> coverArt,
      Value<int> duration,
      Value<DateTime> playedAt,
      Value<int> playCount,
    });

class $$PlayHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlayHistoryTableTable> {
  $$PlayHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackJson => $composableBuilder(
    column: $table.trackJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayHistoryTableTable> {
  $$PlayHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackJson => $composableBuilder(
    column: $table.trackJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayHistoryTableTable> {
  $$PlayHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get trackJson =>
      $composableBuilder(column: $table.trackJson, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get coverArt =>
      $composableBuilder(column: $table.coverArt, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);
}

class $$PlayHistoryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayHistoryTableTable,
          PlayHistoryEntity,
          $$PlayHistoryTableTableFilterComposer,
          $$PlayHistoryTableTableOrderingComposer,
          $$PlayHistoryTableTableAnnotationComposer,
          $$PlayHistoryTableTableCreateCompanionBuilder,
          $$PlayHistoryTableTableUpdateCompanionBuilder,
          (
            PlayHistoryEntity,
            BaseReferences<
              _$AppDatabase,
              $PlayHistoryTableTable,
              PlayHistoryEntity
            >,
          ),
          PlayHistoryEntity,
          PrefetchHooks Function()
        > {
  $$PlayHistoryTableTableTableManager(
    _$AppDatabase db,
    $PlayHistoryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayHistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayHistoryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayHistoryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<String> trackJson = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> sourceName = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
                Value<int> playCount = const Value.absent(),
              }) => PlayHistoryTableCompanion(
                id: id,
                trackId: trackId,
                trackJson: trackJson,
                sourceId: sourceId,
                sourceName: sourceName,
                title: title,
                artist: artist,
                coverArt: coverArt,
                duration: duration,
                playedAt: playedAt,
                playCount: playCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String trackId,
                required String trackJson,
                required String sourceId,
                Value<String> sourceName = const Value.absent(),
                required String title,
                Value<String?> artist = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
                Value<int> playCount = const Value.absent(),
              }) => PlayHistoryTableCompanion.insert(
                id: id,
                trackId: trackId,
                trackJson: trackJson,
                sourceId: sourceId,
                sourceName: sourceName,
                title: title,
                artist: artist,
                coverArt: coverArt,
                duration: duration,
                playedAt: playedAt,
                playCount: playCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayHistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayHistoryTableTable,
      PlayHistoryEntity,
      $$PlayHistoryTableTableFilterComposer,
      $$PlayHistoryTableTableOrderingComposer,
      $$PlayHistoryTableTableAnnotationComposer,
      $$PlayHistoryTableTableCreateCompanionBuilder,
      $$PlayHistoryTableTableUpdateCompanionBuilder,
      (
        PlayHistoryEntity,
        BaseReferences<
          _$AppDatabase,
          $PlayHistoryTableTable,
          PlayHistoryEntity
        >,
      ),
      PlayHistoryEntity,
      PrefetchHooks Function()
    >;
typedef $$SourcedTrackTableTableCreateCompanionBuilder =
    SourcedTrackTableCompanion Function({
      required String trackId,
      required String sourceId,
      Value<String?> libraryId,
      Value<String> qualities,
      Value<String> urlMap,
      Value<String> cachePathMap,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$SourcedTrackTableTableUpdateCompanionBuilder =
    SourcedTrackTableCompanion Function({
      Value<String> trackId,
      Value<String> sourceId,
      Value<String?> libraryId,
      Value<String> qualities,
      Value<String> urlMap,
      Value<String> cachePathMap,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SourcedTrackTableTableFilterComposer
    extends Composer<_$AppDatabase, $SourcedTrackTableTable> {
  $$SourcedTrackTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get libraryId => $composableBuilder(
    column: $table.libraryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qualities => $composableBuilder(
    column: $table.qualities,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get urlMap => $composableBuilder(
    column: $table.urlMap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cachePathMap => $composableBuilder(
    column: $table.cachePathMap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SourcedTrackTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SourcedTrackTableTable> {
  $$SourcedTrackTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get libraryId => $composableBuilder(
    column: $table.libraryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qualities => $composableBuilder(
    column: $table.qualities,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get urlMap => $composableBuilder(
    column: $table.urlMap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cachePathMap => $composableBuilder(
    column: $table.cachePathMap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SourcedTrackTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SourcedTrackTableTable> {
  $$SourcedTrackTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get libraryId =>
      $composableBuilder(column: $table.libraryId, builder: (column) => column);

  GeneratedColumn<String> get qualities =>
      $composableBuilder(column: $table.qualities, builder: (column) => column);

  GeneratedColumn<String> get urlMap =>
      $composableBuilder(column: $table.urlMap, builder: (column) => column);

  GeneratedColumn<String> get cachePathMap => $composableBuilder(
    column: $table.cachePathMap,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SourcedTrackTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SourcedTrackTableTable,
          SourcedTrackEntity,
          $$SourcedTrackTableTableFilterComposer,
          $$SourcedTrackTableTableOrderingComposer,
          $$SourcedTrackTableTableAnnotationComposer,
          $$SourcedTrackTableTableCreateCompanionBuilder,
          $$SourcedTrackTableTableUpdateCompanionBuilder,
          (
            SourcedTrackEntity,
            BaseReferences<
              _$AppDatabase,
              $SourcedTrackTableTable,
              SourcedTrackEntity
            >,
          ),
          SourcedTrackEntity,
          PrefetchHooks Function()
        > {
  $$SourcedTrackTableTableTableManager(
    _$AppDatabase db,
    $SourcedTrackTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourcedTrackTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourcedTrackTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourcedTrackTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> trackId = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String?> libraryId = const Value.absent(),
                Value<String> qualities = const Value.absent(),
                Value<String> urlMap = const Value.absent(),
                Value<String> cachePathMap = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourcedTrackTableCompanion(
                trackId: trackId,
                sourceId: sourceId,
                libraryId: libraryId,
                qualities: qualities,
                urlMap: urlMap,
                cachePathMap: cachePathMap,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                required String sourceId,
                Value<String?> libraryId = const Value.absent(),
                Value<String> qualities = const Value.absent(),
                Value<String> urlMap = const Value.absent(),
                Value<String> cachePathMap = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourcedTrackTableCompanion.insert(
                trackId: trackId,
                sourceId: sourceId,
                libraryId: libraryId,
                qualities: qualities,
                urlMap: urlMap,
                cachePathMap: cachePathMap,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SourcedTrackTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SourcedTrackTableTable,
      SourcedTrackEntity,
      $$SourcedTrackTableTableFilterComposer,
      $$SourcedTrackTableTableOrderingComposer,
      $$SourcedTrackTableTableAnnotationComposer,
      $$SourcedTrackTableTableCreateCompanionBuilder,
      $$SourcedTrackTableTableUpdateCompanionBuilder,
      (
        SourcedTrackEntity,
        BaseReferences<
          _$AppDatabase,
          $SourcedTrackTableTable,
          SourcedTrackEntity
        >,
      ),
      SourcedTrackEntity,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlayerStateTableTableTableManager get playerStateTable =>
      $$PlayerStateTableTableTableManager(_db, _db.playerStateTable);
  $$PlayerTrackTableTableTableManager get playerTrackTable =>
      $$PlayerTrackTableTableTableManager(_db, _db.playerTrackTable);
  $$PlayHistoryTableTableTableManager get playHistoryTable =>
      $$PlayHistoryTableTableTableManager(_db, _db.playHistoryTable);
  $$SourcedTrackTableTableTableManager get sourcedTrackTable =>
      $$SourcedTrackTableTableTableManager(_db, _db.sourcedTrackTable);
}
