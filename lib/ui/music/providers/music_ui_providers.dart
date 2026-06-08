import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/module/module_manager.dart';
import 'package:pomelo/core/storage/settings.dart';
import 'package:pomelo/modules/music/music_module.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/modules/music_sdk/model/song.dart';

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

/// 获取当前来源的歌曲列表
final currentSourceSongsProvider = FutureProvider<List<Song>>((ref) async {
  final sourceId = ref.watch(selectedSourceProvider);

  final providers = await ref.watch(musicProvidersProvider.future);

  if (sourceId == null) {
    // 全部来源: 从所有 provider 获取
    final results = await Future.wait(providers.map((p) => p.getSongs()));
    return results.expand((r) => r.items).toList();
  }

  final module = ModuleManager().find<MusicModule>('music');
  final provider = module?.provider(sourceId);
  if (provider == null) return [];
  final result = await provider.getSongs();
  return result.items;
});
