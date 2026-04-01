import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app.model.freezed.dart';
part 'app.model.g.dart';

@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @ThemeModeConverter() @Default(ThemeMode.system) ThemeMode themeMode,
    @Default('en') String language,
    @Default(true) bool notificationsEnabled,
  }) = _AppSettingsImpl;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}

// 创建 ThemeMode 的转换器
class ThemeModeConverter implements JsonConverter<ThemeMode, String> {
  const ThemeModeConverter();

  @override
  ThemeMode fromJson(String json) {
    return ThemeMode.values.firstWhere(
      (e) => e.name == json,
      orElse: () => ThemeMode.system,
    );
  }

  @override
  String toJson(ThemeMode mode) => mode.name;
}
