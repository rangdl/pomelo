import 'package:pomelo/core/mars.dart';
import 'repository/home_repository.dart';
import 'service/home_service.dart';

/// Home 模块定义
///
/// 遵循 M.A.R.S. 架构：
/// - Model: home_item.dart
/// - Action: (模块初始化/就绪/销毁)
/// - Repository: HomeRepository
/// - Service/State: HomeService / Riverpod Provider
class HomeModule extends Module {
  HomeModule() : _repository = HomeRepository();

  final HomeRepository _repository;
  late final HomeService _service;

  @override
  String get id => 'home';

  @override
  String get displayName => '首页';

  @override
  Future<void> onInit() async {
    // 初始化仓储
    await _repository.onInit();

    // 初始化服务
    _service = HomeService(_repository);
    await _service.onInit();
  }

  @override
  Future<void> onDispose() async {
    await _repository.onDispose();
    await _service.onDispose();
  }

  /// 获取仓储实例（供外部使用）
  HomeRepository get repository => _repository;
}
