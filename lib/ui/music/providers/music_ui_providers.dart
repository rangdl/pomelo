import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/storage/settings.dart';
import 'package:pomelo/core/storage/storage_keys.dart';
import 'package:pomelo/core/pagination/pagination_response.dart';
import 'package:pomelo/modules/music/model/music_source_type.dart';
import 'package:pomelo/modules/music/model/music_service.dart';
import 'package:pomelo/modules/music/model/playlist.dart';
import 'package:pomelo/modules/music/model/leaderboard.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/modules/music/model/track.dart';
import 'package:pomelo/modules/music_local/local_music_providers.dart';
import 'package:pomelo/modules/music_lx_server/providers/lx_server_providers.dart';
import 'package:pomelo/ui/music/model/service_result.dart';
import 'package:pomelo/ui/music/model/merged_track.dart';

import 'package:pomelo/ui/platform/providers/lx_metadata_plugin_paths_provider.dart';

/// 按来源类型分组服务
Map<MusicSourceType, List<MusicService>> groupServicesByType(
  List<MusicService> services,
) {
  final byType = <MusicSourceType, List<MusicService>>{};
  for (final s in services) {
    byType.putIfAbsent(s.sourceType, () => []).add(s);
  }
  return byType;
}

/// 当前选中的音乐来源 sourceId 和 libraryId 的 Notifier
///
/// sourceId 为 null 表示"全部来源"。
/// libraryId 用于多库服务（如 Lx），指定当前使用的库。
/// 选中的来源会自动持久化到 Settings，应用重启后自动恢复。
class SelectedSourceNotifier
    extends Notifier<({String? sourceId, String? libraryId})> {
  @override
  ({String? sourceId, String? libraryId}) build() {
    final savedSource = Settings.get(StorageKeys.musicSelectedSource);
    final savedLibrary = Settings.get(StorageKeys.musicSelectedLibrary);
    final initialState = (
      sourceId: (savedSource != null && savedSource.isNotEmpty)
          ? savedSource
          : null,
      libraryId: (savedLibrary != null && savedLibrary.isNotEmpty)
          ? savedLibrary
          : null,
    );

    // 修复重启后选中库未生效：
    // build() 同步执行时音乐服务尚未注册（lazy 模块未完成 onReady），
    // 直接调用 service.setDefaultLibrary 会因服务为 null 而被跳过。
    // 这里改为在 musicReadyProvider 就绪后再应用持久化的库。
    void applyPersistedLibrary(bool _) {
      final sourceId = initialState.sourceId;
      final libraryId = initialState.libraryId;
      if (sourceId == null || libraryId == null) return;
      final module = ref.read(musicModuleProvider);
      module?.service(sourceId)?.setDefaultLibrary(libraryId);
    }

    ref.listen<AsyncValue<bool>>(musicReadyProvider, (_, ready) {
      ready.whenData(applyPersistedLibrary);
    });
    // 兜底：若服务在 build 前已就绪
    ref.read(musicReadyProvider).whenData(applyPersistedLibrary);

    return initialState;
  }

  void selectAll() {
    state = (sourceId: null, libraryId: null);
    Settings.set(StorageKeys.musicSelectedSource, '');
    Settings.set(StorageKeys.musicSelectedLibrary, '');
  }

  void select(String sourceId, {String? libraryId}) {
    state = (sourceId: sourceId, libraryId: libraryId);
    Settings.set(StorageKeys.musicSelectedSource, sourceId);
    Settings.set(StorageKeys.musicSelectedLibrary, libraryId ?? '');
    // 如果选中了多库服务的某个库，更新服务的默认库
    if (libraryId != null) {
      final module = ref.read(musicModuleProvider);
      final service = module?.service(sourceId);
      service?.setDefaultLibrary(libraryId);
    }
  }
}

/// 当前选中的音乐来源
///
/// 返回 `(sourceId, libraryId)` 记录，sourceId 为 null 表示"全部来源"。
final selectedSourceProvider =
    NotifierProvider<
      SelectedSourceNotifier,
      ({String? sourceId, String? libraryId})
    >(SelectedSourceNotifier.new);

/// 音乐列表数据：曲目列表 + 出错的服务
class MusicListData {
  final List<Track> tracks;
  final List<({String sourceId, String sourceName, Object error})> errors;

  const MusicListData({this.tracks = const [], this.errors = const []});
}

/// 获取当前来源的曲目列表（逐服务隔离异常）
final currentSourceTracksProvider = FutureProvider<MusicListData>((ref) async {
  // 监听本地音乐数据版本，目录/扫描变更后自动刷新曲目列表
  ref.watch(localMusicVersionProvider);
  final selection = ref.watch(selectedSourceProvider);
  final services = await ref.watch(musicServicesProvider.future);

  Iterable<MusicService> targets = services;
  if (selection.sourceId != null) {
    final module = ref.watch(musicModuleProvider);
    final s = module?.service(selection.sourceId!);
    targets = s != null ? [s] : [];
  }

  if (targets.isEmpty) return const MusicListData();

  final results = await safeCallServices<PaginationResponse<Track>>(
    targets.toList(),
    (s) => (s as MusicService).getTracks(),
    getId: (s) => (s as MusicService).sourceId,
    getName: (s) => (s as MusicService).sourceName,
  );

  final tracks = <Track>[];
  final errors = <({String sourceId, String sourceName, Object error})>[];
  for (final r in results) {
    if (r.isSuccess && r.data != null) {
      tracks.addAll(r.data!.items);
    } else if (r.isError && r.error != null) {
      errors.add((
        sourceId: r.sourceId,
        sourceName: r.sourceName,
        error: r.error!,
      ));
    }
  }
  return MusicListData(tracks: tracks, errors: errors);
});

/// 所有已注册的音乐服务列表（监听 Lx 插件路径变化以触发刷新）
///
/// 委托给 [musicServicesProvider]，额外监听 [lxMetadataPluginPathsProvider]
/// 和 [lxServerConnectionProvider] 以在插件增删或 lx-server 连接变化时自动重新计算。
final musicServicesListProvider = FutureProvider<List<MusicService>>((
  ref,
) async {
  ref.watch(lxMetadataPluginPathsProvider);
  ref.watch(lxServerConnectionProvider);
  return ref.watch(musicServicesProvider.future);
});

/// 当前选中服务的歌单分类列表
///
/// 根据 selectedSourceProvider 找到对应 MusicService，调用 getPlaylistCategories()。
/// 若服务不支持歌单分类，返回空列表。
final playlistCategoriesProvider = FutureProvider<List<PlaylistCategory>>((
  ref,
) async {
  await ref.watch(musicReadyProvider.future);
  final selection = ref.watch(selectedSourceProvider);
  if (selection.sourceId == null) return [];

  final module = ref.watch(musicModuleProvider);
  final service = module?.service(selection.sourceId!);
  if (service == null) return [];

  return service.getPlaylistCategories();
});

/// 当前选中的父分类 id
///
/// 为 null 时显示第一个父分类。仅用于切换子分类列表，不触发歌单查询。
/// 监听 [selectedSourceProvider]，切换来源/库时自动重置为 null，避免选中态与新库不匹配。
class SelectedPlaylistParentNotifier extends Notifier<String?> {
  @override
  String? build() {
    ref.watch(selectedSourceProvider);
    return null;
  }

  void select(String? parentId) => state = parentId;
}

final selectedPlaylistParentProvider =
    NotifierProvider<SelectedPlaylistParentNotifier, String?>(
      SelectedPlaylistParentNotifier.new,
    );

/// 当前选中的子分类 id
///
/// 为 null 时不查询歌单列表。只有点击子分类才会设置此值并触发查询。
/// 监听 [selectedSourceProvider]，切换来源/库时自动重置为 null。
class SelectedPlaylistCategoryNotifier extends Notifier<String?> {
  @override
  String? build() {
    ref.watch(selectedSourceProvider);
    return null;
  }

  void select(String? categoryId) => state = categoryId;
}

final selectedPlaylistCategoryProvider =
    NotifierProvider<SelectedPlaylistCategoryNotifier, String?>(
      SelectedPlaylistCategoryNotifier.new,
    );

/// 当前选中的歌单排序方式 id
///
/// 为 null 时使用默认排序。
/// 监听 [selectedSourceProvider]，切换来源/库时自动重置为 null。
class SelectedPlaylistSortNotifier extends Notifier<String?> {
  @override
  String? build() {
    ref.watch(selectedSourceProvider);
    return null;
  }

  void select(String? sortId) => state = sortId;
}

final selectedPlaylistSortProvider =
    NotifierProvider<SelectedPlaylistSortNotifier, String?>(
      SelectedPlaylistSortNotifier.new,
    );

/// 当前选中服务的歌单排序方式列表
final playlistSortOrdersProvider =
    FutureProvider<List<({String id, String name})>>((ref) async {
      await ref.watch(musicReadyProvider.future);
      final selection = ref.watch(selectedSourceProvider);
      if (selection.sourceId == null) return [];

      final module = ref.watch(musicModuleProvider);
      final service = module?.service(selection.sourceId!);
      if (service == null) return [];

      return service.getPlaylistSortOrders();
    });

/// 当前选中分类下的歌单列表
final playlistsByCategoryProvider =
    FutureProvider<PaginationResponse<Playlist>>((ref) async {
      await ref.watch(musicReadyProvider.future);
      final selection = ref.watch(selectedSourceProvider);
      final categoryId = ref.watch(selectedPlaylistCategoryProvider);
      final sortId = ref.watch(selectedPlaylistSortProvider);
      if (selection.sourceId == null || categoryId == null) {
        return PaginationResponse.empty();
      }

      final module = ref.watch(musicModuleProvider);
      final service = module?.service(selection.sourceId!);
      if (service == null) return PaginationResponse.empty();

      return service.getPlaylistsByCategory(categoryId, sortId: sortId);
    });

/// 当前选中服务的排行榜列表
final leaderboardsProvider = FutureProvider<List<Leaderboard>>((ref) async {
  await ref.watch(musicReadyProvider.future);
  final selection = ref.watch(selectedSourceProvider);
  if (selection.sourceId == null) return [];

  final module = ref.watch(musicModuleProvider);
  final service = module?.service(selection.sourceId!);
  if (service == null) return [];

  return service.getBoards();
});

/// 当前选中的排行榜 id
///
/// 为 null 时默认选中第一个排行榜。
/// 监听 [selectedSourceProvider]，切换来源/库时自动重置为 null，避免选中态与新库不匹配。
class SelectedLeaderboardNotifier extends Notifier<String?> {
  @override
  String? build() {
    ref.watch(selectedSourceProvider);
    return null;
  }

  void select(String? id) => state = id;
}

final selectedLeaderboardProvider =
    NotifierProvider<SelectedLeaderboardNotifier, String?>(
      SelectedLeaderboardNotifier.new,
    );

/// 指定排行榜的曲目列表
final leaderboardTracksProvider = FutureProvider.family<List<Track>, String>((
  ref,
  leaderboardId,
) async {
  await ref.watch(musicReadyProvider.future);
  final selection = ref.watch(selectedSourceProvider);
  if (selection.sourceId == null) return [];

  final module = ref.watch(musicModuleProvider);
  final service = module?.service(selection.sourceId!);
  if (service == null) return [];

  return service.getLeaderboardTracks(leaderboardId);
});

/// 搜索结果数据：合并后的曲目列表 + 出错的服务
class SearchListData {
  final List<MergedTrack> tracks;
  final List<({String sourceId, String sourceName, Object error})> errors;

  const SearchListData({this.tracks = const [], this.errors = const []});
}

/// 搜索结果 Provider（按关键词 + sourceId 过滤）
///
/// sourceId 为 null 时搜索全部来源，否则仅搜索指定来源。
final searchResultsProvider =
    FutureProvider.family<
      SearchListData,
      ({String keyword, String? sourceId, String? libraryId})
    >((ref, params) async {
      await ref.watch(musicReadyProvider.future);
      final services = await ref.watch(musicServicesProvider.future);

      Iterable<MusicService> targets = services;
      if (params.sourceId != null) {
        final module = ref.watch(musicModuleProvider);
        final s = module?.service(params.sourceId!);
        targets = s != null ? [s] : [];
      }

      if (targets.isEmpty) return const SearchListData();

      final results = await safeCallServices<PaginationResponse<Track>>(
        targets.toList(),
        (s) => (s as MusicService).searchTracks(params.keyword),
        getId: (s) => (s as MusicService).sourceId,
        getName: (s) => (s as MusicService).sourceName,
      );

      final allTracks = <Track>[];
      final errors = <({String sourceId, String sourceName, Object error})>[];
      for (final r in results) {
        if (r.isSuccess && r.data != null) {
          allTracks.addAll(r.data!.items);
        } else if (r.isError && r.error != null) {
          errors.add((
            sourceId: r.sourceId,
            sourceName: r.sourceName,
            error: r.error!,
          ));
        }
      }

      return SearchListData(tracks: mergeTracks(allTracks), errors: errors);
    });
