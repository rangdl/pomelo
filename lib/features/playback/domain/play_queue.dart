import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 播放队列。
class PlayQueue extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() => const [];

  /// 替换整个队列并定位到 [index]。
  void setAll(List<Map<String, dynamic>> items, {int index = 0}) {
    state = List.unmodifiable(items);
    _index = index.clamp(0, items.isEmpty ? 0 : items.length - 1);
  }

  int _index = 0;
  int get index => _index;

  Map<String, dynamic>? get current =>
      (state.isEmpty || _index < 0 || _index >= state.length)
      ? null
      : state[_index];

  void jumpTo(int index) {
    if (state.isEmpty) return;
    _index = index.clamp(0, state.length - 1);
    // state 引用不变不会触发监听，故复制一份列表
    state = List.unmodifiable(state);
  }

  void clear() {
    state = const [];
    _index = 0;
  }
}
