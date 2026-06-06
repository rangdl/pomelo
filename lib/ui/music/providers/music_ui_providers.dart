import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/module/module_manager.dart';
import 'package:pomelo/modules/music/music_module.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/modules/music_sdk/model/song.dart';

/// 当前选中的音乐来源 sourceId 的 Notifier
///
/// null 表示"全部来源"。
class SelectedSourceNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void selectAll() => state = null;
  void select(String sourceId) => state = sourceId;
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
