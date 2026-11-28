import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_store.dart';

/// 控制中心 / 锁屏媒体卡是否显示歌词，以及歌词占据哪个位置。
///
/// 仅 iOS 生效（Android 通知栏的媒体卡由系统布局决定，不适用）。
/// - [off]：不显示歌词，正常显示「歌名」「歌手」。
/// - [title]：歌名位置显示当前歌词，歌手位置显示「歌名 - 歌手」。
/// - [artist]：歌手位置显示当前歌词，歌名位置显示「歌名 - 歌手」。
enum LockScreenLyricMode {
  off('关闭'),
  title('显示在歌名位置'),
  artist('显示在歌手位置');

  const LockScreenLyricMode(this.label);

  final String label;

  static LockScreenLyricMode fromName(String? name) => LockScreenLyricMode
      .values
      .firstWhere((m) => m.name == name, orElse: () => LockScreenLyricMode.off);
}

final lockScreenLyricModeProvider =
    NotifierProvider<LockScreenLyricModeNotifier, LockScreenLyricMode>(
      LockScreenLyricModeNotifier.new,
    );

class LockScreenLyricModeNotifier extends Notifier<LockScreenLyricMode> {
  static const String _key = 'lockScreenLyricMode';

  @override
  LockScreenLyricMode build() => LockScreenLyricMode.fromName(
    ref.watch(settingsStoreProvider).read<String>(_key),
  );

  Future<void> set(LockScreenLyricMode mode) async {
    if (mode == state) return;
    state = mode;
    await ref.read(settingsStoreProvider).patch({_key: mode.name});
  }
}
