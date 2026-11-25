import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchResults extends Notifier<AsyncValue<List<Map<String, dynamic>>>> {
  @override
  AsyncValue<List<Map<String, dynamic>>> build() => const AsyncValue.data([]);

  void set(AsyncValue<List<Map<String, dynamic>>> value) => state = value;
}

final searchResultsProvider =
    NotifierProvider<SearchResults, AsyncValue<List<Map<String, dynamic>>>>(
      SearchResults.new,
    );
