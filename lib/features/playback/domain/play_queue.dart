import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/playback_providers.dart';

/// 播放队列。
class PlayQueue extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() {
    // 恢复上次的队列（不含自动播放）。
    final snap = ref.watch(playbackSnapshotInitializerProvider);
    if (snap != null && snap.queue.isNotEmpty) {
      _index = snap.index;
      return List.unmodifiable(snap.queue);
    }
    return const [];
  }

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

  /// 删除指定位置的曲目。删除后修正当前索引，返回「新的当前索引」以便上层
  /// 决定是否需要切换当前播放。
  int removeAt(int index) {
    if (state.isEmpty || index < 0 || index >= state.length) return _index;
    final list = List<Map<String, dynamic>>.from(state)..removeAt(index);
    if (index < _index) {
      _index -= 1;
    } else if (index == _index && _index >= list.length) {
      _index = list.isEmpty ? 0 : list.length - 1;
    }
    state = List.unmodifiable(list);
    return _index;
  }

  void clear() {
    state = const [];
    _index = 0;
  }
}
