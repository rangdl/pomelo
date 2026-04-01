// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettingsImpl _$AppSettingsImplFromJson(Map<String, dynamic> json) =>
    _AppSettingsImpl(
      themeMode: json['themeMode'] == null
          ? ThemeMode.system
          : const ThemeModeConverter().fromJson(json['themeMode'] as String),
      language: json['language'] as String? ?? 'en',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    );

Map<String, dynamic> _$AppSettingsImplToJson(_AppSettingsImpl instance) =>
    <String, dynamic>{
      'themeMode': const ThemeModeConverter().toJson(instance.themeMode),
      'language': instance.language,
      'notificationsEnabled': instance.notificationsEnabled,
    };
