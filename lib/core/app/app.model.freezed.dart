// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
AppSettings _$AppSettingsFromJson(
  Map<String, dynamic> json
) {
    return _AppSettingsImpl.fromJson(
      json
    );
}

/// @nodoc
mixin _$AppSettings {

@ThemeModeConverter() ThemeMode get themeMode; String get language; bool get notificationsEnabled;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.language, language) || other.language == language)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,themeMode,language,notificationsEnabled);

@override
String toString() {
  return 'AppSettings(themeMode: $themeMode, language: $language, notificationsEnabled: $notificationsEnabled)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
@ThemeModeConverter() ThemeMode themeMode, String language, bool notificationsEnabled
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? themeMode = null,Object? language = null,Object? notificationsEnabled = null,}) {
  return _then(_self.copyWith(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettingsImpl value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettingsImpl() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettingsImpl value)  $default,){
final _that = this;
switch (_that) {
case _AppSettingsImpl():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettingsImpl value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettingsImpl() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@ThemeModeConverter()  ThemeMode themeMode,  String language,  bool notificationsEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettingsImpl() when $default != null:
return $default(_that.themeMode,_that.language,_that.notificationsEnabled);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@ThemeModeConverter()  ThemeMode themeMode,  String language,  bool notificationsEnabled)  $default,) {final _that = this;
switch (_that) {
case _AppSettingsImpl():
return $default(_that.themeMode,_that.language,_that.notificationsEnabled);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@ThemeModeConverter()  ThemeMode themeMode,  String language,  bool notificationsEnabled)?  $default,) {final _that = this;
switch (_that) {
case _AppSettingsImpl() when $default != null:
return $default(_that.themeMode,_that.language,_that.notificationsEnabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSettingsImpl implements AppSettings {
  const _AppSettingsImpl({@ThemeModeConverter() this.themeMode = ThemeMode.system, this.language = 'en', this.notificationsEnabled = true});
  factory _AppSettingsImpl.fromJson(Map<String, dynamic> json) => _$AppSettingsImplFromJson(json);

@override@JsonKey()@ThemeModeConverter() final  ThemeMode themeMode;
@override@JsonKey() final  String language;
@override@JsonKey() final  bool notificationsEnabled;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsImplCopyWith<_AppSettingsImpl> get copyWith => __$AppSettingsImplCopyWithImpl<_AppSettingsImpl>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSettingsImplToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettingsImpl&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.language, language) || other.language == language)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,themeMode,language,notificationsEnabled);

@override
String toString() {
  return 'AppSettings(themeMode: $themeMode, language: $language, notificationsEnabled: $notificationsEnabled)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsImplCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsImplCopyWith(_AppSettingsImpl value, $Res Function(_AppSettingsImpl) _then) = __$AppSettingsImplCopyWithImpl;
@override @useResult
$Res call({
@ThemeModeConverter() ThemeMode themeMode, String language, bool notificationsEnabled
});




}
/// @nodoc
class __$AppSettingsImplCopyWithImpl<$Res>
    implements _$AppSettingsImplCopyWith<$Res> {
  __$AppSettingsImplCopyWithImpl(this._self, this._then);

  final _AppSettingsImpl _self;
  final $Res Function(_AppSettingsImpl) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? themeMode = null,Object? language = null,Object? notificationsEnabled = null,}) {
  return _then(_AppSettingsImpl(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
