import 'package:pomelo/core/mars.dart';
import '../model/my_profile.dart';

/// My 模块 - 仓储层
class MyRepository extends InMemoryRepository<MyProfile> {
  MyRepository() : super(id: 'my_repository', idSelector: (item) => item.id);

  @override
  Future<void> onInit() async {
    await save(const MyProfile(id: '1', name: '用户', bio: '这个人很懒，什么都没写...'));
  }
}
