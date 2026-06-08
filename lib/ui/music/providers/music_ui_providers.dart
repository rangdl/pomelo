import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/module/module_manager.dart';
import 'package:pomelo/core/storage/settings.dart';
import 'package:pomelo/modules/music/model/pagination_response.dart';
import 'package:pomelo/modules/music/music_module.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/modules/music/model/music_provider.dart';
import 'package:pomelo/modules/music_sdk/model/song.dart';
import 'package:pomelo/ui/music/model/provider_result.dart';

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

/// 音乐列表数据：歌曲列表 + 出错的提供者
class MusicListData {
  final List<Song> songs;
  final List<({String sourceId, String sourceName, Object error})> errors;

  const MusicListData({this.songs = const [], this.errors = const []});
}

/// 获取当前来源的歌曲列表（逐提供者隔离异常）
final currentSourceSongsProvider = FutureProvider<MusicListData>((ref) async {
  final sourceId = ref.watch(selectedSourceProvider);
  final providers = await ref.watch(musicProvidersProvider.future);

  Iterable<MusicProvider> targets = providers;
  if (sourceId != null) {
    final module = ModuleManager().find<MusicModule>('music');
    final p = module?.provider(sourceId);
    targets = p != null ? [p] : [];
  }

  if (targets.isEmpty) return const MusicListData();

  final results = await safeCallProviders<SongPageResult>(
    targets.toList(),
    (p) => (p as MusicProvider).getSongs(),
    getId: (p) => (p as MusicProvider).sourceId,
    getName: (p) => (p as MusicProvider).sourceName,
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
