import 'package:pomelo/core/mars.dart';
import 'model/music_source.dart';
import 'model/music_service.dart';
import 'model/song.dart';
import 'model/album.dart';
import 'model/playlist.dart';

/// Music 模块
///
/// 音乐查询服务模块，统一管理所有注册的 [MusicService]。
///
/// 职责：
/// - 提供 [MusicService] 接口规范，供其他模块实现
/// - 通过 [register] 接收并管理各平台模块注册的音乐服务
/// - 提供统一的多源聚合查询能力（搜索歌曲/专辑/歌单）
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
  final List<MusicSource> _sources = [];

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

  /// 所有已注册的音乐来源（只读）
  List<MusicSource> get sources => List.unmodifiable(_sources);

  // ========== 来源管理 ==========

  /// 添加一个音乐来源
  ///
  /// 会先调用 [MusicSource.init] 初始化来源，
  /// 然后将其提供的所有 [MusicService] 注册到本模块。
  Future<void> addSource(MusicSource source) async {
    await source.init();
    _sources.add(source);
    for (final service in source.services) {
      _services.add(service);
    }
  }

  /// 移除一个音乐来源
  ///
  /// 会注销其提供的所有 [MusicService]，然后调用 [MusicSource.dispose]。
  /// 返回是否找到并移除了该来源。
  Future<bool> removeSource(String sourceId) async {
    final idx = _sources.indexWhere((s) => s.id == sourceId);
    if (idx == -1) return false;
    final source = _sources.removeAt(idx);
    // 注销该来源提供的所有服务
    for (final service in source.services) {
      _services.removeWhere((s) => s.sourceId == service.sourceId);
    }
    await source.dispose();
    return true;
  }

  /// 获取指定类型的来源列表
  List<MusicSource> sourcesOfType(MusicSourceType type) {
    return _sources.where((s) => s.type == type).toList();
  }

  /// 根据来源 id 获取来源
  MusicSource? source(String sourceId) {
    try {
      return _sources.firstWhere((s) => s.id == sourceId);
    } catch (_) {
      return null;
    }
  }

  // ========== 服务管理（保留原有 API） ==========

  /// 注册一个音乐服务
  void register(MusicService service) {
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
    // 等待各平台模块注册 MusicService
  }

  @override
  Future<void> onReady() async {
    // 所有模块就绪，音乐服务应在此时已注册完毕
  }

  @override
  Future<void> onDispose() async {
    // 先注销所有来源
    for (final source in List<MusicSource>.from(_sources)) {
      await source.dispose();
    }
    _sources.clear();
    _services.clear();
  }
}
