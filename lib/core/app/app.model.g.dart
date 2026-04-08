// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppSettingsImplImpl _$$AppSettingsImplImplFromJson(Map json) =>
    _$AppSettingsImplImpl(
      themeMode: json['themeMode'] == null
          ? ThemeMode.system
          : const ThemeModeConverter().fromJson(json['themeMode'] as String),
      language: json['language'] as String? ?? 'en',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    );

Map<String, dynamic> _$$AppSettingsImplImplToJson(
  _$AppSettingsImplImpl instance,
) => <String, dynamic>{
  'themeMode': const ThemeModeConverter().toJson(instance.themeMode),
  'language': instance.language,
  'notificationsEnabled': instance.notificationsEnabled,
};
