import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home_module.dart';
import '../repository/home_repository.dart';

/// HomeModule 实例 Provider
///
/// 内部完成 HomeModule 的创建与 onInit 初始化。
/// main.dart 通过 `container.read(homeModuleProvider.future)` 触发初始化。
final homeModuleProvider = FutureProvider<HomeModule>((ref) async {
  final module = HomeModule();
  await module.onInit();
  ref.onDispose(module.onDispose);
  return module;
});

/// Home 模块 - 仓储 Provider
///
/// 同步派生自 [homeModuleProvider]。main.dart 在 runApp 前已 await
/// `homeModuleProvider.future`，故 UI 访问时必定为 data 状态。
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return ref.watch(homeModuleProvider).requireValue.repository;
});
