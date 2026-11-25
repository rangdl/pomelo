import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/plugin_repository.dart';
import '../domain/plugin_record.dart';
import '../runtime/lx_runtime.dart';
import '../runtime/musicfree_runtime.dart';

// ---------------------------------------------------------------------------
// 仓库与列表
// ---------------------------------------------------------------------------

/// 插件仓库（异步初始化，整个应用共享一份）。
final pluginRepositoryProvider = FutureProvider<PluginRepository>((ref) async {
  return PluginRepository.open();
});

/// 已安装插件列表。仓库发生变更后由调用方 `ref.invalidate` 刷新。
final pluginListProvider = FutureProvider<List<PluginRecord>>((ref) async {
  final repo = await ref.watch(pluginRepositoryProvider.future);
  return repo.plugins;
});

/// 可搜索的 MusicFree 插件。
final searchablePluginsProvider = Provider<List<PluginRecord>>((ref) {
  final list = ref.watch(pluginListProvider).value ?? const [];
  return list
      .where(
        (p) =>
            p.isMusicFree && p.enabled && p.supportedMethods.contains('search'),
      )
      .toList();
});

/// 已启用的 LX 插件。
final lxPluginsProvider = Provider<List<PluginRecord>>((ref) {
  final list = ref.watch(pluginListProvider).value ?? const [];
  return list.where((p) => p.isLx && p.enabled).toList();
});

// ---------------------------------------------------------------------------
// 选择状态
// ---------------------------------------------------------------------------

class SelectedSearchPlugin extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

final selectedSearchPluginProvider =
    NotifierProvider<SelectedSearchPlugin, String?>(SelectedSearchPlugin.new);

class SelectedLxPlugin extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

final selectedLxPluginProvider = NotifierProvider<SelectedLxPlugin, String?>(
  SelectedLxPlugin.new,
);

// ---------------------------------------------------------------------------
// 运行时
// ---------------------------------------------------------------------------

/// MusicFree 运行时，按插件区分。
///
/// 注意不能用 autoDispose：`playItem` 里会先 `ref.read(...future)` 拿实例，
/// 若无其他监听者，provider 会在读取间隙被回收，导致引擎里已加载的
/// `__pluginModule` 丢失（实测报 "not defined"）。
final musicFreeRuntimeProvider =
    FutureProvider.family<MusicFreeRuntime, PluginRecord>((ref, plugin) async {
      final rt = await MusicFreeRuntime.create();
      try {
        rt.loadPlugin(plugin.source, name: plugin.platform);
      } catch (_) {
        rt.dispose();
        rethrow;
      }
      ref.onDispose(rt.dispose);
      return rt;
    });

/// LX 运行时，加载后自动等待脚本 inited。同样不能用 autoDispose。
final lxRuntimeProvider = FutureProvider.family<LxUserApiRuntime, PluginRecord>(
  (ref, plugin) async {
    final rt = await LxUserApiRuntime.create();
    try {
      rt.loadScript(plugin.source, id: plugin.id, name: plugin.platform);
      final ok = await rt.waitForInit();
      if (!ok) {
        throw StateError('LX 脚本初始化失败: ${rt.initError ?? "未知原因"}');
      }
    } catch (_) {
      rt.dispose();
      rethrow;
    }
    ref.onDispose(rt.dispose);
    return rt;
  },
);
