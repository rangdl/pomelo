import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/module/module_manager.dart';
import 'package:pomelo/core/storage/settings.dart';
import 'package:pomelo/core/pagination/pagination_response.dart';
import 'package:pomelo/modules/music/music_module.dart';
import 'package:pomelo/modules/music/model/music_source.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/modules/music/model/music_service.dart';
import 'package:pomelo/modules/music/model/song.dart';
import 'package:pomelo/modules/music_local/providers/local_music_providers.dart';
import 'package:pomelo/ui/music/model/service_result.dart';

/// 持久化 key
const _kSelectedSource = 'music_selected_source';

/// 当前选中的音乐来源 sourceId 的 Notifier
///
/// null 表示"全部来源"。
/// 选中的来源会自动持久化到 Settings，应用重启后自动恢复。
class SelectedSourceNotifier extends Notifier<String?> {
  @override
  String? build() {
    // 从持久化存储恢复
    final saved = Settings.get(_kSelectedSource);
    return (saved != null && saved.isNotEmpty) ? saved : null;
  }

  void selectAll() {
    state = null;
    Settings.set(_kSelectedSource, '');
  }

  void select(String sourceId) {
    state = sourceId;
    Settings.set(_kSelectedSource, sourceId);
  }
}

/// 当前选中的音乐来源 sourceId
final selectedSourceProvider =
    NotifierProvider<SelectedSourceNotifier, String?>(
      SelectedSourceNotifier.new,
    );

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
  final sourceId = ref.watch(selectedSourceProvider);
  final services = await ref.watch(musicServicesProvider.future);

  Iterable<MusicService> targets = services;
  if (sourceId != null) {
    final module = ModuleManager().find<MusicModule>('music');
    final s = module?.service(sourceId);
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

/// 所有已注册的音乐来源列表
final musicSourcesProvider = FutureProvider<List<MusicSource>>((ref) async {
  await ref.watch(musicReadyProvider.future);
  final module = ModuleManager().find<MusicModule>('music');
  return module?.sources ?? [];
});

/// 按来源类型分组的音乐来源
///
/// 返回 Map，key 为 [MusicSourceType]，value 为该类型下的来源列表。
final musicSourcesByTypeProvider =
    FutureProvider<Map<MusicSourceType, List<MusicSource>>>((ref) async {
  await ref.watch(musicReadyProvider.future);
  final module = ModuleManager().find<MusicModule>('music');
  final sources = module?.sources ?? [];
  final map = <MusicSourceType, List<MusicSource>>{};
  for (final s in sources) {
    map.putIfAbsent(s.type, () => []).add(s);
  }
  return map;
});
