/// 单个提供者的调用结果
///
/// 记录调用是否成功，失败时携带错误信息。
class ProviderResult<T> {
  /// 提供者标识
  final String sourceId;

  /// 提供者名称
  final String sourceName;

  /// 调用成功时的数据
  final T? data;

  /// 调用失败时的异常
  final Object? error;

  /// 是否成功
  bool get isSuccess => error == null;

  /// 是否失败
  bool get isError => error != null;

  const ProviderResult.success({
    required this.sourceId,
    required this.sourceName,
    required this.data,
  }) : error = null;

  const ProviderResult.failure({
    required this.sourceId,
    required this.sourceName,
    required this.error,
  }) : data = null;
}

/// 安全调用多个提供者，每个提供者的异常被独立捕获
///
/// 返回 [ProviderResult] 列表，调用方可分别处理成功/失败的结果。
Future<List<ProviderResult<T>>> safeCallProviders<T>(
  List<dynamic> providers,
  Future<T> Function(dynamic provider) call, {
  String? Function(dynamic provider)? getId,
  String? Function(dynamic provider)? getName,
}) async {
  final results = <ProviderResult<T>>[];
  for (final provider in providers) {
    try {
      final data = await call(provider);
      results.add(
        ProviderResult.success(
          sourceId: getId?.call(provider) ?? '',
          sourceName: getName?.call(provider) ?? '',
          data: data,
        ),
      );
    } catch (e) {
      results.add(
        ProviderResult.failure(
          sourceId: getId?.call(provider) ?? '',
          sourceName: getName?.call(provider) ?? '',
          error: e,
        ),
      );
    }
  }
  return results;
}
