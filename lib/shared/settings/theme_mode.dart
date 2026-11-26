import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_quality.dart';
import 'settings_store.dart';

/// 主题模式:跟随系统 / 浅色 / 深色。持久化到 settings.json。
enum ThemeModeOption { system, light, dark }

extension ThemeModeOptionX on ThemeModeOption {
  /// 对应 [MaterialApp.themeMode] 的值。
  ThemeMode get themeMode => switch (this) {
    ThemeModeOption.system => ThemeMode.system,
    ThemeModeOption.light => ThemeMode.light,
    ThemeModeOption.dark => ThemeMode.dark,
  };

  String get label => switch (this) {
    ThemeModeOption.system => '跟随系统',
    ThemeModeOption.light => '浅色模式',
    ThemeModeOption.dark => '深色模式',
  };
}

/// 主题模式初值，由 main() 从设置里读出后注入。
final themeModeInitializerProvider = Provider<ThemeModeOption>(
  (ref) => throw UnimplementedError('must be overridden at startup'),
);

final themeModeOptionProvider =
    NotifierProvider<ThemeModeOptionNotifier, ThemeModeOption>(
      ThemeModeOptionNotifier.new,
    );

class ThemeModeOptionNotifier extends Notifier<ThemeModeOption> {
  @override
  ThemeModeOption build() => ref.watch(themeModeInitializerProvider);

  Future<void> set(ThemeModeOption mode) async {
    if (mode == state) return;
    state = mode;
    await ref.read(settingsStoreProvider).patch({'themeMode': mode.name});
  }
}

/// 音质偏好初值，由 main() 从设置里读出后注入。
final audioQualityInitializerProvider = Provider<AudioQuality>(
  (ref) => AudioQuality.high,
);

final audioQualityProvider =
    NotifierProvider<AudioQualityNotifier, AudioQuality>(
      AudioQualityNotifier.new,
    );

class AudioQualityNotifier extends Notifier<AudioQuality> {
  @override
  AudioQuality build() => ref.watch(audioQualityInitializerProvider);

  Future<void> set(AudioQuality quality) async {
    if (quality == state) return;
    state = quality;
    await ref.read(settingsStoreProvider).patch({'audioQuality': quality.name});
  }
}

/// 启动时读取持久化的主题模式;无记录或损坏时跟随系统。
Future<ThemeModeOption> loadThemeModeOption(SettingsStore store) =>
    Future.value(
      ThemeModeOption.values.firstWhere(
        (m) => m.name == store.read<String>('themeMode'),
        orElse: () => ThemeModeOption.system,
      ),
    );

/// 启动时读取持久化的音质;无记录时默认高品。
Future<AudioQuality> loadAudioQuality(SettingsStore store) =>
    Future.value(AudioQuality.fromName(store.read<String>('audioQuality')));
