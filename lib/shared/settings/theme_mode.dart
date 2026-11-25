import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// 主题模式:跟随系统 / 浅色 / 深色。持久化到 settings.json。
enum ThemeModeOption { system, light, dark }

extension ThemeModeOptionX on ThemeModeOption {
  /// 对应 [MaterialApp.themeMode] 的值。
  ThemeMode get themeMode => switch (this) {
        ThemeModeOption.system => ThemeMode.system,
        ThemeModeOption.light => ThemeMode.light,
        ThemeModeOption.dark => ThemeMode.dark,
      };
}

const _settingsFileName = 'settings.json';

/// 初值由 main() 启动时从磁盘读出后注入,ProviderScope override 提供。
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
    try {
      final file = await _settingsFile();
      await file.writeAsString(
        jsonEncode({'themeMode': mode.name}),
      );
    } catch (_) {
      // 持久化失败不影响本次会话生效
    }
  }
}

Future<File> _settingsFile() async {
  final directory = await getApplicationSupportDirectory();
  return File(
    '${directory.path}${Platform.pathSeparator}$_settingsFileName',
  );
}

/// 启动时读取持久化的主题模式;无记录或损坏时跟随系统。
Future<ThemeModeOption> loadThemeModeOption() async {
  try {
    final file = await _settingsFile();
    if (!await file.exists()) return ThemeModeOption.system;
    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final name = data['themeMode'] as String?;
    return ThemeModeOption.values.firstWhere(
      (m) => m.name == name,
      orElse: () => ThemeModeOption.system,
    );
  } catch (_) {
    return ThemeModeOption.system;
  }
}
