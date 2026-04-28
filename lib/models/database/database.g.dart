// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PreferencesTableTable extends PreferencesTable
    with TableInfo<$PreferencesTableTable, PreferencesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferencesTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _checkUpdateMeta = const VerificationMeta(
    'checkUpdate',
  );
  @override
  late final GeneratedColumn<bool> checkUpdate = GeneratedColumn<bool>(
    'check_update',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("check_update" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _normalizeAudioMeta = const VerificationMeta(
    'normalizeAudio',
  );
  @override
  late final GeneratedColumn<bool> normalizeAudio = GeneratedColumn<bool>(
    'normalize_audio',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("normalize_audio" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _showSystemTrayIconMeta =
      const VerificationMeta('showSystemTrayIcon');
  @override
  late final GeneratedColumn<bool> showSystemTrayIcon = GeneratedColumn<bool>(
    'show_system_tray_icon',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_system_tray_icon" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _systemTitleBarMeta = const VerificationMeta(
    'systemTitleBar',
  );
  @override
  late final GeneratedColumn<bool> systemTitleBar = GeneratedColumn<bool>(
    'system_title_bar',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("system_title_bar" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CloseBehavior, String>
  closeBehavior =
      GeneratedColumn<String>(
        'close_behavior',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(CloseBehavior.close.name),
      ).withConverter<CloseBehavior>(
        $PreferencesTableTable.$convertercloseBehavior,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SpotubeColor, String>
  accentColorScheme =
      GeneratedColumn<String>(
        'accent_color_scheme',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant("Slate:0xff64748b"),
      ).withConverter<SpotubeColor>(
        $PreferencesTableTable.$converteraccentColorScheme,
      );
  @override
  late final GeneratedColumnWithTypeConverter<LayoutMode, String> layoutMode =
      GeneratedColumn<String>(
        'layout_mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(LayoutMode.adaptive.name),
      ).withConverter<LayoutMode>($PreferencesTableTable.$converterlayoutMode);
  @override
  late final GeneratedColumnWithTypeConverter<Locale, String> locale =
      GeneratedColumn<String>(
        'locale',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(
          '{"languageCode":"system","countryCode":"system"}',
        ),
      ).withConverter<Locale>($PreferencesTableTable.$converterlocale);
  static const VerificationMeta _downloadLocationMeta = const VerificationMeta(
    'downloadLocation',
  );
  @override
  late final GeneratedColumn<String> downloadLocation = GeneratedColumn<String>(
    'download_location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(""),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  localLibraryLocation =
      GeneratedColumn<String>(
        'local_library_location',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(""),
      ).withConverter<List<String>>(
        $PreferencesTableTable.$converterlocalLibraryLocation,
      );
  @override
  late final GeneratedColumnWithTypeConverter<ThemeMode, String> themeMode =
      GeneratedColumn<String>(
        'theme_mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(ThemeMode.system.name),
      ).withConverter<ThemeMode>($PreferencesTableTable.$converterthemeMode);
  static const VerificationMeta _discordPresenceMeta = const VerificationMeta(
    'discordPresence',
  );
  @override
  late final GeneratedColumn<bool> discordPresence = GeneratedColumn<bool>(
    'discord_presence',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("discord_presence" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _cacheMusicMeta = const VerificationMeta(
    'cacheMusic',
  );
  @override
  late final GeneratedColumn<bool> cacheMusic = GeneratedColumn<bool>(
    'cache_music',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("cache_music" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    checkUpdate,
    normalizeAudio,
    showSystemTrayIcon,
    systemTitleBar,
    closeBehavior,
    accentColorScheme,
    layoutMode,
    locale,
    downloadLocation,
    localLibraryLocation,
    themeMode,
    discordPresence,
    cacheMusic,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preferences_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreferencesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('check_update')) {
      context.handle(
        _checkUpdateMeta,
        checkUpdate.isAcceptableOrUnknown(
          data['check_update']!,
          _checkUpdateMeta,
        ),
      );
    }
    if (data.containsKey('normalize_audio')) {
      context.handle(
        _normalizeAudioMeta,
        normalizeAudio.isAcceptableOrUnknown(
          data['normalize_audio']!,
          _normalizeAudioMeta,
        ),
      );
    }
    if (data.containsKey('show_system_tray_icon')) {
      context.handle(
        _showSystemTrayIconMeta,
        showSystemTrayIcon.isAcceptableOrUnknown(
          data['show_system_tray_icon']!,
          _showSystemTrayIconMeta,
        ),
      );
    }
    if (data.containsKey('system_title_bar')) {
      context.handle(
        _systemTitleBarMeta,
        systemTitleBar.isAcceptableOrUnknown(
          data['system_title_bar']!,
          _systemTitleBarMeta,
        ),
      );
    }
    if (data.containsKey('download_location')) {
      context.handle(
        _downloadLocationMeta,
        downloadLocation.isAcceptableOrUnknown(
          data['download_location']!,
          _downloadLocationMeta,
        ),
      );
    }
    if (data.containsKey('discord_presence')) {
      context.handle(
        _discordPresenceMeta,
        discordPresence.isAcceptableOrUnknown(
          data['discord_presence']!,
          _discordPresenceMeta,
        ),
      );
    }
    if (data.containsKey('cache_music')) {
      context.handle(
        _cacheMusicMeta,
        cacheMusic.isAcceptableOrUnknown(data['cache_music']!, _cacheMusicMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PreferencesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreferencesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      checkUpdate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}check_update'],
      )!,
      normalizeAudio: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}normalize_audio'],
      )!,
      showSystemTrayIcon: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_system_tray_icon'],
      )!,
      systemTitleBar: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}system_title_bar'],
      )!,
      closeBehavior: $PreferencesTableTable.$convertercloseBehavior.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}close_behavior'],
        )!,
      ),
      accentColorScheme: $PreferencesTableTable.$converteraccentColorScheme
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}accent_color_scheme'],
            )!,
          ),
      layoutMode: $PreferencesTableTable.$converterlayoutMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}layout_mode'],
        )!,
      ),
      locale: $PreferencesTableTable.$converterlocale.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}locale'],
        )!,
      ),
      downloadLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}download_location'],
      )!,
      localLibraryLocation: $PreferencesTableTable
          .$converterlocalLibraryLocation
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}local_library_location'],
            )!,
          ),
      themeMode: $PreferencesTableTable.$converterthemeMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}theme_mode'],
        )!,
      ),
      discordPresence: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}discord_presence'],
      )!,
      cacheMusic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}cache_music'],
      )!,
    );
  }

  @override
  $PreferencesTableTable createAlias(String alias) {
    return $PreferencesTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CloseBehavior, String, String>
  $convertercloseBehavior = const EnumNameConverter<CloseBehavior>(
    CloseBehavior.values,
  );
  static TypeConverter<SpotubeColor, String> $converteraccentColorScheme =
      const SpotubeColorConverter();
  static JsonTypeConverter2<LayoutMode, String, String> $converterlayoutMode =
      const EnumNameConverter<LayoutMode>(LayoutMode.values);
  static TypeConverter<Locale, String> $converterlocale =
      const LocaleConverter();
  static TypeConverter<List<String>, String> $converterlocalLibraryLocation =
      const StringListConverter();
  static JsonTypeConverter2<ThemeMode, String, String> $converterthemeMode =
      const EnumNameConverter<ThemeMode>(ThemeMode.values);
}

class PreferencesTableData extends DataClass
    implements Insertable<PreferencesTableData> {
  final int id;
  final bool checkUpdate;
  final bool normalizeAudio;
  final bool showSystemTrayIcon;
  final bool systemTitleBar;
  final CloseBehavior closeBehavior;
  final SpotubeColor accentColorScheme;
  final LayoutMode layoutMode;
  final Locale locale;
  final String downloadLocation;
  final List<String> localLibraryLocation;
  final ThemeMode themeMode;
  final bool discordPresence;
  final bool cacheMusic;
  const PreferencesTableData({
    required this.id,
    required this.checkUpdate,
    required this.normalizeAudio,
    required this.showSystemTrayIcon,
    required this.systemTitleBar,
    required this.closeBehavior,
    required this.accentColorScheme,
    required this.layoutMode,
    required this.locale,
    required this.downloadLocation,
    required this.localLibraryLocation,
    required this.themeMode,
    required this.discordPresence,
    required this.cacheMusic,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['check_update'] = Variable<bool>(checkUpdate);
    map['normalize_audio'] = Variable<bool>(normalizeAudio);
    map['show_system_tray_icon'] = Variable<bool>(showSystemTrayIcon);
    map['system_title_bar'] = Variable<bool>(systemTitleBar);
    {
      map['close_behavior'] = Variable<String>(
        $PreferencesTableTable.$convertercloseBehavior.toSql(closeBehavior),
      );
    }
    {
      map['accent_color_scheme'] = Variable<String>(
        $PreferencesTableTable.$converteraccentColorScheme.toSql(
          accentColorScheme,
        ),
      );
    }
    {
      map['layout_mode'] = Variable<String>(
        $PreferencesTableTable.$converterlayoutMode.toSql(layoutMode),
      );
    }
    {
      map['locale'] = Variable<String>(
        $PreferencesTableTable.$converterlocale.toSql(locale),
      );
    }
    map['download_location'] = Variable<String>(downloadLocation);
    {
      map['local_library_location'] = Variable<String>(
        $PreferencesTableTable.$converterlocalLibraryLocation.toSql(
          localLibraryLocation,
        ),
      );
    }
    {
      map['theme_mode'] = Variable<String>(
        $PreferencesTableTable.$converterthemeMode.toSql(themeMode),
      );
    }
    map['discord_presence'] = Variable<bool>(discordPresence);
    map['cache_music'] = Variable<bool>(cacheMusic);
    return map;
  }

  PreferencesTableCompanion toCompanion(bool nullToAbsent) {
    return PreferencesTableCompanion(
      id: Value(id),
      checkUpdate: Value(checkUpdate),
      normalizeAudio: Value(normalizeAudio),
      showSystemTrayIcon: Value(showSystemTrayIcon),
      systemTitleBar: Value(systemTitleBar),
      closeBehavior: Value(closeBehavior),
      accentColorScheme: Value(accentColorScheme),
      layoutMode: Value(layoutMode),
      locale: Value(locale),
      downloadLocation: Value(downloadLocation),
      localLibraryLocation: Value(localLibraryLocation),
      themeMode: Value(themeMode),
      discordPresence: Value(discordPresence),
      cacheMusic: Value(cacheMusic),
    );
  }

  factory PreferencesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreferencesTableData(
      id: serializer.fromJson<int>(json['id']),
      checkUpdate: serializer.fromJson<bool>(json['checkUpdate']),
      normalizeAudio: serializer.fromJson<bool>(json['normalizeAudio']),
      showSystemTrayIcon: serializer.fromJson<bool>(json['showSystemTrayIcon']),
      systemTitleBar: serializer.fromJson<bool>(json['systemTitleBar']),
      closeBehavior: $PreferencesTableTable.$convertercloseBehavior.fromJson(
        serializer.fromJson<String>(json['closeBehavior']),
      ),
      accentColorScheme: serializer.fromJson<SpotubeColor>(
        json['accentColorScheme'],
      ),
      layoutMode: $PreferencesTableTable.$converterlayoutMode.fromJson(
        serializer.fromJson<String>(json['layoutMode']),
      ),
      locale: serializer.fromJson<Locale>(json['locale']),
      downloadLocation: serializer.fromJson<String>(json['downloadLocation']),
      localLibraryLocation: serializer.fromJson<List<String>>(
        json['localLibraryLocation'],
      ),
      themeMode: $PreferencesTableTable.$converterthemeMode.fromJson(
        serializer.fromJson<String>(json['themeMode']),
      ),
      discordPresence: serializer.fromJson<bool>(json['discordPresence']),
      cacheMusic: serializer.fromJson<bool>(json['cacheMusic']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'checkUpdate': serializer.toJson<bool>(checkUpdate),
      'normalizeAudio': serializer.toJson<bool>(normalizeAudio),
      'showSystemTrayIcon': serializer.toJson<bool>(showSystemTrayIcon),
      'systemTitleBar': serializer.toJson<bool>(systemTitleBar),
      'closeBehavior': serializer.toJson<String>(
        $PreferencesTableTable.$convertercloseBehavior.toJson(closeBehavior),
      ),
      'accentColorScheme': serializer.toJson<SpotubeColor>(accentColorScheme),
      'layoutMode': serializer.toJson<String>(
        $PreferencesTableTable.$converterlayoutMode.toJson(layoutMode),
      ),
      'locale': serializer.toJson<Locale>(locale),
      'downloadLocation': serializer.toJson<String>(downloadLocation),
      'localLibraryLocation': serializer.toJson<List<String>>(
        localLibraryLocation,
      ),
      'themeMode': serializer.toJson<String>(
        $PreferencesTableTable.$converterthemeMode.toJson(themeMode),
      ),
      'discordPresence': serializer.toJson<bool>(discordPresence),
      'cacheMusic': serializer.toJson<bool>(cacheMusic),
    };
  }

  PreferencesTableData copyWith({
    int? id,
    bool? checkUpdate,
    bool? normalizeAudio,
    bool? showSystemTrayIcon,
    bool? systemTitleBar,
    CloseBehavior? closeBehavior,
    SpotubeColor? accentColorScheme,
    LayoutMode? layoutMode,
    Locale? locale,
    String? downloadLocation,
    List<String>? localLibraryLocation,
    ThemeMode? themeMode,
    bool? discordPresence,
    bool? cacheMusic,
  }) => PreferencesTableData(
    id: id ?? this.id,
    checkUpdate: checkUpdate ?? this.checkUpdate,
    normalizeAudio: normalizeAudio ?? this.normalizeAudio,
    showSystemTrayIcon: showSystemTrayIcon ?? this.showSystemTrayIcon,
    systemTitleBar: systemTitleBar ?? this.systemTitleBar,
    closeBehavior: closeBehavior ?? this.closeBehavior,
    accentColorScheme: accentColorScheme ?? this.accentColorScheme,
    layoutMode: layoutMode ?? this.layoutMode,
    locale: locale ?? this.locale,
    downloadLocation: downloadLocation ?? this.downloadLocation,
    localLibraryLocation: localLibraryLocation ?? this.localLibraryLocation,
    themeMode: themeMode ?? this.themeMode,
    discordPresence: discordPresence ?? this.discordPresence,
    cacheMusic: cacheMusic ?? this.cacheMusic,
  );
  PreferencesTableData copyWithCompanion(PreferencesTableCompanion data) {
    return PreferencesTableData(
      id: data.id.present ? data.id.value : this.id,
      checkUpdate: data.checkUpdate.present
          ? data.checkUpdate.value
          : this.checkUpdate,
      normalizeAudio: data.normalizeAudio.present
          ? data.normalizeAudio.value
          : this.normalizeAudio,
      showSystemTrayIcon: data.showSystemTrayIcon.present
          ? data.showSystemTrayIcon.value
          : this.showSystemTrayIcon,
      systemTitleBar: data.systemTitleBar.present
          ? data.systemTitleBar.value
          : this.systemTitleBar,
      closeBehavior: data.closeBehavior.present
          ? data.closeBehavior.value
          : this.closeBehavior,
      accentColorScheme: data.accentColorScheme.present
          ? data.accentColorScheme.value
          : this.accentColorScheme,
      layoutMode: data.layoutMode.present
          ? data.layoutMode.value
          : this.layoutMode,
      locale: data.locale.present ? data.locale.value : this.locale,
      downloadLocation: data.downloadLocation.present
          ? data.downloadLocation.value
          : this.downloadLocation,
      localLibraryLocation: data.localLibraryLocation.present
          ? data.localLibraryLocation.value
          : this.localLibraryLocation,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      discordPresence: data.discordPresence.present
          ? data.discordPresence.value
          : this.discordPresence,
      cacheMusic: data.cacheMusic.present
          ? data.cacheMusic.value
          : this.cacheMusic,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreferencesTableData(')
          ..write('id: $id, ')
          ..write('checkUpdate: $checkUpdate, ')
          ..write('normalizeAudio: $normalizeAudio, ')
          ..write('showSystemTrayIcon: $showSystemTrayIcon, ')
          ..write('systemTitleBar: $systemTitleBar, ')
          ..write('closeBehavior: $closeBehavior, ')
          ..write('accentColorScheme: $accentColorScheme, ')
          ..write('layoutMode: $layoutMode, ')
          ..write('locale: $locale, ')
          ..write('downloadLocation: $downloadLocation, ')
          ..write('localLibraryLocation: $localLibraryLocation, ')
          ..write('themeMode: $themeMode, ')
          ..write('discordPresence: $discordPresence, ')
          ..write('cacheMusic: $cacheMusic')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    checkUpdate,
    normalizeAudio,
    showSystemTrayIcon,
    systemTitleBar,
    closeBehavior,
    accentColorScheme,
    layoutMode,
    locale,
    downloadLocation,
    localLibraryLocation,
    themeMode,
    discordPresence,
    cacheMusic,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreferencesTableData &&
          other.id == this.id &&
          other.checkUpdate == this.checkUpdate &&
          other.normalizeAudio == this.normalizeAudio &&
          other.showSystemTrayIcon == this.showSystemTrayIcon &&
          other.systemTitleBar == this.systemTitleBar &&
          other.closeBehavior == this.closeBehavior &&
          other.accentColorScheme == this.accentColorScheme &&
          other.layoutMode == this.layoutMode &&
          other.locale == this.locale &&
          other.downloadLocation == this.downloadLocation &&
          other.localLibraryLocation == this.localLibraryLocation &&
          other.themeMode == this.themeMode &&
          other.discordPresence == this.discordPresence &&
          other.cacheMusic == this.cacheMusic);
}

class PreferencesTableCompanion extends UpdateCompanion<PreferencesTableData> {
  final Value<int> id;
  final Value<bool> checkUpdate;
  final Value<bool> normalizeAudio;
  final Value<bool> showSystemTrayIcon;
  final Value<bool> systemTitleBar;
  final Value<CloseBehavior> closeBehavior;
  final Value<SpotubeColor> accentColorScheme;
  final Value<LayoutMode> layoutMode;
  final Value<Locale> locale;
  final Value<String> downloadLocation;
  final Value<List<String>> localLibraryLocation;
  final Value<ThemeMode> themeMode;
  final Value<bool> discordPresence;
  final Value<bool> cacheMusic;
  const PreferencesTableCompanion({
    this.id = const Value.absent(),
    this.checkUpdate = const Value.absent(),
    this.normalizeAudio = const Value.absent(),
    this.showSystemTrayIcon = const Value.absent(),
    this.systemTitleBar = const Value.absent(),
    this.closeBehavior = const Value.absent(),
    this.accentColorScheme = const Value.absent(),
    this.layoutMode = const Value.absent(),
    this.locale = const Value.absent(),
    this.downloadLocation = const Value.absent(),
    this.localLibraryLocation = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.discordPresence = const Value.absent(),
    this.cacheMusic = const Value.absent(),
  });
  PreferencesTableCompanion.insert({
    this.id = const Value.absent(),
    this.checkUpdate = const Value.absent(),
    this.normalizeAudio = const Value.absent(),
    this.showSystemTrayIcon = const Value.absent(),
    this.systemTitleBar = const Value.absent(),
    this.closeBehavior = const Value.absent(),
    this.accentColorScheme = const Value.absent(),
    this.layoutMode = const Value.absent(),
    this.locale = const Value.absent(),
    this.downloadLocation = const Value.absent(),
    this.localLibraryLocation = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.discordPresence = const Value.absent(),
    this.cacheMusic = const Value.absent(),
  });
  static Insertable<PreferencesTableData> custom({
    Expression<int>? id,
    Expression<bool>? checkUpdate,
    Expression<bool>? normalizeAudio,
    Expression<bool>? showSystemTrayIcon,
    Expression<bool>? systemTitleBar,
    Expression<String>? closeBehavior,
    Expression<String>? accentColorScheme,
    Expression<String>? layoutMode,
    Expression<String>? locale,
    Expression<String>? downloadLocation,
    Expression<String>? localLibraryLocation,
    Expression<String>? themeMode,
    Expression<bool>? discordPresence,
    Expression<bool>? cacheMusic,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (checkUpdate != null) 'check_update': checkUpdate,
      if (normalizeAudio != null) 'normalize_audio': normalizeAudio,
      if (showSystemTrayIcon != null)
        'show_system_tray_icon': showSystemTrayIcon,
      if (systemTitleBar != null) 'system_title_bar': systemTitleBar,
      if (closeBehavior != null) 'close_behavior': closeBehavior,
      if (accentColorScheme != null) 'accent_color_scheme': accentColorScheme,
      if (layoutMode != null) 'layout_mode': layoutMode,
      if (locale != null) 'locale': locale,
      if (downloadLocation != null) 'download_location': downloadLocation,
      if (localLibraryLocation != null)
        'local_library_location': localLibraryLocation,
      if (themeMode != null) 'theme_mode': themeMode,
      if (discordPresence != null) 'discord_presence': discordPresence,
      if (cacheMusic != null) 'cache_music': cacheMusic,
    });
  }

  PreferencesTableCompanion copyWith({
    Value<int>? id,
    Value<bool>? checkUpdate,
    Value<bool>? normalizeAudio,
    Value<bool>? showSystemTrayIcon,
    Value<bool>? systemTitleBar,
    Value<CloseBehavior>? closeBehavior,
    Value<SpotubeColor>? accentColorScheme,
    Value<LayoutMode>? layoutMode,
    Value<Locale>? locale,
    Value<String>? downloadLocation,
    Value<List<String>>? localLibraryLocation,
    Value<ThemeMode>? themeMode,
    Value<bool>? discordPresence,
    Value<bool>? cacheMusic,
  }) {
    return PreferencesTableCompanion(
      id: id ?? this.id,
      checkUpdate: checkUpdate ?? this.checkUpdate,
      normalizeAudio: normalizeAudio ?? this.normalizeAudio,
      showSystemTrayIcon: showSystemTrayIcon ?? this.showSystemTrayIcon,
      systemTitleBar: systemTitleBar ?? this.systemTitleBar,
      closeBehavior: closeBehavior ?? this.closeBehavior,
      accentColorScheme: accentColorScheme ?? this.accentColorScheme,
      layoutMode: layoutMode ?? this.layoutMode,
      locale: locale ?? this.locale,
      downloadLocation: downloadLocation ?? this.downloadLocation,
      localLibraryLocation: localLibraryLocation ?? this.localLibraryLocation,
      themeMode: themeMode ?? this.themeMode,
      discordPresence: discordPresence ?? this.discordPresence,
      cacheMusic: cacheMusic ?? this.cacheMusic,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (checkUpdate.present) {
      map['check_update'] = Variable<bool>(checkUpdate.value);
    }
    if (normalizeAudio.present) {
      map['normalize_audio'] = Variable<bool>(normalizeAudio.value);
    }
    if (showSystemTrayIcon.present) {
      map['show_system_tray_icon'] = Variable<bool>(showSystemTrayIcon.value);
    }
    if (systemTitleBar.present) {
      map['system_title_bar'] = Variable<bool>(systemTitleBar.value);
    }
    if (closeBehavior.present) {
      map['close_behavior'] = Variable<String>(
        $PreferencesTableTable.$convertercloseBehavior.toSql(
          closeBehavior.value,
        ),
      );
    }
    if (accentColorScheme.present) {
      map['accent_color_scheme'] = Variable<String>(
        $PreferencesTableTable.$converteraccentColorScheme.toSql(
          accentColorScheme.value,
        ),
      );
    }
    if (layoutMode.present) {
      map['layout_mode'] = Variable<String>(
        $PreferencesTableTable.$converterlayoutMode.toSql(layoutMode.value),
      );
    }
    if (locale.present) {
      map['locale'] = Variable<String>(
        $PreferencesTableTable.$converterlocale.toSql(locale.value),
      );
    }
    if (downloadLocation.present) {
      map['download_location'] = Variable<String>(downloadLocation.value);
    }
    if (localLibraryLocation.present) {
      map['local_library_location'] = Variable<String>(
        $PreferencesTableTable.$converterlocalLibraryLocation.toSql(
          localLibraryLocation.value,
        ),
      );
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(
        $PreferencesTableTable.$converterthemeMode.toSql(themeMode.value),
      );
    }
    if (discordPresence.present) {
      map['discord_presence'] = Variable<bool>(discordPresence.value);
    }
    if (cacheMusic.present) {
      map['cache_music'] = Variable<bool>(cacheMusic.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferencesTableCompanion(')
          ..write('id: $id, ')
          ..write('checkUpdate: $checkUpdate, ')
          ..write('normalizeAudio: $normalizeAudio, ')
          ..write('showSystemTrayIcon: $showSystemTrayIcon, ')
          ..write('systemTitleBar: $systemTitleBar, ')
          ..write('closeBehavior: $closeBehavior, ')
          ..write('accentColorScheme: $accentColorScheme, ')
          ..write('layoutMode: $layoutMode, ')
          ..write('locale: $locale, ')
          ..write('downloadLocation: $downloadLocation, ')
          ..write('localLibraryLocation: $localLibraryLocation, ')
          ..write('themeMode: $themeMode, ')
          ..write('discordPresence: $discordPresence, ')
          ..write('cacheMusic: $cacheMusic')
          ..write(')'))
        .toString();
  }
}

class $AudioPlayerStateTableTable extends AudioPlayerStateTable
    with TableInfo<$AudioPlayerStateTableTable, AudioPlayerStateTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioPlayerStateTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _playingMeta = const VerificationMeta(
    'playing',
  );
  @override
  late final GeneratedColumn<bool> playing = GeneratedColumn<bool>(
    'playing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("playing" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PlaylistMode, String> loopMode =
      GeneratedColumn<String>(
        'loop_mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PlaylistMode>(
        $AudioPlayerStateTableTable.$converterloopMode,
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
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("shuffled" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  collections =
      GeneratedColumn<String>(
        'collections',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>(
        $AudioPlayerStateTableTable.$convertercollections,
      );
  @override
  late final GeneratedColumnWithTypeConverter<List<SpotubeTrackObject>, String>
  tracks =
      GeneratedColumn<String>(
        'tracks',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant("[]"),
      ).withConverter<List<SpotubeTrackObject>>(
        $AudioPlayerStateTableTable.$convertertracks,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    playing,
    loopMode,
    shuffled,
    collections,
    tracks,
    currentIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_player_state_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioPlayerStateTableData> instance, {
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
    } else if (isInserting) {
      context.missing(_playingMeta);
    }
    if (data.containsKey('shuffled')) {
      context.handle(
        _shuffledMeta,
        shuffled.isAcceptableOrUnknown(data['shuffled']!, _shuffledMeta),
      );
    } else if (isInserting) {
      context.missing(_shuffledMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AudioPlayerStateTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioPlayerStateTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      playing: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}playing'],
      )!,
      loopMode: $AudioPlayerStateTableTable.$converterloopMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}loop_mode'],
        )!,
      ),
      shuffled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}shuffled'],
      )!,
      collections: $AudioPlayerStateTableTable.$convertercollections.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}collections'],
        )!,
      ),
      tracks: $AudioPlayerStateTableTable.$convertertracks.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tracks'],
        )!,
      ),
      currentIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_index'],
      )!,
    );
  }

  @override
  $AudioPlayerStateTableTable createAlias(String alias) {
    return $AudioPlayerStateTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PlaylistMode, String, String> $converterloopMode =
      const EnumNameConverter<PlaylistMode>(PlaylistMode.values);
  static TypeConverter<List<String>, String> $convertercollections =
      const StringListConverter();
  static TypeConverter<List<SpotubeTrackObject>, String> $convertertracks =
      const SpotubeTrackObjectListConverter();
}

class AudioPlayerStateTableData extends DataClass
    implements Insertable<AudioPlayerStateTableData> {
  final int id;
  final bool playing;
  final PlaylistMode loopMode;
  final bool shuffled;
  final List<String> collections;
  final List<SpotubeTrackObject> tracks;
  final int currentIndex;
  const AudioPlayerStateTableData({
    required this.id,
    required this.playing,
    required this.loopMode,
    required this.shuffled,
    required this.collections,
    required this.tracks,
    required this.currentIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['playing'] = Variable<bool>(playing);
    {
      map['loop_mode'] = Variable<String>(
        $AudioPlayerStateTableTable.$converterloopMode.toSql(loopMode),
      );
    }
    map['shuffled'] = Variable<bool>(shuffled);
    {
      map['collections'] = Variable<String>(
        $AudioPlayerStateTableTable.$convertercollections.toSql(collections),
      );
    }
    {
      map['tracks'] = Variable<String>(
        $AudioPlayerStateTableTable.$convertertracks.toSql(tracks),
      );
    }
    map['current_index'] = Variable<int>(currentIndex);
    return map;
  }

  AudioPlayerStateTableCompanion toCompanion(bool nullToAbsent) {
    return AudioPlayerStateTableCompanion(
      id: Value(id),
      playing: Value(playing),
      loopMode: Value(loopMode),
      shuffled: Value(shuffled),
      collections: Value(collections),
      tracks: Value(tracks),
      currentIndex: Value(currentIndex),
    );
  }

  factory AudioPlayerStateTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioPlayerStateTableData(
      id: serializer.fromJson<int>(json['id']),
      playing: serializer.fromJson<bool>(json['playing']),
      loopMode: $AudioPlayerStateTableTable.$converterloopMode.fromJson(
        serializer.fromJson<String>(json['loopMode']),
      ),
      shuffled: serializer.fromJson<bool>(json['shuffled']),
      collections: serializer.fromJson<List<String>>(json['collections']),
      tracks: serializer.fromJson<List<SpotubeTrackObject>>(json['tracks']),
      currentIndex: serializer.fromJson<int>(json['currentIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playing': serializer.toJson<bool>(playing),
      'loopMode': serializer.toJson<String>(
        $AudioPlayerStateTableTable.$converterloopMode.toJson(loopMode),
      ),
      'shuffled': serializer.toJson<bool>(shuffled),
      'collections': serializer.toJson<List<String>>(collections),
      'tracks': serializer.toJson<List<SpotubeTrackObject>>(tracks),
      'currentIndex': serializer.toJson<int>(currentIndex),
    };
  }

  AudioPlayerStateTableData copyWith({
    int? id,
    bool? playing,
    PlaylistMode? loopMode,
    bool? shuffled,
    List<String>? collections,
    List<SpotubeTrackObject>? tracks,
    int? currentIndex,
  }) => AudioPlayerStateTableData(
    id: id ?? this.id,
    playing: playing ?? this.playing,
    loopMode: loopMode ?? this.loopMode,
    shuffled: shuffled ?? this.shuffled,
    collections: collections ?? this.collections,
    tracks: tracks ?? this.tracks,
    currentIndex: currentIndex ?? this.currentIndex,
  );
  AudioPlayerStateTableData copyWithCompanion(
    AudioPlayerStateTableCompanion data,
  ) {
    return AudioPlayerStateTableData(
      id: data.id.present ? data.id.value : this.id,
      playing: data.playing.present ? data.playing.value : this.playing,
      loopMode: data.loopMode.present ? data.loopMode.value : this.loopMode,
      shuffled: data.shuffled.present ? data.shuffled.value : this.shuffled,
      collections: data.collections.present
          ? data.collections.value
          : this.collections,
      tracks: data.tracks.present ? data.tracks.value : this.tracks,
      currentIndex: data.currentIndex.present
          ? data.currentIndex.value
          : this.currentIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioPlayerStateTableData(')
          ..write('id: $id, ')
          ..write('playing: $playing, ')
          ..write('loopMode: $loopMode, ')
          ..write('shuffled: $shuffled, ')
          ..write('collections: $collections, ')
          ..write('tracks: $tracks, ')
          ..write('currentIndex: $currentIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    playing,
    loopMode,
    shuffled,
    collections,
    tracks,
    currentIndex,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioPlayerStateTableData &&
          other.id == this.id &&
          other.playing == this.playing &&
          other.loopMode == this.loopMode &&
          other.shuffled == this.shuffled &&
          other.collections == this.collections &&
          other.tracks == this.tracks &&
          other.currentIndex == this.currentIndex);
}

class AudioPlayerStateTableCompanion
    extends UpdateCompanion<AudioPlayerStateTableData> {
  final Value<int> id;
  final Value<bool> playing;
  final Value<PlaylistMode> loopMode;
  final Value<bool> shuffled;
  final Value<List<String>> collections;
  final Value<List<SpotubeTrackObject>> tracks;
  final Value<int> currentIndex;
  const AudioPlayerStateTableCompanion({
    this.id = const Value.absent(),
    this.playing = const Value.absent(),
    this.loopMode = const Value.absent(),
    this.shuffled = const Value.absent(),
    this.collections = const Value.absent(),
    this.tracks = const Value.absent(),
    this.currentIndex = const Value.absent(),
  });
  AudioPlayerStateTableCompanion.insert({
    this.id = const Value.absent(),
    required bool playing,
    required PlaylistMode loopMode,
    required bool shuffled,
    required List<String> collections,
    this.tracks = const Value.absent(),
    this.currentIndex = const Value.absent(),
  }) : playing = Value(playing),
       loopMode = Value(loopMode),
       shuffled = Value(shuffled),
       collections = Value(collections);
  static Insertable<AudioPlayerStateTableData> custom({
    Expression<int>? id,
    Expression<bool>? playing,
    Expression<String>? loopMode,
    Expression<bool>? shuffled,
    Expression<String>? collections,
    Expression<String>? tracks,
    Expression<int>? currentIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playing != null) 'playing': playing,
      if (loopMode != null) 'loop_mode': loopMode,
      if (shuffled != null) 'shuffled': shuffled,
      if (collections != null) 'collections': collections,
      if (tracks != null) 'tracks': tracks,
      if (currentIndex != null) 'current_index': currentIndex,
    });
  }

  AudioPlayerStateTableCompanion copyWith({
    Value<int>? id,
    Value<bool>? playing,
    Value<PlaylistMode>? loopMode,
    Value<bool>? shuffled,
    Value<List<String>>? collections,
    Value<List<SpotubeTrackObject>>? tracks,
    Value<int>? currentIndex,
  }) {
    return AudioPlayerStateTableCompanion(
      id: id ?? this.id,
      playing: playing ?? this.playing,
      loopMode: loopMode ?? this.loopMode,
      shuffled: shuffled ?? this.shuffled,
      collections: collections ?? this.collections,
      tracks: tracks ?? this.tracks,
      currentIndex: currentIndex ?? this.currentIndex,
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
      map['loop_mode'] = Variable<String>(
        $AudioPlayerStateTableTable.$converterloopMode.toSql(loopMode.value),
      );
    }
    if (shuffled.present) {
      map['shuffled'] = Variable<bool>(shuffled.value);
    }
    if (collections.present) {
      map['collections'] = Variable<String>(
        $AudioPlayerStateTableTable.$convertercollections.toSql(
          collections.value,
        ),
      );
    }
    if (tracks.present) {
      map['tracks'] = Variable<String>(
        $AudioPlayerStateTableTable.$convertertracks.toSql(tracks.value),
      );
    }
    if (currentIndex.present) {
      map['current_index'] = Variable<int>(currentIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioPlayerStateTableCompanion(')
          ..write('id: $id, ')
          ..write('playing: $playing, ')
          ..write('loopMode: $loopMode, ')
          ..write('shuffled: $shuffled, ')
          ..write('collections: $collections, ')
          ..write('tracks: $tracks, ')
          ..write('currentIndex: $currentIndex')
          ..write(')'))
        .toString();
  }
}

class $HistoryTableTable extends HistoryTable
    with TableInfo<$HistoryTableTable, HistoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryTableTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<HistoryEntryType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<HistoryEntryType>($HistoryTableTable.$convertertype);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Map<String, dynamic>>($HistoryTableTable.$converterdata);
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, type, itemId, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      type: $HistoryTableTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      data: $HistoryTableTable.$converterdata.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}data'],
        )!,
      ),
    );
  }

  @override
  $HistoryTableTable createAlias(String alias) {
    return $HistoryTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<HistoryEntryType, String, String> $convertertype =
      const EnumNameConverter<HistoryEntryType>(HistoryEntryType.values);
  static TypeConverter<Map<String, dynamic>, String> $converterdata =
      const MapTypeConverter<String, dynamic>();
}

class HistoryTableData extends DataClass
    implements Insertable<HistoryTableData> {
  final int id;
  final DateTime createdAt;
  final HistoryEntryType type;
  final String itemId;
  final Map<String, dynamic> data;
  const HistoryTableData({
    required this.id,
    required this.createdAt,
    required this.type,
    required this.itemId,
    required this.data,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    {
      map['type'] = Variable<String>(
        $HistoryTableTable.$convertertype.toSql(type),
      );
    }
    map['item_id'] = Variable<String>(itemId);
    {
      map['data'] = Variable<String>(
        $HistoryTableTable.$converterdata.toSql(data),
      );
    }
    return map;
  }

  HistoryTableCompanion toCompanion(bool nullToAbsent) {
    return HistoryTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      type: Value(type),
      itemId: Value(itemId),
      data: Value(data),
    );
  }

  factory HistoryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryTableData(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      type: $HistoryTableTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      itemId: serializer.fromJson<String>(json['itemId']),
      data: serializer.fromJson<Map<String, dynamic>>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'type': serializer.toJson<String>(
        $HistoryTableTable.$convertertype.toJson(type),
      ),
      'itemId': serializer.toJson<String>(itemId),
      'data': serializer.toJson<Map<String, dynamic>>(data),
    };
  }

  HistoryTableData copyWith({
    int? id,
    DateTime? createdAt,
    HistoryEntryType? type,
    String? itemId,
    Map<String, dynamic>? data,
  }) => HistoryTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    type: type ?? this.type,
    itemId: itemId ?? this.itemId,
    data: data ?? this.data,
  );
  HistoryTableData copyWithCompanion(HistoryTableCompanion data) {
    return HistoryTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      type: data.type.present ? data.type.value : this.type,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('type: $type, ')
          ..write('itemId: $itemId, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, type, itemId, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.type == this.type &&
          other.itemId == this.itemId &&
          other.data == this.data);
}

class HistoryTableCompanion extends UpdateCompanion<HistoryTableData> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<HistoryEntryType> type;
  final Value<String> itemId;
  final Value<Map<String, dynamic>> data;
  const HistoryTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.type = const Value.absent(),
    this.itemId = const Value.absent(),
    this.data = const Value.absent(),
  });
  HistoryTableCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    required HistoryEntryType type,
    required String itemId,
    required Map<String, dynamic> data,
  }) : type = Value(type),
       itemId = Value(itemId),
       data = Value(data);
  static Insertable<HistoryTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? type,
    Expression<String>? itemId,
    Expression<String>? data,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (type != null) 'type': type,
      if (itemId != null) 'item_id': itemId,
      if (data != null) 'data': data,
    });
  }

  HistoryTableCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<HistoryEntryType>? type,
    Value<String>? itemId,
    Value<Map<String, dynamic>>? data,
  }) {
    return HistoryTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      itemId: itemId ?? this.itemId,
      data: data ?? this.data,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $HistoryTableTable.$convertertype.toSql(type.value),
      );
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(
        $HistoryTableTable.$converterdata.toSql(data.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('type: $type, ')
          ..write('itemId: $itemId, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PreferencesTableTable preferencesTable = $PreferencesTableTable(
    this,
  );
  late final $AudioPlayerStateTableTable audioPlayerStateTable =
      $AudioPlayerStateTableTable(this);
  late final $HistoryTableTable historyTable = $HistoryTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    preferencesTable,
    audioPlayerStateTable,
    historyTable,
  ];
}

typedef $$PreferencesTableTableCreateCompanionBuilder =
    PreferencesTableCompanion Function({
      Value<int> id,
      Value<bool> checkUpdate,
      Value<bool> normalizeAudio,
      Value<bool> showSystemTrayIcon,
      Value<bool> systemTitleBar,
      Value<CloseBehavior> closeBehavior,
      Value<SpotubeColor> accentColorScheme,
      Value<LayoutMode> layoutMode,
      Value<Locale> locale,
      Value<String> downloadLocation,
      Value<List<String>> localLibraryLocation,
      Value<ThemeMode> themeMode,
      Value<bool> discordPresence,
      Value<bool> cacheMusic,
    });
typedef $$PreferencesTableTableUpdateCompanionBuilder =
    PreferencesTableCompanion Function({
      Value<int> id,
      Value<bool> checkUpdate,
      Value<bool> normalizeAudio,
      Value<bool> showSystemTrayIcon,
      Value<bool> systemTitleBar,
      Value<CloseBehavior> closeBehavior,
      Value<SpotubeColor> accentColorScheme,
      Value<LayoutMode> layoutMode,
      Value<Locale> locale,
      Value<String> downloadLocation,
      Value<List<String>> localLibraryLocation,
      Value<ThemeMode> themeMode,
      Value<bool> discordPresence,
      Value<bool> cacheMusic,
    });

class $$PreferencesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PreferencesTableTable> {
  $$PreferencesTableTableFilterComposer({
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

  ColumnFilters<bool> get checkUpdate => $composableBuilder(
    column: $table.checkUpdate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get normalizeAudio => $composableBuilder(
    column: $table.normalizeAudio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showSystemTrayIcon => $composableBuilder(
    column: $table.showSystemTrayIcon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get systemTitleBar => $composableBuilder(
    column: $table.systemTitleBar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CloseBehavior, CloseBehavior, String>
  get closeBehavior => $composableBuilder(
    column: $table.closeBehavior,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<SpotubeColor, SpotubeColor, String>
  get accentColorScheme => $composableBuilder(
    column: $table.accentColorScheme,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<LayoutMode, LayoutMode, String>
  get layoutMode => $composableBuilder(
    column: $table.layoutMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Locale, Locale, String> get locale =>
      $composableBuilder(
        column: $table.locale,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get downloadLocation => $composableBuilder(
    column: $table.downloadLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get localLibraryLocation => $composableBuilder(
    column: $table.localLibraryLocation,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ThemeMode, ThemeMode, String> get themeMode =>
      $composableBuilder(
        column: $table.themeMode,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get discordPresence => $composableBuilder(
    column: $table.discordPresence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get cacheMusic => $composableBuilder(
    column: $table.cacheMusic,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PreferencesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PreferencesTableTable> {
  $$PreferencesTableTableOrderingComposer({
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

  ColumnOrderings<bool> get checkUpdate => $composableBuilder(
    column: $table.checkUpdate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get normalizeAudio => $composableBuilder(
    column: $table.normalizeAudio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showSystemTrayIcon => $composableBuilder(
    column: $table.showSystemTrayIcon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get systemTitleBar => $composableBuilder(
    column: $table.systemTitleBar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closeBehavior => $composableBuilder(
    column: $table.closeBehavior,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accentColorScheme => $composableBuilder(
    column: $table.accentColorScheme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get layoutMode => $composableBuilder(
    column: $table.layoutMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get downloadLocation => $composableBuilder(
    column: $table.downloadLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localLibraryLocation => $composableBuilder(
    column: $table.localLibraryLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get discordPresence => $composableBuilder(
    column: $table.discordPresence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get cacheMusic => $composableBuilder(
    column: $table.cacheMusic,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PreferencesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreferencesTableTable> {
  $$PreferencesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get checkUpdate => $composableBuilder(
    column: $table.checkUpdate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get normalizeAudio => $composableBuilder(
    column: $table.normalizeAudio,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showSystemTrayIcon => $composableBuilder(
    column: $table.showSystemTrayIcon,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get systemTitleBar => $composableBuilder(
    column: $table.systemTitleBar,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<CloseBehavior, String> get closeBehavior =>
      $composableBuilder(
        column: $table.closeBehavior,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<SpotubeColor, String>
  get accentColorScheme => $composableBuilder(
    column: $table.accentColorScheme,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<LayoutMode, String> get layoutMode =>
      $composableBuilder(
        column: $table.layoutMode,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Locale, String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<String> get downloadLocation => $composableBuilder(
    column: $table.downloadLocation,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String>
  get localLibraryLocation => $composableBuilder(
    column: $table.localLibraryLocation,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ThemeMode, String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<bool> get discordPresence => $composableBuilder(
    column: $table.discordPresence,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get cacheMusic => $composableBuilder(
    column: $table.cacheMusic,
    builder: (column) => column,
  );
}

class $$PreferencesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PreferencesTableTable,
          PreferencesTableData,
          $$PreferencesTableTableFilterComposer,
          $$PreferencesTableTableOrderingComposer,
          $$PreferencesTableTableAnnotationComposer,
          $$PreferencesTableTableCreateCompanionBuilder,
          $$PreferencesTableTableUpdateCompanionBuilder,
          (
            PreferencesTableData,
            BaseReferences<
              _$AppDatabase,
              $PreferencesTableTable,
              PreferencesTableData
            >,
          ),
          PreferencesTableData,
          PrefetchHooks Function()
        > {
  $$PreferencesTableTableTableManager(
    _$AppDatabase db,
    $PreferencesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferencesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferencesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferencesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> checkUpdate = const Value.absent(),
                Value<bool> normalizeAudio = const Value.absent(),
                Value<bool> showSystemTrayIcon = const Value.absent(),
                Value<bool> systemTitleBar = const Value.absent(),
                Value<CloseBehavior> closeBehavior = const Value.absent(),
                Value<SpotubeColor> accentColorScheme = const Value.absent(),
                Value<LayoutMode> layoutMode = const Value.absent(),
                Value<Locale> locale = const Value.absent(),
                Value<String> downloadLocation = const Value.absent(),
                Value<List<String>> localLibraryLocation = const Value.absent(),
                Value<ThemeMode> themeMode = const Value.absent(),
                Value<bool> discordPresence = const Value.absent(),
                Value<bool> cacheMusic = const Value.absent(),
              }) => PreferencesTableCompanion(
                id: id,
                checkUpdate: checkUpdate,
                normalizeAudio: normalizeAudio,
                showSystemTrayIcon: showSystemTrayIcon,
                systemTitleBar: systemTitleBar,
                closeBehavior: closeBehavior,
                accentColorScheme: accentColorScheme,
                layoutMode: layoutMode,
                locale: locale,
                downloadLocation: downloadLocation,
                localLibraryLocation: localLibraryLocation,
                themeMode: themeMode,
                discordPresence: discordPresence,
                cacheMusic: cacheMusic,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> checkUpdate = const Value.absent(),
                Value<bool> normalizeAudio = const Value.absent(),
                Value<bool> showSystemTrayIcon = const Value.absent(),
                Value<bool> systemTitleBar = const Value.absent(),
                Value<CloseBehavior> closeBehavior = const Value.absent(),
                Value<SpotubeColor> accentColorScheme = const Value.absent(),
                Value<LayoutMode> layoutMode = const Value.absent(),
                Value<Locale> locale = const Value.absent(),
                Value<String> downloadLocation = const Value.absent(),
                Value<List<String>> localLibraryLocation = const Value.absent(),
                Value<ThemeMode> themeMode = const Value.absent(),
                Value<bool> discordPresence = const Value.absent(),
                Value<bool> cacheMusic = const Value.absent(),
              }) => PreferencesTableCompanion.insert(
                id: id,
                checkUpdate: checkUpdate,
                normalizeAudio: normalizeAudio,
                showSystemTrayIcon: showSystemTrayIcon,
                systemTitleBar: systemTitleBar,
                closeBehavior: closeBehavior,
                accentColorScheme: accentColorScheme,
                layoutMode: layoutMode,
                locale: locale,
                downloadLocation: downloadLocation,
                localLibraryLocation: localLibraryLocation,
                themeMode: themeMode,
                discordPresence: discordPresence,
                cacheMusic: cacheMusic,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreferencesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PreferencesTableTable,
      PreferencesTableData,
      $$PreferencesTableTableFilterComposer,
      $$PreferencesTableTableOrderingComposer,
      $$PreferencesTableTableAnnotationComposer,
      $$PreferencesTableTableCreateCompanionBuilder,
      $$PreferencesTableTableUpdateCompanionBuilder,
      (
        PreferencesTableData,
        BaseReferences<
          _$AppDatabase,
          $PreferencesTableTable,
          PreferencesTableData
        >,
      ),
      PreferencesTableData,
      PrefetchHooks Function()
    >;
typedef $$AudioPlayerStateTableTableCreateCompanionBuilder =
    AudioPlayerStateTableCompanion Function({
      Value<int> id,
      required bool playing,
      required PlaylistMode loopMode,
      required bool shuffled,
      required List<String> collections,
      Value<List<SpotubeTrackObject>> tracks,
      Value<int> currentIndex,
    });
typedef $$AudioPlayerStateTableTableUpdateCompanionBuilder =
    AudioPlayerStateTableCompanion Function({
      Value<int> id,
      Value<bool> playing,
      Value<PlaylistMode> loopMode,
      Value<bool> shuffled,
      Value<List<String>> collections,
      Value<List<SpotubeTrackObject>> tracks,
      Value<int> currentIndex,
    });

class $$AudioPlayerStateTableTableFilterComposer
    extends Composer<_$AppDatabase, $AudioPlayerStateTableTable> {
  $$AudioPlayerStateTableTableFilterComposer({
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

  ColumnWithTypeConverterFilters<PlaylistMode, PlaylistMode, String>
  get loopMode => $composableBuilder(
    column: $table.loopMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get shuffled => $composableBuilder(
    column: $table.shuffled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get collections => $composableBuilder(
    column: $table.collections,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    List<SpotubeTrackObject>,
    List<SpotubeTrackObject>,
    String
  >
  get tracks => $composableBuilder(
    column: $table.tracks,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AudioPlayerStateTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioPlayerStateTableTable> {
  $$AudioPlayerStateTableTableOrderingComposer({
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

  ColumnOrderings<String> get collections => $composableBuilder(
    column: $table.collections,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tracks => $composableBuilder(
    column: $table.tracks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudioPlayerStateTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioPlayerStateTableTable> {
  $$AudioPlayerStateTableTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<PlaylistMode, String> get loopMode =>
      $composableBuilder(column: $table.loopMode, builder: (column) => column);

  GeneratedColumn<bool> get shuffled =>
      $composableBuilder(column: $table.shuffled, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get collections =>
      $composableBuilder(
        column: $table.collections,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<SpotubeTrackObject>, String>
  get tracks =>
      $composableBuilder(column: $table.tracks, builder: (column) => column);

  GeneratedColumn<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => column,
  );
}

class $$AudioPlayerStateTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioPlayerStateTableTable,
          AudioPlayerStateTableData,
          $$AudioPlayerStateTableTableFilterComposer,
          $$AudioPlayerStateTableTableOrderingComposer,
          $$AudioPlayerStateTableTableAnnotationComposer,
          $$AudioPlayerStateTableTableCreateCompanionBuilder,
          $$AudioPlayerStateTableTableUpdateCompanionBuilder,
          (
            AudioPlayerStateTableData,
            BaseReferences<
              _$AppDatabase,
              $AudioPlayerStateTableTable,
              AudioPlayerStateTableData
            >,
          ),
          AudioPlayerStateTableData,
          PrefetchHooks Function()
        > {
  $$AudioPlayerStateTableTableTableManager(
    _$AppDatabase db,
    $AudioPlayerStateTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioPlayerStateTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AudioPlayerStateTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AudioPlayerStateTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> playing = const Value.absent(),
                Value<PlaylistMode> loopMode = const Value.absent(),
                Value<bool> shuffled = const Value.absent(),
                Value<List<String>> collections = const Value.absent(),
                Value<List<SpotubeTrackObject>> tracks = const Value.absent(),
                Value<int> currentIndex = const Value.absent(),
              }) => AudioPlayerStateTableCompanion(
                id: id,
                playing: playing,
                loopMode: loopMode,
                shuffled: shuffled,
                collections: collections,
                tracks: tracks,
                currentIndex: currentIndex,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required bool playing,
                required PlaylistMode loopMode,
                required bool shuffled,
                required List<String> collections,
                Value<List<SpotubeTrackObject>> tracks = const Value.absent(),
                Value<int> currentIndex = const Value.absent(),
              }) => AudioPlayerStateTableCompanion.insert(
                id: id,
                playing: playing,
                loopMode: loopMode,
                shuffled: shuffled,
                collections: collections,
                tracks: tracks,
                currentIndex: currentIndex,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AudioPlayerStateTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioPlayerStateTableTable,
      AudioPlayerStateTableData,
      $$AudioPlayerStateTableTableFilterComposer,
      $$AudioPlayerStateTableTableOrderingComposer,
      $$AudioPlayerStateTableTableAnnotationComposer,
      $$AudioPlayerStateTableTableCreateCompanionBuilder,
      $$AudioPlayerStateTableTableUpdateCompanionBuilder,
      (
        AudioPlayerStateTableData,
        BaseReferences<
          _$AppDatabase,
          $AudioPlayerStateTableTable,
          AudioPlayerStateTableData
        >,
      ),
      AudioPlayerStateTableData,
      PrefetchHooks Function()
    >;
typedef $$HistoryTableTableCreateCompanionBuilder =
    HistoryTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      required HistoryEntryType type,
      required String itemId,
      required Map<String, dynamic> data,
    });
typedef $$HistoryTableTableUpdateCompanionBuilder =
    HistoryTableCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<HistoryEntryType> type,
      Value<String> itemId,
      Value<Map<String, dynamic>> data,
    });

class $$HistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryTableTable> {
  $$HistoryTableTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<HistoryEntryType, HistoryEntryType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>,
    Map<String, dynamic>,
    String
  >
  get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$HistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryTableTable> {
  $$HistoryTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryTableTable> {
  $$HistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<HistoryEntryType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>, String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);
}

class $$HistoryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistoryTableTable,
          HistoryTableData,
          $$HistoryTableTableFilterComposer,
          $$HistoryTableTableOrderingComposer,
          $$HistoryTableTableAnnotationComposer,
          $$HistoryTableTableCreateCompanionBuilder,
          $$HistoryTableTableUpdateCompanionBuilder,
          (
            HistoryTableData,
            BaseReferences<_$AppDatabase, $HistoryTableTable, HistoryTableData>,
          ),
          HistoryTableData,
          PrefetchHooks Function()
        > {
  $$HistoryTableTableTableManager(_$AppDatabase db, $HistoryTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<HistoryEntryType> type = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<Map<String, dynamic>> data = const Value.absent(),
              }) => HistoryTableCompanion(
                id: id,
                createdAt: createdAt,
                type: type,
                itemId: itemId,
                data: data,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required HistoryEntryType type,
                required String itemId,
                required Map<String, dynamic> data,
              }) => HistoryTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                type: type,
                itemId: itemId,
                data: data,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistoryTableTable,
      HistoryTableData,
      $$HistoryTableTableFilterComposer,
      $$HistoryTableTableOrderingComposer,
      $$HistoryTableTableAnnotationComposer,
      $$HistoryTableTableCreateCompanionBuilder,
      $$HistoryTableTableUpdateCompanionBuilder,
      (
        HistoryTableData,
        BaseReferences<_$AppDatabase, $HistoryTableTable, HistoryTableData>,
      ),
      HistoryTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PreferencesTableTableTableManager get preferencesTable =>
      $$PreferencesTableTableTableManager(_db, _db.preferencesTable);
  $$AudioPlayerStateTableTableTableManager get audioPlayerStateTable =>
      $$AudioPlayerStateTableTableTableManager(_db, _db.audioPlayerStateTable);
  $$HistoryTableTableTableManager get historyTable =>
      $$HistoryTableTableTableManager(_db, _db.historyTable);
}
