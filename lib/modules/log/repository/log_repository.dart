/// 日志仓储层
///
/// 负责日志数据的存取、查询和清理。
/// 内存 + 文件双存储，文件采用 JSON Lines 格式（每行一条 JSON）。
library;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:pomelo/core/mars.dart';

import '../model/log_entry.dart';

class LogRepository extends Repository<LogEntry> {
  /// 最大内存日志条数（超过时自动清理旧日志）
  static const int defaultMaxEntries = 10000;

  final int maxEntries;

  /// 按时间排序的内存日志队列
  final Queue<LogEntry> _entries = Queue();

  /// 日志文件（JSON Lines 格式）
  File? _logFile;

  /// 文件写入的最低级别（低于此级别的日志仅存内存，不写文件）
  ///
  /// 默认 warning，可通过 [setStorageLevel] 修改，持久化到 Settings。
  LogLevel _storageLevel = LogLevel.warning;

  LogRepository({this.maxEntries = defaultMaxEntries});

  @override
  String get id => 'log_repository';

  /// 当前文件存储的最低日志级别
  LogLevel get storageLevel => _storageLevel;

  /// 设置文件存储的最低日志级别并持久化
  Future<void> setStorageLevel(LogLevel level) async {
    _storageLevel = level;
    await Settings.set(StorageKeys.logStorageLevel, level.name);
  }

  /// 初始化文件存储
  ///
  /// [logDir] 日志文件所在目录（建议使用应用文档目录下的 logs 子目录）。
  /// 加载已有的日志文件，并从 Settings 读取存储级别。
  Future<void> initFileStorage(String logDir) async {
    // 从 Settings 读取存储级别
    final savedLevel = Settings.get(StorageKeys.logStorageLevel);
    if (savedLevel != null) {
      _storageLevel = LogLevel.values.firstWhere(
        (e) => e.name == savedLevel,
        orElse: () => LogLevel.warning,
      );
    }

    // 确保目录存在
    final dir = Directory(logDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // 按日期命名日志文件（如 log_2026-06-15.jsonl）
    final today = DateTime.now();
    final fileName =
        'log_${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}.jsonl';
    _logFile = File('${dir.path}${Platform.pathSeparator}$fileName');

    // 加载已有日志
    await _loadFromFile();
  }

  /// 从日志文件加载条目到内存
  Future<void> _loadFromFile() async {
    final file = _logFile;
    if (file == null || !await file.exists()) return;

    try {
      final lines = await file.readAsLines();
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        try {
          final json = jsonDecode(line) as Map<String, dynamic>;
          _entries.addLast(LogEntry.fromJson(json));
        } catch (_) {
          // 跳过格式错误的行
        }
      }
      _trimExcess();
    } catch (_) {
      // 文件读取失败，忽略（下次写入时会重建）
    }
  }

  /// 追加一条日志到文件
  Future<void> _appendToFile(LogEntry entry) async {
    final file = _logFile;
    if (file == null) return;

    // 只存储 >= storageLevel 的日志
    if (entry.level.index < _storageLevel.index) return;

    try {
      final line = jsonEncode(entry.toJson());
      await file.writeAsString('$line\n', mode: FileMode.append);
    } catch (_) {
      // 文件写入失败，静默忽略（不影响内存中的日志）
    }
  }

  @override
  Future<List<LogEntry>> fetchAll() async => _entries.toList();

  @override
  Future<LogEntry?> fetchById(String id) async {
    for (final entry in _entries) {
      if ('${entry.timestamp.millisecondsSinceEpoch}-${entry.message.hashCode}' ==
          id) {
        return entry;
      }
    }
    return null;
  }

  @override
  Future<void> save(LogEntry item) async {
    _entries.addLast(item);
    _trimExcess();
    // 异步写文件（不阻塞主流程）
    unawaited(_appendToFile(item));
  }

  @override
  Future<void> saveAll(List<LogEntry> items) async {
    for (final item in items) {
      _entries.addLast(item);
    }
    _trimExcess();
    for (final item in items) {
      unawaited(_appendToFile(item));
    }
  }

  @override
  Future<void> delete(String id) async {
    _entries.removeWhere(
      (e) =>
          '${e.timestamp.millisecondsSinceEpoch}-${e.message.hashCode}' == id,
    );
  }

  @override
  Future<void> deleteAll() async {
    _entries.clear();
    // 清空日志文件
    final file = _logFile;
    if (file != null && await file.exists()) {
      try {
        await file.writeAsString('');
      } catch (_) {}
    }
  }

  /// 根据查询条件过滤日志
  Future<List<LogEntry>> query(LogQuery query) async {
    var results = _entries.where(query.matches).toList();

    if (query.descending) {
      results = results.reversed.toList();
    }

    if (query.limit > 0 && results.length > query.limit) {
      results = results.sublist(0, query.limit);
    }

    return results;
  }

  /// 获取所有日志级别统计
  Future<Map<LogLevel, int>> getLevelStats() async {
    final stats = <LogLevel, int>{};
    for (final level in LogLevel.values) {
      stats[level] = 0;
    }
    for (final entry in _entries) {
      stats[entry.level] = (stats[entry.level] ?? 0) + 1;
    }
    return stats;
  }

  /// 获取所有标签列表
  Future<Set<String>> getTags() async {
    return _entries.map((e) => e.tag).toSet();
  }

  /// 清理超过指定时间的日志
  Future<int> cleanOlderThan(Duration duration) async {
    final cutoff = DateTime.now().subtract(duration);
    final before = _entries.length;
    _entries.removeWhere((e) => e.timestamp.isBefore(cutoff));
    return before - _entries.length;
  }

  /// 清理指定级别的日志
  Future<int> cleanByLevel(LogLevel level) async {
    final before = _entries.length;
    _entries.removeWhere((e) => e.level == level);
    return before - _entries.length;
  }

  /// 当前日志总条数
  int get count => _entries.length;

  /// 超出限制时自动裁剪最旧的日志
  void _trimExcess() {
    while (_entries.length > maxEntries) {
      _entries.removeFirst();
    }
  }

  /// 将日志文件内容导出为字符串
  Future<String> exportFileContent() async {
    final file = _logFile;
    if (file == null || !await file.exists()) return '';
    return file.readAsString();
  }

  /// 日志文件路径
  String? get logFilePath => _logFile?.path;

  @override
  Future<void> onInit() async {
    await super.onInit();
  }

  @override
  Future<void> onDispose() async {
    await super.onDispose();
  }
}

