import 'package:pomelo/core/core.dart';
import '../model/home_item.dart';
import '../repository/home_repository.dart';

/// Home 模块 - 服务层
///
/// 封装 Home 模块的纯业务逻辑。
class HomeService extends Service {
  @override
  String get id => 'home_service';

  final HomeRepository repository;

  HomeService(this.repository);

  /// 获取所有首页条目
  List<HomeItem> getAllItems() => throw UnimplementedError('待实现');
}
