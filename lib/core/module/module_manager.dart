import 'dart:async';
import 'module.dart';

/// M.A.R.S. 模块管理器
///
/// 负责模块的生命周期管理：注册、初始化、就绪、销毁。
/// 采用延迟注册模式，确保模块按依赖顺序初始化。
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

  /// 初始化所有已注册模块（按依赖拓扑排序）
  Future<void> initAll() async {
    final sorted = _topologicalSort();
    for (final module in sorted) {
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
