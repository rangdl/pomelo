/// 日志模块 - 模块定义
///
/// 提供应用内日志记录、查询、过滤和导出功能。
/// 遵循 M.A.R.S. 架构：
/// - Model: log_entry.dart
/// - Action: (模块初始化/就绪/销毁)
/// - Repository: LogRepository
/// - Service/State: LogService / Riverpod Provider
library;

import 'package:path_provider/path_provider.dart';
import 'package:pomelo/core/mars.dart';

import 'repository/log_repository.dart';
import 'service/log_service.dart';

class LogModule extends Module {
  LogModule() : _repository = LogRepository();

  final LogRepository _repository;
  late final LogService _service;

  @override
  String get id => 'log';

  @override
  String get displayName => '日志';

  @override
  bool get lazy => false; // 日志模块非延迟加载，便于其他模块使用

  @override
  List<String> get dependencies => [];

  @override
  Future<void> onInit() async {
    // 初始化仓储
    await _repository.onInit();

    // 初始化文件存储（应用文档目录/logs/）
    try {
      final appDir = await getApplicationDocumentsDirectory();
      await _repository.initFileStorage('${appDir.path}/logs');
    } catch (_) {
      // 文件存储初始化失败不影响内存日志
    }

    // 初始化服务
    _service = LogService(_repository);
    await _service.onInit();
  }

  @override
  Future<void> onReady() async {
    // 所有依赖模块就绪后的逻辑
  }

  @override
  Future<void> onDispose() async {
    await _repository.onDispose();
    await _service.onDispose();
  }

  /// 获取仓储实例（供外部使用）
  LogRepository get repository => _repository;

  /// 获取服务实例（供外部使用）
  LogService get service => _service;
}
