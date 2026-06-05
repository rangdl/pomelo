import 'package:pomelo/core/mars.dart';
import '../model/my_profile.dart';
import '../repository/my_repository.dart';

/// My 模块 - 服务层
class MyService extends Service {
  @override
  String get id => 'my_service';

  final MyRepository repository;

  MyService(this.repository);

  /// 获取用户信息
  MyProfile? getProfile() => throw UnimplementedError('待实现');
}
