/// DLNA 投屏门面服务
///
/// 对 [DlnaDiscovery] 与 [DlnaControl] 的薄封装，简化上层 Provider 调用。
///
/// 一个实例同时持有「当前设备」与「设备控制客户端」：
/// - [discover]：发现局域网内 DLNA 设备
/// - [connect]：选定目标设备，创建控制客户端
/// - [castTrack]：一步完成 SetAVTransportURI + Play
/// - 控制方法：[play] / [pause] / [stop] / [seek] / [getVolume] 等
///
/// 设计要点：
/// - Service 层无状态依赖（不持有 Riverpod Ref），符合项目分层规范
/// - 所有控制方法在未连接时返回安全的默认值（不抛异常）
library;

import 'package:pomelo/services/cast/dlna_control.dart';
import 'package:pomelo/services/cast/dlna_device.dart';
import 'package:pomelo/services/cast/dlna_discovery.dart';

/// 投屏进度信息
typedef CastPositionInfo = ({Duration position, Duration duration});

/// DLNA 投屏门面服务
class DlnaCastService {
  final DlnaDiscovery _discovery;
  DlnaControl? _control;
  DlnaDevice? _currentDevice;

  DlnaCastService({DlnaDiscovery? discovery})
      : _discovery = discovery ?? DlnaDiscovery();

  /// 当前已连接的设备（未连接时为 null）
  DlnaDevice? get currentDevice => _currentDevice;

  /// 是否已连接
  bool get isConnected => _control != null && _currentDevice != null;

  /// 发现设备
  Future<List<DlnaDevice>> discover({
    Duration timeout = const Duration(seconds: 5),
    void Function(DlnaDevice device)? onDeviceFound,
  }) {
    return _discovery.discover(
      timeout: timeout,
      onDeviceFound: onDeviceFound,
    );
  }

  /// 连接到目标设备
  ///
  /// 如果设备未提供 AVTransport 服务，将无法投屏。
  void connect(DlnaDevice device) {
    _currentDevice = device;
    _control = DlnaControl(device);
  }

  /// 投送曲目并播放
  ///
  /// 流程：SetAVTransportURI -> 等待设备就绪 -> Play。
  /// 中间间隔 300ms 让设备有时间加载 URI（实测某些电视需要这个间隔）。
  Future<void> castTrack(String url, {String? metadata}) async {
    final control = _control;
    if (control == null) {
      throw StateError('DlnaCastService 未连接设备');
    }
    await control.setAvTransportUri(url, metadata: metadata);
    // 给设备一些时间加载 URI
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await control.play();
  }

  /// 播放
  Future<void> play() async {
    await _control?.play();
  }

  /// 暂停
  Future<void> pause() async {
    await _control?.pause();
  }

  /// 停止（不取消 URI，仅停止播放）
  Future<void> stop() async {
    await _control?.stop();
  }

  /// 跳转进度
  Future<void> seek(Duration position) async {
    await _control?.seek(position);
  }

  /// 获取进度信息
  ///
  /// 未连接或调用失败时返回 0/0。
  Future<CastPositionInfo> getPositionInfo() async {
    try {
      final info = await _control?.getPositionInfo();
      if (info == null) {
        return (position: Duration.zero, duration: Duration.zero);
      }
      return (position: info.position, duration: info.duration);
    } catch (_) {
      return (position: Duration.zero, duration: Duration.zero);
    }
  }

  /// 获取传输状态（'PLAYING' / 'PAUSED_PLAYBACK' / 'STOPPED' 等）
  ///
  /// 未连接或调用失败时返回空字符串。
  Future<String> getTransportState() async {
    try {
      return await _control?.getTransportState() ?? '';
    } catch (_) {
      return '';
    }
  }

  /// 获取音量（0-100）
  Future<int> getVolume() async {
    try {
      return await _control?.getVolume() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// 设备健康检查
  ///
  /// 调用一个轻量 SOAP action（GetTransportInfo）判断设备是否可达。
  /// 调用方据此判断连接是否中断，触发重连逻辑。
  /// 未连接时返回 false。
  Future<bool> ping() async {
    if (_control == null) return false;
    try {
      await _control!.getTransportState();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 设置音量（0-100）
  Future<void> setVolume(int volume) async {
    try {
      await _control?.setVolume(volume);
    } catch (_) {
      // 静默忽略：音量失败不影响主流程
    }
  }

  /// 断开当前设备
  ///
  /// 优先调用 Stop 让设备停止播放，然后清空内部状态。
  Future<void> disconnect() async {
    try {
      await _control?.stop();
    } catch (_) {
      // 停止失败也允许断开
    }
    _control = null;
    _currentDevice = null;
  }

  /// 关闭服务，释放资源
  void dispose() {
    _control = null;
    _currentDevice = null;
  }
}
