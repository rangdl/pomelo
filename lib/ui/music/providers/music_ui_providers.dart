import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/preferences/user_preference_provider.dart';
import 'package:pomelo/core/pagination/pagination_response.dart';
import 'package:pomelo/modules/music/model/music_source_type.dart';
import 'package:pomelo/modules/music/model/music_server.dart';
import 'package:pomelo/modules/music/model/playlist.dart';
import 'package:pomelo/modules/music/model/leaderboard.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/modules/music/model/track.dart';
import 'package:pomelo/modules/music_local/local_music_providers.dart';
import 'package:pomelo/core/service_result.dart';
import 'package:pomelo/ui/music/model/merged_track.dart';

/// 按来源类型分组服务
Map<MusicSourceType, List<MusicServer>> groupServicesByType(
  List<MusicServer> services,
) {
  final byType = <MusicSourceType, List<MusicServer>>{};
  for (final s in services) {
    byType.putIfAbsent(s.sourceType, () => []).add(s);
  }
  return byType;
}

/// 当前选中的音乐来源 sourceId 和 libraryId 的 Notifier
///
/// sourceId 为 null 表示"全部来源"。
/// libraryId 用于多库服务（如 Lx），指定当前使用的库。
/// 选中的来源自动持久化到 UserPreference，应用重启后自动恢复。
class SelectedSourceNotifier
    extends Notifier<({String? sourceId, String? libraryId})> {
  @override
  ({String? sourceId, String? libraryId}) build() {
    final pref = ref.watch(userPreferenceProvider);
    final initialState = (
      sourceId: pref.selectedSourceId,
      libraryId: pref.selectedLibraryId,
    );

    // 应用持久化的库选择：
    // 监听对应 sourceId 的 MusicServer，当其加载完成时应用持久化的 libraryId。
    if (initialState.sourceId != null && initialState.libraryId != null) {
      ref.listen<MusicServer?>(
        musicServerBySourceProvider(initialState.sourceId!),
        (prev, next) {
          if (next != null && prev == null) {
            next.setDefaultLibrary(initialState.libraryId!);
          }
        },
      );
      // 兜底：若服务在 build 前已就绪
      final server = ref.read(
        musicServerBySourceProvider(initialState.sourceId!),
      );
      if (server != null) {
        server.setDefaultLibrary(initialState.libraryId!);
      }
    }

    return initialState;
  }

  void selectAll() {
    state = (sourceId: null, libraryId: null);
    ref.read(userPreferenceProvider.notifier).clearSelectedSource();
  }

  void select(String sourceId, {String? libraryId}) {
    state = (sourceId: sourceId, libraryId: libraryId);
    ref
        .read(userPreferenceProvider.notifier)
        .selectSource(sourceId, libraryId: libraryId);
    // 如果选中了多库服务的某个库，更新服务的默认库
    if (libraryId != null) {
      final service = ref.read(musicServerBySourceProvider(sourceId));
      service?.setDefaultLibrary(libraryId);
    }
  }
}

/// 当前选中的音乐来源
///
/// 返回 `(sourceId, libraryId)` 记录，sourceId 为 null 表示"全部来源"。
final selectedSourceProvider = NotifierProvider<
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
  final services = await ref.watch(musicServersProvider.future);

  Iterable<MusicServer> targets = services;
  if (selection.sourceId != null) {
    final s = ref.watch(musicServerBySourceProvider(selection.sourceId!));
    targets = s != null ? [s] : [];
  }

  if (targets.isEmpty) return const MusicListData();

  final results = await safeCallServices<PaginationResponse<Track>>(
    targets.toList(),
    (s) => (s as MusicServer).getTracks(),
    getId: (s) => (s as MusicServer).sourceId,
    getName: (s) => (s as MusicServer).sourceName,
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

/// 当前选中的单个音乐服务（null 表示"全部来源"或服务未就绪）
///
/// 集中处理"选中来源 → 服务实例"逻辑，消除各 FutureProvider 的样板代码。
/// 依赖 [selectedSourceProvider] 与 [musicServersProvider]，任一变化时自动重建。
final currentMusicServerProvider = FutureProvider<MusicServer?>((ref) async {
  final selection = ref.watch(selectedSourceProvider);
  if (selection.sourceId == null) return null;
  await ref.watch(musicServersProvider.future);
  return ref.watch(musicServerBySourceProvider(selection.sourceId!));
});

/// 当前选中服务的歌单分类列表
///
/// 根据 selectedSourceProvider 找到对应 MusicServer，调用 getPlaylistCategories()。
/// 若服务不支持歌单分类，返回空列表。
final playlistCategoriesProvider = FutureProvider<List<PlaylistCategory>>((
  ref,
) async {
  final service = await ref.watch(currentMusicServerProvider.future);
  if (service == null) return [];
  return service.getPlaylistCategories();
});

/// 切换音乐来源/库时自动重置为 null 的选中态 Notifier 基类
///
/// 监听 [selectedSourceProvider]，确保切换来源/库时选中态自动清空，
/// 避免选中态与新库不匹配。子类只需声明空类体即可获得此能力与 `select` 方法。
abstract class SourceBoundSelectionNotifier extends Notifier<String?> {
  @override
  String? build() {
    ref.watch(selectedSourceProvider);
    return null;
  }

  void select(String? id) => state = id;
}

/// 当前选中的父分类 id
///
/// 为 null 时显示第一个父分类。仅用于切换子分类列表，不触发歌单查询。
class SelectedPlaylistParentNotifier extends SourceBoundSelectionNotifier {}

final selectedPlaylistParentProvider = NotifierProvider<
  SelectedPlaylistParentNotifier,
  String?
>(SelectedPlaylistParentNotifier.new);

/// 当前选中的子分类 id
///
/// 为 null 时不查询歌单列表。只有点击子分类才会设置此值并触发查询。
class SelectedPlaylistCategoryNotifier extends SourceBoundSelectionNotifier {}

final selectedPlaylistCategoryProvider = NotifierProvider<
  SelectedPlaylistCategoryNotifier,
  String?
>(SelectedPlaylistCategoryNotifier.new);

/// 当前选中的歌单排序方式 id
///
/// 为 null 时使用默认排序。
class SelectedPlaylistSortNotifier extends SourceBoundSelectionNotifier {}

final selectedPlaylistSortProvider = NotifierProvider<
  SelectedPlaylistSortNotifier,
  String?
>(SelectedPlaylistSortNotifier.new);

/// 当前选中服务的歌单排序方式列表
final playlistSortOrdersProvider = FutureProvider<List<({String id, String name})>>((
  ref,
) async {
  final service = await ref.watch(currentMusicServerProvider.future);
  if (service == null) return [];
  return service.getPlaylistSortOrders();
});

/// 当前选中分类下的歌单列表
final playlistsByCategoryProvider = FutureProvider<PaginationResponse<Playlist>>((
  ref,
) async {
  final categoryId = ref.watch(selectedPlaylistCategoryProvider);
  final sortId = ref.watch(selectedPlaylistSortProvider);
  if (categoryId == null) return PaginationResponse.empty();

  final service = await ref.watch(currentMusicServerProvider.future);
  if (service == null) return PaginationResponse.empty();

  return service.getPlaylistsByCategory(categoryId, sortId: sortId);
});

/// 当前选中服务的排行榜列表
final leaderboardsProvider = FutureProvider<List<Leaderboard>>((ref) async {
  final service = await ref.watch(currentMusicServerProvider.future);
  if (service == null) return [];
  return service.getBoards();
});

/// 当前选中的排行榜 id
///
/// 为 null 时默认选中第一个排行榜。
class SelectedLeaderboardNotifier extends SourceBoundSelectionNotifier {}

final selectedLeaderboardProvider = NotifierProvider<
  SelectedLeaderboardNotifier,
  String?
>(SelectedLeaderboardNotifier.new);

/// 指定排行榜的曲目列表
final leaderboardTracksProvider = FutureProvider.family<List<Track>, String>((
  ref,
  leaderboardId,
) async {
  final service = await ref.watch(currentMusicServerProvider.future);
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
final searchResultsProvider = FutureProvider.family<
  SearchListData,
  ({String keyword, String? sourceId, String? libraryId})
>((ref, params) async {
  final services = await ref.watch(musicServersProvider.future);

  Iterable<MusicServer> targets = services;
  if (params.sourceId != null) {
    final s = ref.watch(musicServerBySourceProvider(params.sourceId!));
    targets = s != null ? [s] : [];
  }

  if (targets.isEmpty) return const SearchListData();

  final results = await safeCallServices<PaginationResponse<Track>>(
    targets.toList(),
    (s) => (s as MusicServer).searchTracks(params.keyword),
    getId: (s) => (s as MusicServer).sourceId,
    getName: (s) => (s as MusicServer).sourceName,
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
