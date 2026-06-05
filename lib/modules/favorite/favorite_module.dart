import 'package:pomelo/core/mars.dart';
import 'repository/favorite_repository.dart';
import 'service/favorite_service.dart';

/// Favorite 模块定义
///
/// 遵循 M.A.R.S. 架构：
/// - Model: favorite_item.dart
/// - Action: (模块初始化/就绪/销毁)
/// - Repository: FavoriteRepository
/// - Service/State: FavoriteService / Riverpod Provider
class FavoriteModule extends Module {
  FavoriteModule() : _repository = FavoriteRepository();

  final FavoriteRepository _repository;
  late final FavoriteService _service;

  @override
  String get id => 'favorite';

  @override
  String get displayName => '收藏';

  @override
  bool get lazy => true;

  @override
  Future<void> onInit() async {
    await _repository.onInit();
    _service = FavoriteService(_repository);
    await _service.onInit();
  }

  @override
  Future<void> onDispose() async {
    await _repository.onDispose();
    await _service.onDispose();
  }

  /// 获取仓储实例（供外部使用）
  FavoriteRepository get repository => _repository;
}
