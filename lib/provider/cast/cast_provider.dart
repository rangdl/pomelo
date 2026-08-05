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
import 'package:pomelo/services/audio_player/audio_player.dart' as svc;
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
  late DlnaCastServiceInterface _service;
  Timer? _positionTimer;

  /// 进度轮询间隔
  static const _pollInterval = Duration(seconds: 1);

  /// 连续健康检查失败次数（每次 ping 成功重置为 0）
  int _consecutiveFailures = 0;

  /// 触发重连的失败阈值
  static const _failureThreshold = 5;

  /// 最大重连尝试次数（超过则放弃并断开）
  static const _maxReconnectAttempts = 3;

  /// 当前重连尝试次数
  int _reconnectAttempts = 0;

  /// 是否正在执行重连（防止并发重连）
  bool _reconnecting = false;

  @override
  CastState build() {
    _service = DlnaCastService();

    // 监听当前曲目 ID 变化，自动重投新曲目
    ref.listen<String?>(audioPlayerProvider.select((s) => s.activeTrack?.id), (
      previous,
      next,
    ) {
      if (state.isCasting && previous != next) {
        _castCurrentTrack();
      }
    });

    ref.onDispose(() {
      _positionTimer?.cancel();
      _service.dispose();
    });

    return const CastState();
  }

  /// 将设备按 id 去重并入已发现列表（保留最新描述版本）
  void _upsertDevice(DlnaDevice device) {
    if (!ref.mounted) return;
    final devices = List<DlnaDevice>.from(state.discoveredDevices);
    final idx = devices.indexWhere((d) => d.id == device.id);
    if (idx == -1) {
      devices.add(device);
    } else {
      devices[idx] = device;
    }
    state = state.copyWith(discoveredDevices: devices, clearError: true);
  }

  /// 发现设备
  ///
  /// 开始持续监听（投屏页打开期间设备列表实时刷新）。
  /// 底层 SSDP 监听持续运行，不再 5s 后自动停止；用户选定设备 [connect]
  /// 或关闭投屏页（[disconnect] / [build] 的 onDispose）时释放监听。
  /// 监听启动失败时回退到一次性发现。
  Future<void> discover() async {
    if (!ref.mounted) return;
    state = const CastState(
      connectionState: CastConnectionState.discovering,
      discoveredDevices: [],
    );

    try {
      await _service.startDiscovery(onDeviceFound: _upsertDevice);
      // 持续监听：保持在 discovering 状态，不自动停止。
    } catch (e, stack) {
      AppLogger.reportError(e, stack, '[Cast] 持续发现启动失败，回退一次性发现');
      if (!ref.mounted) return;
      try {
        final result = await _service.discover(onDeviceFound: _upsertDevice);
        if (!ref.mounted) return;
        state = state.copyWith(
          connectionState: CastConnectionState.disconnected,
          discoveredDevices: result,
          clearError: true,
        );
      } catch (e2, stack2) {
        AppLogger.reportError(e2, stack2, '[Cast] 发现设备失败');
        if (!ref.mounted) return;
        state = state.copyWith(
          connectionState: CastConnectionState.disconnected,
          errorMessage: '搜索设备失败: $e2',
        );
      }
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

      // 投屏成功后暂停本地播放器，避免双重音频
      try {
        await svc.audioPlayer.pause();
      } catch (e) {
        AppLogger.log.w('[Cast] 暂停本地播放器失败: $e');
      }

      // 重置重连计数
      _consecutiveFailures = 0;
      _reconnectAttempts = 0;

      state = state.copyWith(
        connectionState: CastConnectionState.connected,
        currentDevice: device,
      );
      // 已连接设备，停止持续监听以释放 UDP 端口
      // （deviceManager 仍保留，供后续自动重连取底层设备）
      unawaited(_service.stopDiscovery());
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
    // dlna_dart 内部构建 DIDL-Lite 元数据，仅传 title
    await _service.castTrack(url, title: track.title);
  }

  /// 解析投屏 URL
  Future<String?> _resolveCastUrl(Track track) async {
    final useProxy = ref.read(
      userPreferenceProvider.select((p) => p.castLocalProxy),
    );

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
  /// 优先返回处于私有网段（192.168.* / 172.16-31.* / 10.*）且非链路本地
  /// （169.254.*）、非 CGNAT（100.*）的地址，多网卡 / 连 VPN 时更可能命中
  /// 真正的局域网网卡；无匹配时兜底取第一个非回环地址。获取失败返回 null。
  Future<String?> _getLanIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );
      String? fallback;
      String? preferred;
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (addr.isLoopback) continue;
          final ip = addr.address;
          fallback ??= ip;
          if (preferred == null && _isPreferredLanIp(ip)) {
            preferred = ip;
          }
        }
      }
      return preferred ?? fallback;
    } catch (e, stack) {
      AppLogger.reportError(e, stack, '[Cast] 获取 LAN IP 失败');
    }
    return null;
  }

  /// 是否优先选用的局域网地址：私有网段且非链路本地 / CGNAT
  static bool _isPreferredLanIp(String ip) {
    if (ip.startsWith('169.254.')) return false; // 链路本地 APIPA，多为无 DHCP / VPN 占位
    if (ip.startsWith('100.')) return false; // CGNAT（运营商大内网 / 部分 VPN）
    if (ip.startsWith('192.168.')) return true;
    if (ip.startsWith('10.')) return true;
    if (ip.startsWith('172.')) {
      final parts = ip.split('.');
      final seg = parts.length > 1 ? int.tryParse(parts[1]) : null;
      if (seg != null && seg >= 16 && seg <= 31) return true;
    }
    return false;
  }

  /// 启动进度轮询
  ///
  /// 每次轮询：
  /// 1. 通过 `ping()` 做健康检查（GetTransportInfo 调用）
  /// 2. 连续 [_failureThreshold] 次失败后触发自动重连
  /// 3. 重连成功则继续轮询；超过 [_maxReconnectAttempts] 次仍失败则断开
  void _startPositionPolling() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(_pollInterval, (_) async {
      if (!ref.mounted || _reconnecting) return;
      try {
        // 健康检查：通过 GetTransportInfo 一次调用同时获取传输状态
        final alive = await _service.ping();
        if (!alive) {
          _consecutiveFailures++;
          if (ref.mounted) {
            state = state.copyWith(
              errorMessage:
                  '与设备通信失败 ($_consecutiveFailures/$_failureThreshold)',
            );
          }
          if (_consecutiveFailures >= _failureThreshold) {
            await _tryReconnect();
          }
          return;
        }

        // 重置失败计数（设备响应正常）
        _consecutiveFailures = 0;

        // 拉取进度与音量
        final info = await _service.getPositionInfo();
        final transport = await _service.getTransportState();
        if (!ref.mounted) return;
        state = state.copyWith(
          position: info.position,
          duration: info.duration,
          transportState: transport.isEmpty ? null : transport,
          clearError: true,
        );
        if (state.volume == null) {
          final vol = await _service.getVolume();
          if (!ref.mounted) return;
          state = state.copyWith(volume: vol);
        }
      } catch (e, stack) {
        AppLogger.reportError(e, stack, '[Cast] 轮询进度失败');
        _consecutiveFailures++;
        if (_consecutiveFailures >= _failureThreshold) {
          await _tryReconnect();
        }
      }
    });
  }

  /// 尝试自动重连
  ///
  /// 流程：
  /// 1. 设置 `_reconnecting` 标志防止并发重连
  /// 2. 最多重试 [_maxReconnectAttempts] 次：
  ///    - 重新创建 DlnaControl 实例
  ///    - 重新投送当前曲目
  ///    - 验证 ping 成功
  /// 3. 重连成功重置失败计数、恢复轮询
  /// 4. 超过最大尝试次数则放弃，断开连接
  Future<void> _tryReconnect() async {
    if (_reconnecting || !state.isCasting) return;
    _reconnecting = true;
    _positionTimer?.cancel();

    AppLogger.log.w(
      '[Cast] 检测到设备失联，开始自动重连 (attempt=${_reconnectAttempts + 1}/$_maxReconnectAttempts)',
    );
    if (ref.mounted) {
      state = state.copyWith(errorMessage: '正在尝试重连...');
    }

    final device = state.currentDevice;
    if (device == null) {
      _reconnecting = false;
      return;
    }

    try {
      // 清理旧连接
      await _service.disconnect();
      // 指数退避：500ms / 1s / 2s
      final backoffMs = 500 * (1 << _reconnectAttempts);
      await Future.delayed(Duration(milliseconds: backoffMs));

      _service.connect(device);
      final ok = await _service.ping();
      if (ok) {
        await _castCurrentTrack();
        if (!ref.mounted) {
          _reconnecting = false;
          return;
        }
        _consecutiveFailures = 0;
        _reconnectAttempts = 0;
        state = state.copyWith(clearError: true);
        AppLogger.log.i('[Cast] 重连成功');
        _startPositionPolling();
      } else {
        throw Exception('ping 失败');
      }
    } catch (e, stack) {
      AppLogger.reportError(e, stack, '[Cast] 重连失败');
      _reconnectAttempts++;
      if (_reconnectAttempts >= _maxReconnectAttempts) {
        AppLogger.log.e('[Cast] 重连次数已达上限，断开连接');
        await disconnect();
      } else {
        // 递归重试
        await _tryReconnect();
      }
    } finally {
      _reconnecting = false;
    }
  }

  /// 暂停投屏播放
  Future<void> pause() async {
    try {
      await _service.pause();
      if (ref.mounted) {
        state = state.copyWith(transportState: 'PAUSED_PLAYBACK');
      }
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
  ///
  /// 重置所有重连状态，并停止投屏设备的播放。
  /// 不自动恢复本地播放器（避免用户已离开原播放位置时突然出声）。
  Future<void> disconnect() async {
    _positionTimer?.cancel();
    _positionTimer = null;
    _consecutiveFailures = 0;
    _reconnectAttempts = 0;
    _reconnecting = false;
    await _service.disconnect();
    await _service.stopDiscovery();
    if (ref.mounted) {
      state = CastState(discoveredDevices: state.discoveredDevices);
    }
  }
}
