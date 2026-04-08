// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) {
  return _AppSettingsImpl.fromJson(json);
}

/// @nodoc
mixin _$AppSettings {
  @ThemeModeConverter()
  ThemeMode get themeMode => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  bool get notificationsEnabled => throw _privateConstructorUsedError;

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppSettingsCopyWith<AppSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSettingsCopyWith<$Res> {
  factory $AppSettingsCopyWith(
    AppSettings value,
    $Res Function(AppSettings) then,
  ) = _$AppSettingsCopyWithImpl<$Res, AppSettings>;
  @useResult
  $Res call({
    @ThemeModeConverter() ThemeMode themeMode,
    String language,
    bool notificationsEnabled,
  });
}

/// @nodoc
class _$AppSettingsCopyWithImpl<$Res, $Val extends AppSettings>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? language = null,
    Object? notificationsEnabled = null,
  }) {
    return _then(
      _value.copyWith(
            themeMode: null == themeMode
                ? _value.themeMode
                : themeMode // ignore: cast_nullable_to_non_nullable
                      as ThemeMode,
            language: null == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String,
            notificationsEnabled: null == notificationsEnabled
                ? _value.notificationsEnabled
                : notificationsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppSettingsImplImplCopyWith<$Res>
    implements $AppSettingsCopyWith<$Res> {
  factory _$$AppSettingsImplImplCopyWith(
    _$AppSettingsImplImpl value,
    $Res Function(_$AppSettingsImplImpl) then,
  ) = __$$AppSettingsImplImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @ThemeModeConverter() ThemeMode themeMode,
    String language,
    bool notificationsEnabled,
  });
}

/// @nodoc
class __$$AppSettingsImplImplCopyWithImpl<$Res>
    extends _$AppSettingsCopyWithImpl<$Res, _$AppSettingsImplImpl>
    implements _$$AppSettingsImplImplCopyWith<$Res> {
  __$$AppSettingsImplImplCopyWithImpl(
    _$AppSettingsImplImpl _value,
    $Res Function(_$AppSettingsImplImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? language = null,
    Object? notificationsEnabled = null,
  }) {
    return _then(
      _$AppSettingsImplImpl(
        themeMode: null == themeMode
            ? _value.themeMode
            : themeMode // ignore: cast_nullable_to_non_nullable
                  as ThemeMode,
        language: null == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String,
        notificationsEnabled: null == notificationsEnabled
            ? _value.notificationsEnabled
            : notificationsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppSettingsImplImpl implements _AppSettingsImpl {
  const _$AppSettingsImplImpl({
    @ThemeModeConverter() this.themeMode = ThemeMode.system,
    this.language = 'en',
    this.notificationsEnabled = true,
  });

  factory _$AppSettingsImplImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppSettingsImplImplFromJson(json);

  @override
  @JsonKey()
  @ThemeModeConverter()
  final ThemeMode themeMode;
  @override
  @JsonKey()
  final String language;
  @override
  @JsonKey()
  final bool notificationsEnabled;

  @override
  String toString() {
    return 'AppSettings(themeMode: $themeMode, language: $language, notificationsEnabled: $notificationsEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppSettingsImplImpl &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.notificationsEnabled, notificationsEnabled) ||
                other.notificationsEnabled == notificationsEnabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, themeMode, language, notificationsEnabled);

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppSettingsImplImplCopyWith<_$AppSettingsImplImpl> get copyWith =>
      __$$AppSettingsImplImplCopyWithImpl<_$AppSettingsImplImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AppSettingsImplImplToJson(this);
  }
}

abstract class _AppSettingsImpl implements AppSettings {
  const factory _AppSettingsImpl({
    @ThemeModeConverter() final ThemeMode themeMode,
    final String language,
    final bool notificationsEnabled,
  }) = _$AppSettingsImplImpl;

  factory _AppSettingsImpl.fromJson(Map<String, dynamic> json) =
      _$AppSettingsImplImpl.fromJson;

  @override
  @ThemeModeConverter()
  ThemeMode get themeMode;
  @override
  String get language;
  @override
  bool get notificationsEnabled;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppSettingsImplImplCopyWith<_$AppSettingsImplImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
