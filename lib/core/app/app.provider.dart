import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/experimental/persist.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart';
import 'package:pomelo/core/helper.dart';
import 'package:pomelo/global.dart';
import 'package:riverpod_sqflite/riverpod_sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app.model.dart';

// 创建 Storage 实例，全局共享
final storageProvider = FutureProvider<JsonSqFliteStorage>((ref) async {
  if (Helper.isDesktop) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  return JsonSqFliteStorage.open(join(appDocumentsDir.path, 'riverpod.db'));
});

class _AppSettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    await persist(
      ref.watch(storageProvider.future),
      key: 'app_settings',
      encode: (settings) => jsonEncode(settings),
      decode: (json) =>
          AppSettings.fromJson(jsonDecode(json) as Map<String, dynamic>),
      options: const StorageOptions(
        destroyKey: '1.0',
        cacheTime: StorageCacheTime.unsafe_forever,
      ),
    ).future;
    return state.value ?? const AppSettings();
  }

  void setThemeMode(ThemeMode mode) async {
    state = AsyncData((await future).copyWith(themeMode: mode));
  }
}

final appSettingsProvider =
    AsyncNotifierProvider<_AppSettingsNotifier, AppSettings>(
      () => _AppSettingsNotifier(),
    );
