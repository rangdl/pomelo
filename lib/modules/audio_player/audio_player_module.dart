/// 音频播放器模块 - 模块定义
///
/// 提供音频播放控制、播放队列管理和播放状态持久化功能。
/// 遵循 M.A.R.S. 架构：
/// - Model: state.dart, audio_player.dart
/// - Action: (模块初始化/就绪/销毁)
/// - Repository: AudioPlayerRepository
/// - Service/State: AudioPlayerService / Riverpod Provider
library;

import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:pomelo/core/mars.dart';
import 'package:pomelo/core/log.dart';
import 'package:pomelo/modules/music/music_module.dart';
import 'package:pomelo/modules/music/model/music_service.dart';
import 'package:pomelo/modules/music/model/song.dart';
import 'package:pomelo/modules/music_lx/model/lx_music_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'model/media.dart';
import 'providers/router.dart';
import 'providers/playback.dart';
import 'repository/audio_player_repository.dart';
import 'service/audio_player_service.dart';

class AudioPlayerModule extends Module {
  AudioPlayerModule() : _repository = AudioPlayerRepository();

  final AudioPlayerRepository _repository;
  late final AudioPlayerService _service;
  HttpServer? _server;

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

    // 启动本地 HTTP 代理服务
    await _startServer();
  }

  @override
  Future<void> onReady() async {
    // 所有依赖模块就绪后的逻辑
  }

  @override
  Future<void> onDispose() async {
    await _stopServer();
    await _repository.onDispose();
    await _service.onDispose();
  }

  /// 启动本地 HTTP 代理服务（用于在线曲目流式转发）
  Future<void> _startServer() async {
    // 分配端口（优先使用已配置的端口，否则随机生成）
    if (PomeloMedia.serverPort == 0) {
      PomeloMedia.serverPort = Random().nextInt(17500) + 5000;
    }

    // 构建播放路由（注入 AudioPlayerService、活跃曲目获取器和 URL 解析器）
    final playbackRoutes = ServerPlaybackRoutes(
      audioPlayer: _service,
      getActiveTrack: () {
        // 从底层播放器获取当前曲目信息
        final playlist = _service.playlist;
        if (playlist.index < 0 || playlist.medias.isEmpty) return null;
        final media = playlist.medias.elementAtOrNull(playlist.index);
        if (media == null) return null;
        return PomeloMedia.media(media).track;
      },
      getTrackUrl: (Song track) async {
        // 通过 MusicModule 找到对应的 MusicService，调用 getMusicUrl 获取播放链接
        final musicModule = ModuleManager().find<MusicModule>('music');
        if (musicModule == null) return track.map(full: (f) => f.src, local: (l) => l.path);
        // 先尝试精确匹配 sourceId
        MusicService? service = musicModule.service(track.source.id);
        // 若无精确匹配，尝试找到拥有该 library 的 Lx 服务
        if (service == null) {
          for (final s in musicModule.services) {
            if (s is LxMusicService && s.libraries.any((l) => l.id == track.source.id)) {
              service = s;
              break;
            }
          }
        }
        if (service == null) return track.map(full: (f) => f.src, local: (l) => l.path);
        return service.getMusicUrl(track as SongFull);
      },
    );

    final router = buildServerRouter(playbackRoutes);

    // 构建 pipeline（调试模式下启用请求日志）
    var pipeline = const Pipeline();
    if (kDebugMode) {
      pipeline = pipeline.addMiddleware(logRequests());
    }

    _server = await shelf_io.serve(
      pipeline.addHandler(router.call),
      InternetAddress.anyIPv4,
      PomeloMedia.serverPort,
    );

    log.info(
      'AudioPlayer',
      'HTTP server started at http://${_server!.address.host}:${_server!.port}',
    );
  }

  /// 停止本地 HTTP 代理服务
  Future<void> _stopServer() async {
    await _server?.close();
    _server = null;
    log.info('AudioPlayer', 'HTTP server stopped');
  }

  /// 获取仓储实例（供外部使用）
  AudioPlayerRepository get repository => _repository;

  /// 获取服务实例（供外部使用）
  AudioPlayerService get service => _service;

  /// 获取服务器端口
  int get serverPort => PomeloMedia.serverPort;
}
