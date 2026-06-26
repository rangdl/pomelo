/// 音频播放器模块 - Riverpod Providers
///
/// 提供音频播放器模块的响应式状态管理。
library;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/modules/audio_player/providers/audio_player.dart';

import 'audio_player_module.dart';
import 'model/state.dart';
import 'service/audio_player_service.dart';
import 'services/audio_services.dart';

/// 音频播放器 Module Provider
final audioPlayerModuleProvider = Provider<AudioPlayerModule>((ref) {
  throw UnimplementedError(
    'AudioPlayerModule must be provided via overrides in main.dart',
  );
});

/// 音频播放器 Service Provider
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  return ref.watch(audioPlayerModuleProvider).service;
});

/// 音频播放器状态 state Provider
final audioPlayerProvider =
    NotifierProvider<AudioPlayerNotifier, AudioPlayerState>(
      () => AudioPlayerNotifier(),
    );

/// 平台媒体控制服务 Provider
///
/// 在应用启动时初始化 [AudioServices]，封装 Windows SMTC 和移动端通知栏控制。
/// 通过 `ref.watch(audioServicesProvider)` 触发初始化。
final audioServicesProvider = FutureProvider<AudioServices>((ref) async {
  // 确保 audioPlayerProvider 已初始化
  ref.watch(audioPlayerProvider);
  final audioPlayerNotifier = ref.read(audioPlayerProvider.notifier);

  final services = await AudioServices.create(ref, audioPlayerNotifier);
  ref.onDispose(services.dispose);

  // 初始化完成后同步当前曲目元数据
  final activeTrack = ref.read(audioPlayerProvider).activeTrack;
  if (activeTrack != null) {
    await services.addTrack(activeTrack);
  }

  return services;
});
