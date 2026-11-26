import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/settings/settings_store.dart';
import '../data/plugin_repository.dart';
import '../domain/plugin_record.dart';
import '../runtime/pomelo_plugin_runtime.dart';

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

/// 可搜索的插件。
final searchablePluginsProvider = Provider<List<PluginRecord>>((ref) {
  final list = ref.watch(pluginListProvider).value ?? const [];
  return list
      .where((p) => p.enabled && p.supportedMethods.contains('search'))
      .toList();
});

// ---------------------------------------------------------------------------
// 选择状态
// ---------------------------------------------------------------------------

/// 启动时由 main() 注入上次选中的搜索插件 id。
final selectedSearchPluginInitializerProvider = Provider<String?>(
  (ref) => null,
);

class SelectedSearchPlugin extends Notifier<String?> {
  @override
  String? build() => ref.watch(selectedSearchPluginInitializerProvider);

  void select(String? id) {
    state = id;
    // 持久化：下次启动仍停留在上次选择的插件（测试未注入 store 时忽略）。
    try {
      unawaited(
        ref.read(settingsStoreProvider).patch({'selectedSearchPluginId': id}),
      );
    } catch (_) {
      // 未注入设置存储（如单测）时仅保留内存状态。
    }
  }
}

final selectedSearchPluginProvider =
    NotifierProvider<SelectedSearchPlugin, String?>(SelectedSearchPlugin.new);

// ---------------------------------------------------------------------------
// 运行时
// ---------------------------------------------------------------------------

/// 插件实例闲置多久后回收（每个插件独立 Isolate，不宜长驻）。
const Duration _idleTimeout = Duration(minutes: 10);

/// 插件运行时，按插件 **id** 缓存。
///
/// 不能用 autoDispose：`playItem` 里会先 `ref.read(...future)` 拿实例，
/// 若无其他监听者，provider 会在读取间隙被回收，导致引擎里已加载的
/// `__pluginModule` 丢失（实测报 "not defined"）。
///
/// 用 id 而不是 PluginRecord 对象做 key：插件更新/重装会产生新对象，
/// 旧对象做 key 会让旧引擎永久驻留。安装/更新/删除后调用方只需
/// `ref.invalidate(pluginRuntimeProvider(id))`，旧实例即随 provider 销毁。
final pluginRuntimeProvider =
    FutureProvider.family<PomeloPluginRuntime, String>((ref, pluginId) async {
      final repo = await ref.watch(pluginRepositoryProvider.future);
      final plugin = repo.plugins.where((p) => p.id == pluginId).firstOrNull;
      if (plugin == null) {
        throw StateError('插件不存在或已被移除: $pluginId');
      }
      final rt = await PomeloPluginRuntime.create();
      try {
        await rt.loadPlugin(plugin.source, name: plugin.platform);
      } catch (_) {
        await rt.dispose();
        rethrow;
      }

      // 闲置回收：每个插件独占一个 Isolate，长期驻留会累积内存。
      // 每次调用都重置计时，10 分钟无活动即销毁实例（下次使用会重新加载）。
      Timer? idleTimer;
      void touch() {
        idleTimer?.cancel();
        idleTimer = Timer(_idleTimeout, () {
          if (!ref.mounted) return;
          ref.invalidateSelf();
        });
      }

      rt.onActivity = touch;
      touch();
      ref.onDispose(() {
        idleTimer?.cancel();
        unawaited(rt.dispose());
      });
      return rt;
    });
