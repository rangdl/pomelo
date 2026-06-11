import 'package:pomelo/core/mars.dart';
import 'model/music_provider.dart';
import 'model/pagination_response.dart';

/// Music 模块
///
/// 音乐查询服务模块，统一管理所有注册的 [MusicProvider]。
///
/// 职责：
/// - 提供 [MusicProvider] 接口规范，供其他模块实现
/// - 通过 [register] 接收并管理各平台模块注册的音乐服务
/// - 提供统一的多源聚合查询能力（搜索歌曲/专辑/歌单）
///
/// 本模块不包含播放功能，播放由 audio_player 模块负责。
///
/// 遵循 M.A.R.S. 架构：
/// - Model: song.dart, album.dart, playlist.dart, music_provider.dart
/// - Action: (模块初始化/就绪/销毁)
/// - Repository: 由各 MusicProvider 实现自行管理
/// - Service/State: Riverpod Provider
class MusicModule extends Module {
  final List<MusicProvider> _providers = [];

  @override
  String get id => 'music';

  @override
  String get displayName => '音乐';

  @override
  bool get lazy => true;

  @override
  List<String> get dependencies => ['home'];

  /// 所有已注册的提供者（只读）
  List<MusicProvider> get providers => List.unmodifiable(_providers);

  /// 注册一个音乐数据提供者
  void register(MusicProvider provider) {
    _providers.add(provider);
  }

  /// 注销一个音乐数据提供者
  bool unregister(String sourceId) {
    final before = _providers.length;
    _providers.removeWhere((p) => p.sourceId == sourceId);
    return _providers.length < before;
  }

  /// 根据 sourceId 获取对应的提供者
  MusicProvider? provider(String sourceId) {
    try {
      return _providers.firstWhere((p) => p.sourceId == sourceId);
    } catch (_) {
      return null;
    }
  }

  /// 获取指定 sourceId 的提供者（不存在则抛异常）
  MusicProvider require(String sourceId) {
    return provider(sourceId) ??
        (throw StateError('未找到 MusicProvider: $sourceId。请确认对应模块已注册并初始化。'));
  }

  /// 获取所有符合类型的提供者
  List<T> providersOf<T extends MusicProvider>() {
    return _providers.whereType<T>().toList();
  }

  /// 按分类分组所有提供者
  ///
  /// 返回 Map，key 为 [categoryId]，value 为该分类下的提供者列表。
  /// 可用于 UI 上按分组展示来源选择。
  Map<String, List<MusicProvider>> providersByCategory() {
    final map = <String, List<MusicProvider>>{};
    for (final p in _providers) {
      map.putIfAbsent(p.categoryId, () => []).add(p);
    }
    return map;
  }

  /// 获取指定分类下的所有提供者
  List<MusicProvider> providersInCategory(String categoryId) {
    return _providers.where((p) => p.categoryId == categoryId).toList();
  }

  /// 获取所有已注册的分类及其名称
  ///
  /// 返回按首次出现顺序排列的 (categoryId, categoryName) 列表。
  List<({String id, String name})> get categories {
    final seen = <String, String>{};
    for (final p in _providers) {
      seen.putIfAbsent(p.categoryId, () => p.categoryName);
    }
    return seen.entries.map((e) => (id: e.key, name: e.value)).toList();
  }

  // ========== 便捷查询（遍历所有提供者） ==========

  /// 在所有提供者中搜索歌曲
  Future<SongPageResult> searchSongs(
    String keyword, {
    int page = 1,
    int limit = 20,
  }) async {
    final results = await Future.wait(
      _providers.map((p) => p.searchSongs(keyword, page: page, limit: limit)),
    );
    // 合并所有分页结果
    final allItems = results.expand((r) => r.items).toList();
    return PaginationResponse.fromList(allItems, page: page, limit: limit);
  }

  /// 在所有提供者中搜索专辑
  Future<AlbumPageResult> searchAlbums(
    String keyword, {
    int page = 1,
    int limit = 20,
  }) async {
    final results = await Future.wait(
      _providers.map((p) => p.searchAlbums(keyword, page: page, limit: limit)),
    );
    final allItems = results.expand((r) => r.items).toList();
    return PaginationResponse.fromList(allItems, page: page, limit: limit);
  }

  /// 在所有提供者中搜索歌单
  Future<PlaylistPageResult> searchPlaylists(
    String keyword, {
    int page = 1,
    int limit = 20,
  }) async {
    final results = await Future.wait(
      _providers.map(
        (p) => p.searchPlaylists(keyword, page: page, limit: limit),
      ),
    );
    final allItems = results.expand((r) => r.items).toList();
    return PaginationResponse.fromList(allItems, page: page, limit: limit);
  }

  // ========== 生命周期 ==========

  @override
  Future<void> onInit() async {
    // 等待各平台模块注册 MusicProvider
  }

  @override
  Future<void> onReady() async {
    // 所有模块就绪，音乐提供者应在此时已注册完毕
  }

  @override
  Future<void> onDispose() async {
    _providers.clear();
  }
}
