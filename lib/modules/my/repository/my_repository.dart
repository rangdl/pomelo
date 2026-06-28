import 'package:pomelo/core/core.dart';
import '../model/my_profile.dart';

/// My 模块 - 持久化仓储层
///
/// 基于 PersistentRepository + hive_ce Box，数据自动持久化。
/// 数据结构变更时无需迁移操作。
class MyRepository extends PersistentRepository<MyProfile> {
  @override
  String get boxName => 'my_profile';

  @override
  String idSelector(MyProfile item) => item.id;

  @override
  MyProfile fromJson(Map<String, dynamic> json) => MyProfile.fromJson(json);

  @override
  Map<String, dynamic> toJson(MyProfile item) => item.toJson();

  @override
  Future<void> onInit() async {
    await super.onInit();

    // 首次使用时写入默认数据
    if (count == 0) {
      await save(const MyProfile(id: '1', name: '用户', bio: '这个人很懒，什么都没写...'));
    }
  }
}
