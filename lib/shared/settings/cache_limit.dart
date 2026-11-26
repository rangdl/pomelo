import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/playback/data/media_proxy_server.dart';
import 'settings_store.dart';

/// 缓存上限选项（0 表示不限制）。
enum CacheLimitOption {
  unlimited(0, '不限制'),
  mb256(256, '256 MB'),
  mb512(512, '512 MB'),
  gb1(1024, '1 GB'),
  gb2(2048, '2 GB');

  const CacheLimitOption(this.megabytes, this.label);

  final int megabytes;
  final String label;

  int get bytes => megabytes * 1024 * 1024;
}

/// 启动时由 main() 注入已保存的上限，供 Notifier 初始化。
final cacheLimitInitializerProvider = Provider<CacheLimitOption>(
  (ref) => CacheLimitOption.unlimited,
);

class CacheLimitNotifier extends Notifier<CacheLimitOption> {
  @override
  CacheLimitOption build() => ref.watch(cacheLimitInitializerProvider);

  Future<void> set(CacheLimitOption option) async {
    if (option == state) return;
    state = option;
    final server = MediaProxyServer.instance;
    if (server != null) {
      server.maxCacheBytes = option.bytes;
      unawaited(server.enforceLimit());
    }
    await ref.read(settingsStoreProvider).patch({
      'cacheLimitMb': option.megabytes,
    });
  }
}

final cacheLimitProvider =
    NotifierProvider<CacheLimitNotifier, CacheLimitOption>(
      CacheLimitNotifier.new,
    );

/// 从设置里还原缓存上限。
CacheLimitOption cacheLimitFromStore(SettingsStore store) {
  final mb = store.read<int>('cacheLimitMb') ?? 0;
  return CacheLimitOption.values.firstWhere(
    (option) => option.megabytes == mb,
    orElse: () => CacheLimitOption.unlimited,
  );
}
