import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_store.dart';

/// 插件取链失败后的熔断策略。
///
/// 粒度是「插件 × 音源 key」：聚合插件可能 kg 挂了但 kw 还正常。
/// 计时用墙钟而非播放进度——语义是「这段时间内别再打这个插件了」。
class CircuitBreakerConfig {
  const CircuitBreakerConfig({
    this.failureThreshold = 3,
    this.cooldownMinutes = 10,
  });

  /// 连续失败多少次后熔断（1–10）。
  final int failureThreshold;

  /// 熔断后冷却多少分钟（1–60）。
  final int cooldownMinutes;

  Duration get cooldown => Duration(minutes: cooldownMinutes);

  CircuitBreakerConfig copyWith({int? failureThreshold, int? cooldownMinutes}) {
    return CircuitBreakerConfig(
      failureThreshold: failureThreshold ?? this.failureThreshold,
      cooldownMinutes: cooldownMinutes ?? this.cooldownMinutes,
    );
  }

  static CircuitBreakerConfig fromStore(SettingsStore store) {
    final threshold = store.read<int>('breakerThreshold') ?? 3;
    final minutes = store.read<int>('breakerCooldownMinutes') ?? 10;
    return CircuitBreakerConfig(
      failureThreshold: threshold.clamp(1, 10),
      cooldownMinutes: minutes.clamp(1, 60),
    );
  }
}

final circuitBreakerInitializerProvider = Provider<CircuitBreakerConfig>(
  (ref) => const CircuitBreakerConfig(),
);

class CircuitBreakerConfigNotifier extends Notifier<CircuitBreakerConfig> {
  @override
  CircuitBreakerConfig build() => ref.watch(circuitBreakerInitializerProvider);

  Future<void> set(CircuitBreakerConfig config) async {
    state = config;
    await ref.read(settingsStoreProvider).patch({
      'breakerThreshold': config.failureThreshold,
      'breakerCooldownMinutes': config.cooldownMinutes,
    });
  }
}

final circuitBreakerConfigProvider =
    NotifierProvider<CircuitBreakerConfigNotifier, CircuitBreakerConfig>(
      CircuitBreakerConfigNotifier.new,
    );

/// 顺序播放时，连续多少首取链失败就停止。
///
/// 0 表示不自动跳下一首（取链失败直接暂停）；不可关闭，只能调数值。
class ConsecutiveFailureLimit {
  const ConsecutiveFailureLimit(this.value);

  /// 0–10；0 = 不跳下一首。
  final int value;

  bool get stopImmediately => value == 0;

  static ConsecutiveFailureLimit fromStore(SettingsStore store) =>
      ConsecutiveFailureLimit(
        (store.read<int>('consecutiveFailureLimit') ?? 3).clamp(0, 10),
      );
}

final consecutiveFailureLimitInitializerProvider =
    Provider<ConsecutiveFailureLimit>(
      (ref) => const ConsecutiveFailureLimit(3),
    );

class ConsecutiveFailureLimitNotifier
    extends Notifier<ConsecutiveFailureLimit> {
  @override
  ConsecutiveFailureLimit build() =>
      ref.watch(consecutiveFailureLimitInitializerProvider);

  Future<void> set(int value) async {
    final next = ConsecutiveFailureLimit(value.clamp(0, 10));
    if (next.value == state.value) return;
    state = next;
    await ref.read(settingsStoreProvider).patch({
      'consecutiveFailureLimit': next.value,
    });
  }
}

final consecutiveFailureLimitProvider =
    NotifierProvider<ConsecutiveFailureLimitNotifier, ConsecutiveFailureLimit>(
      ConsecutiveFailureLimitNotifier.new,
    );
