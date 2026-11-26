import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../storage/json_file_store.dart';

/// 共享的设置存储（由 main() 启动时 open 后注入）。
final settingsStoreProvider = Provider<SettingsStore>(
  (ref) => throw UnimplementedError('settingsStoreProvider 需在启动时 override'),
);

/// `settings.json` 的底层读写：所有设置项合并存同一个 JSON 对象，
/// 避免不同设置互相覆盖。上层各 Notifier 通过 [SettingsStore.patch]
/// 只更新自己的字段。
class SettingsStore {
  SettingsStore._(this._store, this._data);

  final JsonFileStore _store;
  final Map<String, dynamic> _data;

  static const _fileName = 'settings.json';

  static Future<SettingsStore> open() async {
    final dir = await getApplicationSupportDirectory();
    final store = JsonFileStore(
      File('${dir.path}${Platform.pathSeparator}$_fileName'),
    );
    final raw = await store.read();
    final data = raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};
    return SettingsStore._(store, data);
  }

  T? read<T>(String key) {
    final v = _data[key];
    return v is T ? v : null;
  }

  /// 合并写入一个或多个字段，并落盘。
  Future<void> patch(Map<String, dynamic> values) async {
    _data.addAll(values);
    // 原子写入失败静默：不影响本次会话内的设置生效。
    await _store.write(_data);
  }
}
