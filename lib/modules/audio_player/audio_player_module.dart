/// 音频播放器模块 - 模块定义
///
/// 提供音频播放控制、播放队列管理和播放状态持久化功能。
/// 遵循 M.A.R.S. 架构：
/// - Model: state.dart, audio_player.dart
/// - Action: (模块初始化/就绪/销毁)
/// - Repository: AudioPlayerRepository
/// - Service/State: AudioPlayerService / Riverpod Provider
library;

import 'package:pomelo/core/mars.dart';

import 'repository/audio_player_repository.dart';
import 'service/audio_player_service.dart';

class AudioPlayerModule extends Module {
  AudioPlayerModule() : _repository = AudioPlayerRepository();

  final AudioPlayerRepository _repository;
  late final AudioPlayerService _service;

  @override
  String get id => 'audio_player';

  @override
  String get displayName => '音频播放器';

  @override
  bool get lazy => false; // 播放器非延迟加载，应用启动即初始化

  @override
  List<String> get dependencies => ['log'];

  @override
  Future<void> onInit() async {
    // 初始化仓储
    await _repository.onInit();

    // 初始化服务
    _service = AudioPlayerService(_repository);
    await _service.onInit();
  }

  @override
  Future<void> onReady() async {
    // 所有依赖模块就绪后的逻辑
  }

  @override
  Future<void> onDispose() async {
    await _repository.onDispose();
    await _service.onDispose();
  }

  /// 获取仓储实例（供外部使用）
  AudioPlayerRepository get repository => _repository;

  /// 获取服务实例（供外部使用）
  AudioPlayerService get service => _service;
}
