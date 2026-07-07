/// SOAP 控制服务
///
/// 封装对 DLNA 设备的 AVTransport / RenderingControl 服务的 SOAP 调用。
///
/// 每个方法对应一个 DLNA 标准 Action，发送 POST 请求到设备 serviceURL，
/// 请求体为 SOAP Envelope XML，响应通过正则提取关键字段。
///
/// 设计要点：
/// - 不依赖 xml 包（pubspec 中未引入），用正则做轻量解析
/// - SOAP 失败用 try/catch 捕获并记录日志，对外抛出异常让上层决定如何处理
/// - Duration 与 DLNA 时间格式 `H:MM:SS(.fff)` 互转
library;

import 'package:dio/dio.dart';
import 'package:pomelo/services/cast/dlna_device.dart';
import 'package:pomelo/services/logger/logger.dart';

/// AVTransport 服务 URN
const _avTransportServiceUrn = 'urn:schemas-upnp-org:service:AVTransport:1';

/// RenderingControl 服务 URN
const _renderingControlServiceUrn =
    'urn:schemas-upnp-org:service:RenderingControl:1';

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
  final Dio _dio;

  DlnaControl(this.device, {Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 3),
                receiveTimeout: const Duration(seconds: 5),
              ),
            );

  // ==================== AVTransport ====================

  /// 设置当前媒体 URI
  ///
  /// 必须在 [play] 之前调用。metadata 可选，部分设备会展示元信息。
  Future<void> setAvTransportUri(String uri, {String? metadata}) async {
    final escapedUri = _escapeXml(uri);
    final escapedMetadata = _escapeXml(metadata ?? '');
    final body = _buildSoapEnvelope(
      serviceUrn: _avTransportServiceUrn,
      action: 'SetAVTransportURI',
      args: '''
        <InstanceID>0</InstanceID>
        <CurrentURI>$escapedUri</CurrentURI>
        <CurrentURIMetaData>$escapedMetadata</CurrentURIMetaData>
      ''',
    );
    await _postSoap(
      device.avTransportUrl!,
      actionHeader: '$_avTransportServiceUrn#SetAVTransportURI',
      body: body,
    );
  }

  /// 播放
  Future<void> play() async {
    final body = _buildSoapEnvelope(
      serviceUrn: _avTransportServiceUrn,
      action: 'Play',
      args: '''
        <InstanceID>0</InstanceID>
        <Speed>1</Speed>
      ''',
    );
    await _postSoap(
      device.avTransportUrl!,
      actionHeader: '$_avTransportServiceUrn#Play',
      body: body,
    );
  }

  /// 暂停
  Future<void> pause() async {
    final body = _buildSoapEnvelope(
      serviceUrn: _avTransportServiceUrn,
      action: 'Pause',
      args: '<InstanceID>0</InstanceID>',
    );
    await _postSoap(
      device.avTransportUrl!,
      actionHeader: '$_avTransportServiceUrn#Pause',
      body: body,
    );
  }

  /// 停止
  Future<void> stop() async {
    final body = _buildSoapEnvelope(
      serviceUrn: _avTransportServiceUrn,
      action: 'Stop',
      args: '<InstanceID>0</InstanceID>',
    );
    await _postSoap(
      device.avTransportUrl!,
      actionHeader: '$_avTransportServiceUrn#Stop',
      body: body,
    );
  }

  /// 跳转进度
  ///
  /// [position] 转换为 DLNA 时间格式 `H:MM:SS.fff`。
  Future<void> seek(Duration position) async {
    final target = _formatDuration(position);
    final body = _buildSoapEnvelope(
      serviceUrn: _avTransportServiceUrn,
      action: 'Seek',
      args: '''
        <InstanceID>0</InstanceID>
        <Unit>REL_TIME</Unit>
        <Target>$target</Target>
      ''',
    );
    await _postSoap(
      device.avTransportUrl!,
      actionHeader: '$_avTransportServiceUrn#Seek',
      body: body,
    );
  }

  /// 获取播放进度信息
  ///
  /// 返回当前播放位置、总时长以及时长是否有效。
  /// 部分设备对本地音频可能不返回总时长。
  Future<PositionInfo> getPositionInfo() async {
    final body = _buildSoapEnvelope(
      serviceUrn: _avTransportServiceUrn,
      action: 'GetPositionInfo',
      args: '<InstanceID>0</InstanceID>',
    );
    final response = await _postSoap(
      device.avTransportUrl!,
      actionHeader: '$_avTransportServiceUrn#GetPositionInfo',
      body: body,
    );
    final trackDurationRaw = _extractTag(response, 'TrackDuration') ?? '';
    final relTimeRaw = _extractTag(response, 'RelTime') ?? '';
    final duration = _parseDuration(trackDurationRaw);
    final position = _parseDuration(relTimeRaw);
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
    final body = _buildSoapEnvelope(
      serviceUrn: _avTransportServiceUrn,
      action: 'GetTransportInfo',
      args: '<InstanceID>0</InstanceID>',
    );
    final response = await _postSoap(
      device.avTransportUrl!,
      actionHeader: '$_avTransportServiceUrn#GetTransportInfo',
      body: body,
    );
    return _extractTag(response, 'CurrentTransportState') ?? '';
  }

  // ==================== RenderingControl ====================

  /// 获取音量（0-100）
  Future<int> getVolume() async {
    final url = device.renderingControlUrl;
    if (url == null) return 0;
    final body = _buildSoapEnvelope(
      serviceUrn: _renderingControlServiceUrn,
      action: 'GetVolume',
      args: '''
        <InstanceID>0</InstanceID>
        <Channel>Master</Channel>
      ''',
    );
    final response = await _postSoap(
      url,
      actionHeader: '$_renderingControlServiceUrn#GetVolume',
      body: body,
    );
    final raw = _extractTag(response, 'CurrentVolume') ?? '0';
    final vol = int.tryParse(raw) ?? 0;
    return vol.clamp(0, 100);
  }

  /// 设置音量（0-100）
  Future<void> setVolume(int volume) async {
    final url = device.renderingControlUrl;
    if (url == null) {
      AppLogger.log.w('[DlnaControl] 设备未提供 RenderingControl 服务');
      return;
    }
    final clamped = volume.clamp(0, 100);
    final body = _buildSoapEnvelope(
      serviceUrn: _renderingControlServiceUrn,
      action: 'SetVolume',
      args: '''
        <InstanceID>0</InstanceID>
        <Channel>Master</Channel>
        <DesiredVolume>$clamped</DesiredVolume>
      ''',
    );
    await _postSoap(
      url,
      actionHeader: '$_renderingControlServiceUrn#SetVolume',
      body: body,
    );
  }

  // ==================== 内部工具 ====================

  /// 发送 SOAP POST 请求并返回响应文本
  Future<String> _postSoap(
    String url, {
    required String actionHeader,
    required String body,
  }) async {
    try {
      final response = await _dio.post<String>(
        url,
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'text/xml; charset="utf-8"',
            'SOAPAction': '"$actionHeader"',
          },
          // 5 秒超时由 BaseOptions 提供
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.data ?? '';
    } on DioException catch (e, stack) {
      // 部分设备在出错时仍返回 SOAP fault，记录但向上抛出
      final responseBody = e.response?.data?.toString() ?? '';
      AppLogger.log.w(
        '[DlnaControl] SOAP 调用失败 action=$actionHeader '
        'status=${e.response?.statusCode} body=$responseBody',
      );
      AppLogger.reportError(
        e,
        stack,
        '[DlnaControl] SOAP $actionHeader 失败',
      );
      rethrow;
    } catch (e, stack) {
      AppLogger.reportError(e, stack, '[DlnaControl] SOAP $actionHeader 异常');
      rethrow;
    }
  }

  /// 构建 SOAP Envelope
  ///
  /// [serviceUrn] 服务 URN（如 `urn:schemas-upnp-org:service:AVTransport:1`）
  /// [action] SOAP Action 名称（如 `Play`）
  /// [args] 内部参数 XML 字符串
  String _buildSoapEnvelope({
    required String serviceUrn,
    required String action,
    required String args,
  }) {
    return '<?xml version="1.0" encoding="utf-8"?>'
        '<s:Envelope '
        'xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" '
        's:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
        '<s:Body>'
        '<u:$action xmlns:u="$serviceUrn">'
        '$args'
        '</u:$action>'
        '</s:Body>'
        '</s:Envelope>';
  }

  /// 提取 SOAP 响应中指定 XML 标签内的文本（正则匹配，兼容命名空间前缀）
  String? _extractTag(String xml, String tagName) {
    final pattern = RegExp(
      r'<[\w]*:?' + RegExp.escape(tagName) + r'[^>]*>([^<]*)</[\w]*:?' +
          RegExp.escape(tagName) + r'>',
      caseSensitive: false,
    );
    final match = pattern.firstMatch(xml);
    return match?.group(1)?.trim();
  }

  /// XML 转义
  String _escapeXml(String s) {
    return s
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

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
