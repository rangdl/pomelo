import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// `settings.json` 的底层读写：所有设置项合并存同一个 JSON 对象，
/// 避免不同设置互相覆盖。上层各 Notifier 通过 [SettingsStore.patch]
/// 只更新自己的字段。
class SettingsStore {
  SettingsStore._(this._file, this._data);

  final File _file;
  final Map<String, dynamic> _data;

  static const _fileName = 'settings.json';

  static Future<SettingsStore> open() async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}$_fileName');
    Map<String, dynamic> data = {};
    try {
      if (await file.exists()) {
        final raw = jsonDecode(await file.readAsString());
        if (raw is Map<String, dynamic>) data = raw;
      }
    } catch (_) {
      data = {};
    }
    return SettingsStore._(file, data);
  }

  T? read<T>(String key) {
    final v = _data[key];
    return v is T ? v : null;
  }

  /// 合并写入一个或多个字段，并落盘。
  Future<void> patch(Map<String, dynamic> values) async {
    _data.addAll(values);
    try {
      await _file.writeAsString(jsonEncode(_data));
    } catch (_) {
      // 持久化失败不影响本次会话生效
    }
  }
}
