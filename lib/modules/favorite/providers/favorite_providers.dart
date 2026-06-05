import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/favorite_repository.dart';

/// Favorite 模块 - 状态管理层 (Riverpod Provider)
final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  final repo = FavoriteRepository();
  repo.onInit();
  ref.onDispose(() => repo.onDispose());
  return repo;
});
