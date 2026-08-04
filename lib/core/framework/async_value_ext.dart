/// [AsyncValue] 扩展方法
///
/// 提供 [whenOrDefault] 作为 [AsyncValue.when] 的简化替代方案，
/// 仅需传入 `data` 回调，`loading` 和 `error` 状态使用通用实现。
library;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

extension AsyncValueExt<T> on AsyncValue<T> {
  /// [AsyncValue.when] 的简化版，仅接收 [data] 回调。
  ///
  /// - **loading**: 居中 [CircularProgressIndicator]（可用 [loading] 覆盖）
  /// - **error**: 居中错误文本（`加载失败: $error`，可用 [error] 覆盖）
  /// - **data**: 由调用方提供的 [data] 回调构建
  ///
  /// 适合不需要自定义 loading/error UI 的场景：
  /// ```dart
  /// // 原写法
  /// asyncValue.when(
  ///   data: (data) => MyContent(data: data),
  ///   loading: () => const Center(child: CircularProgressIndicator()),
  ///   error: (e, _) => Center(child: Text('加载失败: $e')),
  /// );
  ///
  /// // 简化写法
  /// asyncValue.whenOrDefault((data) => MyContent(data: data));
  /// ```
  Widget whenOrDefault(
    Widget Function(T data) data, {
    Widget Function()? loading,
    Widget Function(Object error, StackTrace? stackTrace)? error,
  }) {
    return when(
      data: data,
      loading: loading ?? () => const Center(child: CircularProgressIndicator()),
      error: error != null
          ? (e, st) => error(e, st)
          : (e, _) => Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '加载失败: $e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
    );
  }
}
