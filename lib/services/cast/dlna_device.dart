/// DLNA 设备数据模型
///
/// 表示一个通过 SSDP 发现的 DLNA/UPnP 渲染设备（智能电视、网络音箱等）。
///
/// 字段来源：
/// - [id]：SSDP 响应中的 USN（unique service name），保证全局唯一
/// - [name]：设备描述 XML 中的 `<friendlyName>`
/// - [location]：SSDP 响应中的 LOCATION 头，指向设备描述 XML
/// - [avTransportUrl] / [renderingControlUrl]：从设备描述 XML 的 serviceList
///   解析出的服务控制 URL（相对路径已基于 [location] 解析为绝对地址）
///
/// 设计约定：
/// - 不可变模型（`@immutable` + 全 `final` 字段），符合项目规范
/// - 按 [id] 判等（同一设备重复发现可去重）
/// - [isPlayable] 表示设备是否提供 AVTransport 服务，决定是否可投屏
library;

import 'package:flutter/foundation.dart';

@immutable
class DlnaDevice {
  /// 唯一标识（SSDP USN）
  final String id;

  /// 设备显示名称（friendlyName）
  final String name;

  /// 设备描述 XML 的 URL（SSDP LOCATION）
  final String location;

  /// AVTransport 服务控制 URL，null 表示设备未暴露该服务
  final String? avTransportUrl;

  /// RenderingControl 服务控制 URL，null 表示设备未暴露该服务
  final String? renderingControlUrl;

  /// 厂商
  final String? manufacturer;

  /// 设备型号
  final String? modelName;

  const DlnaDevice({
    required this.id,
    required this.name,
    required this.location,
    this.avTransportUrl,
    this.renderingControlUrl,
    this.manufacturer,
    this.modelName,
  });

  /// 设备是否可投屏（必须暴露 AVTransport 服务）
  bool get isPlayable => avTransportUrl != null;

  /// 创建副本
  ///
  /// 用于解析设备描述 XML 后补充 serviceURL 等字段。
  DlnaDevice copyWith({
    String? name,
    String? avTransportUrl,
    String? renderingControlUrl,
    String? manufacturer,
    String? modelName,
  }) {
    return DlnaDevice(
      id: id,
      name: name ?? this.name,
      location: location,
      avTransportUrl: avTransportUrl ?? this.avTransportUrl,
      renderingControlUrl: renderingControlUrl ?? this.renderingControlUrl,
      manufacturer: manufacturer ?? this.manufacturer,
      modelName: modelName ?? this.modelName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DlnaDevice && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'DlnaDevice(id: $id, name: $name, playable: $isPlayable)';
}
