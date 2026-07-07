/// SSDP 设备发现服务
///
/// 使用 Dart `RawDatagramSocket` 实现 UDP 多播 M-SEARCH，发现局域网内
/// 支持 DLNA/UPnP AVTransport 服务的渲染设备（智能电视、网络音箱等）。
///
/// 发现流程：
/// 1. 向 SSDP 多播地址 `239.255.255.250:1900` 发送 M-SEARCH 消息
/// 2. 监听 UDP 响应，按 USN 去重
/// 3. 对每个响应的 LOCATION URL 发起 HTTP GET 获取设备描述 XML
/// 4. 手写解析 XML 提取 friendlyName、manufacturer、modelName
/// 5. 解析 serviceList 找到 AVTransport / RenderingControl 的 controlURL
///
/// 设计要点：
/// - 不依赖 xml 包（pubspec 中未引入），用正则做轻量解析
/// - 设备描述 XML 可能很大，限制 `Options(receiveTimeout)` 避免卡死
/// - controlURL 可能是相对路径，基于 location 用 `Uri.resolve` 拼接
/// - 所有 IO 失败用 try/catch，记录日志后跳过，不抛出
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pomelo/services/cast/dlna_device.dart';
import 'package:pomelo/services/logger/logger.dart';

/// SSDP 多播地址
const _ssdpAddress = '239.255.255.250';
const _ssdpPort = 1900;
const _ssdpMulticastUrl = '$_ssdpAddress:$_ssdpPort';

/// AVTransport 服务类型
const _avTransportServiceType =
    'urn:schemas-upnp-org:service:AVTransport:1';

/// RenderingControl 服务类型
const _renderingControlServiceType =
    'urn:schemas-upnp-org:service:RenderingControl:1';

/// SSDP 设备发现服务
class DlnaDiscovery {
  /// HTTP 客户端（用于获取设备描述 XML）
  final Dio _dio;

  DlnaDiscovery({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 3),
                receiveTimeout: const Duration(seconds: 5),
                responseType: ResponseType.plain,
              ),
            );

  /// 发现设备
  ///
  /// 发送 M-SEARCH 并在 [timeout] 后返回结果。
  /// 每发现一个新设备（按 USN 去重）调用 [onDeviceFound] 回调。
  ///
  /// 注意：M-SEARCH 会发送多种 ST（Search Target）以兼顾严格匹配
  /// AVTransport 的设备与仅响应 `ssdp:all` 的设备。
  Future<List<DlnaDevice>> discover({
    Duration timeout = const Duration(seconds: 5),
    void Function(DlnaDevice device)? onDeviceFound,
  }) async {
    final found = <String, DlnaDevice>{};
    RawDatagramSocket? socket;

    try {
      socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0, // 任意可用端口
      );
      // 加入多播组，确保能收到多播响应
      try {
        socket.joinMulticast(InternetAddress(_ssdpAddress));
      } catch (e, stack) {
        // 部分平台加入多播可能失败，记录但不中断（仍可能收到单播响应）
        AppLogger.log.w('[DlnaDiscovery] joinMulticast 失败: $e');
        AppLogger.reportError(e, stack, '[DlnaDiscovery] joinMulticast');
      }

      // 监听响应
      final subscription = socket.listen(
        (event) async {
          if (event != RawSocketEvent.read) return;
          final datagram = socket?.receive();
          if (datagram == null) return;
          await _handleResponse(datagram, found, onDeviceFound);
        },
        onError: (e, stack) {
          AppLogger.reportError(e, stack, '[DlnaDiscovery] socket listen');
        },
      );

      // 发送多种 ST 的 M-SEARCH
      await _sendMSearch(socket, _avTransportServiceType);
      await _sendMSearch(socket, 'ssdp:all');
      await _sendMSearch(socket, 'upnp:rootdevice');

      // 等待超时收集响应
      await Future.delayed(timeout);
      await subscription.cancel();
    } catch (e, stack) {
      AppLogger.reportError(e, stack, '[DlnaDiscovery] discover');
    } finally {
      try {
        socket?.close();
      } catch (_) {}
    }

    AppLogger.log.i('[DlnaDiscovery] 发现 ${found.length} 个设备');
    return found.values.toList();
  }

  /// 发送一条 M-SEARCH 消息
  Future<void> _sendMSearch(RawDatagramSocket socket, String st) async {
    final message = 'M-SEARCH * HTTP/1.1\r\n'
        'HOST: $_ssdpMulticastUrl\r\n'
        'MAN: "ssdp:discover"\r\n'
        'MX: 3\r\n'
        'ST: $st\r\n'
        '\r\n';
    try {
      socket.send(
        utf8.encode(message),
        InternetAddress(_ssdpAddress),
        _ssdpPort,
      );
    } catch (e, stack) {
      AppLogger.reportError(e, stack, '[DlnaDiscovery] _sendMSearch($st)');
    }
  }

  /// 处理 SSDP 响应数据
  Future<void> _handleResponse(
    Datagram datagram,
    Map<String, DlnaDevice> found,
    void Function(DlnaDevice)? onDeviceFound,
  ) async {
    final String text;
    try {
      text = utf8.decode(datagram.data, allowMalformed: true);
    } catch (e) {
      return;
    }

    // 仅处理 HTTP 响应（M-SEARCH 应答以 HTTP/ 开头）
    if (!text.startsWith('HTTP/')) return;

    final usn = _parseHeader(text, 'USN');
    final location = _parseHeader(text, 'LOCATION');
    if (usn == null || location == null || usn.isEmpty || location.isEmpty) {
      return;
    }

    // 去重
    if (found.containsKey(usn)) return;

    AppLogger.log.d('[DlnaDiscovery] 发现设备 USN=$usn LOCATION=$location');

    // 优先放入一个最小化的设备记录，确保即使解析失败也能展示
    final initial = DlnaDevice(
      id: usn,
      name: Uri.tryParse(location)?.host ?? '未知设备',
      location: location,
    );
    found[usn] = initial;
    onDeviceFound?.call(initial);

    // 异步获取设备描述补充详细信息
    final detailed = await _fetchDeviceDescription(initial);
    if (detailed != null) {
      found[usn] = detailed;
      onDeviceFound?.call(detailed);
    }
  }

  /// 从响应文本中解析 HTTP 头（不区分大小写）
  String? _parseHeader(String text, String name) {
    final lines = text.split('\r\n');
    for (final line in lines) {
      final idx = line.indexOf(':');
      if (idx <= 0) continue;
      final key = line.substring(0, idx).trim();
      if (key.toUpperCase() == name.toUpperCase()) {
        return line.substring(idx + 1).trim();
      }
    }
    return null;
  }

  /// 获取并解析设备描述 XML
  Future<DlnaDevice?> _fetchDeviceDescription(DlnaDevice device) async {
    try {
      final response = await _dio.get<String>(device.location);
      if (response.data == null || response.data!.isEmpty) return null;

      // 限制处理大小（防止异常巨大的 XML）
      final xml = response.data!;
      if (xml.length > 512 * 1024) {
        AppLogger.log.w(
          '[DlnaDiscovery] 设备描述 XML 过大 (${xml.length} bytes)，跳过: ${device.location}',
        );
        return null;
      }

      return _parseDeviceDescription(device, xml);
    } catch (e, stack) {
      AppLogger.reportError(
        e,
        stack,
        '[DlnaDiscovery] 获取设备描述失败: ${device.location}',
      );
      return null;
    }
  }

  /// 解析设备描述 XML（手写正则解析）
  ///
  /// 提取：
  /// - friendlyName
  /// - manufacturer
  /// - modelName
  /// - AVTransport / RenderingControl 的 controlURL
  DlnaDevice? _parseDeviceDescription(DlnaDevice device, String xml) {
    String? friendlyName = _extractTag(xml, 'friendlyName');
    String? manufacturer = _extractTag(xml, 'manufacturer');
    String? modelName = _extractTag(xml, 'modelName');

    // 解析服务列表
    final avTransportUrl = _extractServiceControlUrl(
      xml,
      _avTransportServiceType,
      device.location,
    );
    final renderingControlUrl = _extractServiceControlUrl(
      xml,
      _renderingControlServiceType,
      device.location,
    );

    return device.copyWith(
      name: (friendlyName != null && friendlyName.isNotEmpty)
          ? friendlyName
          : device.name,
      manufacturer: manufacturer,
      modelName: modelName,
      avTransportUrl: avTransportUrl,
      renderingControlUrl: renderingControlUrl,
    );
  }

  /// 提取首个 XML 标签内的文本
  ///
  /// 兼容带命名空间前缀的标签（如 `<tns:friendlyName>`）。
  String? _extractTag(String xml, String tagName) {
    final pattern = RegExp(
      '<[\\w]*:?$tagName[^>]*>([^<]*)</[\\w]*:?$tagName>',
      caseSensitive: false,
    );
    final match = pattern.firstMatch(xml);
    if (match == null) return null;
    final value = match.group(1)?.trim();
    if (value == null || value.isEmpty) return null;
    // 解码常见 XML 实体
    return _decodeXmlEntities(value);
  }

  /// 从 serviceList 中提取指定服务类型的 controlURL
  ///
  /// XML 结构示例：
  /// ```xml
  /// <service>
  ///   <serviceType>urn:schemas-upnp-org:service:AVTransport:1</serviceType>
  ///   <serviceId>urn:upnp-org:serviceId:AVTransport</serviceId>
  ///   <controlURL>/ctl/AVTransport</controlURL>
  ///   <eventSubURL>/evt/AVTransport</eventSubURL>
  ///   <SCPDURL>/xml/AVTransport.xml</SCPDURL>
  /// </service>
  /// ```
  ///
  /// 控制端点 controlURL 可能是相对路径，需基于 location 拼接为绝对 URL。
  String? _extractServiceControlUrl(
    String xml,
    String serviceType,
    String location,
  ) {
    // 匹配所有 <service>...</service> 块
    final servicePattern = RegExp(
      r'<service>([\s\S]*?)</service>',
      caseSensitive: false,
    );
    for (final match in servicePattern.allMatches(xml)) {
      final block = match.group(1);
      if (block == null) continue;
      if (!block.contains(serviceType)) continue;

      // 提取该 service 块中的 controlURL
      final ctrlPattern = RegExp(
        r'<[\w]*:?controlURL[^>]*>([^<]*)</[\w]*:?controlURL>',
        caseSensitive: false,
      );
      final ctrlMatch = ctrlPattern.firstMatch(block);
      if (ctrlMatch == null) continue;
      final raw = ctrlMatch.group(1)?.trim();
      if (raw == null || raw.isEmpty) continue;

      // 相对路径基于 location 解析为绝对地址
      return _resolveUrl(location, raw);
    }
    return null;
  }

  /// 将可能的相对 URL 基于 base 解析为绝对 URL
  String _resolveUrl(String base, String url) {
    // 已是绝对 URL
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    final baseUri = Uri.tryParse(base);
    if (baseUri == null) return url;
    return baseUri.resolve(url).toString();
  }

  /// 解码 XML 实体（仅处理常见 5 种）
  String _decodeXmlEntities(String s) {
    return s
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'");
  }
}
