import 'dart:async';
import 'module.dart';

/// M.A.R.S. 模块管理器
///
/// 负责模块的生命周期管理：注册、初始化、就绪、销毁。
/// 支持延迟加载 — 标记为 [Module.lazy] 的模块不会在应用启动时自动初始化，
/// 而是在首次通过 [lazyInit] 触发时才执行生命周期。
class ModuleManager {
  ModuleManager._();

  static final ModuleManager _instance = ModuleManager._();
  factory ModuleManager() => _instance;

  final Map<String, Module> _modules = {};
  final List<Module> _initializationOrder = [];

  /// 获取已注册的模块（只读视图）
  Map<String, Module> get modules => Map.unmodifiable(_modules);

  /// 获取初始化顺序列表
  List<Module> get initializationOrder =>
      List.unmodifiable(_initializationOrder);

  /// 注册单个模块
  Future<void> register(Module module) async {
    _modules[module.id] = module;
  }

  /// 批量注册模块
  Future<void> registerAll(List<Module> modules) async {
    for (final module in modules) {
      _modules[module.id] = module;
    }
  }

  /// 初始化所有**非延迟**模块（按依赖拓扑排序）
  ///
  /// 标记为 [Module.lazy] 的模块会被跳过，
  /// 它们会在首次调用 [lazyInit] 时按需初始化。
  Future<void> initAll() async {
    final sorted = _topologicalSort();
    for (final module in sorted) {
      if (module.lazy) continue;
      await module.init();
      _initializationOrder.add(module);
    }
  }

  /// 触发所有已初始化模块的 onReady
  Future<void> readyAll() async {
    for (final module in _initializationOrder) {
      await module.ready();
    }
  }

  /// 按需初始化一个延迟加载模块
  ///
  /// 如果模块已初始化或不是延迟模块则直接返回。
  /// 会自动先初始化该模块所依赖的其他模块（递归处理依赖链）。
  ///
  /// 使用示例：
  /// ```dart
  /// // 在用户导航到收藏页时触发
  /// await ModuleManager().lazyInit('favorite');
  /// ```
  Future<void> lazyInit(String id) async {
    final module = _modules[id];
    if (module == null) {
      throw MissingDependencyException('尝试延迟加载不存在的模块: $id');
    }
    if (module.isInitialized) return;
    if (!module.lazy) {
      // 非延迟模块应由 initAll 初始化，此处只需等待即可
      return;
    }

    // 递归初始化依赖模块
    for (final depId in module.dependencies) {
      final dep = _modules[depId];
      if (dep != null && !dep.isInitialized) {
        await lazyInit(depId);
      }
    }

    await module.init();
    await module.ready();
    _initializationOrder.add(module);
  }

  /// 获取指定模块，若为延迟模块则自动初始化
  ///
  /// 适用于按类型从 Provider 或其他地方懒加载模块的场景。
  Future<T?> require<T extends Module>(String id) async {
    final module = _modules[id];
    if (module == null) return null;
    if (module.lazy && !module.isInitialized) {
      await lazyInit(id);
    }
    return module as T?;
  }

  /// 获取指定模块
  T? find<T extends Module>(String id) => _modules[id] as T?;

  /// 按类型获取模块
  T? findByType<T extends Module>() {
    for (final module in _modules.values) {
      if (module is T) return module;
    }
    return null;
  }

  /// 销毁单个模块
  Future<void> disposeModule(String id) async {
    final module = _modules[id];
    if (module != null) {
      await module.dispose();
      _modules.remove(id);
      _initializationOrder.remove(module);
    }
  }

  /// 销毁所有模块
  Future<void> disposeAll() async {
    for (final module in _initializationOrder.reversed) {
      await module.dispose();
    }
    _modules.clear();
    _initializationOrder.clear();
  }

  /// 拓扑排序，确保依赖模块先初始化
  List<Module> _topologicalSort() {
    final visited = <String>{};
    final result = <Module>[];
    final tempMark = <String>{};

    void dfs(Module module) {
      if (tempMark.contains(module.id)) {
        throw CycleDependencyException('检测到循环依赖: ${module.id}');
      }
      if (visited.contains(module.id)) return;

      tempMark.add(module.id);

      for (final depId in module.dependencies) {
        final dep = _modules[depId];
        if (dep != null) {
          dfs(dep);
        } else {
          throw MissingDependencyException('模块 ${module.id} 依赖 $depId，但未注册');
        }
      }

      tempMark.remove(module.id);
      visited.add(module.id);
      result.add(module);
    }

    for (final module in _modules.values) {
      if (!visited.contains(module.id)) {
        dfs(module);
      }
    }

    return result;
  }
}

/// 循环依赖异常
class CycleDependencyException implements Exception {
  final String message;
  CycleDependencyException(this.message);

  @override
  String toString() => 'CycleDependencyException: $message';
}

/// 缺少依赖异常
class MissingDependencyException implements Exception {
  final String message;
  MissingDependencyException(this.message);

  @override
  String toString() => 'MissingDependencyException: $message';
}
