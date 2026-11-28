import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/settings/playback_resilience.dart';
import '../../../shared/settings/settings_store.dart';

/// 一条兜底链：某个音源 key 下，按优先级排列的插件 id。
///
/// 未配置的 key 回落到 [defaultKey] 那条链；再没有就按插件安装顺序兜底。
const String kDefaultChainKey = 'default';

/// 兜底链配置：音源 key → 有序插件 id 列表。
class FallbackChains {
  const FallbackChains(this.chains);

  final Map<String, List<String>> chains;

  List<String> chainFor(String sourceKey) =>
      chains[sourceKey] ?? chains[kDefaultChainKey] ?? const [];

  FallbackChains withChain(String key, List<String> ids) {
    final next = Map<String, List<String>>.from(chains);
    if (ids.isEmpty) {
      next.remove(key);
    } else {
      next[key] = ids;
    }
    return FallbackChains(next);
  }

  static FallbackChains fromStore(SettingsStore store) {
    final raw = store.read<Map>('fallbackChains');
    if (raw == null) return const FallbackChains({});
    final parsed = <String, List<String>>{};
    for (final entry in raw.entries) {
      final list = entry.value;
      if (list is List) {
        parsed['${entry.key}'] = list.map((e) => '$e').toList();
      }
    }
    return FallbackChains(parsed);
  }

  Map<String, dynamic> toJson() => chains;
}

final fallbackChainsInitializerProvider = Provider<FallbackChains>(
  (ref) => const FallbackChains({}),
);

class FallbackChainsNotifier extends Notifier<FallbackChains> {
  @override
  FallbackChains build() => ref.watch(fallbackChainsInitializerProvider);

  Future<void> setChain(String key, List<String> ids) async {
    state = state.withChain(key, ids);
    await ref.read(settingsStoreProvider).patch({
      'fallbackChains': state.toJson(),
    });
  }
}

final fallbackChainsProvider =
    NotifierProvider<FallbackChainsNotifier, FallbackChains>(
      FallbackChainsNotifier.new,
    );

/// 熔断状态：`插件id|音源key` → 失败次数 / 熔断截止时间。
class BreakerKey {
  const BreakerKey(this.pluginId, this.sourceKey);

  final String pluginId;
  final String sourceKey;

  String get id => '$pluginId|$sourceKey';

  @override
  bool operator ==(Object other) =>
      other is BreakerKey &&
      other.pluginId == pluginId &&
      other.sourceKey == sourceKey;

  @override
  int get hashCode => Object.hash(pluginId, sourceKey);
}

/// 单个插件+音源组合的熔断状态。
class BreakerState {
  BreakerState({this.failures = 0, this.openUntil});

  /// 连续失败次数（成功一次即清零）。
  int failures;

  /// 熔断截止时间；非空且未到期期间跳过该插件。
  DateTime? openUntil;

  bool isOpen(DateTime now) => openUntil != null && now.isBefore(openUntil!);

  Duration remaining(DateTime now) {
    if (openUntil == null) return Duration.zero;
    final left = openUntil!.difference(now);
    return left.isNegative ? Duration.zero : left;
  }
}

/// 插件取链熔断器。
///
/// 只在「取链失败」时计数；成功一次立即恢复。状态仅存内存，
/// 重启清零——用户主动重启后不该继续等冷却。
class CircuitBreaker {
  CircuitBreaker(this._config);

  CircuitBreakerConfig _config;
  final Map<String, BreakerState> _states = {};

  /// 状态变化回调，用于界面刷新（插件页显示剩余冷却时间）。
  final ValueNotifier<int> revision = ValueNotifier(0);

  CircuitBreakerConfig get config => _config;

  set config(CircuitBreakerConfig next) {
    _config = next;
    revision.value++;
  }

  BreakerState stateOf(BreakerKey key) => _states[key.id] ?? BreakerState();

  /// 该组合此刻是否应当跳过（处于熔断冷却期内）。
  bool shouldSkip(BreakerKey key, {DateTime? now}) {
    final s = _states[key.id];
    if (s == null || s.openUntil == null) return false;
    final t = now ?? DateTime.now();
    if (t.isBefore(s.openUntil!)) return true;
    // 冷却到期：放行一次试探，失败计数保留（下次失败会立刻再次熔断）。
    s.openUntil = null;
    return false;
  }

  /// 记录一次失败；达到阈值即开始冷却。
  void recordFailure(BreakerKey key, {DateTime? now}) {
    final s = _states.putIfAbsent(key.id, BreakerState.new);
    s.failures++;
    if (s.failures >= _config.failureThreshold) {
      final t = now ?? DateTime.now();
      s.openUntil = t.add(_config.cooldown);
      debugPrint(
        '[pomelo] 熔断 ${key.id}：连续失败 ${s.failures} 次，'
        '冷却至 ${s.openUntil}',
      );
    }
    revision.value++;
  }

  /// 记录一次成功：清零失败计数并解除熔断。
  void recordSuccess(BreakerKey key) {
    final s = _states[key.id];
    if (s == null) return;
    if (s.failures == 0 && s.openUntil == null) return;
    s.failures = 0;
    s.openUntil = null;
    revision.value++;
  }

  /// 清空全部状态（设置页「重置熔断」用）。
  void reset() {
    _states.clear();
    revision.value++;
  }
}

final circuitBreakerProvider = Provider<CircuitBreaker>((ref) {
  final breaker = CircuitBreaker(ref.read(circuitBreakerConfigProvider));
  ref.listen(circuitBreakerConfigProvider, (_, next) => breaker.config = next);
  return breaker;
});
