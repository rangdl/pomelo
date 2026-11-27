import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_store.dart';

/// 点击歌曲播放后是否自动进入播放页（默认开启，保持原有行为）。
///
/// 直接懒读 settings.json，无需在 main() 里注入初值；写入即持久化。
final openPlayerOnPlayProvider =
    NotifierProvider<OpenPlayerOnPlayNotifier, bool>(
      OpenPlayerOnPlayNotifier.new,
    );

class OpenPlayerOnPlayNotifier extends Notifier<bool> {
  static const String _key = 'openPlayerOnPlay';

  @override
  bool build() => ref.watch(settingsStoreProvider).read<bool>(_key) ?? true;

  Future<void> set(bool value) async {
    if (value == state) return;
    state = value;
    await ref.read(settingsStoreProvider).patch({_key: value});
  }
}
