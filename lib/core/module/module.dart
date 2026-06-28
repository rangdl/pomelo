/// M.A.R.S. 模块化架构核心 - 模块抽象基类
///
/// 模块是一个完整业务功能的自包含单元，包含：
/// - [M]odel: 数据模型层
/// - [A]ction: 应用用例层
/// - [R]epository: 数据仓储层
/// - [S]ervice/State: 服务/状态管理层
///
/// 每个模块可独立开发、测试、加载/卸载。
abstract class Module {
  /// 模块唯一标识
  String get id;

  /// 模块显示名称
  String get displayName;

  /// 模块版本号
  String get version => '1.0.0';

  /// 模块依赖的其他模块ID列表
  List<String> get dependencies => [];

  /// 是否为延迟加载模块
  ///
  /// 延迟模块不会在应用启动时自动初始化，
  /// 而是在首次使用时才执行生命周期。
  /// 适用于非首屏、低频访问的模块，可缩短应用冷启动时间。
  bool get lazy => false;

  /// 模块初始化（启动时调用）
  Future<void> onInit() async {}

  /// 模块就绪（所有依赖模块初始化完毕后调用）
  Future<void> onReady() async {}

  /// 模块销毁（热卸载时调用）
  Future<void> onDispose() async {}

  /// 是否已初始化
  bool get isInitialized => _isInitialized;
  bool _isInitialized = false;

  /// 内部初始化
  Future<void> init() async {
    if (_isInitialized) return;
    await onInit();
    _isInitialized = true;
  }

  /// 内部就绪
  Future<void> ready() async {
    if (!_isInitialized) return;
    await onReady();
  }

  /// 内部销毁
  Future<void> dispose() async {
    if (!_isInitialized) return;
    await onDispose();
    _isInitialized = false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Module && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Module($id: $displayName)';
}
