import 'package:pomelo/core/core.dart';
import '../model/home_item.dart';

/// Home 模块 - 仓储层
///
/// 负责 Home 模块的数据访问。
class HomeRepository extends InMemoryRepository<HomeItem> {
  HomeRepository()
    : super(id: 'home_repository', idSelector: (item) => item.id);

  @override
  Future<void> onInit() async {
    await super.onInit();
    // 初始化默认数据
    await saveAll([
      const HomeItem(
        id: '1',
        title: '模块化架构',
        subtitle: 'M.A.R.S. 模式让代码更清晰',
        icon: 'layers',
      ),
      const HomeItem(
        id: '2',
        title: 'Riverpod 状态管理',
        subtitle: '编译安全、测试友好',
        icon: 'bolt',
      ),
      const HomeItem(
        id: '3',
        title: 'GoRouter 路由',
        subtitle: '声明式、类型安全的路由方案',
        icon: 'route',
      ),
    ]);
  }
}
