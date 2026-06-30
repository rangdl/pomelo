import 'package:pomelo/core/core.dart';
import '../model/my_profile.dart';

/// My 模块 - 内存仓储层
///
/// 基于 InMemoryRepository，数据仅在内存中不持久化。
/// （此模块为示例模块，未被其他模块引用）
class MyRepository extends InMemoryRepository<MyProfile> {
  MyRepository() : super(id: 'my_repository', idSelector: (item) => item.id);

  @override
  Future<void> onInit() async {
    await super.onInit();

    // 首次使用时写入默认数据
    if ((await fetchAll()).isEmpty) {
      await save(const MyProfile(id: '1', name: '用户', bio: '这个人很懒，什么都没写...'));
    }
  }
}
