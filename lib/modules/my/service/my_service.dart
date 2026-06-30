import 'package:pomelo/core/core.dart';
import '../model/my_profile.dart';
import '../repository/my_repository.dart';

/// My 模块 - 服务层（示例模块）
///
/// 此模块为示例模块，未被其他模块引用。
/// 设置类操作请使用 [userPreferenceProvider]。
class MyService extends Service {
  @override
  String get id => 'my_service';

  final MyRepository repository;

  MyService(this.repository);

  /// 获取用户信息
  MyProfile? getProfile() => throw UnimplementedError('待实现');
}
