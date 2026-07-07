/// DLNA 投屏状态管理 Provider
///
/// 基于 Riverpod Notifier 管理投屏全流程状态，包括：
/// - 设备发现（discovering）
/// - 连接设备并投送当前曲目（connecting -> connected）
/// - 进度/音量/传输状态轮询
/// - 当前曲目切换时自动重投
///
/// 与播放器状态联动：
/// - 监听 [audioPlayerProvider] 当前曲目变化，自动投送新曲目
/// - 通过 `UserPreference.castLocalProxy` 决定投屏 URL 来源：
///   - true（默认）：始终通过本地 HTTP 服务器 `/stream/<trackId>` 代理，
///     便于统一缓存与控制（DLNA 设备无法访问外网鉴权链接时尤其重要）
///   - false：在线音源直接投送其原始 URL；本地文件仍需通过本地服务器代理
///
/// 设计约定（项目规范）：
/// - Service 层不持有 Ref；Provider 层通过 Ref 访问 Service 和其他 Provider
/// - 异步操作中所有 ref 读取与状态修改前必须 `if (!ref.mounted) return;`
/// - 构建期修改 Provider 状态用 `Future.microtask()` 延迟
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/models/metadata/track.dart';
import 'package:pomelo/core/preferences/user_preference_provider.dart';
import 'package:pomelo/provider/audio_player/audio_player.dart';
import 'package:pomelo/services/audio_player/media.dart';
import 'package:pomelo/services/cast/dlna_cast_service.dart';
import 'package:pomelo/services/cast/dlna_device.dart';
import 'package:pomelo/services/logger/logger.dart';

/// 投屏连接状态
enum CastConnectionState {
  /// 已断开
  disconnected,

  /// 正在搜索设备
  discovering,

  /// 正在连接设备（连接 + 投送首曲）
  connecting,

  /// 已连接，正在投屏
  connected,
}

/// 投屏状态
@immutable
class CastState {
  /// 连接状态
  final CastConnectionState connectionState;

  /// 已发现的设备列表
  final List<DlnaDevice> discoveredDevices;

  /// 当前连接的设备
  final DlnaDevice? currentDevice;

  /// 当前播放进度
  final Duration position;

  /// 当前曲目总时长
  final Duration duration;

  /// 音量（0-100），null 表示未知
  final int? volume;

  /// 设备传输状态：'PLAYING' / 'PAUSED_PLAYBACK' / 'STOPPED' / 'TRANSITIONING'
  final String? transportState;

  /// 错误信息（非 null 时建议向用户展示）
  final String? errorMessage;

  const CastState({
    this.connectionState = CastConnectionState.disconnected,
    this.discoveredDevices = const [],
    this.currentDevice,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume,
    this.transportState,
    this.errorMessage,
  });

  /// 是否正在投屏（已连接且有目标设备）
  bool get isCasting =>
      connectionState == CastConnectionState.connected && currentDevice != null;

  /// 当前是否在播放
  bool get isPlaying => transportState == 'PLAYING';

  /// 创建副本
  CastState copyWith({
    CastConnectionState? connectionState,
    List<DlnaDevice>? discoveredDevices,
    DlnaDevice? currentDevice,
    Duration? position,
    Duration? duration,
    int? volume,
    String? transportState,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CastState(
      connectionState: connectionState ?? this.connectionState,
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      currentDevice: currentDevice ?? this.currentDevice,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      transportState: transportState ?? this.transportState,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// 投屏状态 Provider
final castProvider = NotifierProvider<CastNotifier, CastState>(
  CastNotifier.new,
);

/// 投屏状态管理 Notifier
class CastNotifier extends Notifier<CastState> {
  final DlnaCastService _service = DlnaCastService();
  Timer? _positionTimer;

  /// 进度轮询间隔
  static const _pollInterval = Duration(seconds: 1);

  @override
  CastState build() {
    // 监听当前曲目 ID 变化，自动重投新曲目
    ref.listen<String?>(
      audioPlayerProvider.select((s) => s.activeTrack?.id),
      (previous, next) {
        if (state.isCasting && previous != next) {
          _castCurrentTrack();
        }
      },
    );

    ref.onDispose(() {
      _positionTimer?.cancel();
      _service.dispose();
    });

    return const CastState();
  }

  /// 发现设备
  ///
  /// 重置已发现设备列表，开始一次新的搜索。
  /// 在 [timeout] 后停止搜索，最终结果通过 state.discoveredDevices 暴露。
  Future<void> discover({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (!ref.mounted) return;
    state = const CastState(
      connectionState: CastConnectionState.discovering,
      discoveredDevices: [],
    );

    try {
      final devices = <DlnaDevice>[];
      final result = await _service.discover(
        timeout: timeout,
        onDeviceFound: (device) {
          // 实时更新设备列表（按 id 去重，保留最新描述版本）
          final idx = devices.indexWhere((d) => d.id == device.id);
          if (idx == -1) {
            devices.add(device);
          } else {
            devices[idx] = device;
          }
          if (ref.mounted) {
            state = state.copyWith(discoveredDevices: List.of(devices));
          }
        },
      );

      if (!ref.mounted) return;
      // 用最终结果替换（包含所有发现的设备）
      state = state.copyWith(
        connectionState: CastConnectionState.disconnected,
        discoveredDevices: result,
        clearError: true,
      );
    } catch (e, stack) {
      AppLogger.reportError(e, stack, '[Cast] 发现设备失败');
      if (!ref.mounted) return;
      state = state.copyWith(
        connectionState: CastConnectionState.disconnected,
        errorMessage: '搜索设备失败: $e',
      );
    }
  }

  /// 连接目标设备并投送当前曲目
  Future<void> connect(DlnaDevice device) async {
    if (!ref.mounted) return;
    AppLogger.log.i('[Cast] 连接设备: ${device.name} (${device.id})');

    state = state.copyWith(
      connectionState: CastConnectionState.connecting,
      currentDevice: device,
      clearError: true,
    );

    try {
      _service.connect(device);
      await _castCurrentTrack();
      if (!ref.mounted) return;

      state = state.copyWith(
        connectionState: CastConnectionState.connected,
        currentDevice: device,
      );
      _startPositionPolling();
    } catch (e, stack) {
      AppLogger.reportError(e, stack, '[Cast] 连接设备失败');
      if (!ref.mounted) return;
      // 注意：直接构造新 CastState，避免 copyWith 中 currentDevice: null
      // 被当作"不更新"处理（与可空字段的 sentinel 约定保持一致）。
      state = CastState(
        discoveredDevices: state.discoveredDevices,
        errorMessage: '连接设备失败: $e',
      );
    }
  }

  /// 投送当前曲目到已连接的设备
  ///
  /// URL 解析规则：
  /// - castLocalProxy=true：始终用 `http://<lan-ip>:<port>/stream/<trackId>`
  /// - castLocalProxy=false：
  ///   - 在线音源（track.src != null）：直接用 track.src
  ///   - 本地文件（track.path != null）：仍用本地服务器代理
  ///   - 都为 null：投屏失败
  Future<void> _castCurrentTrack() async {
    final track = ref.read(audioPlayerProvider).activeTrack;
    if (track == null) {
      state = state.copyWith(errorMessage: '当前没有播放中的曲目');
      return;
    }

    final url = await _resolveCastUrl(track);
    if (url == null) {
      state = state.copyWith(errorMessage: '当前曲目无法投屏');
      return;
    }

    AppLogger.log.i('[Cast] 投送曲目: ${track.title} -> $url');
    await _service.castTrack(url);
  }

  /// 解析投屏 URL
  Future<String?> _resolveCastUrl(Track track) async {
    final useProxy =
        ref.read(userPreferenceProvider.select((p) => p.castLocalProxy));

    // 在线音源且未启用本地代理：直接使用原始 URL
    if (!useProxy && track.isOnline && track.src != null) {
      return track.src;
    }

    // 其他情况（本地文件 或 启用本地代理）：通过本地 HTTP 服务器代理
    if (PomeloMedia.serverPort == 0) {
      AppLogger.log.w('[Cast] 本地服务器未启动，无法投屏');
      return null;
    }
    final lanIp = await _getLanIp();
    if (lanIp == null) {
      AppLogger.log.w('[Cast] 无法获取本机 LAN IP');
      return null;
    }
    return 'http://$lanIp:${PomeloMedia.serverPort}/stream/${track.id}';
  }

  /// 获取本机局域网 IPv4 地址
  ///
  /// 优先返回第一个非 loopback 的 IPv4 地址。多网卡时取第一个。
  /// 获取失败时返回 null。
  Future<String?> _getLanIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (e, stack) {
      AppLogger.reportError(e, stack, '[Cast] 获取 LAN IP 失败');
    }
    return null;
  }

  /// 启动进度轮询
  void _startPositionPolling() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(_pollInterval, (_) async {
      if (!ref.mounted) {
        _positionTimer?.cancel();
        return;
      }
      try {
        final info = await _service.getPositionInfo();
        final transport = await _service.getTransportState();
        if (!ref.mounted) return;
        state = state.copyWith(
          position: info.position,
          duration: info.duration,
          transportState: transport.isEmpty ? null : transport,
        );
        // 每隔几次轮询更新一次音量（减少设备负担）
        // 这里采用简单的「无音量时拉取一次」策略，避免持续打设备
        if (state.volume == null) {
          final vol = await _service.getVolume();
          if (!ref.mounted) return;
          state = state.copyWith(volume: vol);
        }
      } catch (e, stack) {
        AppLogger.reportError(e, stack, '[Cast] 轮询进度失败');
      }
    });
  }

  /// 暂停投屏播放
  Future<void> pause() async {
    try {
      await _service.pause();
      if (ref.mounted) state = state.copyWith(transportState: 'PAUSED_PLAYBACK');
    } catch (e, stack) {
      AppLogger.reportError(e, stack, '[Cast] 暂停失败');
    }
  }

  /// 恢复投屏播放
  Future<void> resume() async {
    try {
      await _service.play();
      if (ref.mounted) state = state.copyWith(transportState: 'PLAYING');
    } catch (e, stack) {
      AppLogger.reportError(e, stack, '[Cast] 恢复失败');
    }
  }

  /// 停止投屏播放（保留连接）
  Future<void> stop() async {
    try {
      await _service.stop();
      if (ref.mounted) state = state.copyWith(transportState: 'STOPPED');
    } catch (e, stack) {
      AppLogger.reportError(e, stack, '[Cast] 停止失败');
    }
  }

  /// 跳转进度
  Future<void> seek(Duration position) async {
    try {
      await _service.seek(position);
      if (ref.mounted) state = state.copyWith(position: position);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, '[Cast] 跳转进度失败');
    }
  }

  /// 设置音量
  Future<void> setVolume(int volume) async {
    final clamped = volume.clamp(0, 100);
    try {
      await _service.setVolume(clamped);
      if (ref.mounted) state = state.copyWith(volume: clamped);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, '[Cast] 设置音量失败');
    }
  }

  /// 断开投屏
  Future<void> disconnect() async {
    _positionTimer?.cancel();
    _positionTimer = null;
    await _service.disconnect();
    if (ref.mounted) {
      state = CastState(
        discoveredDevices: state.discoveredDevices,
      );
    }
  }
}
