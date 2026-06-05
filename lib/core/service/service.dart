/// M.A.R.S. 服务层抽象基类
///
/// Service 封装纯业务逻辑，不依赖 UI。
/// 通常被 Action 层或 Provider 调用。
abstract class Service {
  /// 服务标识
  String get id;

  /// 初始化服务
  Future<void> onInit() async {}

  /// 销毁服务
  Future<void> onDispose() async {}

  final bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
}
