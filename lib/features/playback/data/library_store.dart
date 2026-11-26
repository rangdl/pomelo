import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../shared/storage/json_file_store.dart';

/// 本地音乐库：收藏与播放历史（各存一个 JSON 文件）。
///
/// 只存轻量元信息（id/标题/歌手/封面/duration/lxSource/来源插件），
/// 不存解析出的直链（直链有时效，播放时重新解析）。
class LibraryStore {
  LibraryStore._(this._historyStore, this._favoritesStore);

  final JsonFileStore _historyStore;
  final JsonFileStore _favoritesStore;

  static const _historyMax = 200;

  static Future<LibraryStore> open() async {
    final dir = await getApplicationSupportDirectory();
    final base = dir.path;
    return LibraryStore._(
      JsonFileStore(File('$base${Platform.pathSeparator}history.json')),
      JsonFileStore(File('$base${Platform.pathSeparator}favorites.json')),
    );
  }

  Future<List<Map<String, dynamic>>> _readList(JsonFileStore store) async {
    final raw = await store.read();
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    }
    return [];
  }

  Future<void> _writeList(
    JsonFileStore store,
    List<Map<String, dynamic>> list,
  ) async {
    await store.write(list);
  }

  // ---- 历史 ----

  Future<List<Map<String, dynamic>>> loadHistory() => _readList(_historyStore);

  /// 记录一次播放（去重：同一首挪到最前；最多保留 [_historyMax] 条）。
  Future<List<Map<String, dynamic>>> pushHistory(
    Map<String, dynamic> item,
  ) async {
    final list = await loadHistory();
    final key = _key(item);
    list.removeWhere((e) => _key(e) == key);
    list.insert(0, _sanitize(item, withTime: true));
    final trimmed = list.take(_historyMax).toList();
    await _writeList(_historyStore, trimmed);
    return trimmed;
  }

  Future<List<Map<String, dynamic>>> clearHistory() async {
    await _writeList(_historyStore, []);
    return [];
  }

  // ---- 收藏 ----

  Future<List<Map<String, dynamic>>> loadFavorites() =>
      _readList(_favoritesStore);

  Future<List<Map<String, dynamic>>> clearFavorites() async {
    await _writeList(_favoritesStore, []);
    return [];
  }

  /// 批量收藏（已存在的不重复添加），返回最新列表。
  Future<List<Map<String, dynamic>>> addFavorites(
    Iterable<Map<String, dynamic>> items,
  ) async {
    final list = await loadFavorites();
    final keys = list.map(_key).toSet();
    // 倒序插入，保证批量收藏后列表顺序与传入顺序一致。
    for (final item in items.toList().reversed) {
      if (keys.add(_key(item))) {
        list.insert(0, _sanitize(item));
      }
    }
    await _writeList(_favoritesStore, list);
    return list;
  }

  Future<bool> isFavorite(Map<String, dynamic> item) async {
    final list = await loadFavorites();
    final key = _key(item);
    return list.any((e) => _key(e) == key);
  }

  /// 切换收藏状态，返回切换后是否已收藏。
  Future<bool> toggleFavorite(Map<String, dynamic> item) async {
    final list = await loadFavorites();
    final key = _key(item);
    final existed = list.any((e) => _key(e) == key);
    if (existed) {
      list.removeWhere((e) => _key(e) == key);
    } else {
      list.insert(0, _sanitize(item));
    }
    await _writeList(_favoritesStore, list);
    return !existed;
  }

  static String _key(Map<String, dynamic> item) =>
      '${item['_pluginId'] ?? ''}:${item['id'] ?? item['title'] ?? ''}';

  /// 只保留可持久化、可再解析的字段（去掉运行时私有缓存/直链）。
  static Map<String, dynamic> _sanitize(
    Map<String, dynamic> item, {
    bool withTime = false,
  }) {
    final copy = Map<String, dynamic>.from(item);
    copy.remove('_resolvedUrl');
    copy.remove('_headers');
    if (withTime) copy['_playedAt'] = DateTime.now().millisecondsSinceEpoch;
    return copy;
  }
}
