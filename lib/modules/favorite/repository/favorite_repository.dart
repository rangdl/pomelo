import 'package:pomelo/core/mars.dart';
import '../model/favorite_item.dart';

/// Favorite 模块 - 仓储层
class FavoriteRepository extends InMemoryRepository<FavoriteItem> {
  FavoriteRepository()
    : super(id: 'favorite_repository', idSelector: (item) => item.id);

  @override
  Future<void> onInit() async {
    await super.onInit();
    // 初始化默认数据
    await saveAll([
      const FavoriteItem(id: '1', title: '示例收藏 1', icon: 'heart'),
      const FavoriteItem(id: '2', title: '示例收藏 2', icon: 'heart'),
    ]);
  }
}
