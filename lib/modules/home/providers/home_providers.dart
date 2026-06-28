import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home_module.dart';
import '../repository/home_repository.dart';

/// Home 模块 - 状态管理层 (Riverpod Provider)
///
/// 通过 Module 实例获取仓储，确保数据源一致性。
/// 注意: 使用前需确保 HomeModule 已在 main.dart 中初始化并通过 override 注入。
final homeModuleProvider = Provider<HomeModule>((ref) {
  throw UnimplementedError(
    'HomeModule 尚未初始化。请在 main.dart 中 override 此 Provider。',
  );
});

/// Home 模块 - 仓储 Provider
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return ref.watch(homeModuleProvider).repository;
});
