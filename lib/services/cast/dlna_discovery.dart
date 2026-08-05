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
  bool _listening = false;

  /// 当前 DeviceManager（供 DlnaCastService 取底层 DLNADevice）
  DeviceManager? get deviceManager => _deviceManager;

  /// 是否正在监听
  bool get isListening => _listening;

  /// 开始持续监听设备（投屏页打开期间调用）
  ///
  /// 启动 SSDP 多播监听，[DLNAManager] 内部每 2s 自动重发 M-SEARCH，
  /// 设备列表会持续刷新（在线设备保持、新设备自动加入、离线设备按
  /// 120s 不活跃被清理）。重复调用安全：已在监听则直接返回。
  /// 调用 [stop] 释放 UDP 资源。
  Future<void> start({
    void Function(DlnaDevice device)? onDeviceFound,
  }) async {
    if (_listening) return;
    _listening = true;
    try {
      _manager = DLNAManager();
      _deviceManager = await _manager!.start();
      _subscription = _deviceManager!.devices.stream.listen((deviceList) {
        if (!_listening) return;
        for (final entry in deviceList.entries) {
          // 调用方（discover / cast_provider）按 id 去重
          onDeviceFound?.call(_mapToDevice(entry.key, entry.value));
        }
      });
    } catch (e, stack) {
      AppLogger.reportError(e, stack, '[DlnaDiscovery] start');
      _listening = false;
      await stop();
    }
  }

  /// 停止监听并释放 UDP 端口
  ///
  /// 注意：保留 [_deviceManager] 引用。因为 [DeviceManager.dispose] 仅关闭
  /// 流控制器、不清空 [DeviceManager.deviceList]，后续 [DlnaCastService.connect]
  /// 仍可取回底层 `DLNADevice` 用于 SOAP 控制（含自动重连场景）。
  Future<void> stop() async {
    if (!_listening && _manager == null) return;
    _listening = false;
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
    // _deviceManager 保留引用，供 connect / 重连取底层设备
  }

  /// 一次性发现（向后兼容）：监听 [timeout] 后自动停止并返回最终列表
  Future<List<DlnaDevice>> discover({
    Duration timeout = const Duration(seconds: 5),
    void Function(DlnaDevice device)? onDeviceFound,
  }) async {
    final found = <String, DlnaDevice>{};
    await start(
      onDeviceFound: (device) {
        if (!found.containsKey(device.id)) {
          found[device.id] = device;
          onDeviceFound?.call(device);
        } else {
          // 已存在设备，更新为最新描述（friendlyName 等可能变化）
          found[device.id] = device;
        }
      },
    );
    await Future.delayed(timeout);
    await stop();
    AppLogger.log.i('[DlnaDiscovery] 发现 ${found.length} 个设备');
    return found.values.toList();
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
    _listening = false;
    _subscription?.cancel();
    _subscription = null;
    _manager?.stop();
    _manager = null;
    _deviceManager = null;
  }
}
