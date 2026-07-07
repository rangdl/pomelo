/// DIDL-Lite 元数据构造工具
///
/// 为 DLNA 投屏构造符合 UPnP MediaServer 规范的 DIDL-Lite XML，
/// 让渲染设备（智能电视/音箱）能显示曲目标题、艺术家、专辑、封面等信息。
///
/// 规范参考：UPnP MediaServer DCP v1.0 + DLNA CTT
///
/// 字段说明：
/// - `dc:title` / `dc:creator`：Dublin Core 标题/创作者
/// - `upnp:artist` / `upnp:album` / `upnp:albumArtURI`：UPnP 扩展字段
/// - `res`：资源描述（含 protocolInfo，部分设备据此选择解码器）
/// - `upnp:class`：对象类型，音乐曲目统一用 `object.item.audioItem.musicTrack`
///
/// 设计要点：
/// - 仅在 coverArt 为 HTTP(S) URL 时填充 `upnp:albumArtURI`，
///   因为本地文件路径设备无法访问
/// - 所有文本字段做 XML 转义
/// - 不依赖 xml 包，手写模板拼接
library;

import 'package:pomelo/core/models/metadata/track.dart';

/// 构造 DIDL-Lite 元数据 XML
///
/// [track]：当前曲目
/// [streamUrl]：实际投送的流媒体 URL（用于 `<res>` 字段）
///
/// 返回完整的 DIDL-Lite XML 字符串，可直接作为 SOAP `CurrentURIMetaData` 参数。
String buildDidlLiteMetadata(Track track, String streamUrl) {
  final title = _escape(track.title);
  final artist = _escape(track.artist ?? '');
  final album = _escape(track.album ?? '');

  // 仅当封面为 HTTP(S) URL 时包含（设备无法访问本地文件路径）
  final coverArt = track.coverArt;
  final albumArtUri = (coverArt != null && _isHttpUrl(coverArt))
      ? '<upnp:albumArtURI>${_escape(coverArt)}</upnp:albumArtURI>'
      : '';

  // protocolInfo：使用通配 content-type，兼容大多数设备
  // 格式：<protocol>:<network>:<content-type>:<additional-info>
  const protocolInfo = 'http-get:*:audio/*:*';

  return '''
<DIDL-Lite xmlns="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/">
  <item id="${track.id}" parentID="0" restricted="1">
    <dc:title>$title</dc:title>
    ${artist.isNotEmpty ? '<dc:creator>$artist</dc:creator>' : ''}
    ${artist.isNotEmpty ? '<upnp:artist>$artist</upnp:artist>' : ''}
    ${album.isNotEmpty ? '<upnp:album>$album</upnp:album>' : ''}
    $albumArtUri
    <res protocolInfo="$protocolInfo">${_escape(streamUrl)}</res>
    <upnp:class>object.item.audioItem.musicTrack</upnp:class>
  </item>
</DIDL-Lite>
'''.trim();
}

/// 判断字符串是否为 HTTP(S) URL
bool _isHttpUrl(String s) {
  final lower = s.toLowerCase();
  return lower.startsWith('http://') || lower.startsWith('https://');
}

/// XML 实体转义
String _escape(String s) {
  if (s.isEmpty) return s;
  return s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}
