import 'package:pomelo/core/mars.dart';

/// Example 模块定义
///
/// 演示 M.A.R.S. 架构的完整模块示例。
class ExampleModule extends Module {
  @override
  String get id => 'example';

  @override
  String get displayName => '示例';

  @override
  List<String> get dependencies => ['home'];

  @override
  Future<void> onInit() async {
    // 示例模块初始化逻辑
  }

  @override
  Future<void> onReady() async {
    // 所有依赖模块就绪后的逻辑
  }
}
