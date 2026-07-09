/// SSDP 设备发现服务
///
/// 基于 `dlna_dart` 的 [DLNAManager] 实现局域网 DLNA/UPnP 渲染设备发现。
///
/// 发现流程：
/// 1. `DLNAManager.start()` 启动 SSDP 多播监听 + 周期性 M-SEARCH
/// 2. 通过 `DeviceManager.devices` 流订阅设备列表更新
/// 3. 将 `DLNADevice`（dlna_dart）映射为项目内部的 [DlnaDevice] 模型
///
/// 设计要点：
/// - 保留对 [DeviceManager] 的引用，供 [DlnaCastService] 在 connect 时
///   取回底层 `DLNADevice` 用于 SOAP 控制
/// - 发现超时后自动 `stop()`，避免持续占用 UDP 端口
/// - 流式回调 [onDeviceFound] 让上层实时刷新设备列表
library;

import 'dart:async';

import 'package:dlna_dart/dlna.dart';
import 'package:pomelo/services/cast/dlna_device.dart';
import 'package:pomelo/services/logger/logger.dart';

/// SSDP 设备发现服务
class DlnaDiscovery {
  DLNAManager? _manager;
  DeviceManager? _deviceManager;
  StreamSubscription<Map<String, DLNADevice>>? _subscription;
  bool _stopped = false;

  /// 当前 DeviceManager（供 DlnaCastService 取底层 DLNADevice）
  DeviceManager? get deviceManager => _deviceManager;

  /// 发现设备
  ///
  /// 启动 SSDP 搜索，在 [timeout] 后停止并返回最终设备列表。
  /// 每次设备列表变化时回调 [onDeviceFound]（按 id 去重由调用方处理）。
  Future<List<DlnaDevice>> discover({
    Duration timeout = const Duration(seconds: 5),
    void Function(DlnaDevice device)? onDeviceFound,
  }) async {
    _stopped = false;
    final found = <String, DlnaDevice>{};

    try {
      _manager = DLNAManager();
      _deviceManager = await _manager!.start();

      _subscription = _deviceManager!.devices.stream.listen((deviceList) {
        if (_stopped) return;
        for (final entry in deviceList.entries) {
          final dlnaDevice = _mapToDevice(entry.key, entry.value);
          // 仅对新设备回调，已存在的不重复回调
          if (!found.containsKey(dlnaDevice.id)) {
            found[dlnaDevice.id] = dlnaDevice;
            onDeviceFound?.call(dlnaDevice);
          } else {
            // 已存在设备，更新为最新描述（friendlyName 等可能变化）
            found[dlnaDevice.id] = dlnaDevice;
          }
        }
      });

      await Future.delayed(timeout);
      await _stop();
    } catch (e, stack) {
      AppLogger.reportError(e, stack, '[DlnaDiscovery] discover');
      await _stop();
    }

    AppLogger.log.i('[DlnaDiscovery] 发现 ${found.length} 个设备');
    return found.values.toList();
  }

  /// 停止搜索并释放资源
  Future<void> _stop() async {
    _stopped = true;
    try {
      await _subscription?.cancel();
    } catch (_) {}
    _subscription = null;
    try {
      _manager?.stop();
    } catch (e) {
      AppLogger.log.w('[DlnaDiscovery] stop 失败: $e');
    }
    _manager = null;
    // 注意：deviceManager 保留引用，供 DlnaCastService.connect 查找底层设备
    // 但下次 discover 会覆盖；调用方应在 connect 完成前不要再次 discover
  }

  /// 将 dlna_dart 的 DLNADevice 映射为项目内部 DlnaDevice
  DlnaDevice _mapToDevice(String key, DLNADevice dlnaDevice) {
    final info = dlnaDevice.info;
    // 检查 serviceList 是否包含 AVTransport / RenderingControl 服务
    final hasAvTransport = info.serviceList.any(
      (s) =>
          (s['serviceId'] as String?)?.contains('AVTransport') == true ||
          (s['serviceType'] as String?)?.contains('AVTransport') == true,
    );
    final hasRenderingControl = info.serviceList.any(
      (s) =>
          (s['serviceId'] as String?)?.contains('RenderingControl') == true ||
          (s['serviceType'] as String?)?.contains('RenderingControl') == true,
    );

    return DlnaDevice(
      id: key,
      name: info.friendlyName.isNotEmpty ? info.friendlyName : key,
      location: info.URLBase,
      avTransportUrl: hasAvTransport ? '${info.URLBase}/AVTransport' : null,
      renderingControlUrl: hasRenderingControl
          ? '${info.URLBase}/RenderingControl'
          : null,
    );
  }

  /// 关闭并释放所有资源
  void dispose() {
    _stopped = true;
    _subscription?.cancel();
    _subscription = null;
    _manager?.stop();
    _manager = null;
    _deviceManager = null;
  }
}
