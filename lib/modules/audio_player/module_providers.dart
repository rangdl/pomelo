/// 音频播放器模块 - Riverpod Providers
///
/// 提供音频播放器模块的响应式状态管理。
library;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/modules/audio_player/providers/audio_player.dart';

import 'audio_player_module.dart';
import 'model/state.dart';
import 'service/audio_player_service.dart';

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
