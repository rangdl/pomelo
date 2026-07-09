/// SOAP 控制服务
///
/// 基于 `dlna_dart` 的 [DLNADevice] 实现对 DLNA 设备的 AVTransport /
/// RenderingControl 控制。
///
/// 每个方法委托给底层 [DLNADevice]，响应通过 `dlna_dart` 的解析器
/// （`PositionParser` / `TransportInfoParser` / `VolumeParser`）提取关键字段。
///
/// 设计要点：
/// - 不再手写 SOAP envelope / 正则解析，全部由 dlna_dart 负责
/// - Duration 与 DLNA 时间格式 `H:MM:SS(.fff)` 互转仍在本层处理
/// - 失败向上抛出异常，由 [DlnaCastService] 决定如何处理
library;

import 'package:dlna_dart/dlna.dart';
import 'package:dlna_dart/xmlParser.dart';
import 'package:pomelo/services/cast/dlna_device.dart';
import 'package:pomelo/services/logger/logger.dart';

/// 进度信息
typedef PositionInfo = ({
  Duration position,
  Duration duration,
  /// 设备是否返回有效的时长
  bool trackDurationAvailable,
});

/// SOAP 控制服务
class DlnaControl {
  final DlnaDevice device;
  final DLNADevice _dlnaDevice;

  DlnaControl(this.device, this._dlnaDevice);

  // ==================== AVTransport ====================

  /// 设置当前媒体 URI
  ///
  /// 必须在 [play] 之前调用。
  /// dlna_dart 内部会构建 DIDL-Lite 元数据（含 title）。
  Future<void> setAvTransportUri(
    String uri, {
    String title = '',
  }) async {
    await _dlnaDevice.setUrl(uri, title: title, type: AudioMime.any);
  }

  /// 播放
  Future<void> play() async {
    await _dlnaDevice.play();
  }

  /// 暂停
  Future<void> pause() async {
    await _dlnaDevice.pause();
  }

  /// 停止
  Future<void> stop() async {
    await _dlnaDevice.stop();
  }

  /// 跳转进度
  ///
  /// [position] 转换为 DLNA 时间格式 `H:MM:SS(.fff)`。
  Future<void> seek(Duration position) async {
    final target = _formatDuration(position);
    await _dlnaDevice.seek(target);
  }

  /// 获取播放进度信息
  ///
  /// 返回当前播放位置、总时长以及时长是否有效。
  /// 部分设备对本地音频可能不返回总时长。
  Future<PositionInfo> getPositionInfo() async {
    final raw = await _dlnaDevice.position();
    final parsed = PositionParser(raw);
    final duration = _parseDuration(parsed.TrackDuration);
    final position = _parseDuration(parsed.RelTime);
    return (
      position: position,
      duration: duration,
      trackDurationAvailable: duration.inMilliseconds > 0,
    );
  }

  /// 获取传输状态
  ///
  /// 返回值：'PLAYING' / 'PAUSED_PLAYBACK' / 'STOPPED' / 'TRANSITIONING' /
  /// 'NO_MEDIA_PRESENT' 等。失败返回空字符串。
  Future<String> getTransportState() async {
    try {
      final raw = await _dlnaDevice.getTransportInfo();
      return TransportInfoParser(raw).CurrentTransportState;
    } catch (e, stack) {
      AppLogger.reportError(e, stack, '[DlnaControl] getTransportState');
      return '';
    }
  }

  // ==================== RenderingControl ====================

  /// 获取音量（0-100）
  Future<int> getVolume() async {
    try {
      final raw = await _dlnaDevice.getVolume();
      final vol = VolumeParser(raw).current;
      return vol.clamp(0, 100);
    } catch (e, stack) {
      AppLogger.reportError(e, stack, '[DlnaControl] getVolume');
      return 0;
    }
  }

  /// 设置音量（0-100）
  Future<void> setVolume(int volume) async {
    final clamped = volume.clamp(0, 100);
    await _dlnaDevice.volume(clamped);
  }

  // ==================== 内部工具 ====================

  /// Duration 转 DLNA 时间格式 `H:MM:SS.fff`
  ///
  /// 例如 `Duration(minutes: 1, seconds: 23, milliseconds: 456)` => `0:01:23.456`
  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    final millis = d.inMilliseconds.remainder(1000);
    return '$hours:${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}'
        '.${millis.toString().padLeft(3, '0')}';
  }

  /// DLNA 时间格式 `H:MM:SS(.fff)` 转 Duration
  ///
  /// 无效值（`NOT_IMPLEMENTED`、`00:00:00`、负数等）返回 [Duration.zero]。
  Duration _parseDuration(String raw) {
    if (raw.isEmpty) return Duration.zero;
    // 部分设备返回 `NOT_IMPLEMENTED` 表示未实现
    if (raw.toUpperCase() == 'NOT_IMPLEMENTED') return Duration.zero;
    // 兼容前导的 `+` / `-`
    final trimmed = raw.trim();
    // 格式 H:MM:SS 或 H:MM:SS.fff
    final match = RegExp(
      r'^([+-]?\d+):([0-5]?\d):([0-5]?\d)(?:\.(\d+))?$',
    ).firstMatch(trimmed);
    if (match == null) return Duration.zero;
    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
    final millisStr = match.group(4) ?? '';
    var millis = 0;
    if (millisStr.isNotEmpty) {
      // 截断到 3 位毫秒
      final padded = (millisStr.length >= 3)
          ? millisStr.substring(0, 3)
          : millisStr.padRight(3, '0');
      millis = int.tryParse(padded) ?? 0;
    }
    final isNegative = trimmed.startsWith('-');
    final value = Duration(
      hours: hours.abs(),
      minutes: minutes,
      seconds: seconds,
      milliseconds: millis,
    );
    return isNegative ? -value : value;
  }
}
