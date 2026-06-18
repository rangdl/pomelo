import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/module/module_manager.dart';
import 'package:pomelo/core/storage/settings.dart';
import 'package:pomelo/core/pagination/pagination_response.dart';
import 'package:pomelo/modules/music/music_module.dart';
import 'package:pomelo/modules/music/model/music_service.dart';
import 'package:pomelo/modules/music/model/playlist.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/modules/music/model/song.dart';
import 'package:pomelo/modules/music_local/local_music_providers.dart';
import 'package:pomelo/modules/music_lx/model/lx_music_service.dart';
import 'package:pomelo/ui/music/model/service_result.dart';

import 'package:pomelo/ui/platform/providers/lx_metadata_plugin_paths_provider.dart';

/// 持久化 key
const _kSelectedSource = 'music_selected_source';
const _kSelectedLibrary = 'music_selected_library';

/// 当前选中的音乐来源 sourceId 和 libraryId 的 Notifier
///
/// sourceId 为 null 表示"全部来源"。
/// libraryId 用于多库服务（如 Lx），指定当前使用的库。
/// 选中的来源会自动持久化到 Settings，应用重启后自动恢复。
class SelectedSourceNotifier
    extends Notifier<({String? sourceId, String? libraryId})> {
  @override
  ({String? sourceId, String? libraryId}) build() {
    final savedSource = Settings.get(_kSelectedSource);
    final savedLibrary = Settings.get(_kSelectedLibrary);
    return (
      sourceId: (savedSource != null && savedSource.isNotEmpty)
          ? savedSource
          : null,
      libraryId: (savedLibrary != null && savedLibrary.isNotEmpty)
          ? savedLibrary
          : null,
    );
  }

  void selectAll() {
    state = (sourceId: null, libraryId: null);
    Settings.set(_kSelectedSource, '');
    Settings.set(_kSelectedLibrary, '');
  }

  void select(String sourceId, {String? libraryId}) {
    state = (sourceId: sourceId, libraryId: libraryId);
    Settings.set(_kSelectedSource, sourceId);
    Settings.set(_kSelectedLibrary, libraryId ?? '');
    // 如果选中了多库服务的某个库，更新服务的默认库
    if (libraryId != null) {
      final module = ModuleManager().find<MusicModule>('music');
      final service = module?.service(sourceId);
      if (service is LxMusicService) {
        service.setDefaultLibrary(libraryId);
      }
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

/// 音乐列表数据：歌曲列表 + 出错的服务
class MusicListData {
  final List<Song> songs;
  final List<({String sourceId, String sourceName, Object error})> errors;

  const MusicListData({this.songs = const [], this.errors = const []});
}

/// 获取当前来源的歌曲列表（逐服务隔离异常）
final currentSourceSongsProvider = FutureProvider<MusicListData>((ref) async {
  // 监听本地音乐数据版本，目录/扫描变更后自动刷新歌曲列表
  ref.watch(localMusicVersionProvider);
  final selection = ref.watch(selectedSourceProvider);
  final services = await ref.watch(musicServicesProvider.future);

  Iterable<MusicService> targets = services;
  if (selection.sourceId != null) {
    final module = ModuleManager().find<MusicModule>('music');
    final s = module?.service(selection.sourceId!);
    targets = s != null ? [s] : [];
  }

  if (targets.isEmpty) return const MusicListData();

  final results = await safeCallServices<PaginationResponse<Song>>(
    targets.toList(),
    (s) => (s as MusicService).getSongs(),
    getId: (s) => (s as MusicService).sourceId,
    getName: (s) => (s as MusicService).sourceName,
  );

  final songs = <Song>[];
  final errors = <({String sourceId, String sourceName, Object error})>[];
  for (final r in results) {
    if (r.isSuccess && r.data != null) {
      songs.addAll(r.data!.items);
    } else if (r.isError && r.error != null) {
      errors.add((
        sourceId: r.sourceId,
        sourceName: r.sourceName,
        error: r.error!,
      ));
    }
  }
  return MusicListData(songs: songs, errors: errors);
});

/// 所有已注册的音乐服务列表
final musicServicesListProvider = FutureProvider<List<MusicService>>((
  ref,
) async {
  await ref.watch(musicReadyProvider.future);
  // 监听 lx 元数据插件路径变化，插件增删时触发重新计算
  ref.watch(lxMetadataPluginPathsProvider);
  final module = ModuleManager().find<MusicModule>('music');
  return module?.services ?? [];
});

/// 当前选中服务的歌单分类列表
///
/// 根据 selectedSourceProvider 找到对应 MusicService，调用 getPlaylistCategories()。
/// 若服务不支持歌单分类，返回空列表。
final playlistCategoriesProvider = FutureProvider<List<PlaylistCategory>>(
  (ref) async {
    await ref.watch(musicReadyProvider.future);
    final selection = ref.watch(selectedSourceProvider);
    if (selection.sourceId == null) return [];

    final module = ModuleManager().find<MusicModule>('music');
    final service = module?.service(selection.sourceId!);
    if (service == null) return [];

    return service.getPlaylistCategories();
  },
);

/// 当前选中的父分类 id
///
/// 为 null 时显示第一个父分类。仅用于切换子分类列表，不触发歌单查询。
class SelectedPlaylistParentNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? parentId) => state = parentId;
}

final selectedPlaylistParentProvider =
    NotifierProvider<SelectedPlaylistParentNotifier, String?>(
  SelectedPlaylistParentNotifier.new,
);

/// 当前选中的子分类 id
///
/// 为 null 时不查询歌单列表。只有点击子分类才会设置此值并触发查询。
class SelectedPlaylistCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? categoryId) => state = categoryId;
}

final selectedPlaylistCategoryProvider =
    NotifierProvider<SelectedPlaylistCategoryNotifier, String?>(
  SelectedPlaylistCategoryNotifier.new,
);

/// 当前选中分类下的歌单列表
final playlistsByCategoryProvider =
    FutureProvider<PaginationResponse<Playlist>>((ref) async {
  await ref.watch(musicReadyProvider.future);
  final selection = ref.watch(selectedSourceProvider);
  final categoryId = ref.watch(selectedPlaylistCategoryProvider);
  if (selection.sourceId == null || categoryId == null) {
    return PaginationResponse.empty();
  }

  final module = ModuleManager().find<MusicModule>('music');
  final service = module?.service(selection.sourceId!);
  if (service == null) return PaginationResponse.empty();

  return service.getPlaylistsByCategory(categoryId);
});
