import 'package:pomelo/core/mars.dart';
import 'repository/my_repository.dart';
import 'service/my_service.dart';

/// My 模块定义
///
/// 遵循 M.A.R.S. 架构：
/// - Model: my_profile.dart
/// - Action: (模块初始化/就绪/销毁)
/// - Repository: MyRepository
/// - Service/State: MyService / Riverpod Provider
class MyModule extends Module {
  MyModule() : _repository = MyRepository();

  final MyRepository _repository;
  late final MyService _service;

  @override
  String get id => 'my';

  @override
  String get displayName => '我的';

  @override
  bool get lazy => true;

  @override
  Future<void> onInit() async {
    await _repository.onInit();
    _service = MyService(_repository);
    await _service.onInit();
  }

  @override
  Future<void> onDispose() async {
    await _repository.onDispose();
    await _service.onDispose();
  }

  /// 获取仓储实例（供外部使用）
  MyRepository get repository => _repository;
}
