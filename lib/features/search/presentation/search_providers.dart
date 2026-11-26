import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/settings/settings_store.dart';

class SearchResults extends Notifier<AsyncValue<List<Map<String, dynamic>>>> {
  @override
  AsyncValue<List<Map<String, dynamic>>> build() => const AsyncValue.data([]);

  void set(AsyncValue<List<Map<String, dynamic>>> value) => state = value;
}

final searchResultsProvider =
    NotifierProvider<SearchResults, AsyncValue<List<Map<String, dynamic>>>>(
      SearchResults.new,
    );

/// 搜索历史（最多 10 条，落盘到 settings.json，重启后保留）。
class SearchHistory extends Notifier<List<String>> {
  static const String _key = 'searchHistory';
  static const int _max = 10;

  @override
  List<String> build() {
    try {
      final stored = ref.read(settingsStoreProvider).read<List<dynamic>>(_key);
      return [
        for (final v in stored ?? const <dynamic>[])
          if (v is String && v.isNotEmpty) v,
      ];
    } catch (_) {
      return const [];
    }
  }

  Future<void> add(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final list = [q, ...state.where((e) => e != q)].take(_max).toList();
    state = list;
    await ref.read(settingsStoreProvider).patch({_key: list});
  }

  Future<void> remove(String query) async {
    final list = state.where((e) => e != query).toList();
    state = list;
    await ref.read(settingsStoreProvider).patch({_key: list});
  }

  Future<void> clear() async {
    state = const [];
    await ref.read(settingsStoreProvider).patch({_key: const <String>[]});
  }
}

final searchHistoryProvider = NotifierProvider<SearchHistory, List<String>>(
  SearchHistory.new,
);
