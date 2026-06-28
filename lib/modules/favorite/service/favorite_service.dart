import 'package:pomelo/core/core.dart';
import '../model/favorite_item.dart';
import '../repository/favorite_repository.dart';

/// Favorite 模块 - 服务层
class FavoriteService extends Service {
  @override
  String get id => 'favorite_service';

  final FavoriteRepository repository;

  FavoriteService(this.repository);

  /// 获取所有收藏
  List<FavoriteItem> getAllItems() => throw UnimplementedError('待实现');
}
