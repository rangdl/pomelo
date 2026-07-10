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

class $PreferenceTableTable extends PreferenceTable
    with TableInfo<$PreferenceTableTable, PreferenceEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferenceTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preference_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreferenceEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PreferenceEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreferenceEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $PreferenceTableTable createAlias(String alias) {
    return $PreferenceTableTable(attachedDatabase, alias);
  }
}

class PreferenceEntity extends DataClass
    implements Insertable<PreferenceEntity> {
  /// 固定为 0，确保单行
  final int id;

  /// UserPreference 的 JSON 字符串
  final String value;
  const PreferenceEntity({required this.id, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['value'] = Variable<String>(value);
    return map;
  }

  PreferenceTableCompanion toCompanion(bool nullToAbsent) {
    return PreferenceTableCompanion(id: Value(id), value: Value(value));
  }

  factory PreferenceEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreferenceEntity(
      id: serializer.fromJson<int>(json['id']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'value': serializer.toJson<String>(value),
    };
  }

  PreferenceEntity copyWith({int? id, String? value}) =>
      PreferenceEntity(id: id ?? this.id, value: value ?? this.value);
  PreferenceEntity copyWithCompanion(PreferenceTableCompanion data) {
    return PreferenceEntity(
      id: data.id.present ? data.id.value : this.id,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreferenceEntity(')
          ..write('id: $id, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreferenceEntity &&
          other.id == this.id &&
          other.value == this.value);
}

class PreferenceTableCompanion extends UpdateCompanion<PreferenceEntity> {
  final Value<int> id;
  final Value<String> value;
  const PreferenceTableCompanion({
    this.id = const Value.absent(),
    this.value = const Value.absent(),
  });
  PreferenceTableCompanion.insert({
    this.id = const Value.absent(),
    required String value,
  }) : value = Value(value);
  static Insertable<PreferenceEntity> custom({
    Expression<int>? id,
    Expression<String>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (value != null) 'value': value,
    });
  }

  PreferenceTableCompanion copyWith({Value<int>? id, Value<String>? value}) {
    return PreferenceTableCompanion(
      id: id ?? this.id,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferenceTableCompanion(')
          ..write('id: $id, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $MusicServerConfigTableTable extends MusicServerConfigTable
    with TableInfo<$MusicServerConfigTableTable, MusicServerConfigEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MusicServerConfigTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configJsonMeta = const VerificationMeta(
    'configJson',
  );
  @override
  late final GeneratedColumn<String> configJson = GeneratedColumn<String>(
    'config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, type, configJson, enabled];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'music_server_config_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MusicServerConfigEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('config_json')) {
      context.handle(
        _configJsonMeta,
        configJson.isAcceptableOrUnknown(data['config_json']!, _configJsonMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MusicServerConfigEntity map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MusicServerConfigEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      configJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $MusicServerConfigTableTable createAlias(String alias) {
    return $MusicServerConfigTableTable(attachedDatabase, alias);
  }
}

class MusicServerConfigEntity extends DataClass
    implements Insertable<MusicServerConfigEntity> {
  /// 配置唯一标识（如 'local'、'lx'、'lx-server-xxx'、'subsonic-xxx'）
  final String id;

  /// 显示名称
  final String name;

  /// 来源类型（MusicSourceType.name）
  final String type;

  /// 子类额外字段的 JSON 字符串
  final String configJson;

  /// 是否启用
  final bool enabled;
  const MusicServerConfigEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.configJson,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['config_json'] = Variable<String>(configJson);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  MusicServerConfigTableCompanion toCompanion(bool nullToAbsent) {
    return MusicServerConfigTableCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      configJson: Value(configJson),
      enabled: Value(enabled),
    );
  }

  factory MusicServerConfigEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MusicServerConfigEntity(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      configJson: serializer.fromJson<String>(json['configJson']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'configJson': serializer.toJson<String>(configJson),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  MusicServerConfigEntity copyWith({
    String? id,
    String? name,
    String? type,
    String? configJson,
    bool? enabled,
  }) => MusicServerConfigEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    configJson: configJson ?? this.configJson,
    enabled: enabled ?? this.enabled,
  );
  MusicServerConfigEntity copyWithCompanion(
    MusicServerConfigTableCompanion data,
  ) {
    return MusicServerConfigEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MusicServerConfigEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('configJson: $configJson, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, configJson, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MusicServerConfigEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.configJson == this.configJson &&
          other.enabled == this.enabled);
}

class MusicServerConfigTableCompanion
    extends UpdateCompanion<MusicServerConfigEntity> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String> configJson;
  final Value<bool> enabled;
  final Value<int> rowid;
  const MusicServerConfigTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.configJson = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MusicServerConfigTableCompanion.insert({
    required String id,
    required String name,
    required String type,
    this.configJson = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type);
  static Insertable<MusicServerConfigEntity> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? configJson,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (configJson != null) 'config_json': configJson,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MusicServerConfigTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String>? configJson,
    Value<bool>? enabled,
    Value<int>? rowid,
  }) {
    return MusicServerConfigTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      configJson: configJson ?? this.configJson,
      enabled: enabled ?? this.enabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (configJson.present) {
      map['config_json'] = Variable<String>(configJson.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MusicServerConfigTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('configJson: $configJson, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTrackTableTable extends LocalTrackTable
    with TableInfo<$LocalTrackTableTable, LocalTrackEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTrackTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumIdMeta = const VerificationMeta(
    'albumId',
  );
  @override
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
    'album_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artistIdMeta = const VerificationMeta(
    'artistId',
  );
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
    'artist_id',
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
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _srcMeta = const VerificationMeta('src');
  @override
  late final GeneratedColumn<String> src = GeneratedColumn<String>(
    'src',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _isLocalMeta = const VerificationMeta(
    'isLocal',
  );
  @override
  late final GeneratedColumn<bool> isLocal = GeneratedColumn<bool>(
    'is_local',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_local" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    id,
    title,
    artist,
    album,
    albumId,
    artistId,
    coverArt,
    duration,
    path,
    src,
    sourceId,
    libraryId,
    isLocal,
    trackJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_track_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTrackEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('album_id')) {
      context.handle(
        _albumIdMeta,
        albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta),
      );
    }
    if (data.containsKey('artist_id')) {
      context.handle(
        _artistIdMeta,
        artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta),
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
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    }
    if (data.containsKey('src')) {
      context.handle(
        _srcMeta,
        src.isAcceptableOrUnknown(data['src']!, _srcMeta),
      );
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
    if (data.containsKey('is_local')) {
      context.handle(
        _isLocalMeta,
        isLocal.isAcceptableOrUnknown(data['is_local']!, _isLocalMeta),
      );
    }
    if (data.containsKey('track_json')) {
      context.handle(
        _trackJsonMeta,
        trackJson.isAcceptableOrUnknown(data['track_json']!, _trackJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_trackJsonMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTrackEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTrackEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      ),
      albumId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_id'],
      ),
      artistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_id'],
      ),
      coverArt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art'],
      ),
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      ),
      src: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}src'],
      ),
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      libraryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}library_id'],
      ),
      isLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_local'],
      )!,
      trackJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalTrackTableTable createAlias(String alias) {
    return $LocalTrackTableTable(attachedDatabase, alias);
  }
}

class LocalTrackEntity extends DataClass
    implements Insertable<LocalTrackEntity> {
  /// 曲目 ID（主键，与 Track.id 一致）
  final String id;

  /// 标题
  final String title;

  /// 艺术家（可空）
  final String? artist;

  /// 专辑名（可空）
  final String? album;

  /// 专辑 ID（可空）
  final String? albumId;

  /// 艺术家 ID（可空）
  final String? artistId;

  /// 封面地址（URL 或本地文件路径，可空）
  final String? coverArt;

  /// 时长（秒）
  final int duration;

  /// 本地文件路径（本地扫描曲目必填，在线缓存曲目可为空）
  final String? path;

  /// 在线播放地址（可空）
  final String? src;

  /// 来源 ID（如 'local'、'lx-server-xxx'、'subsonic-xxx'）
  final String sourceId;

  /// 库 ID（可空）
  final String? libraryId;

  /// 是否为本地曲目（path != null）
  final bool isLocal;

  /// 完整 Track JSON（用于零丢失恢复）
  final String trackJson;

  /// 最后更新时间
  final DateTime updatedAt;
  const LocalTrackEntity({
    required this.id,
    required this.title,
    this.artist,
    this.album,
    this.albumId,
    this.artistId,
    this.coverArt,
    required this.duration,
    this.path,
    this.src,
    required this.sourceId,
    this.libraryId,
    required this.isLocal,
    required this.trackJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    if (!nullToAbsent || albumId != null) {
      map['album_id'] = Variable<String>(albumId);
    }
    if (!nullToAbsent || artistId != null) {
      map['artist_id'] = Variable<String>(artistId);
    }
    if (!nullToAbsent || coverArt != null) {
      map['cover_art'] = Variable<String>(coverArt);
    }
    map['duration'] = Variable<int>(duration);
    if (!nullToAbsent || path != null) {
      map['path'] = Variable<String>(path);
    }
    if (!nullToAbsent || src != null) {
      map['src'] = Variable<String>(src);
    }
    map['source_id'] = Variable<String>(sourceId);
    if (!nullToAbsent || libraryId != null) {
      map['library_id'] = Variable<String>(libraryId);
    }
    map['is_local'] = Variable<bool>(isLocal);
    map['track_json'] = Variable<String>(trackJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalTrackTableCompanion toCompanion(bool nullToAbsent) {
    return LocalTrackTableCompanion(
      id: Value(id),
      title: Value(title),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      album: album == null && nullToAbsent
          ? const Value.absent()
          : Value(album),
      albumId: albumId == null && nullToAbsent
          ? const Value.absent()
          : Value(albumId),
      artistId: artistId == null && nullToAbsent
          ? const Value.absent()
          : Value(artistId),
      coverArt: coverArt == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArt),
      duration: Value(duration),
      path: path == null && nullToAbsent ? const Value.absent() : Value(path),
      src: src == null && nullToAbsent ? const Value.absent() : Value(src),
      sourceId: Value(sourceId),
      libraryId: libraryId == null && nullToAbsent
          ? const Value.absent()
          : Value(libraryId),
      isLocal: Value(isLocal),
      trackJson: Value(trackJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalTrackEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTrackEntity(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String?>(json['artist']),
      album: serializer.fromJson<String?>(json['album']),
      albumId: serializer.fromJson<String?>(json['albumId']),
      artistId: serializer.fromJson<String?>(json['artistId']),
      coverArt: serializer.fromJson<String?>(json['coverArt']),
      duration: serializer.fromJson<int>(json['duration']),
      path: serializer.fromJson<String?>(json['path']),
      src: serializer.fromJson<String?>(json['src']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      libraryId: serializer.fromJson<String?>(json['libraryId']),
      isLocal: serializer.fromJson<bool>(json['isLocal']),
      trackJson: serializer.fromJson<String>(json['trackJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String?>(artist),
      'album': serializer.toJson<String?>(album),
      'albumId': serializer.toJson<String?>(albumId),
      'artistId': serializer.toJson<String?>(artistId),
      'coverArt': serializer.toJson<String?>(coverArt),
      'duration': serializer.toJson<int>(duration),
      'path': serializer.toJson<String?>(path),
      'src': serializer.toJson<String?>(src),
      'sourceId': serializer.toJson<String>(sourceId),
      'libraryId': serializer.toJson<String?>(libraryId),
      'isLocal': serializer.toJson<bool>(isLocal),
      'trackJson': serializer.toJson<String>(trackJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalTrackEntity copyWith({
    String? id,
    String? title,
    Value<String?> artist = const Value.absent(),
    Value<String?> album = const Value.absent(),
    Value<String?> albumId = const Value.absent(),
    Value<String?> artistId = const Value.absent(),
    Value<String?> coverArt = const Value.absent(),
    int? duration,
    Value<String?> path = const Value.absent(),
    Value<String?> src = const Value.absent(),
    String? sourceId,
    Value<String?> libraryId = const Value.absent(),
    bool? isLocal,
    String? trackJson,
    DateTime? updatedAt,
  }) => LocalTrackEntity(
    id: id ?? this.id,
    title: title ?? this.title,
    artist: artist.present ? artist.value : this.artist,
    album: album.present ? album.value : this.album,
    albumId: albumId.present ? albumId.value : this.albumId,
    artistId: artistId.present ? artistId.value : this.artistId,
    coverArt: coverArt.present ? coverArt.value : this.coverArt,
    duration: duration ?? this.duration,
    path: path.present ? path.value : this.path,
    src: src.present ? src.value : this.src,
    sourceId: sourceId ?? this.sourceId,
    libraryId: libraryId.present ? libraryId.value : this.libraryId,
    isLocal: isLocal ?? this.isLocal,
    trackJson: trackJson ?? this.trackJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalTrackEntity copyWithCompanion(LocalTrackTableCompanion data) {
    return LocalTrackEntity(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
      coverArt: data.coverArt.present ? data.coverArt.value : this.coverArt,
      duration: data.duration.present ? data.duration.value : this.duration,
      path: data.path.present ? data.path.value : this.path,
      src: data.src.present ? data.src.value : this.src,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      libraryId: data.libraryId.present ? data.libraryId.value : this.libraryId,
      isLocal: data.isLocal.present ? data.isLocal.value : this.isLocal,
      trackJson: data.trackJson.present ? data.trackJson.value : this.trackJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTrackEntity(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('albumId: $albumId, ')
          ..write('artistId: $artistId, ')
          ..write('coverArt: $coverArt, ')
          ..write('duration: $duration, ')
          ..write('path: $path, ')
          ..write('src: $src, ')
          ..write('sourceId: $sourceId, ')
          ..write('libraryId: $libraryId, ')
          ..write('isLocal: $isLocal, ')
          ..write('trackJson: $trackJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    artist,
    album,
    albumId,
    artistId,
    coverArt,
    duration,
    path,
    src,
    sourceId,
    libraryId,
    isLocal,
    trackJson,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTrackEntity &&
          other.id == this.id &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.albumId == this.albumId &&
          other.artistId == this.artistId &&
          other.coverArt == this.coverArt &&
          other.duration == this.duration &&
          other.path == this.path &&
          other.src == this.src &&
          other.sourceId == this.sourceId &&
          other.libraryId == this.libraryId &&
          other.isLocal == this.isLocal &&
          other.trackJson == this.trackJson &&
          other.updatedAt == this.updatedAt);
}

class LocalTrackTableCompanion extends UpdateCompanion<LocalTrackEntity> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> artist;
  final Value<String?> album;
  final Value<String?> albumId;
  final Value<String?> artistId;
  final Value<String?> coverArt;
  final Value<int> duration;
  final Value<String?> path;
  final Value<String?> src;
  final Value<String> sourceId;
  final Value<String?> libraryId;
  final Value<bool> isLocal;
  final Value<String> trackJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalTrackTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.albumId = const Value.absent(),
    this.artistId = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.duration = const Value.absent(),
    this.path = const Value.absent(),
    this.src = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.libraryId = const Value.absent(),
    this.isLocal = const Value.absent(),
    this.trackJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTrackTableCompanion.insert({
    required String id,
    required String title,
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.albumId = const Value.absent(),
    this.artistId = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.duration = const Value.absent(),
    this.path = const Value.absent(),
    this.src = const Value.absent(),
    required String sourceId,
    this.libraryId = const Value.absent(),
    this.isLocal = const Value.absent(),
    required String trackJson,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       sourceId = Value(sourceId),
       trackJson = Value(trackJson);
  static Insertable<LocalTrackEntity> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<String>? albumId,
    Expression<String>? artistId,
    Expression<String>? coverArt,
    Expression<int>? duration,
    Expression<String>? path,
    Expression<String>? src,
    Expression<String>? sourceId,
    Expression<String>? libraryId,
    Expression<bool>? isLocal,
    Expression<String>? trackJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (albumId != null) 'album_id': albumId,
      if (artistId != null) 'artist_id': artistId,
      if (coverArt != null) 'cover_art': coverArt,
      if (duration != null) 'duration': duration,
      if (path != null) 'path': path,
      if (src != null) 'src': src,
      if (sourceId != null) 'source_id': sourceId,
      if (libraryId != null) 'library_id': libraryId,
      if (isLocal != null) 'is_local': isLocal,
      if (trackJson != null) 'track_json': trackJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTrackTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? artist,
    Value<String?>? album,
    Value<String?>? albumId,
    Value<String?>? artistId,
    Value<String?>? coverArt,
    Value<int>? duration,
    Value<String?>? path,
    Value<String?>? src,
    Value<String>? sourceId,
    Value<String?>? libraryId,
    Value<bool>? isLocal,
    Value<String>? trackJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalTrackTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      artistId: artistId ?? this.artistId,
      coverArt: coverArt ?? this.coverArt,
      duration: duration ?? this.duration,
      path: path ?? this.path,
      src: src ?? this.src,
      sourceId: sourceId ?? this.sourceId,
      libraryId: libraryId ?? this.libraryId,
      isLocal: isLocal ?? this.isLocal,
      trackJson: trackJson ?? this.trackJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (coverArt.present) {
      map['cover_art'] = Variable<String>(coverArt.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (src.present) {
      map['src'] = Variable<String>(src.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (libraryId.present) {
      map['library_id'] = Variable<String>(libraryId.value);
    }
    if (isLocal.present) {
      map['is_local'] = Variable<bool>(isLocal.value);
    }
    if (trackJson.present) {
      map['track_json'] = Variable<String>(trackJson.value);
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
    return (StringBuffer('LocalTrackTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('albumId: $albumId, ')
          ..write('artistId: $artistId, ')
          ..write('coverArt: $coverArt, ')
          ..write('duration: $duration, ')
          ..write('path: $path, ')
          ..write('src: $src, ')
          ..write('sourceId: $sourceId, ')
          ..write('libraryId: $libraryId, ')
          ..write('isLocal: $isLocal, ')
          ..write('trackJson: $trackJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAlbumTableTable extends LocalAlbumTable
    with TableInfo<$LocalAlbumTableTable, LocalAlbumEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAlbumTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
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
  static const VerificationMeta _artistIdMeta = const VerificationMeta(
    'artistId',
  );
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
    'artist_id',
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
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _songCountMeta = const VerificationMeta(
    'songCount',
  );
  @override
  late final GeneratedColumn<int> songCount = GeneratedColumn<int>(
    'song_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  static const VerificationMeta _albumJsonMeta = const VerificationMeta(
    'albumJson',
  );
  @override
  late final GeneratedColumn<String> albumJson = GeneratedColumn<String>(
    'album_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    id,
    name,
    artist,
    artistId,
    coverArt,
    year,
    songCount,
    sourceId,
    albumJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_album_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAlbumEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('artist_id')) {
      context.handle(
        _artistIdMeta,
        artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta),
      );
    }
    if (data.containsKey('cover_art')) {
      context.handle(
        _coverArtMeta,
        coverArt.isAcceptableOrUnknown(data['cover_art']!, _coverArtMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('song_count')) {
      context.handle(
        _songCountMeta,
        songCount.isAcceptableOrUnknown(data['song_count']!, _songCountMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('album_json')) {
      context.handle(
        _albumJsonMeta,
        albumJson.isAcceptableOrUnknown(data['album_json']!, _albumJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_albumJsonMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAlbumEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAlbumEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      artistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_id'],
      ),
      coverArt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      songCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_count'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      albumJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalAlbumTableTable createAlias(String alias) {
    return $LocalAlbumTableTable(attachedDatabase, alias);
  }
}

class LocalAlbumEntity extends DataClass
    implements Insertable<LocalAlbumEntity> {
  /// 专辑 ID（主键）
  final String id;

  /// 专辑名称
  final String name;

  /// 艺术家（可空）
  final String? artist;

  /// 艺术家 ID（可空）
  final String? artistId;

  /// 封面地址（可空）
  final String? coverArt;

  /// 发行年份（可空）
  final int? year;

  /// 歌曲数量
  final int songCount;

  /// 来源 ID
  final String sourceId;

  /// 完整 Album JSON
  final String albumJson;

  /// 最后更新时间
  final DateTime updatedAt;
  const LocalAlbumEntity({
    required this.id,
    required this.name,
    this.artist,
    this.artistId,
    this.coverArt,
    this.year,
    required this.songCount,
    required this.sourceId,
    required this.albumJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || artistId != null) {
      map['artist_id'] = Variable<String>(artistId);
    }
    if (!nullToAbsent || coverArt != null) {
      map['cover_art'] = Variable<String>(coverArt);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    map['song_count'] = Variable<int>(songCount);
    map['source_id'] = Variable<String>(sourceId);
    map['album_json'] = Variable<String>(albumJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalAlbumTableCompanion toCompanion(bool nullToAbsent) {
    return LocalAlbumTableCompanion(
      id: Value(id),
      name: Value(name),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      artistId: artistId == null && nullToAbsent
          ? const Value.absent()
          : Value(artistId),
      coverArt: coverArt == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArt),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      songCount: Value(songCount),
      sourceId: Value(sourceId),
      albumJson: Value(albumJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalAlbumEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAlbumEntity(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      artist: serializer.fromJson<String?>(json['artist']),
      artistId: serializer.fromJson<String?>(json['artistId']),
      coverArt: serializer.fromJson<String?>(json['coverArt']),
      year: serializer.fromJson<int?>(json['year']),
      songCount: serializer.fromJson<int>(json['songCount']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      albumJson: serializer.fromJson<String>(json['albumJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'artist': serializer.toJson<String?>(artist),
      'artistId': serializer.toJson<String?>(artistId),
      'coverArt': serializer.toJson<String?>(coverArt),
      'year': serializer.toJson<int?>(year),
      'songCount': serializer.toJson<int>(songCount),
      'sourceId': serializer.toJson<String>(sourceId),
      'albumJson': serializer.toJson<String>(albumJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalAlbumEntity copyWith({
    String? id,
    String? name,
    Value<String?> artist = const Value.absent(),
    Value<String?> artistId = const Value.absent(),
    Value<String?> coverArt = const Value.absent(),
    Value<int?> year = const Value.absent(),
    int? songCount,
    String? sourceId,
    String? albumJson,
    DateTime? updatedAt,
  }) => LocalAlbumEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    artist: artist.present ? artist.value : this.artist,
    artistId: artistId.present ? artistId.value : this.artistId,
    coverArt: coverArt.present ? coverArt.value : this.coverArt,
    year: year.present ? year.value : this.year,
    songCount: songCount ?? this.songCount,
    sourceId: sourceId ?? this.sourceId,
    albumJson: albumJson ?? this.albumJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalAlbumEntity copyWithCompanion(LocalAlbumTableCompanion data) {
    return LocalAlbumEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      artist: data.artist.present ? data.artist.value : this.artist,
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
      coverArt: data.coverArt.present ? data.coverArt.value : this.coverArt,
      year: data.year.present ? data.year.value : this.year,
      songCount: data.songCount.present ? data.songCount.value : this.songCount,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      albumJson: data.albumJson.present ? data.albumJson.value : this.albumJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAlbumEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('artist: $artist, ')
          ..write('artistId: $artistId, ')
          ..write('coverArt: $coverArt, ')
          ..write('year: $year, ')
          ..write('songCount: $songCount, ')
          ..write('sourceId: $sourceId, ')
          ..write('albumJson: $albumJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    artist,
    artistId,
    coverArt,
    year,
    songCount,
    sourceId,
    albumJson,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAlbumEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.artist == this.artist &&
          other.artistId == this.artistId &&
          other.coverArt == this.coverArt &&
          other.year == this.year &&
          other.songCount == this.songCount &&
          other.sourceId == this.sourceId &&
          other.albumJson == this.albumJson &&
          other.updatedAt == this.updatedAt);
}

class LocalAlbumTableCompanion extends UpdateCompanion<LocalAlbumEntity> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> artist;
  final Value<String?> artistId;
  final Value<String?> coverArt;
  final Value<int?> year;
  final Value<int> songCount;
  final Value<String> sourceId;
  final Value<String> albumJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalAlbumTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.artist = const Value.absent(),
    this.artistId = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.year = const Value.absent(),
    this.songCount = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.albumJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAlbumTableCompanion.insert({
    required String id,
    required String name,
    this.artist = const Value.absent(),
    this.artistId = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.year = const Value.absent(),
    this.songCount = const Value.absent(),
    required String sourceId,
    required String albumJson,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       sourceId = Value(sourceId),
       albumJson = Value(albumJson);
  static Insertable<LocalAlbumEntity> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? artist,
    Expression<String>? artistId,
    Expression<String>? coverArt,
    Expression<int>? year,
    Expression<int>? songCount,
    Expression<String>? sourceId,
    Expression<String>? albumJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (artist != null) 'artist': artist,
      if (artistId != null) 'artist_id': artistId,
      if (coverArt != null) 'cover_art': coverArt,
      if (year != null) 'year': year,
      if (songCount != null) 'song_count': songCount,
      if (sourceId != null) 'source_id': sourceId,
      if (albumJson != null) 'album_json': albumJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAlbumTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? artist,
    Value<String?>? artistId,
    Value<String?>? coverArt,
    Value<int?>? year,
    Value<int>? songCount,
    Value<String>? sourceId,
    Value<String>? albumJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalAlbumTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      coverArt: coverArt ?? this.coverArt,
      year: year ?? this.year,
      songCount: songCount ?? this.songCount,
      sourceId: sourceId ?? this.sourceId,
      albumJson: albumJson ?? this.albumJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (coverArt.present) {
      map['cover_art'] = Variable<String>(coverArt.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (songCount.present) {
      map['song_count'] = Variable<int>(songCount.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (albumJson.present) {
      map['album_json'] = Variable<String>(albumJson.value);
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
    return (StringBuffer('LocalAlbumTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('artist: $artist, ')
          ..write('artistId: $artistId, ')
          ..write('coverArt: $coverArt, ')
          ..write('year: $year, ')
          ..write('songCount: $songCount, ')
          ..write('sourceId: $sourceId, ')
          ..write('albumJson: $albumJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalArtistTableTable extends LocalArtistTable
    with TableInfo<$LocalArtistTableTable, LocalArtistEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalArtistTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _artistImageUrlMeta = const VerificationMeta(
    'artistImageUrl',
  );
  @override
  late final GeneratedColumn<String> artistImageUrl = GeneratedColumn<String>(
    'artist_image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumCountMeta = const VerificationMeta(
    'albumCount',
  );
  @override
  late final GeneratedColumn<int> albumCount = GeneratedColumn<int>(
    'album_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  static const VerificationMeta _artistJsonMeta = const VerificationMeta(
    'artistJson',
  );
  @override
  late final GeneratedColumn<String> artistJson = GeneratedColumn<String>(
    'artist_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    id,
    name,
    coverArt,
    artistImageUrl,
    albumCount,
    sourceId,
    artistJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_artist_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalArtistEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cover_art')) {
      context.handle(
        _coverArtMeta,
        coverArt.isAcceptableOrUnknown(data['cover_art']!, _coverArtMeta),
      );
    }
    if (data.containsKey('artist_image_url')) {
      context.handle(
        _artistImageUrlMeta,
        artistImageUrl.isAcceptableOrUnknown(
          data['artist_image_url']!,
          _artistImageUrlMeta,
        ),
      );
    }
    if (data.containsKey('album_count')) {
      context.handle(
        _albumCountMeta,
        albumCount.isAcceptableOrUnknown(data['album_count']!, _albumCountMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('artist_json')) {
      context.handle(
        _artistJsonMeta,
        artistJson.isAcceptableOrUnknown(data['artist_json']!, _artistJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_artistJsonMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalArtistEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalArtistEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      coverArt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art'],
      ),
      artistImageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_image_url'],
      ),
      albumCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}album_count'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      artistJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalArtistTableTable createAlias(String alias) {
    return $LocalArtistTableTable(attachedDatabase, alias);
  }
}

class LocalArtistEntity extends DataClass
    implements Insertable<LocalArtistEntity> {
  /// 艺术家 ID（主键）
  final String id;

  /// 艺术家名称
  final String name;

  /// 封面地址（可空）
  final String? coverArt;

  /// 艺术家图片 URL（可空）
  final String? artistImageUrl;

  /// 专辑数量
  final int albumCount;

  /// 来源 ID
  final String sourceId;

  /// 完整 Artist JSON
  final String artistJson;

  /// 最后更新时间
  final DateTime updatedAt;
  const LocalArtistEntity({
    required this.id,
    required this.name,
    this.coverArt,
    this.artistImageUrl,
    required this.albumCount,
    required this.sourceId,
    required this.artistJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || coverArt != null) {
      map['cover_art'] = Variable<String>(coverArt);
    }
    if (!nullToAbsent || artistImageUrl != null) {
      map['artist_image_url'] = Variable<String>(artistImageUrl);
    }
    map['album_count'] = Variable<int>(albumCount);
    map['source_id'] = Variable<String>(sourceId);
    map['artist_json'] = Variable<String>(artistJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalArtistTableCompanion toCompanion(bool nullToAbsent) {
    return LocalArtistTableCompanion(
      id: Value(id),
      name: Value(name),
      coverArt: coverArt == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArt),
      artistImageUrl: artistImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(artistImageUrl),
      albumCount: Value(albumCount),
      sourceId: Value(sourceId),
      artistJson: Value(artistJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalArtistEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalArtistEntity(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      coverArt: serializer.fromJson<String?>(json['coverArt']),
      artistImageUrl: serializer.fromJson<String?>(json['artistImageUrl']),
      albumCount: serializer.fromJson<int>(json['albumCount']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      artistJson: serializer.fromJson<String>(json['artistJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'coverArt': serializer.toJson<String?>(coverArt),
      'artistImageUrl': serializer.toJson<String?>(artistImageUrl),
      'albumCount': serializer.toJson<int>(albumCount),
      'sourceId': serializer.toJson<String>(sourceId),
      'artistJson': serializer.toJson<String>(artistJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalArtistEntity copyWith({
    String? id,
    String? name,
    Value<String?> coverArt = const Value.absent(),
    Value<String?> artistImageUrl = const Value.absent(),
    int? albumCount,
    String? sourceId,
    String? artistJson,
    DateTime? updatedAt,
  }) => LocalArtistEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    coverArt: coverArt.present ? coverArt.value : this.coverArt,
    artistImageUrl: artistImageUrl.present
        ? artistImageUrl.value
        : this.artistImageUrl,
    albumCount: albumCount ?? this.albumCount,
    sourceId: sourceId ?? this.sourceId,
    artistJson: artistJson ?? this.artistJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalArtistEntity copyWithCompanion(LocalArtistTableCompanion data) {
    return LocalArtistEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      coverArt: data.coverArt.present ? data.coverArt.value : this.coverArt,
      artistImageUrl: data.artistImageUrl.present
          ? data.artistImageUrl.value
          : this.artistImageUrl,
      albumCount: data.albumCount.present
          ? data.albumCount.value
          : this.albumCount,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      artistJson: data.artistJson.present
          ? data.artistJson.value
          : this.artistJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalArtistEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('coverArt: $coverArt, ')
          ..write('artistImageUrl: $artistImageUrl, ')
          ..write('albumCount: $albumCount, ')
          ..write('sourceId: $sourceId, ')
          ..write('artistJson: $artistJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    coverArt,
    artistImageUrl,
    albumCount,
    sourceId,
    artistJson,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalArtistEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.coverArt == this.coverArt &&
          other.artistImageUrl == this.artistImageUrl &&
          other.albumCount == this.albumCount &&
          other.sourceId == this.sourceId &&
          other.artistJson == this.artistJson &&
          other.updatedAt == this.updatedAt);
}

class LocalArtistTableCompanion extends UpdateCompanion<LocalArtistEntity> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> coverArt;
  final Value<String?> artistImageUrl;
  final Value<int> albumCount;
  final Value<String> sourceId;
  final Value<String> artistJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalArtistTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.artistImageUrl = const Value.absent(),
    this.albumCount = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.artistJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalArtistTableCompanion.insert({
    required String id,
    required String name,
    this.coverArt = const Value.absent(),
    this.artistImageUrl = const Value.absent(),
    this.albumCount = const Value.absent(),
    required String sourceId,
    required String artistJson,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       sourceId = Value(sourceId),
       artistJson = Value(artistJson);
  static Insertable<LocalArtistEntity> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? coverArt,
    Expression<String>? artistImageUrl,
    Expression<int>? albumCount,
    Expression<String>? sourceId,
    Expression<String>? artistJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (coverArt != null) 'cover_art': coverArt,
      if (artistImageUrl != null) 'artist_image_url': artistImageUrl,
      if (albumCount != null) 'album_count': albumCount,
      if (sourceId != null) 'source_id': sourceId,
      if (artistJson != null) 'artist_json': artistJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalArtistTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? coverArt,
    Value<String?>? artistImageUrl,
    Value<int>? albumCount,
    Value<String>? sourceId,
    Value<String>? artistJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalArtistTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      coverArt: coverArt ?? this.coverArt,
      artistImageUrl: artistImageUrl ?? this.artistImageUrl,
      albumCount: albumCount ?? this.albumCount,
      sourceId: sourceId ?? this.sourceId,
      artistJson: artistJson ?? this.artistJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (coverArt.present) {
      map['cover_art'] = Variable<String>(coverArt.value);
    }
    if (artistImageUrl.present) {
      map['artist_image_url'] = Variable<String>(artistImageUrl.value);
    }
    if (albumCount.present) {
      map['album_count'] = Variable<int>(albumCount.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (artistJson.present) {
      map['artist_json'] = Variable<String>(artistJson.value);
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
    return (StringBuffer('LocalArtistTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('coverArt: $coverArt, ')
          ..write('artistImageUrl: $artistImageUrl, ')
          ..write('albumCount: $albumCount, ')
          ..write('sourceId: $sourceId, ')
          ..write('artistJson: $artistJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalPlaylistTableTable extends LocalPlaylistTable
    with TableInfo<$LocalPlaylistTableTable, LocalPlaylistEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPlaylistTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
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
  static const VerificationMeta _songCountMeta = const VerificationMeta(
    'songCount',
  );
  @override
  late final GeneratedColumn<int> songCount = GeneratedColumn<int>(
    'song_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  static const VerificationMeta _playlistJsonMeta = const VerificationMeta(
    'playlistJson',
  );
  @override
  late final GeneratedColumn<String> playlistJson = GeneratedColumn<String>(
    'playlist_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    id,
    name,
    owner,
    coverArt,
    songCount,
    sourceId,
    playlistJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_playlist_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalPlaylistEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    }
    if (data.containsKey('cover_art')) {
      context.handle(
        _coverArtMeta,
        coverArt.isAcceptableOrUnknown(data['cover_art']!, _coverArtMeta),
      );
    }
    if (data.containsKey('song_count')) {
      context.handle(
        _songCountMeta,
        songCount.isAcceptableOrUnknown(data['song_count']!, _songCountMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('playlist_json')) {
      context.handle(
        _playlistJsonMeta,
        playlistJson.isAcceptableOrUnknown(
          data['playlist_json']!,
          _playlistJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_playlistJsonMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalPlaylistEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPlaylistEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      ),
      coverArt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art'],
      ),
      songCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_count'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      playlistJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalPlaylistTableTable createAlias(String alias) {
    return $LocalPlaylistTableTable(attachedDatabase, alias);
  }
}

class LocalPlaylistEntity extends DataClass
    implements Insertable<LocalPlaylistEntity> {
  /// 歌单 ID（主键）
  final String id;

  /// 歌单名称
  final String name;

  /// 创建者/拥有者（可空）
  final String? owner;

  /// 封面地址（可空）
  final String? coverArt;

  /// 歌曲数量
  final int songCount;

  /// 来源 ID
  final String sourceId;

  /// 完整 Playlist JSON
  final String playlistJson;

  /// 最后更新时间
  final DateTime updatedAt;
  const LocalPlaylistEntity({
    required this.id,
    required this.name,
    this.owner,
    this.coverArt,
    required this.songCount,
    required this.sourceId,
    required this.playlistJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || owner != null) {
      map['owner'] = Variable<String>(owner);
    }
    if (!nullToAbsent || coverArt != null) {
      map['cover_art'] = Variable<String>(coverArt);
    }
    map['song_count'] = Variable<int>(songCount);
    map['source_id'] = Variable<String>(sourceId);
    map['playlist_json'] = Variable<String>(playlistJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalPlaylistTableCompanion toCompanion(bool nullToAbsent) {
    return LocalPlaylistTableCompanion(
      id: Value(id),
      name: Value(name),
      owner: owner == null && nullToAbsent
          ? const Value.absent()
          : Value(owner),
      coverArt: coverArt == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArt),
      songCount: Value(songCount),
      sourceId: Value(sourceId),
      playlistJson: Value(playlistJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalPlaylistEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPlaylistEntity(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      owner: serializer.fromJson<String?>(json['owner']),
      coverArt: serializer.fromJson<String?>(json['coverArt']),
      songCount: serializer.fromJson<int>(json['songCount']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      playlistJson: serializer.fromJson<String>(json['playlistJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'owner': serializer.toJson<String?>(owner),
      'coverArt': serializer.toJson<String?>(coverArt),
      'songCount': serializer.toJson<int>(songCount),
      'sourceId': serializer.toJson<String>(sourceId),
      'playlistJson': serializer.toJson<String>(playlistJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalPlaylistEntity copyWith({
    String? id,
    String? name,
    Value<String?> owner = const Value.absent(),
    Value<String?> coverArt = const Value.absent(),
    int? songCount,
    String? sourceId,
    String? playlistJson,
    DateTime? updatedAt,
  }) => LocalPlaylistEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    owner: owner.present ? owner.value : this.owner,
    coverArt: coverArt.present ? coverArt.value : this.coverArt,
    songCount: songCount ?? this.songCount,
    sourceId: sourceId ?? this.sourceId,
    playlistJson: playlistJson ?? this.playlistJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalPlaylistEntity copyWithCompanion(LocalPlaylistTableCompanion data) {
    return LocalPlaylistEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      owner: data.owner.present ? data.owner.value : this.owner,
      coverArt: data.coverArt.present ? data.coverArt.value : this.coverArt,
      songCount: data.songCount.present ? data.songCount.value : this.songCount,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      playlistJson: data.playlistJson.present
          ? data.playlistJson.value
          : this.playlistJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPlaylistEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('owner: $owner, ')
          ..write('coverArt: $coverArt, ')
          ..write('songCount: $songCount, ')
          ..write('sourceId: $sourceId, ')
          ..write('playlistJson: $playlistJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    owner,
    coverArt,
    songCount,
    sourceId,
    playlistJson,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPlaylistEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.owner == this.owner &&
          other.coverArt == this.coverArt &&
          other.songCount == this.songCount &&
          other.sourceId == this.sourceId &&
          other.playlistJson == this.playlistJson &&
          other.updatedAt == this.updatedAt);
}

class LocalPlaylistTableCompanion extends UpdateCompanion<LocalPlaylistEntity> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> owner;
  final Value<String?> coverArt;
  final Value<int> songCount;
  final Value<String> sourceId;
  final Value<String> playlistJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalPlaylistTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.owner = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.songCount = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.playlistJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPlaylistTableCompanion.insert({
    required String id,
    required String name,
    this.owner = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.songCount = const Value.absent(),
    required String sourceId,
    required String playlistJson,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       sourceId = Value(sourceId),
       playlistJson = Value(playlistJson);
  static Insertable<LocalPlaylistEntity> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? owner,
    Expression<String>? coverArt,
    Expression<int>? songCount,
    Expression<String>? sourceId,
    Expression<String>? playlistJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (owner != null) 'owner': owner,
      if (coverArt != null) 'cover_art': coverArt,
      if (songCount != null) 'song_count': songCount,
      if (sourceId != null) 'source_id': sourceId,
      if (playlistJson != null) 'playlist_json': playlistJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPlaylistTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? owner,
    Value<String?>? coverArt,
    Value<int>? songCount,
    Value<String>? sourceId,
    Value<String>? playlistJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalPlaylistTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      owner: owner ?? this.owner,
      coverArt: coverArt ?? this.coverArt,
      songCount: songCount ?? this.songCount,
      sourceId: sourceId ?? this.sourceId,
      playlistJson: playlistJson ?? this.playlistJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (coverArt.present) {
      map['cover_art'] = Variable<String>(coverArt.value);
    }
    if (songCount.present) {
      map['song_count'] = Variable<int>(songCount.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (playlistJson.present) {
      map['playlist_json'] = Variable<String>(playlistJson.value);
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
    return (StringBuffer('LocalPlaylistTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('owner: $owner, ')
          ..write('coverArt: $coverArt, ')
          ..write('songCount: $songCount, ')
          ..write('sourceId: $sourceId, ')
          ..write('playlistJson: $playlistJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LxSourceScriptTableTable extends LxSourceScriptTable
    with TableInfo<$LxSourceScriptTableTable, LxSourceScriptEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LxSourceScriptTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _homepageMeta = const VerificationMeta(
    'homepage',
  );
  @override
  late final GeneratedColumn<String> homepage = GeneratedColumn<String>(
    'homepage',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scriptMeta = const VerificationMeta('script');
  @override
  late final GeneratedColumn<String> script = GeneratedColumn<String>(
    'script',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _librariesJsonMeta = const VerificationMeta(
    'librariesJson',
  );
  @override
  late final GeneratedColumn<String> librariesJson = GeneratedColumn<String>(
    'libraries_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    author,
    homepage,
    version,
    script,
    librariesJson,
    createdAt,
    enabled,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lx_source_script_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LxSourceScriptEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('homepage')) {
      context.handle(
        _homepageMeta,
        homepage.isAcceptableOrUnknown(data['homepage']!, _homepageMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('script')) {
      context.handle(
        _scriptMeta,
        script.isAcceptableOrUnknown(data['script']!, _scriptMeta),
      );
    } else if (isInserting) {
      context.missing(_scriptMeta);
    }
    if (data.containsKey('libraries_json')) {
      context.handle(
        _librariesJsonMeta,
        librariesJson.isAcceptableOrUnknown(
          data['libraries_json']!,
          _librariesJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LxSourceScriptEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LxSourceScriptEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      homepage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}homepage'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      ),
      script: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}script'],
      )!,
      librariesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}libraries_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $LxSourceScriptTableTable createAlias(String alias) {
    return $LxSourceScriptTableTable(attachedDatabase, alias);
  }
}

class LxSourceScriptEntity extends DataClass
    implements Insertable<LxSourceScriptEntity> {
  /// 脚本唯一标识（基于脚本内容 hash 生成）
  final String id;

  /// 脚本名称（解析自 @name）
  final String name;

  /// 描述（解析自 @description，可空）
  final String? description;

  /// 作者（解析自 @author，可空）
  final String? author;

  /// 主页（解析自 @homepage，可空）
  final String? homepage;

  /// 版本（解析自 @version，可空）
  final String? version;

  /// 完整脚本内容
  final String script;

  /// 注册的库与音质列表 JSON 字符串
  final String librariesJson;

  /// 添加时间
  final DateTime createdAt;

  /// 是否启用
  final bool enabled;

  /// 排序顺序（数值越小越靠前，默认 0）
  ///
  /// 用户拖拽排序后更新此字段。调用音源时按此字段升序使用。
  final int sortOrder;
  const LxSourceScriptEntity({
    required this.id,
    required this.name,
    this.description,
    this.author,
    this.homepage,
    this.version,
    required this.script,
    required this.librariesJson,
    required this.createdAt,
    required this.enabled,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || homepage != null) {
      map['homepage'] = Variable<String>(homepage);
    }
    if (!nullToAbsent || version != null) {
      map['version'] = Variable<String>(version);
    }
    map['script'] = Variable<String>(script);
    map['libraries_json'] = Variable<String>(librariesJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['enabled'] = Variable<bool>(enabled);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LxSourceScriptTableCompanion toCompanion(bool nullToAbsent) {
    return LxSourceScriptTableCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      homepage: homepage == null && nullToAbsent
          ? const Value.absent()
          : Value(homepage),
      version: version == null && nullToAbsent
          ? const Value.absent()
          : Value(version),
      script: Value(script),
      librariesJson: Value(librariesJson),
      createdAt: Value(createdAt),
      enabled: Value(enabled),
      sortOrder: Value(sortOrder),
    );
  }

  factory LxSourceScriptEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LxSourceScriptEntity(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      author: serializer.fromJson<String?>(json['author']),
      homepage: serializer.fromJson<String?>(json['homepage']),
      version: serializer.fromJson<String?>(json['version']),
      script: serializer.fromJson<String>(json['script']),
      librariesJson: serializer.fromJson<String>(json['librariesJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'author': serializer.toJson<String?>(author),
      'homepage': serializer.toJson<String?>(homepage),
      'version': serializer.toJson<String?>(version),
      'script': serializer.toJson<String>(script),
      'librariesJson': serializer.toJson<String>(librariesJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'enabled': serializer.toJson<bool>(enabled),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  LxSourceScriptEntity copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> author = const Value.absent(),
    Value<String?> homepage = const Value.absent(),
    Value<String?> version = const Value.absent(),
    String? script,
    String? librariesJson,
    DateTime? createdAt,
    bool? enabled,
    int? sortOrder,
  }) => LxSourceScriptEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    author: author.present ? author.value : this.author,
    homepage: homepage.present ? homepage.value : this.homepage,
    version: version.present ? version.value : this.version,
    script: script ?? this.script,
    librariesJson: librariesJson ?? this.librariesJson,
    createdAt: createdAt ?? this.createdAt,
    enabled: enabled ?? this.enabled,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  LxSourceScriptEntity copyWithCompanion(LxSourceScriptTableCompanion data) {
    return LxSourceScriptEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      author: data.author.present ? data.author.value : this.author,
      homepage: data.homepage.present ? data.homepage.value : this.homepage,
      version: data.version.present ? data.version.value : this.version,
      script: data.script.present ? data.script.value : this.script,
      librariesJson: data.librariesJson.present
          ? data.librariesJson.value
          : this.librariesJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LxSourceScriptEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('author: $author, ')
          ..write('homepage: $homepage, ')
          ..write('version: $version, ')
          ..write('script: $script, ')
          ..write('librariesJson: $librariesJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('enabled: $enabled, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    author,
    homepage,
    version,
    script,
    librariesJson,
    createdAt,
    enabled,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LxSourceScriptEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.author == this.author &&
          other.homepage == this.homepage &&
          other.version == this.version &&
          other.script == this.script &&
          other.librariesJson == this.librariesJson &&
          other.createdAt == this.createdAt &&
          other.enabled == this.enabled &&
          other.sortOrder == this.sortOrder);
}

class LxSourceScriptTableCompanion
    extends UpdateCompanion<LxSourceScriptEntity> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> author;
  final Value<String?> homepage;
  final Value<String?> version;
  final Value<String> script;
  final Value<String> librariesJson;
  final Value<DateTime> createdAt;
  final Value<bool> enabled;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const LxSourceScriptTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.author = const Value.absent(),
    this.homepage = const Value.absent(),
    this.version = const Value.absent(),
    this.script = const Value.absent(),
    this.librariesJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.enabled = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LxSourceScriptTableCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.author = const Value.absent(),
    this.homepage = const Value.absent(),
    this.version = const Value.absent(),
    required String script,
    this.librariesJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.enabled = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       script = Value(script);
  static Insertable<LxSourceScriptEntity> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? author,
    Expression<String>? homepage,
    Expression<String>? version,
    Expression<String>? script,
    Expression<String>? librariesJson,
    Expression<DateTime>? createdAt,
    Expression<bool>? enabled,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (author != null) 'author': author,
      if (homepage != null) 'homepage': homepage,
      if (version != null) 'version': version,
      if (script != null) 'script': script,
      if (librariesJson != null) 'libraries_json': librariesJson,
      if (createdAt != null) 'created_at': createdAt,
      if (enabled != null) 'enabled': enabled,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LxSourceScriptTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? author,
    Value<String?>? homepage,
    Value<String?>? version,
    Value<String>? script,
    Value<String>? librariesJson,
    Value<DateTime>? createdAt,
    Value<bool>? enabled,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return LxSourceScriptTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      author: author ?? this.author,
      homepage: homepage ?? this.homepage,
      version: version ?? this.version,
      script: script ?? this.script,
      librariesJson: librariesJson ?? this.librariesJson,
      createdAt: createdAt ?? this.createdAt,
      enabled: enabled ?? this.enabled,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (homepage.present) {
      map['homepage'] = Variable<String>(homepage.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (script.present) {
      map['script'] = Variable<String>(script.value);
    }
    if (librariesJson.present) {
      map['libraries_json'] = Variable<String>(librariesJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LxSourceScriptTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('author: $author, ')
          ..write('homepage: $homepage, ')
          ..write('version: $version, ')
          ..write('script: $script, ')
          ..write('librariesJson: $librariesJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('enabled: $enabled, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LxSourceUsageTableTable extends LxSourceUsageTable
    with TableInfo<$LxSourceUsageTableTable, LxSourceUsageEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LxSourceUsageTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _scriptIdMeta = const VerificationMeta(
    'scriptId',
  );
  @override
  late final GeneratedColumn<String> scriptId = GeneratedColumn<String>(
    'script_id',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCountMeta = const VerificationMeta(
    'totalCount',
  );
  @override
  late final GeneratedColumn<int> totalCount = GeneratedColumn<int>(
    'total_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _successCountMeta = const VerificationMeta(
    'successCount',
  );
  @override
  late final GeneratedColumn<int> successCount = GeneratedColumn<int>(
    'success_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxDurationMsMeta = const VerificationMeta(
    'maxDurationMs',
  );
  @override
  late final GeneratedColumn<int> maxDurationMs = GeneratedColumn<int>(
    'max_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _minDurationMsMeta = const VerificationMeta(
    'minDurationMs',
  );
  @override
  late final GeneratedColumn<int> minDurationMs = GeneratedColumn<int>(
    'min_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalDurationMsMeta = const VerificationMeta(
    'totalDurationMs',
  );
  @override
  late final GeneratedColumn<int> totalDurationMs = GeneratedColumn<int>(
    'total_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    scriptId,
    libraryId,
    totalCount,
    successCount,
    maxDurationMs,
    minDurationMs,
    totalDurationMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lx_source_usage_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LxSourceUsageEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('script_id')) {
      context.handle(
        _scriptIdMeta,
        scriptId.isAcceptableOrUnknown(data['script_id']!, _scriptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scriptIdMeta);
    }
    if (data.containsKey('library_id')) {
      context.handle(
        _libraryIdMeta,
        libraryId.isAcceptableOrUnknown(data['library_id']!, _libraryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_libraryIdMeta);
    }
    if (data.containsKey('total_count')) {
      context.handle(
        _totalCountMeta,
        totalCount.isAcceptableOrUnknown(data['total_count']!, _totalCountMeta),
      );
    }
    if (data.containsKey('success_count')) {
      context.handle(
        _successCountMeta,
        successCount.isAcceptableOrUnknown(
          data['success_count']!,
          _successCountMeta,
        ),
      );
    }
    if (data.containsKey('max_duration_ms')) {
      context.handle(
        _maxDurationMsMeta,
        maxDurationMs.isAcceptableOrUnknown(
          data['max_duration_ms']!,
          _maxDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('min_duration_ms')) {
      context.handle(
        _minDurationMsMeta,
        minDurationMs.isAcceptableOrUnknown(
          data['min_duration_ms']!,
          _minDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('total_duration_ms')) {
      context.handle(
        _totalDurationMsMeta,
        totalDurationMs.isAcceptableOrUnknown(
          data['total_duration_ms']!,
          _totalDurationMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {scriptId, libraryId};
  @override
  LxSourceUsageEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LxSourceUsageEntity(
      scriptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}script_id'],
      )!,
      libraryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}library_id'],
      )!,
      totalCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_count'],
      )!,
      successCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}success_count'],
      )!,
      maxDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_duration_ms'],
      )!,
      minDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_duration_ms'],
      )!,
      totalDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_duration_ms'],
      )!,
    );
  }

  @override
  $LxSourceUsageTableTable createAlias(String alias) {
    return $LxSourceUsageTableTable(attachedDatabase, alias);
  }
}

class LxSourceUsageEntity extends DataClass
    implements Insertable<LxSourceUsageEntity> {
  /// 音源脚本 ID（关联 [LxSourceScriptTable.id]）
  final String scriptId;

  /// 库 ID（如 kw、kg、tx 等）
  final String libraryId;

  /// 总调用次数
  final int totalCount;

  /// 成功次数
  final int successCount;

  /// 最高耗时（毫秒）
  final int maxDurationMs;

  /// 最低耗时（毫秒）
  final int minDurationMs;

  /// 累计耗时（毫秒），用于计算平均耗时
  final int totalDurationMs;
  const LxSourceUsageEntity({
    required this.scriptId,
    required this.libraryId,
    required this.totalCount,
    required this.successCount,
    required this.maxDurationMs,
    required this.minDurationMs,
    required this.totalDurationMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['script_id'] = Variable<String>(scriptId);
    map['library_id'] = Variable<String>(libraryId);
    map['total_count'] = Variable<int>(totalCount);
    map['success_count'] = Variable<int>(successCount);
    map['max_duration_ms'] = Variable<int>(maxDurationMs);
    map['min_duration_ms'] = Variable<int>(minDurationMs);
    map['total_duration_ms'] = Variable<int>(totalDurationMs);
    return map;
  }

  LxSourceUsageTableCompanion toCompanion(bool nullToAbsent) {
    return LxSourceUsageTableCompanion(
      scriptId: Value(scriptId),
      libraryId: Value(libraryId),
      totalCount: Value(totalCount),
      successCount: Value(successCount),
      maxDurationMs: Value(maxDurationMs),
      minDurationMs: Value(minDurationMs),
      totalDurationMs: Value(totalDurationMs),
    );
  }

  factory LxSourceUsageEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LxSourceUsageEntity(
      scriptId: serializer.fromJson<String>(json['scriptId']),
      libraryId: serializer.fromJson<String>(json['libraryId']),
      totalCount: serializer.fromJson<int>(json['totalCount']),
      successCount: serializer.fromJson<int>(json['successCount']),
      maxDurationMs: serializer.fromJson<int>(json['maxDurationMs']),
      minDurationMs: serializer.fromJson<int>(json['minDurationMs']),
      totalDurationMs: serializer.fromJson<int>(json['totalDurationMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scriptId': serializer.toJson<String>(scriptId),
      'libraryId': serializer.toJson<String>(libraryId),
      'totalCount': serializer.toJson<int>(totalCount),
      'successCount': serializer.toJson<int>(successCount),
      'maxDurationMs': serializer.toJson<int>(maxDurationMs),
      'minDurationMs': serializer.toJson<int>(minDurationMs),
      'totalDurationMs': serializer.toJson<int>(totalDurationMs),
    };
  }

  LxSourceUsageEntity copyWith({
    String? scriptId,
    String? libraryId,
    int? totalCount,
    int? successCount,
    int? maxDurationMs,
    int? minDurationMs,
    int? totalDurationMs,
  }) => LxSourceUsageEntity(
    scriptId: scriptId ?? this.scriptId,
    libraryId: libraryId ?? this.libraryId,
    totalCount: totalCount ?? this.totalCount,
    successCount: successCount ?? this.successCount,
    maxDurationMs: maxDurationMs ?? this.maxDurationMs,
    minDurationMs: minDurationMs ?? this.minDurationMs,
    totalDurationMs: totalDurationMs ?? this.totalDurationMs,
  );
  LxSourceUsageEntity copyWithCompanion(LxSourceUsageTableCompanion data) {
    return LxSourceUsageEntity(
      scriptId: data.scriptId.present ? data.scriptId.value : this.scriptId,
      libraryId: data.libraryId.present ? data.libraryId.value : this.libraryId,
      totalCount: data.totalCount.present
          ? data.totalCount.value
          : this.totalCount,
      successCount: data.successCount.present
          ? data.successCount.value
          : this.successCount,
      maxDurationMs: data.maxDurationMs.present
          ? data.maxDurationMs.value
          : this.maxDurationMs,
      minDurationMs: data.minDurationMs.present
          ? data.minDurationMs.value
          : this.minDurationMs,
      totalDurationMs: data.totalDurationMs.present
          ? data.totalDurationMs.value
          : this.totalDurationMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LxSourceUsageEntity(')
          ..write('scriptId: $scriptId, ')
          ..write('libraryId: $libraryId, ')
          ..write('totalCount: $totalCount, ')
          ..write('successCount: $successCount, ')
          ..write('maxDurationMs: $maxDurationMs, ')
          ..write('minDurationMs: $minDurationMs, ')
          ..write('totalDurationMs: $totalDurationMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    scriptId,
    libraryId,
    totalCount,
    successCount,
    maxDurationMs,
    minDurationMs,
    totalDurationMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LxSourceUsageEntity &&
          other.scriptId == this.scriptId &&
          other.libraryId == this.libraryId &&
          other.totalCount == this.totalCount &&
          other.successCount == this.successCount &&
          other.maxDurationMs == this.maxDurationMs &&
          other.minDurationMs == this.minDurationMs &&
          other.totalDurationMs == this.totalDurationMs);
}

class LxSourceUsageTableCompanion extends UpdateCompanion<LxSourceUsageEntity> {
  final Value<String> scriptId;
  final Value<String> libraryId;
  final Value<int> totalCount;
  final Value<int> successCount;
  final Value<int> maxDurationMs;
  final Value<int> minDurationMs;
  final Value<int> totalDurationMs;
  final Value<int> rowid;
  const LxSourceUsageTableCompanion({
    this.scriptId = const Value.absent(),
    this.libraryId = const Value.absent(),
    this.totalCount = const Value.absent(),
    this.successCount = const Value.absent(),
    this.maxDurationMs = const Value.absent(),
    this.minDurationMs = const Value.absent(),
    this.totalDurationMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LxSourceUsageTableCompanion.insert({
    required String scriptId,
    required String libraryId,
    this.totalCount = const Value.absent(),
    this.successCount = const Value.absent(),
    this.maxDurationMs = const Value.absent(),
    this.minDurationMs = const Value.absent(),
    this.totalDurationMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : scriptId = Value(scriptId),
       libraryId = Value(libraryId);
  static Insertable<LxSourceUsageEntity> custom({
    Expression<String>? scriptId,
    Expression<String>? libraryId,
    Expression<int>? totalCount,
    Expression<int>? successCount,
    Expression<int>? maxDurationMs,
    Expression<int>? minDurationMs,
    Expression<int>? totalDurationMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (scriptId != null) 'script_id': scriptId,
      if (libraryId != null) 'library_id': libraryId,
      if (totalCount != null) 'total_count': totalCount,
      if (successCount != null) 'success_count': successCount,
      if (maxDurationMs != null) 'max_duration_ms': maxDurationMs,
      if (minDurationMs != null) 'min_duration_ms': minDurationMs,
      if (totalDurationMs != null) 'total_duration_ms': totalDurationMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LxSourceUsageTableCompanion copyWith({
    Value<String>? scriptId,
    Value<String>? libraryId,
    Value<int>? totalCount,
    Value<int>? successCount,
    Value<int>? maxDurationMs,
    Value<int>? minDurationMs,
    Value<int>? totalDurationMs,
    Value<int>? rowid,
  }) {
    return LxSourceUsageTableCompanion(
      scriptId: scriptId ?? this.scriptId,
      libraryId: libraryId ?? this.libraryId,
      totalCount: totalCount ?? this.totalCount,
      successCount: successCount ?? this.successCount,
      maxDurationMs: maxDurationMs ?? this.maxDurationMs,
      minDurationMs: minDurationMs ?? this.minDurationMs,
      totalDurationMs: totalDurationMs ?? this.totalDurationMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (scriptId.present) {
      map['script_id'] = Variable<String>(scriptId.value);
    }
    if (libraryId.present) {
      map['library_id'] = Variable<String>(libraryId.value);
    }
    if (totalCount.present) {
      map['total_count'] = Variable<int>(totalCount.value);
    }
    if (successCount.present) {
      map['success_count'] = Variable<int>(successCount.value);
    }
    if (maxDurationMs.present) {
      map['max_duration_ms'] = Variable<int>(maxDurationMs.value);
    }
    if (minDurationMs.present) {
      map['min_duration_ms'] = Variable<int>(minDurationMs.value);
    }
    if (totalDurationMs.present) {
      map['total_duration_ms'] = Variable<int>(totalDurationMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LxSourceUsageTableCompanion(')
          ..write('scriptId: $scriptId, ')
          ..write('libraryId: $libraryId, ')
          ..write('totalCount: $totalCount, ')
          ..write('successCount: $successCount, ')
          ..write('maxDurationMs: $maxDurationMs, ')
          ..write('minDurationMs: $minDurationMs, ')
          ..write('totalDurationMs: $totalDurationMs, ')
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
  late final $PreferenceTableTable preferenceTable = $PreferenceTableTable(
    this,
  );
  late final $MusicServerConfigTableTable musicServerConfigTable =
      $MusicServerConfigTableTable(this);
  late final $LocalTrackTableTable localTrackTable = $LocalTrackTableTable(
    this,
  );
  late final $LocalAlbumTableTable localAlbumTable = $LocalAlbumTableTable(
    this,
  );
  late final $LocalArtistTableTable localArtistTable = $LocalArtistTableTable(
    this,
  );
  late final $LocalPlaylistTableTable localPlaylistTable =
      $LocalPlaylistTableTable(this);
  late final $LxSourceScriptTableTable lxSourceScriptTable =
      $LxSourceScriptTableTable(this);
  late final $LxSourceUsageTableTable lxSourceUsageTable =
      $LxSourceUsageTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    playerStateTable,
    playerTrackTable,
    playHistoryTable,
    sourcedTrackTable,
    preferenceTable,
    musicServerConfigTable,
    localTrackTable,
    localAlbumTable,
    localArtistTable,
    localPlaylistTable,
    lxSourceScriptTable,
    lxSourceUsageTable,
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
typedef $$PreferenceTableTableCreateCompanionBuilder =
    PreferenceTableCompanion Function({Value<int> id, required String value});
typedef $$PreferenceTableTableUpdateCompanionBuilder =
    PreferenceTableCompanion Function({Value<int> id, Value<String> value});

class $$PreferenceTableTableFilterComposer
    extends Composer<_$AppDatabase, $PreferenceTableTable> {
  $$PreferenceTableTableFilterComposer({
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

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PreferenceTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PreferenceTableTable> {
  $$PreferenceTableTableOrderingComposer({
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

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PreferenceTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreferenceTableTable> {
  $$PreferenceTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$PreferenceTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PreferenceTableTable,
          PreferenceEntity,
          $$PreferenceTableTableFilterComposer,
          $$PreferenceTableTableOrderingComposer,
          $$PreferenceTableTableAnnotationComposer,
          $$PreferenceTableTableCreateCompanionBuilder,
          $$PreferenceTableTableUpdateCompanionBuilder,
          (
            PreferenceEntity,
            BaseReferences<
              _$AppDatabase,
              $PreferenceTableTable,
              PreferenceEntity
            >,
          ),
          PreferenceEntity,
          PrefetchHooks Function()
        > {
  $$PreferenceTableTableTableManager(
    _$AppDatabase db,
    $PreferenceTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferenceTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferenceTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferenceTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> value = const Value.absent(),
              }) => PreferenceTableCompanion(id: id, value: value),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String value}) =>
                  PreferenceTableCompanion.insert(id: id, value: value),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreferenceTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PreferenceTableTable,
      PreferenceEntity,
      $$PreferenceTableTableFilterComposer,
      $$PreferenceTableTableOrderingComposer,
      $$PreferenceTableTableAnnotationComposer,
      $$PreferenceTableTableCreateCompanionBuilder,
      $$PreferenceTableTableUpdateCompanionBuilder,
      (
        PreferenceEntity,
        BaseReferences<_$AppDatabase, $PreferenceTableTable, PreferenceEntity>,
      ),
      PreferenceEntity,
      PrefetchHooks Function()
    >;
typedef $$MusicServerConfigTableTableCreateCompanionBuilder =
    MusicServerConfigTableCompanion Function({
      required String id,
      required String name,
      required String type,
      Value<String> configJson,
      Value<bool> enabled,
      Value<int> rowid,
    });
typedef $$MusicServerConfigTableTableUpdateCompanionBuilder =
    MusicServerConfigTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<String> configJson,
      Value<bool> enabled,
      Value<int> rowid,
    });

class $$MusicServerConfigTableTableFilterComposer
    extends Composer<_$AppDatabase, $MusicServerConfigTableTable> {
  $$MusicServerConfigTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MusicServerConfigTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MusicServerConfigTableTable> {
  $$MusicServerConfigTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MusicServerConfigTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MusicServerConfigTableTable> {
  $$MusicServerConfigTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$MusicServerConfigTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MusicServerConfigTableTable,
          MusicServerConfigEntity,
          $$MusicServerConfigTableTableFilterComposer,
          $$MusicServerConfigTableTableOrderingComposer,
          $$MusicServerConfigTableTableAnnotationComposer,
          $$MusicServerConfigTableTableCreateCompanionBuilder,
          $$MusicServerConfigTableTableUpdateCompanionBuilder,
          (
            MusicServerConfigEntity,
            BaseReferences<
              _$AppDatabase,
              $MusicServerConfigTableTable,
              MusicServerConfigEntity
            >,
          ),
          MusicServerConfigEntity,
          PrefetchHooks Function()
        > {
  $$MusicServerConfigTableTableTableManager(
    _$AppDatabase db,
    $MusicServerConfigTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MusicServerConfigTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MusicServerConfigTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MusicServerConfigTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> configJson = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MusicServerConfigTableCompanion(
                id: id,
                name: name,
                type: type,
                configJson: configJson,
                enabled: enabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                Value<String> configJson = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MusicServerConfigTableCompanion.insert(
                id: id,
                name: name,
                type: type,
                configJson: configJson,
                enabled: enabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MusicServerConfigTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MusicServerConfigTableTable,
      MusicServerConfigEntity,
      $$MusicServerConfigTableTableFilterComposer,
      $$MusicServerConfigTableTableOrderingComposer,
      $$MusicServerConfigTableTableAnnotationComposer,
      $$MusicServerConfigTableTableCreateCompanionBuilder,
      $$MusicServerConfigTableTableUpdateCompanionBuilder,
      (
        MusicServerConfigEntity,
        BaseReferences<
          _$AppDatabase,
          $MusicServerConfigTableTable,
          MusicServerConfigEntity
        >,
      ),
      MusicServerConfigEntity,
      PrefetchHooks Function()
    >;
typedef $$LocalTrackTableTableCreateCompanionBuilder =
    LocalTrackTableCompanion Function({
      required String id,
      required String title,
      Value<String?> artist,
      Value<String?> album,
      Value<String?> albumId,
      Value<String?> artistId,
      Value<String?> coverArt,
      Value<int> duration,
      Value<String?> path,
      Value<String?> src,
      required String sourceId,
      Value<String?> libraryId,
      Value<bool> isLocal,
      required String trackJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalTrackTableTableUpdateCompanionBuilder =
    LocalTrackTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> artist,
      Value<String?> album,
      Value<String?> albumId,
      Value<String?> artistId,
      Value<String?> coverArt,
      Value<int> duration,
      Value<String?> path,
      Value<String?> src,
      Value<String> sourceId,
      Value<String?> libraryId,
      Value<bool> isLocal,
      Value<String> trackJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalTrackTableTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTrackTableTable> {
  $$LocalTrackTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumId => $composableBuilder(
    column: $table.albumId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistId => $composableBuilder(
    column: $table.artistId,
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

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get src => $composableBuilder(
    column: $table.src,
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

  ColumnFilters<bool> get isLocal => $composableBuilder(
    column: $table.isLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackJson => $composableBuilder(
    column: $table.trackJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTrackTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTrackTableTable> {
  $$LocalTrackTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumId => $composableBuilder(
    column: $table.albumId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistId => $composableBuilder(
    column: $table.artistId,
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

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get src => $composableBuilder(
    column: $table.src,
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

  ColumnOrderings<bool> get isLocal => $composableBuilder(
    column: $table.isLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackJson => $composableBuilder(
    column: $table.trackJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTrackTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTrackTableTable> {
  $$LocalTrackTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get albumId =>
      $composableBuilder(column: $table.albumId, builder: (column) => column);

  GeneratedColumn<String> get artistId =>
      $composableBuilder(column: $table.artistId, builder: (column) => column);

  GeneratedColumn<String> get coverArt =>
      $composableBuilder(column: $table.coverArt, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get src =>
      $composableBuilder(column: $table.src, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get libraryId =>
      $composableBuilder(column: $table.libraryId, builder: (column) => column);

  GeneratedColumn<bool> get isLocal =>
      $composableBuilder(column: $table.isLocal, builder: (column) => column);

  GeneratedColumn<String> get trackJson =>
      $composableBuilder(column: $table.trackJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalTrackTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTrackTableTable,
          LocalTrackEntity,
          $$LocalTrackTableTableFilterComposer,
          $$LocalTrackTableTableOrderingComposer,
          $$LocalTrackTableTableAnnotationComposer,
          $$LocalTrackTableTableCreateCompanionBuilder,
          $$LocalTrackTableTableUpdateCompanionBuilder,
          (
            LocalTrackEntity,
            BaseReferences<
              _$AppDatabase,
              $LocalTrackTableTable,
              LocalTrackEntity
            >,
          ),
          LocalTrackEntity,
          PrefetchHooks Function()
        > {
  $$LocalTrackTableTableTableManager(
    _$AppDatabase db,
    $LocalTrackTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTrackTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTrackTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTrackTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> albumId = const Value.absent(),
                Value<String?> artistId = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<String?> path = const Value.absent(),
                Value<String?> src = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String?> libraryId = const Value.absent(),
                Value<bool> isLocal = const Value.absent(),
                Value<String> trackJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTrackTableCompanion(
                id: id,
                title: title,
                artist: artist,
                album: album,
                albumId: albumId,
                artistId: artistId,
                coverArt: coverArt,
                duration: duration,
                path: path,
                src: src,
                sourceId: sourceId,
                libraryId: libraryId,
                isLocal: isLocal,
                trackJson: trackJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> albumId = const Value.absent(),
                Value<String?> artistId = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<String?> path = const Value.absent(),
                Value<String?> src = const Value.absent(),
                required String sourceId,
                Value<String?> libraryId = const Value.absent(),
                Value<bool> isLocal = const Value.absent(),
                required String trackJson,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTrackTableCompanion.insert(
                id: id,
                title: title,
                artist: artist,
                album: album,
                albumId: albumId,
                artistId: artistId,
                coverArt: coverArt,
                duration: duration,
                path: path,
                src: src,
                sourceId: sourceId,
                libraryId: libraryId,
                isLocal: isLocal,
                trackJson: trackJson,
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

typedef $$LocalTrackTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTrackTableTable,
      LocalTrackEntity,
      $$LocalTrackTableTableFilterComposer,
      $$LocalTrackTableTableOrderingComposer,
      $$LocalTrackTableTableAnnotationComposer,
      $$LocalTrackTableTableCreateCompanionBuilder,
      $$LocalTrackTableTableUpdateCompanionBuilder,
      (
        LocalTrackEntity,
        BaseReferences<_$AppDatabase, $LocalTrackTableTable, LocalTrackEntity>,
      ),
      LocalTrackEntity,
      PrefetchHooks Function()
    >;
typedef $$LocalAlbumTableTableCreateCompanionBuilder =
    LocalAlbumTableCompanion Function({
      required String id,
      required String name,
      Value<String?> artist,
      Value<String?> artistId,
      Value<String?> coverArt,
      Value<int?> year,
      Value<int> songCount,
      required String sourceId,
      required String albumJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalAlbumTableTableUpdateCompanionBuilder =
    LocalAlbumTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> artist,
      Value<String?> artistId,
      Value<String?> coverArt,
      Value<int?> year,
      Value<int> songCount,
      Value<String> sourceId,
      Value<String> albumJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalAlbumTableTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAlbumTableTable> {
  $$LocalAlbumTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get songCount => $composableBuilder(
    column: $table.songCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumJson => $composableBuilder(
    column: $table.albumJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAlbumTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAlbumTableTable> {
  $$LocalAlbumTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistId => $composableBuilder(
    column: $table.artistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get songCount => $composableBuilder(
    column: $table.songCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumJson => $composableBuilder(
    column: $table.albumJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAlbumTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAlbumTableTable> {
  $$LocalAlbumTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get artistId =>
      $composableBuilder(column: $table.artistId, builder: (column) => column);

  GeneratedColumn<String> get coverArt =>
      $composableBuilder(column: $table.coverArt, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get songCount =>
      $composableBuilder(column: $table.songCount, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get albumJson =>
      $composableBuilder(column: $table.albumJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalAlbumTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAlbumTableTable,
          LocalAlbumEntity,
          $$LocalAlbumTableTableFilterComposer,
          $$LocalAlbumTableTableOrderingComposer,
          $$LocalAlbumTableTableAnnotationComposer,
          $$LocalAlbumTableTableCreateCompanionBuilder,
          $$LocalAlbumTableTableUpdateCompanionBuilder,
          (
            LocalAlbumEntity,
            BaseReferences<
              _$AppDatabase,
              $LocalAlbumTableTable,
              LocalAlbumEntity
            >,
          ),
          LocalAlbumEntity,
          PrefetchHooks Function()
        > {
  $$LocalAlbumTableTableTableManager(
    _$AppDatabase db,
    $LocalAlbumTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAlbumTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAlbumTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAlbumTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> artistId = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<int> songCount = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> albumJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAlbumTableCompanion(
                id: id,
                name: name,
                artist: artist,
                artistId: artistId,
                coverArt: coverArt,
                year: year,
                songCount: songCount,
                sourceId: sourceId,
                albumJson: albumJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> artist = const Value.absent(),
                Value<String?> artistId = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<int> songCount = const Value.absent(),
                required String sourceId,
                required String albumJson,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAlbumTableCompanion.insert(
                id: id,
                name: name,
                artist: artist,
                artistId: artistId,
                coverArt: coverArt,
                year: year,
                songCount: songCount,
                sourceId: sourceId,
                albumJson: albumJson,
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

typedef $$LocalAlbumTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAlbumTableTable,
      LocalAlbumEntity,
      $$LocalAlbumTableTableFilterComposer,
      $$LocalAlbumTableTableOrderingComposer,
      $$LocalAlbumTableTableAnnotationComposer,
      $$LocalAlbumTableTableCreateCompanionBuilder,
      $$LocalAlbumTableTableUpdateCompanionBuilder,
      (
        LocalAlbumEntity,
        BaseReferences<_$AppDatabase, $LocalAlbumTableTable, LocalAlbumEntity>,
      ),
      LocalAlbumEntity,
      PrefetchHooks Function()
    >;
typedef $$LocalArtistTableTableCreateCompanionBuilder =
    LocalArtistTableCompanion Function({
      required String id,
      required String name,
      Value<String?> coverArt,
      Value<String?> artistImageUrl,
      Value<int> albumCount,
      required String sourceId,
      required String artistJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalArtistTableTableUpdateCompanionBuilder =
    LocalArtistTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> coverArt,
      Value<String?> artistImageUrl,
      Value<int> albumCount,
      Value<String> sourceId,
      Value<String> artistJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalArtistTableTableFilterComposer
    extends Composer<_$AppDatabase, $LocalArtistTableTable> {
  $$LocalArtistTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistImageUrl => $composableBuilder(
    column: $table.artistImageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get albumCount => $composableBuilder(
    column: $table.albumCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistJson => $composableBuilder(
    column: $table.artistJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalArtistTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalArtistTableTable> {
  $$LocalArtistTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistImageUrl => $composableBuilder(
    column: $table.artistImageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get albumCount => $composableBuilder(
    column: $table.albumCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistJson => $composableBuilder(
    column: $table.artistJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalArtistTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalArtistTableTable> {
  $$LocalArtistTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get coverArt =>
      $composableBuilder(column: $table.coverArt, builder: (column) => column);

  GeneratedColumn<String> get artistImageUrl => $composableBuilder(
    column: $table.artistImageUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get albumCount => $composableBuilder(
    column: $table.albumCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get artistJson => $composableBuilder(
    column: $table.artistJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalArtistTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalArtistTableTable,
          LocalArtistEntity,
          $$LocalArtistTableTableFilterComposer,
          $$LocalArtistTableTableOrderingComposer,
          $$LocalArtistTableTableAnnotationComposer,
          $$LocalArtistTableTableCreateCompanionBuilder,
          $$LocalArtistTableTableUpdateCompanionBuilder,
          (
            LocalArtistEntity,
            BaseReferences<
              _$AppDatabase,
              $LocalArtistTableTable,
              LocalArtistEntity
            >,
          ),
          LocalArtistEntity,
          PrefetchHooks Function()
        > {
  $$LocalArtistTableTableTableManager(
    _$AppDatabase db,
    $LocalArtistTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalArtistTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalArtistTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalArtistTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<String?> artistImageUrl = const Value.absent(),
                Value<int> albumCount = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> artistJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalArtistTableCompanion(
                id: id,
                name: name,
                coverArt: coverArt,
                artistImageUrl: artistImageUrl,
                albumCount: albumCount,
                sourceId: sourceId,
                artistJson: artistJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> coverArt = const Value.absent(),
                Value<String?> artistImageUrl = const Value.absent(),
                Value<int> albumCount = const Value.absent(),
                required String sourceId,
                required String artistJson,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalArtistTableCompanion.insert(
                id: id,
                name: name,
                coverArt: coverArt,
                artistImageUrl: artistImageUrl,
                albumCount: albumCount,
                sourceId: sourceId,
                artistJson: artistJson,
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

typedef $$LocalArtistTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalArtistTableTable,
      LocalArtistEntity,
      $$LocalArtistTableTableFilterComposer,
      $$LocalArtistTableTableOrderingComposer,
      $$LocalArtistTableTableAnnotationComposer,
      $$LocalArtistTableTableCreateCompanionBuilder,
      $$LocalArtistTableTableUpdateCompanionBuilder,
      (
        LocalArtistEntity,
        BaseReferences<
          _$AppDatabase,
          $LocalArtistTableTable,
          LocalArtistEntity
        >,
      ),
      LocalArtistEntity,
      PrefetchHooks Function()
    >;
typedef $$LocalPlaylistTableTableCreateCompanionBuilder =
    LocalPlaylistTableCompanion Function({
      required String id,
      required String name,
      Value<String?> owner,
      Value<String?> coverArt,
      Value<int> songCount,
      required String sourceId,
      required String playlistJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalPlaylistTableTableUpdateCompanionBuilder =
    LocalPlaylistTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> owner,
      Value<String?> coverArt,
      Value<int> songCount,
      Value<String> sourceId,
      Value<String> playlistJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalPlaylistTableTableFilterComposer
    extends Composer<_$AppDatabase, $LocalPlaylistTableTable> {
  $$LocalPlaylistTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get songCount => $composableBuilder(
    column: $table.songCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playlistJson => $composableBuilder(
    column: $table.playlistJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalPlaylistTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalPlaylistTableTable> {
  $$LocalPlaylistTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get songCount => $composableBuilder(
    column: $table.songCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playlistJson => $composableBuilder(
    column: $table.playlistJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalPlaylistTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalPlaylistTableTable> {
  $$LocalPlaylistTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<String> get coverArt =>
      $composableBuilder(column: $table.coverArt, builder: (column) => column);

  GeneratedColumn<int> get songCount =>
      $composableBuilder(column: $table.songCount, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get playlistJson => $composableBuilder(
    column: $table.playlistJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalPlaylistTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalPlaylistTableTable,
          LocalPlaylistEntity,
          $$LocalPlaylistTableTableFilterComposer,
          $$LocalPlaylistTableTableOrderingComposer,
          $$LocalPlaylistTableTableAnnotationComposer,
          $$LocalPlaylistTableTableCreateCompanionBuilder,
          $$LocalPlaylistTableTableUpdateCompanionBuilder,
          (
            LocalPlaylistEntity,
            BaseReferences<
              _$AppDatabase,
              $LocalPlaylistTableTable,
              LocalPlaylistEntity
            >,
          ),
          LocalPlaylistEntity,
          PrefetchHooks Function()
        > {
  $$LocalPlaylistTableTableTableManager(
    _$AppDatabase db,
    $LocalPlaylistTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPlaylistTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalPlaylistTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalPlaylistTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> owner = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<int> songCount = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> playlistJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPlaylistTableCompanion(
                id: id,
                name: name,
                owner: owner,
                coverArt: coverArt,
                songCount: songCount,
                sourceId: sourceId,
                playlistJson: playlistJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> owner = const Value.absent(),
                Value<String?> coverArt = const Value.absent(),
                Value<int> songCount = const Value.absent(),
                required String sourceId,
                required String playlistJson,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPlaylistTableCompanion.insert(
                id: id,
                name: name,
                owner: owner,
                coverArt: coverArt,
                songCount: songCount,
                sourceId: sourceId,
                playlistJson: playlistJson,
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

typedef $$LocalPlaylistTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalPlaylistTableTable,
      LocalPlaylistEntity,
      $$LocalPlaylistTableTableFilterComposer,
      $$LocalPlaylistTableTableOrderingComposer,
      $$LocalPlaylistTableTableAnnotationComposer,
      $$LocalPlaylistTableTableCreateCompanionBuilder,
      $$LocalPlaylistTableTableUpdateCompanionBuilder,
      (
        LocalPlaylistEntity,
        BaseReferences<
          _$AppDatabase,
          $LocalPlaylistTableTable,
          LocalPlaylistEntity
        >,
      ),
      LocalPlaylistEntity,
      PrefetchHooks Function()
    >;
typedef $$LxSourceScriptTableTableCreateCompanionBuilder =
    LxSourceScriptTableCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      Value<String?> author,
      Value<String?> homepage,
      Value<String?> version,
      required String script,
      Value<String> librariesJson,
      Value<DateTime> createdAt,
      Value<bool> enabled,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$LxSourceScriptTableTableUpdateCompanionBuilder =
    LxSourceScriptTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<String?> author,
      Value<String?> homepage,
      Value<String?> version,
      Value<String> script,
      Value<String> librariesJson,
      Value<DateTime> createdAt,
      Value<bool> enabled,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$LxSourceScriptTableTableFilterComposer
    extends Composer<_$AppDatabase, $LxSourceScriptTableTable> {
  $$LxSourceScriptTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homepage => $composableBuilder(
    column: $table.homepage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get script => $composableBuilder(
    column: $table.script,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get librariesJson => $composableBuilder(
    column: $table.librariesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LxSourceScriptTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LxSourceScriptTableTable> {
  $$LxSourceScriptTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homepage => $composableBuilder(
    column: $table.homepage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get script => $composableBuilder(
    column: $table.script,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get librariesJson => $composableBuilder(
    column: $table.librariesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LxSourceScriptTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LxSourceScriptTableTable> {
  $$LxSourceScriptTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get homepage =>
      $composableBuilder(column: $table.homepage, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get script =>
      $composableBuilder(column: $table.script, builder: (column) => column);

  GeneratedColumn<String> get librariesJson => $composableBuilder(
    column: $table.librariesJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$LxSourceScriptTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LxSourceScriptTableTable,
          LxSourceScriptEntity,
          $$LxSourceScriptTableTableFilterComposer,
          $$LxSourceScriptTableTableOrderingComposer,
          $$LxSourceScriptTableTableAnnotationComposer,
          $$LxSourceScriptTableTableCreateCompanionBuilder,
          $$LxSourceScriptTableTableUpdateCompanionBuilder,
          (
            LxSourceScriptEntity,
            BaseReferences<
              _$AppDatabase,
              $LxSourceScriptTableTable,
              LxSourceScriptEntity
            >,
          ),
          LxSourceScriptEntity,
          PrefetchHooks Function()
        > {
  $$LxSourceScriptTableTableTableManager(
    _$AppDatabase db,
    $LxSourceScriptTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LxSourceScriptTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LxSourceScriptTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LxSourceScriptTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> homepage = const Value.absent(),
                Value<String?> version = const Value.absent(),
                Value<String> script = const Value.absent(),
                Value<String> librariesJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LxSourceScriptTableCompanion(
                id: id,
                name: name,
                description: description,
                author: author,
                homepage: homepage,
                version: version,
                script: script,
                librariesJson: librariesJson,
                createdAt: createdAt,
                enabled: enabled,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> homepage = const Value.absent(),
                Value<String?> version = const Value.absent(),
                required String script,
                Value<String> librariesJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LxSourceScriptTableCompanion.insert(
                id: id,
                name: name,
                description: description,
                author: author,
                homepage: homepage,
                version: version,
                script: script,
                librariesJson: librariesJson,
                createdAt: createdAt,
                enabled: enabled,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LxSourceScriptTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LxSourceScriptTableTable,
      LxSourceScriptEntity,
      $$LxSourceScriptTableTableFilterComposer,
      $$LxSourceScriptTableTableOrderingComposer,
      $$LxSourceScriptTableTableAnnotationComposer,
      $$LxSourceScriptTableTableCreateCompanionBuilder,
      $$LxSourceScriptTableTableUpdateCompanionBuilder,
      (
        LxSourceScriptEntity,
        BaseReferences<
          _$AppDatabase,
          $LxSourceScriptTableTable,
          LxSourceScriptEntity
        >,
      ),
      LxSourceScriptEntity,
      PrefetchHooks Function()
    >;
typedef $$LxSourceUsageTableTableCreateCompanionBuilder =
    LxSourceUsageTableCompanion Function({
      required String scriptId,
      required String libraryId,
      Value<int> totalCount,
      Value<int> successCount,
      Value<int> maxDurationMs,
      Value<int> minDurationMs,
      Value<int> totalDurationMs,
      Value<int> rowid,
    });
typedef $$LxSourceUsageTableTableUpdateCompanionBuilder =
    LxSourceUsageTableCompanion Function({
      Value<String> scriptId,
      Value<String> libraryId,
      Value<int> totalCount,
      Value<int> successCount,
      Value<int> maxDurationMs,
      Value<int> minDurationMs,
      Value<int> totalDurationMs,
      Value<int> rowid,
    });

class $$LxSourceUsageTableTableFilterComposer
    extends Composer<_$AppDatabase, $LxSourceUsageTableTable> {
  $$LxSourceUsageTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get scriptId => $composableBuilder(
    column: $table.scriptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get libraryId => $composableBuilder(
    column: $table.libraryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get successCount => $composableBuilder(
    column: $table.successCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxDurationMs => $composableBuilder(
    column: $table.maxDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minDurationMs => $composableBuilder(
    column: $table.minDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDurationMs => $composableBuilder(
    column: $table.totalDurationMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LxSourceUsageTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LxSourceUsageTableTable> {
  $$LxSourceUsageTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get scriptId => $composableBuilder(
    column: $table.scriptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get libraryId => $composableBuilder(
    column: $table.libraryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get successCount => $composableBuilder(
    column: $table.successCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxDurationMs => $composableBuilder(
    column: $table.maxDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minDurationMs => $composableBuilder(
    column: $table.minDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDurationMs => $composableBuilder(
    column: $table.totalDurationMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LxSourceUsageTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LxSourceUsageTableTable> {
  $$LxSourceUsageTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get scriptId =>
      $composableBuilder(column: $table.scriptId, builder: (column) => column);

  GeneratedColumn<String> get libraryId =>
      $composableBuilder(column: $table.libraryId, builder: (column) => column);

  GeneratedColumn<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get successCount => $composableBuilder(
    column: $table.successCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxDurationMs => $composableBuilder(
    column: $table.maxDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minDurationMs => $composableBuilder(
    column: $table.minDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalDurationMs => $composableBuilder(
    column: $table.totalDurationMs,
    builder: (column) => column,
  );
}

class $$LxSourceUsageTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LxSourceUsageTableTable,
          LxSourceUsageEntity,
          $$LxSourceUsageTableTableFilterComposer,
          $$LxSourceUsageTableTableOrderingComposer,
          $$LxSourceUsageTableTableAnnotationComposer,
          $$LxSourceUsageTableTableCreateCompanionBuilder,
          $$LxSourceUsageTableTableUpdateCompanionBuilder,
          (
            LxSourceUsageEntity,
            BaseReferences<
              _$AppDatabase,
              $LxSourceUsageTableTable,
              LxSourceUsageEntity
            >,
          ),
          LxSourceUsageEntity,
          PrefetchHooks Function()
        > {
  $$LxSourceUsageTableTableTableManager(
    _$AppDatabase db,
    $LxSourceUsageTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LxSourceUsageTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LxSourceUsageTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LxSourceUsageTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> scriptId = const Value.absent(),
                Value<String> libraryId = const Value.absent(),
                Value<int> totalCount = const Value.absent(),
                Value<int> successCount = const Value.absent(),
                Value<int> maxDurationMs = const Value.absent(),
                Value<int> minDurationMs = const Value.absent(),
                Value<int> totalDurationMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LxSourceUsageTableCompanion(
                scriptId: scriptId,
                libraryId: libraryId,
                totalCount: totalCount,
                successCount: successCount,
                maxDurationMs: maxDurationMs,
                minDurationMs: minDurationMs,
                totalDurationMs: totalDurationMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String scriptId,
                required String libraryId,
                Value<int> totalCount = const Value.absent(),
                Value<int> successCount = const Value.absent(),
                Value<int> maxDurationMs = const Value.absent(),
                Value<int> minDurationMs = const Value.absent(),
                Value<int> totalDurationMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LxSourceUsageTableCompanion.insert(
                scriptId: scriptId,
                libraryId: libraryId,
                totalCount: totalCount,
                successCount: successCount,
                maxDurationMs: maxDurationMs,
                minDurationMs: minDurationMs,
                totalDurationMs: totalDurationMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LxSourceUsageTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LxSourceUsageTableTable,
      LxSourceUsageEntity,
      $$LxSourceUsageTableTableFilterComposer,
      $$LxSourceUsageTableTableOrderingComposer,
      $$LxSourceUsageTableTableAnnotationComposer,
      $$LxSourceUsageTableTableCreateCompanionBuilder,
      $$LxSourceUsageTableTableUpdateCompanionBuilder,
      (
        LxSourceUsageEntity,
        BaseReferences<
          _$AppDatabase,
          $LxSourceUsageTableTable,
          LxSourceUsageEntity
        >,
      ),
      LxSourceUsageEntity,
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
  $$PreferenceTableTableTableManager get preferenceTable =>
      $$PreferenceTableTableTableManager(_db, _db.preferenceTable);
  $$MusicServerConfigTableTableTableManager get musicServerConfigTable =>
      $$MusicServerConfigTableTableTableManager(
        _db,
        _db.musicServerConfigTable,
      );
  $$LocalTrackTableTableTableManager get localTrackTable =>
      $$LocalTrackTableTableTableManager(_db, _db.localTrackTable);
  $$LocalAlbumTableTableTableManager get localAlbumTable =>
      $$LocalAlbumTableTableTableManager(_db, _db.localAlbumTable);
  $$LocalArtistTableTableTableManager get localArtistTable =>
      $$LocalArtistTableTableTableManager(_db, _db.localArtistTable);
  $$LocalPlaylistTableTableTableManager get localPlaylistTable =>
      $$LocalPlaylistTableTableTableManager(_db, _db.localPlaylistTable);
  $$LxSourceScriptTableTableTableManager get lxSourceScriptTable =>
      $$LxSourceScriptTableTableTableManager(_db, _db.lxSourceScriptTable);
  $$LxSourceUsageTableTableTableManager get lxSourceUsageTable =>
      $$LxSourceUsageTableTableTableManager(_db, _db.lxSourceUsageTable);
}
