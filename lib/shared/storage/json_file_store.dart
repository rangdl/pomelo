import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// JSON 文件存储：原子写入 + 串行 + 损坏回退。
///
/// 之前各模块直接 `writeAsString`：进程被杀/磁盘写满时会留下半个 JSON，
/// 下次启动整份数据读不出来。这里统一处理：
///   - 先写 `.tmp`，再改名覆盖，保证主文件要么是旧内容要么是新内容；
///   - 覆盖前把旧内容复制成 `.bak`，主文件损坏时回退；
///   - 同一文件的写入排成队列，避免并发写互相踩；
///   - 落盘带 schemaVersion，向后兼容旧的裸 JSON 结构。
class JsonFileStore {
  JsonFileStore(this.file);

  final File file;

  /// 当前写入格式版本。未来结构变化时递增，并在读取处做迁移。
  static const int schemaVersion = 1;

  /// 按文件路径维护写队列（同一文件的所有实例共享）。
  static final Map<String, Future<void>> _queues = {};

  File get _temp => File('${file.path}.tmp');
  File get _backup => File('${file.path}.bak');

  /// 读取并解析内容；主文件损坏时回退到 `.bak`，都失败返回 null。
  Future<dynamic> read() async {
    final primary = await _tryRead(file);
    if (primary != null) return _unwrap(primary);
    final backup = await _tryRead(_backup);
    return backup == null ? null : _unwrap(backup);
  }

  /// 原子写入（失败静默，不影响本次会话）。
  Future<void> write(Object? data) {
    final previous = _queues[file.path] ?? Future<void>.value();
    final next = previous.then((_) => _writeNow(data));
    _queues[file.path] = next;
    return next;
  }

  dynamic _unwrap(dynamic raw) {
    if (raw is Map && raw['schemaVersion'] is int && raw.containsKey('data')) {
      final version = raw['schemaVersion'] as int;
      // 来自更新版本的 App：结构可能不兼容，宁可当没有数据。
      if (version > schemaVersion) return null;
      return raw['data'];
    }
    // 旧格式：裸 JSON（没有包一层 version/data）。
    return raw;
  }

  Future<dynamic> _tryRead(File f) async {
    try {
      if (!await f.exists()) return null;
      final raw = await f.readAsString();
      if (raw.trim().isEmpty) return null;
      return jsonDecode(raw);
    } catch (e) {
      debugPrint('[pomelo] 读取 ${f.path} 失败: $e');
      return null;
    }
  }

  Future<void> _writeNow(Object? data) async {
    try {
      await file.parent.create(recursive: true);
      await _temp.writeAsString(
        jsonEncode({'schemaVersion': schemaVersion, 'data': data}),
        flush: true,
      );
      // 保留上一份可用内容，主文件写坏时仍能回退。
      if (await file.exists()) {
        try {
          await file.copy(_backup.path);
        } catch (_) {
          // 备份失败不影响主流程。
        }
      }
      await _temp.rename(file.path);
    } catch (e) {
      debugPrint('[pomelo] 写入 ${file.path} 失败: $e');
      try {
        if (await _temp.exists()) await _temp.delete();
      } catch (_) {
        // 忽略。
      }
    }
  }
}
