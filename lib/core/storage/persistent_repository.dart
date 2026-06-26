/// 持久化仓储基类
///
/// 基于 hive_ce Box 的字符串存储，数据以 JSON String 存入。
/// 利用 JSON 的"缺 key 容忍"特性，实现**零迁移 schema 升级**。
///
/// 只要遵循以下规则，任何结构变更都无需迁移操作：
/// - 新增字段: 构造器给默认值，fromJson 用 `??` 兜底
/// - 删除字段: 移除构造参数和 toJson 行即可
/// - 重命名字段: fromJson 中 `json['new'] ?? json['old']` 过渡一个版本
///
/// 用法:
/// ```dart
/// class TrackRepository extends PersistentRepository<Track> {
///   @override
///   String get boxName => 'tracks';
///
///   @override
///   String idSelector(Track item) => item.id;
///
///   @override
///   Track fromJson(Map<String, dynamic> json) => Track(
///     id: json['id'] as String,
///     title: json['title'] as String? ?? '',
///   );
///
///   @override
///   Map<String, dynamic> toJson(Track item) => {
///     'id': item.id,
///     'title': item.title,
///   };
/// }
/// ```
library;

import 'dart:convert';

import 'package:hive_ce/hive.dart';

/// 持久化仓储 — 模块继承此类获得免迁移的持久化能力
abstract class PersistentRepository<T> {
  /// Box 名称（每个模块用不同名称，完全独立）
  String get boxName;

  /// 获取 ID 的函数
  String idSelector(T item);

  /// 反序列化（JSON String → T）
  T fromJson(Map<String, dynamic> json);

  /// 序列化（T → JSON String）
  Map<String, dynamic> toJson(T item);

  late final Box<String> _box;

  /// 仓储是否已初始化
  bool get isInitialized => __isInitialized;
  bool __isInitialized = false;

  /// 打开 Box（由模块的 onInit 调用）
  Future<void> onInit() async {
    if (__isInitialized) return;
    _box = await Hive.openBox<String>(boxName);
    __isInitialized = true;
  }

  /// 关闭 Box（由模块的 onDispose 调用）
  Future<void> onDispose() async {
    if (!__isInitialized) return;
    await _box.close();
    __isInitialized = false;
  }

  // ======================== CRUD ========================

  /// 获取所有数据
  Future<List<T>> fetchAll() async {
    return _box.values
        .map((jsonStr) => fromJson(jsonDecode(jsonStr) as Map<String, dynamic>))
        .toList();
  }

  /// 按 ID 获取
  Future<T?> fetchById(String id) async {
    final jsonStr = _box.get(id);
    if (jsonStr == null) return null;
    return fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  /// 保存（新增或覆盖）
  Future<void> save(T item) async {
    await _box.put(idSelector(item), jsonEncode(toJson(item)));
  }

  /// 批量保存
  Future<void> saveAll(List<T> items) async {
    await _box.putAll({
      for (final item in items) idSelector(item): jsonEncode(toJson(item)),
    });
  }

  /// 删除
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// 清空所有
  Future<void> deleteAll() async {
    await _box.clear();
  }

  /// 数据数量
  int get count => _box.length;

  /// 所有 ID
  Iterable<String> get keys => _box.keys.cast<String>();
}
