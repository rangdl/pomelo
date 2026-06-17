import 'package:pomelo/core/mars.dart';
import 'model/music_service.dart';
import 'model/music_source_type.dart';
import 'model/song.dart';
import 'model/album.dart';
import 'model/playlist.dart';

/// Music 模块
///
/// 音乐查询服务模块，统一管理所有注册的 [MusicService]。
///
/// 职责：
/// - 提供 [MusicService] 接口规范，供其他模块实现
/// - 通过 [register] 接收并管理各模块注册的音乐服务
/// - 提供统一的多源聚合查询能力（搜索歌曲/专辑/歌单）
/// - 通过 [maxServiceCount] 限制同类型服务的注册数量
///
/// 本模块不包含播放功能，播放由 audio_player 模块负责。
///
/// 遵循 M.A.R.S. 架构：
/// - Model: song.dart, album.dart, playlist.dart, music_service.dart
/// - Action: (模块初始化/就绪/销毁)
/// - Repository: 由各 MusicService 实现自行管理
/// - Service/State: Riverpod Provider
class MusicModule extends Module {
  final List<MusicService> _services = [];

  @override
  String get id => 'music';

  @override
  String get displayName => '音乐';

  @override
  bool get lazy => true;

  @override
  List<String> get dependencies => ['home'];

  /// 所有已注册的音乐服务（只读）
  List<MusicService> get services => List.unmodifiable(_services);

  // ========== 服务管理 ==========

  /// 注册一个音乐服务
  ///
  /// 会检查同 [MusicSourceType] 已注册的数量是否达到
  /// [MusicService.maxServiceCount] 上限，达到则抛出 [StateError]。
  void register(MusicService service) {
    final sameTypeCount =
        _services.where((s) => s.sourceType == service.sourceType).length;
    if (sameTypeCount >= service.maxServiceCount) {
      throw StateError(
        '无法注册 ${service.sourceType.displayName} 服务: '
        '已达到最大注册数量 ${service.maxServiceCount}',
      );
    }
    _services.add(service);
  }

  /// 注销一个音乐服务
  bool unregister(String sourceId) {
    final before = _services.length;
    _services.removeWhere((s) => s.sourceId == sourceId);
    return _services.length < before;
  }

  /// 根据 sourceId 获取对应的服务
  MusicService? service(String sourceId) {
    try {
      return _services.firstWhere((s) => s.sourceId == sourceId);
    } catch (_) {
      return null;
    }
  }

  /// 获取指定 sourceId 的服务（不存在则抛异常）
  MusicService require(String sourceId) {
    return service(sourceId) ??
        (throw StateError('未找到 MusicService: $sourceId。请确认对应模块已注册并初始化。'));
  }

  /// 获取所有符合类型的服务
  List<T> servicesOf<T extends MusicService>() {
    return _services.whereType<T>().toList();
  }

  /// 获取指定来源类型的所有服务
  List<MusicService> servicesByType(MusicSourceType type) {
    return _services.where((s) => s.sourceType == type).toList();
  }

  /// 按分类分组所有服务
  ///
  /// 返回 Map，key 为 [categoryId]，value 为该分类下的服务列表。
  /// 可用于 UI 上按分组展示来源选择。
  Map<String, List<MusicService>> servicesByCategory() {
    final map = <String, List<MusicService>>{};
    for (final s in _services) {
      map.putIfAbsent(s.categoryId, () => []).add(s);
    }
    return map;
  }

  /// 获取指定分类下的所有服务
  List<MusicService> servicesInCategory(String categoryId) {
    return _services.where((s) => s.categoryId == categoryId).toList();
  }

  /// 获取所有已注册的分类及其名称
  ///
  /// 返回按首次出现顺序排列的 (categoryId, categoryName) 列表。
  List<({String id, String name})> get categories {
    final seen = <String, String>{};
    for (final s in _services) {
      seen.putIfAbsent(s.categoryId, () => s.categoryName);
    }
    return seen.entries.map((e) => (id: e.key, name: e.value)).toList();
  }

  // ========== 便捷查询（遍历所有服务） ==========

  /// 在所有服务中搜索歌曲
  Future<PaginationResponse<Song>> searchSongs(
    String keyword, {
    int page = 1,
    int limit = 20,
  }) async {
    final results = await Future.wait(
      _services.map((s) => s.searchSongs(keyword, page: page, limit: limit)),
    );
    // 合并所有分页结果
    final allItems = results.expand((r) => r.items).toList();
    return PaginationResponse.fromList(allItems, page: page, limit: limit);
  }

  /// 在所有服务中搜索专辑
  Future<PaginationResponse<Album>> searchAlbums(
    String keyword, {
    int page = 1,
    int limit = 20,
  }) async {
    final results = await Future.wait(
      _services.map((s) => s.searchAlbums(keyword, page: page, limit: limit)),
    );
    final allItems = results.expand((r) => r.items).toList();
    return PaginationResponse.fromList(allItems, page: page, limit: limit);
  }

  /// 在所有服务中搜索歌单
  Future<PaginationResponse<Playlist>> searchPlaylists(
    String keyword, {
    int page = 1,
    int limit = 20,
  }) async {
    final results = await Future.wait(
      _services.map(
        (s) => s.searchPlaylists(keyword, page: page, limit: limit),
      ),
    );
    final allItems = results.expand((r) => r.items).toList();
    return PaginationResponse.fromList(allItems, page: page, limit: limit);
  }

  // ========== 生命周期 ==========

  @override
  Future<void> onInit() async {
    // 等待各音乐模块注册 MusicService
  }

  @override
  Future<void> onReady() async {
    // 所有模块就绪，音乐服务应在此时已注册完毕
  }

  @override
  Future<void> onDispose() async {
    _services.clear();
  }
}
