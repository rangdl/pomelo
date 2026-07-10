/// 基于滑动窗口的限流器
///
/// 在指定时间窗口 [period] 内最多允许 [maxRequests] 次请求。
/// 超出时调用 [acquire] 会等待最早请求过期后再放行。
///
/// 典型用途：限制获取播放链接的频率，避免对音源服务造成过大压力。
library;

/// 滑动窗口限流器
class RateLimiter {
  /// 窗口内最大请求数
  final int maxRequests;

  /// 时间窗口
  final Duration period;

  final List<DateTime> _timestamps = [];

  RateLimiter({required this.maxRequests, required this.period});

  /// 获取一个请求许可，超出限流时阻塞等待
  Future<void> acquire() async {
    while (true) {
      final now = DateTime.now();
      _timestamps.removeWhere((t) => now.difference(t) > period);
      if (_timestamps.length < maxRequests) {
        _timestamps.add(now);
        return;
      }
      // 等待最早的时间戳滑出窗口
      final oldest = _timestamps.first;
      final wait = period - now.difference(oldest);
      if (wait > Duration.zero) {
        await Future.delayed(wait);
      }
    }
  }
}

/// 获取播放链接的全局限流器：每秒最多 3 次
final musicUrlRateLimiter = RateLimiter(
  maxRequests: 3,
  period: const Duration(seconds: 1),
);
