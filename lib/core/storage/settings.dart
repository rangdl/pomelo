/// 全局运行时设置
///
/// 基于 hive_ce Box 的键值存储，所有值以 String 形式存入。
/// 所有模块均可直接调用，无需依赖注入。
///
/// 用法（任何模块的 Service / Repository / Provider 中）:
/// ```dart
/// // === 写入 ===
/// await Settings.set('theme_mode', 'dark');
/// await Settings.setInt('font_size', 16);
/// await Settings.setBool('notifications_enabled', true);
///
/// // === 读取 ===
/// final theme = Settings.get('theme_mode', defaultValue: 'light');
/// final fontSize = Settings.getInt('font_size', defaultValue: 14);
/// final notif = Settings.getBool('notifications_enabled', defaultValue: true);
///
/// // === 在 Riverpod Provider 中响应式监听 ===
/// final currentTheme = ref.watch(settingsProvider);
/// ```
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

/// 全局运行时设置 — dagger 模块可直接静态调用
///
/// 初始化: 在 main.dart 中 Hive.init() 后调用 Settings.init()
class Settings {
  Settings._();

  static Box<String>? _box;

  /// Box 名称（对应磁盘上的 app_settings.hive 文件）
  static const String _boxName = 'app_settings';

  /// 是否已初始化
  static bool get isInitialized => _box != null;

  /// 内部暴露给 Riverpod Provider 使用
  static Box<String>? get _internalBox => _box;

  /// 初始化（由 main.dart 启动时调用）
  static Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  // ======================== 读取 ========================

  /// 获取原始 String 值
  static String? get(String key, {String? defaultValue}) {
    return _box?.get(key, defaultValue: defaultValue);
  }

  /// 获取 int 值（自动从 String 解析）
  static int? getInt(String key, {int? defaultValue}) {
    final val = _box?.get(key);
    if (val == null) return defaultValue;
    return int.tryParse(val) ?? defaultValue;
  }

  /// 获取 bool 值（自动解析 "true"/"false"）
  static bool? getBool(String key, {bool? defaultValue}) {
    final val = _box?.get(key);
    if (val == null) return defaultValue;
    if (val == 'true') return true;
    if (val == 'false') return false;
    return defaultValue;
  }

  /// 获取 double 值
  static double? getDouble(String key, {double? defaultValue}) {
    final val = _box?.get(key);
    if (val == null) return defaultValue;
    return double.tryParse(val) ?? defaultValue;
  }

  /// 获取 JSON 对象（自动 decode）
  static Map<String, dynamic>? getJson(String key) {
    final val = _box?.get(key);
    if (val == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(val) as Map);
    } catch (_) {
      return null;
    }
  }

  // ======================== 写入 ========================

  /// 写入值（自动 toString）
  static Future<void> set(String key, dynamic value) async {
    await _box?.put(key, value.toString());
  }

  /// 写入 int 值
  static Future<void> setInt(String key, int value) async {
    await _box?.put(key, value.toString());
  }

  /// 写入 bool 值
  static Future<void> setBool(String key, bool value) async {
    await _box?.put(key, value.toString());
  }

  /// 写入 double 值
  static Future<void> setDouble(String key, double value) async {
    await _box?.put(key, value.toString());
  }

  /// 写入 JSON 对象（自动 encode）
  static Future<void> setJson(String key, Map<String, dynamic> value) async {
    await _box?.put(key, jsonEncode(value));
  }

  /// 批量写入（自动跳过 null 值）
  static Future<void> setAll(Map<String, dynamic> entries) async {
    for (final entry in entries.entries) {
      if (entry.value == null) continue;
      await _box?.put(entry.key, entry.value.toString());
    }
  }

  // ======================== 删除/查询 ========================

  /// 删除某个键
  static Future<void> remove(String key) async {
    await _box?.delete(key);
  }

  /// 清空所有设置
  static Future<void> clear() async {
    await _box?.clear();
  }

  /// 所有键
  static Iterable<String> get keys => _box?.keys.cast<String>() ?? [];

  /// 是否包含某个键
  static bool has(String key) => _box?.containsKey(key) ?? false;

  // ======================== 响应式监听 ========================

  /// 监听某个键的变化
  static Stream<BoxEvent> watchAll() {
    return _box!.watch();
  }

  /// 监听指定键的变化
  static Stream<BoxEvent> watchKey(String key) {
    return _box!.watch(key: key);
  }
}

/// ====================================================================
/// Riverpod Provider 集成 — 在 Widget 中响应式监听设置变化
/// ====================================================================

/// 全量设置监听 provider
///
/// 用法:
/// ```dart
/// final settings = ref.watch(settingsProvider);
/// settings.when(
///   data: (map) => Text(map['theme_mode'] ?? 'light'),
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('$e'),
/// );
/// ```
final settingsProvider = StreamProvider<Map<String, String?>>((ref) {
  final box = Settings._internalBox;
  if (box == null) return const Stream.empty();

  return box.watch().map((_) {
    return {for (final key in box.keys) key: box.get(key)};
  });
});

/// 监听单个设置项的变化
///
/// 用法:
/// ```dart
/// final themeMode = ref.watch(settingWatcherProvider('theme_mode'));
/// ```
final settingWatcherProvider = Provider.family<String?, String>((
  ref,
  String key,
) {
  return Settings.get(key);
});
