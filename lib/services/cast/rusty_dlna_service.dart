/// 基于 rusty_dlna（Rust）的 DLNA 投屏门面服务
///
/// 与 [DlnaCastService] 提供相同的公开 API，底层使用 Rust 实现的
/// SSDP 发现 + SOAP 控制，通过 flutter_rust_bridge 桥接。
///
/// 差异：
/// - 设备发现是一次性返回（无流式回调），内部模拟 onDeviceFound 回调
/// - 设备控制方法直接在 ProjectorInfo 上调用，无需额外控制客户端
/// - TransportState 枚举需映射为字符串（'PLAYING' / 'PAUSED_PLAYBACK' 等）
library;

import 'package:collection/collection.dart';
import 'package:pomelo/services/cast/dlna_cast_service.dart';
import 'package:pomelo/services/cast/dlna_device.dart';
import 'package:rusty_dlna/api/cast.dart';
import 'package:rusty_dlna/frb_generated.dart';

/// TransportState 枚举 → 字符串映射
String _transportStateToString(TransportState state) {
  return switch (state) {
    TransportState.playing => 'PLAYING',
    TransportState.paused => 'PAUSED_PLAYBACK',
    TransportState.stopped => 'STOPPED',
    TransportState.transitioning => 'TRANSITIONING',
    TransportState.noMedia => 'NO_MEDIA_PRESENT',
    TransportState.unknown => '',
  };
}

/// rusty_dlna 投屏门面服务
class RustyDlnaService implements DlnaCastServiceInterface {
  final List<ProjectorInfo> _discovered = [];
  ProjectorInfo? _projector;
  DlnaDevice? _currentDevice;

  @override
  DlnaDevice? get currentDevice => _currentDevice;

  @override
  bool get isConnected => _projector != null && _currentDevice != null;

  /// rusty_dlna 是否已初始化
  static bool _initialized = false;

  /// 初始化 Rust 运行时
  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    await RustLib.init();
    _initialized = true;
  }

  @override
  Future<List<DlnaDevice>> discover({
    Duration timeout = const Duration(seconds: 5),
    void Function(DlnaDevice device)? onDeviceFound,
  }) async {
    await ensureInitialized();
    _discovered.clear();

    final devices = await scanProjectors(
      timeoutSecs: BigInt.from(timeout.inSeconds),
    );
    _discovered.addAll(devices);

    final result = <DlnaDevice>[];
    for (final d in devices) {
      final device = DlnaDevice(
        id: d.ip,
        name: d.friendlyName.isNotEmpty ? d.friendlyName : d.ip,
        location: d.locationXmlUrl,
        avTransportUrl: d.avTransportUrl,
        renderingControlUrl: d.renderingControlUrl,
      );
      onDeviceFound?.call(device);
      result.add(device);
    }
    return result;
  }

  @override
  void connect(DlnaDevice device) {
    _currentDevice = device;
    _projector = _discovered.firstWhereOrNull((p) => p.ip == device.id);
    if (_projector == null) {
      throw StateError('未找到底层 ProjectorInfo: ${device.id}');
    }
  }

  @override
  Future<void> castTrack(String url, {String title = ''}) async {
    if (_projector == null) {
      throw StateError('RustyDlnaService 未连接设备');
    }
    await _projector!.castVideo(videoUrl: url);
  }

  @override
  Future<void> play() async => await _projector?.play();

  @override
  Future<void> pause() async => await _projector?.pause();

  @override
  Future<void> stop() async => await _projector?.stop();

  @override
  Future<void> seek(Duration position) async {
    final target = _formatDuration(position);
    await _projector?.seek(targetTime: target);
  }

  @override
  Future<CastPositionInfo> getPositionInfo() async {
    try {
      final (current, total) =
          await _projector?.getPositionInfo() ?? ('', '');
      return (
        position: _parseDuration(current),
        duration: _parseDuration(total),
      );
    } catch (_) {
      return (position: Duration.zero, duration: Duration.zero);
    }
  }

  @override
  Future<String> getTransportState() async {
    try {
      final state = await _projector?.getTransportInfo();
      if (state == null) return '';
      return _transportStateToString(state);
    } catch (_) {
      return '';
    }
  }

  @override
  Future<int> getVolume() async {
    try {
      return await _projector?.getVolume() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<void> setVolume(int volume) async {
    try {
      await _projector?.setVolume(volume: volume.clamp(0, 100));
    } catch (_) {}
  }

  @override
  Future<bool> ping() async {
    if (_projector == null) return false;
    try {
      await _projector!.getTransportInfo();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _projector?.stop();
    } catch (_) {}
    _projector = null;
    _currentDevice = null;
  }

  @override
  void dispose() {
    _projector = null;
    _currentDevice = null;
    _discovered.clear();
  }

  // ==================== 内部工具 ====================

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '$hours:${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Duration _parseDuration(String raw) {
    if (raw.isEmpty) return Duration.zero;
    final match = RegExp(
      r'^([+-]?\d+):([0-5]?\d):([0-5]?\d)(?:\.(\d+))?$',
    ).firstMatch(raw.trim());
    if (match == null) return Duration.zero;
    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
    final millisStr = match.group(4) ?? '';
    var millis = 0;
    if (millisStr.isNotEmpty) {
      final padded = millisStr.length >= 3
          ? millisStr.substring(0, 3)
          : millisStr.padRight(3, '0');
      millis = int.tryParse(padded) ?? 0;
    }
    return Duration(
      hours: hours.abs(),
      minutes: minutes,
      seconds: seconds,
      milliseconds: millis,
    );
  }
}
