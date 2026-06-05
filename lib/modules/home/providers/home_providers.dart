import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/home_repository.dart';

/// Home 模块 - 状态管理层 (Riverpod Provider)
///
/// 使用 Riverpod 管理响应式状态，替代传统 Service 层状态管理。
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final repo = HomeRepository();
  repo.onInit();
  ref.onDispose(() => repo.onDispose());
  return repo;
});
