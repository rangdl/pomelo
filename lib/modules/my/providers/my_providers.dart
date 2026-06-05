import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/my_repository.dart';

/// My 模块 - 状态管理层 (Riverpod Provider)
final myRepositoryProvider = Provider<MyRepository>((ref) {
  final repo = MyRepository();
  repo.onInit();
  ref.onDispose(() => repo.onDispose());
  return repo;
});
