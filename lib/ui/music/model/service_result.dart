/// 单个服务的调用结果
///
/// 记录调用是否成功，失败时携带错误信息。
class ServiceResult<T> {
  /// 服务标识
  final String sourceId;

  /// 服务名称
  final String sourceName;

  /// 调用成功时的数据
  final T? data;

  /// 调用失败时的异常
  final Object? error;

  /// 是否成功
  bool get isSuccess => error == null;

  /// 是否失败
  bool get isError => error != null;

  const ServiceResult.success({
    required this.sourceId,
    required this.sourceName,
    required this.data,
  }) : error = null;

  const ServiceResult.failure({
    required this.sourceId,
    required this.sourceName,
    required this.error,
  }) : data = null;
}

/// 安全调用多个服务，每个服务的异常被独立捕获
///
/// 返回 [ServiceResult] 列表，调用方可分别处理成功/失败的结果。
Future<List<ServiceResult<T>>> safeCallServices<T>(
  List<dynamic> services,
  Future<T> Function(dynamic service) call, {
  String? Function(dynamic service)? getId,
  String? Function(dynamic service)? getName,
}) async {
  final results = <ServiceResult<T>>[];
  for (final service in services) {
    try {
      final data = await call(service);
      results.add(
        ServiceResult.success(
          sourceId: getId?.call(service) ?? '',
          sourceName: getName?.call(service) ?? '',
          data: data,
        ),
      );
    } catch (e) {
      results.add(
        ServiceResult.failure(
          sourceId: getId?.call(service) ?? '',
          sourceName: getName?.call(service) ?? '',
          error: e,
        ),
      );
    }
  }
  return results;
}
