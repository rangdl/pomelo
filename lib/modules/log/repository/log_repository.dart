/// 日志仓储层
///
/// 负责日志数据的存取、查询和清理。
/// 基于内存存储，可选支持持久化。
library;

import 'dart:collection';

import 'package:pomelo/core/mars.dart';

import '../model/log_entry.dart';

class LogRepository extends Repository<LogEntry> {
  /// 最大日志条数（超过时自动清理旧日志）
  static const int defaultMaxEntries = 10000;

  final int maxEntries;

  /// 按时间排序的日志队列
  final Queue<LogEntry> _entries = Queue();

  LogRepository({this.maxEntries = defaultMaxEntries});

  @override
  String get id => 'log_repository';

  @override
  Future<List<LogEntry>> fetchAll() async => _entries.toList();

  @override
  Future<LogEntry?> fetchById(String id) async {
    // 使用时间戳 + 消息作为简易 ID 匹配
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
  }

  @override
  Future<void> saveAll(List<LogEntry> items) async {
    for (final item in items) {
      _entries.addLast(item);
    }
    _trimExcess();
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

  /// 清理超过指定天数的日志
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

  @override
  Future<void> onInit() async {
    // 可在此处加载持久化日志
  }

  @override
  Future<void> onDispose() async {
    // 可在此处持久化日志
  }
}
