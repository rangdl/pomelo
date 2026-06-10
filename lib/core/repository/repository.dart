/// M.A.R.S. 仓储层抽象基类
///
/// Repository 负责数据访问，作为数据源（本地DB、API、内存）的统一抽象。
/// 模块通过 Repository 获取数据，而不直接依赖数据源实现。
abstract class Repository<T> {
  /// 仓储标识
  String get id;

  /// 获取所有数据
  Future<List<T>> fetchAll();

  /// 按ID获取单条数据
  Future<T?> fetchById(String id);

  /// 保存数据
  Future<void> save(T item);

  /// 批量保存
  Future<void> saveAll(List<T> items);

  /// 删除数据
  Future<void> delete(String id);

  /// 删除所有
  Future<void> deleteAll();

  /// 仓储是否已初始化
  bool get isInitialized => _isInitialized;
  bool _isInitialized = false;

  /// 初始化仓储
  Future<void> onInit() async {
    _isInitialized = true;
  }

  /// 销毁仓储
  Future<void> onDispose() async {
    _isInitialized = false;
  }
}

/// 基础内存仓储实现
class InMemoryRepository<T> extends Repository<T> {
  @override
  final String id;

  final Map<String, T> _store = {};

  /// 获取ID的函数
  final String Function(T item) idSelector;

  InMemoryRepository({required this.id, required this.idSelector});

  @override
  Future<List<T>> fetchAll() async => _store.values.toList();

  @override
  Future<T?> fetchById(String id) async => _store[id];

  @override
  Future<void> save(T item) async {
    _store[idSelector(item)] = item;
  }

  @override
  Future<void> saveAll(List<T> items) async {
    for (final item in items) {
      _store[idSelector(item)] = item;
    }
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
  }

  @override
  Future<void> deleteAll() async {
    _store.clear();
  }
}
