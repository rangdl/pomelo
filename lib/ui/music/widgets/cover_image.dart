import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'cover_placeholder.dart';

/// 统一的封面图加载组件
///
/// 封装 `coverArt` 为空/加载失败的兜底逻辑（显示 [CoverPlaceholder]）。
/// 自动识别来源：
/// - `http(s)://` 网络地址：使用 [CachedNetworkImage]（磁盘缓存 + 防盗链请求头）
/// - 本地文件路径：使用 [Image.file]
/// - 空/加载失败：显示 [CoverPlaceholder]
///
/// 可选 [size] 指定正方形边长（为 null 时撑满父容器，常配合 AspectRatio/Expanded 使用）。
/// 可选 [borderRadius] 自动包裹 ClipRRect，省去外部手动裁剪。
class CoverImage extends StatelessWidget {
  final String? coverArt;
  final ColorScheme colorScheme;
  final double? size;
  final BorderRadius? borderRadius;

  const CoverImage({
    super.key,
    required this.coverArt,
    required this.colorScheme,
    this.size,
    this.borderRadius,
  });

  /// 判断是否为网络地址
  static bool _isNetworkUrl(String s) {
    final lower = s.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  /// 根据域名返回防盗链请求头
  ///
  /// 咪咕音乐 CDN (d.musicapp.migu.cn) 等需要 Referer 才能正常返回图片，
  /// 否则返回 403/HTML 导致解码失败显示占位图。
  static Map<String, String> _headersFor(String url) {
    try {
      final host = Uri.parse(url).host.toLowerCase();
      // 咪咕音乐防盗链
      if (host.contains('migu.cn') || host.contains('miguvideo')) {
        return {
          'Referer': 'https://music.migu.cn/',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
              'AppleWebKit/537.36 (KHTML, like Gecko) '
              'Chrome/120.0.0.0 Safari/537.36',
        };
      }
    } catch (_) {}
    return const {};
  }

  @override
  Widget build(BuildContext context) {
    final Widget image;
    if (coverArt == null || coverArt!.isEmpty) {
      image = CoverPlaceholder(
        colorScheme: colorScheme,
        width: size,
        height: size,
      );
    } else if (_isNetworkUrl(coverArt!)) {
      image = CachedNetworkImage(
        imageUrl: coverArt!,
        httpHeaders: _headersFor(coverArt!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) => CoverPlaceholder(
          colorScheme: colorScheme,
          width: size,
          height: size,
        ),
        errorWidget: (_, _, _) => CoverPlaceholder(
          colorScheme: colorScheme,
          width: size,
          height: size,
        ),
      );
    } else {
      // 本地文件路径（如本地音乐封面、缓存的封面图）
      image = Image.file(
        File(coverArt!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => CoverPlaceholder(
          colorScheme: colorScheme,
          width: size,
          height: size,
        ),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
