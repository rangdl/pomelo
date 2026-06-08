import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/module/module_manager.dart';
import 'package:pomelo/modules/music/music_module.dart';
import '../model/music_provider.dart';

/// 检查所有音乐模块是否已就绪（自动触发懒加载）
final musicReadyProvider = FutureProvider<bool>((ref) async {
  final mm = ModuleManager();
  if (!mm.modules.containsKey('music')) return false;
  await mm.lazyInit('music');
  await mm.lazyInit('music_local');
  if (mm.modules.containsKey('music_lx')) {
    await mm.lazyInit('music_lx');
  }
  return true;
});

/// 持有 MusicModule 实例的 Provider
final musicModuleProvider = Provider<MusicModule?>((ref) {
  final mm = ModuleManager();
  return mm.find<MusicModule>('music');
});

/// 所有注册的 MusicProvider 列表（自动触发懒加载）
final musicProvidersProvider = FutureProvider<List<MusicProvider>>((ref) async {
  await ref.watch(musicReadyProvider.future);
  return ref.watch(musicModuleProvider)?.providers ?? [];
});

/// 根据 sourceId 获取特定 MusicProvider
final musicProviderBySourceProvider = Provider.family<MusicProvider?, String>((
  ref,
  sourceId,
) {
  final module = ref.watch(musicModuleProvider);
  return module?.provider(sourceId);
});

/// 按分类分组的所有 MusicProvider
///
/// 返回 Map，key 为类别标识，value 为Provider列表。
final musicProvidersByCategoryProvider =
    FutureProvider<Map<String, List<MusicProvider>>>((ref) async {
      await ref.watch(musicReadyProvider.future);
      final module = ref.watch(musicModuleProvider);
      return module?.providersByCategory() ?? {};
    });

/// 所有已注册的分类列表
final musicCategoriesProvider =
    FutureProvider<List<({String id, String name})>>((ref) async {
      await ref.watch(musicReadyProvider.future);
      final module = ref.watch(musicModuleProvider);
      return module?.categories ?? [];
    });
