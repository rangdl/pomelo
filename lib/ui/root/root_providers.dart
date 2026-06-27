import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 当前激活的 Tab 索引。
///
/// 由 Root 布局在 Tab 切换时更新，各 Tab 页面通过 watch 此 Provider
/// 判断自身是否处于激活状态，从而正确设置/清除内联导航状态。
final activeTabIndexProvider =
    NotifierProvider<_ActiveTabIndexNotifier, int>(
  _ActiveTabIndexNotifier.new,
);

class _ActiveTabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int value) => state = value;
}

/// 当前 Tab 是否存在可返回的内联导航（如首页内联查看歌单详情）。
///
/// 桌面端标题栏的返回按钮通过此 Provider 判断是否激活。
/// 各 Tab 页面在进入内联子页面时调用 `set(true)` 并注册回调，
/// 退出时调用 `set(false)` 清除回调。
final rootCanPopProvider = NotifierProvider<_RootCanPopNotifier, bool>(
  _RootCanPopNotifier.new,
);

class _RootCanPopNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

/// 当前 Tab 内联导航的返回回调。
///
/// 当 [rootCanPopProvider] 为 true 时，标题栏返回按钮调用此回调。
final rootPopCallbackProvider =
    NotifierProvider<_RootPopCallbackNotifier, VoidCallback?>(
  _RootPopCallbackNotifier.new,
);

class _RootPopCallbackNotifier extends Notifier<VoidCallback?> {
  @override
  VoidCallback? build() => null;

  void set(VoidCallback? callback) => state = callback;
}
