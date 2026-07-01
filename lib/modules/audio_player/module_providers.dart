/// 音频播放器模块 - Riverpod Providers
///
/// 提供音频播放器模块的响应式状态管理。
library;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/models/database/database_provider.dart';
import 'package:pomelo/modules/audio_player/providers/audio_player.dart';

import 'audio_player_module.dart';
import 'model/state.dart';
import 'service/audio_player_service.dart';
import 'services/audio_services.dart';

/// AudioPlayerModule 实例 Provider
///
/// 内部完成 AudioPlayerModule 的创建与 init 初始化（含 HTTP 服务器启动）。
/// main.dart 通过 `container.read(audioPlayerModuleProvider.future)` 触发初始化，
/// 随后注入 ProviderContainer（供 ServerPlaybackRoutes 访问 sourcedTrackProvider）。
final audioPlayerModuleProvider = FutureProvider<AudioPlayerModule>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final module = AudioPlayerModule(db: db);
  await module.init();
  ref.onDispose(module.dispose);
  return module;
});

/// 音频播放器 Service Provider
///
/// 同步派生自 [audioPlayerModuleProvider]。main.dart 在 runApp 前已 await
/// `audioPlayerModuleProvider.future`，故 UI 访问时必定为 data 状态。
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  return ref.watch(audioPlayerModuleProvider).requireValue.service;
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
