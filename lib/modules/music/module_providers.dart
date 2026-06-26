import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'model/track.dart';
import 'music_module.dart';

// ============================================================
// Music SDK Provider
// 注意: 使用模块实例前需确保模块已通过 ModuleManager.lazyInit 初始化
// ============================================================

/// 持有 MusicModule 实例的 Provider
final musicSdkModuleProvider = Provider<MusicModule>((ref) {
  throw UnimplementedError(
    'MusicModule 尚未初始化。请先调用 ModuleManager.lazyInit("music")。',
  );
});

/// 音乐搜索关键词 Notifier
class SearchKeywordNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String keyword) => state = keyword;
}

/// 音乐搜索关键词状态
final musicSearchKeywordProvider =
    NotifierProvider<SearchKeywordNotifier, String>(SearchKeywordNotifier.new);

/// 音乐搜索结果
final musicSearchResultProvider = Provider<List<Track>>((ref) {
  final keyword = ref.watch(musicSearchKeywordProvider);
  if (keyword.isEmpty) return [];
  return []; // TODO: 接入搜索逻辑
});
