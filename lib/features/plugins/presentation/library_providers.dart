import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../playback/data/library_store.dart';

/// 本地音乐库存储（启动时 open 后注入；未注入则懒加载）。
final libraryStoreProvider = FutureProvider<LibraryStore>((ref) {
  return LibraryStore.open();
});

/// 收藏列表。
class FavoritesNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final store = await ref.watch(libraryStoreProvider.future);
    return store.loadFavorites();
  }

  Future<bool> toggle(Map<String, dynamic> item) async {
    final store = await ref.read(libraryStoreProvider.future);
    final nowFav = await store.toggleFavorite(item);
    state = AsyncData(await store.loadFavorites());
    return nowFav;
  }

  bool contains(Map<String, dynamic> item) {
    final list = state.value ?? const [];
    final key =
        '${item['_pluginId'] ?? ''}:${item['id'] ?? item['title'] ?? ''}';
    return list.any(
      (e) => '${e['_pluginId'] ?? ''}:${e['id'] ?? e['title'] ?? ''}' == key,
    );
  }

  Future<void> clear() async {
    final store = await ref.read(libraryStoreProvider.future);
    await store.clearFavorites();
    state = const AsyncData([]);
  }

  /// 批量收藏，返回新增数量（已收藏的不重复计入）。
  Future<int> addAll(Iterable<Map<String, dynamic>> items) async {
    final store = await ref.read(libraryStoreProvider.future);
    final before = (await store.loadFavorites()).length;
    final list = await store.addFavorites(items);
    state = AsyncData(list);
    return list.length - before;
  }
}

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<Map<String, dynamic>>>(
      FavoritesNotifier.new,
    );

/// 播放历史。
class HistoryNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final store = await ref.watch(libraryStoreProvider.future);
    return store.loadHistory();
  }

  Future<void> record(Map<String, dynamic> item) async {
    final store = await ref.read(libraryStoreProvider.future);
    final list = await store.pushHistory(item);
    state = AsyncData(list);
  }

  Future<void> clear() async {
    final store = await ref.read(libraryStoreProvider.future);
    await store.clearHistory();
    state = const AsyncData([]);
  }
}

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<Map<String, dynamic>>>(
      HistoryNotifier.new,
    );
