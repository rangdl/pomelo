import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../features/playback/data/media_proxy_server.dart';

/// 统一网络封面：按显示尺寸解码 + 首帧淡入 + 内置占位。
///
/// 列表里大量 36–108 逻辑像素的小封面，如果按原图（常见 500–1000px）解码，
/// 内存和首帧耗时都会被放大，因此这里强制按 [decodeWidth] 解码。
class CoverImage extends StatelessWidget {
  const CoverImage({
    super.key,
    required this.url,
    required this.decodeWidth,
    this.icon = Icons.music_note_rounded,
    this.iconSize = 20,
  });

  /// 原始封面地址（可能为空：为空时只显示占位）。
  final String url;

  /// 控件逻辑宽度，用于计算解码尺寸（会乘以设备像素比）。
  final double decodeWidth;
  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = Center(
      child: Icon(icon, size: iconSize, color: scheme.onSurfaceVariant),
    );
    final target = url.trim();
    if (target.isEmpty) {
      return ColoredBox(color: scheme.surfaceContainerHigh, child: placeholder);
    }
    final background = ColoredBox(
      color: scheme.surfaceContainerHigh,
      child: placeholder,
    );

    // 插件常把占位封面写成 `data:image/svg+xml;base64,…`：Flutter 不支持
    // SVG 解码，直接显示占位，避免 NetworkImage 抛「No host specified」。
    if (target.startsWith('data:')) {
      final bytes = _decodeInlineImage(target);
      if (bytes == null) return background;
      return Stack(
        fit: StackFit.expand,
        children: [
          background,
          Image.memory(
            bytes,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => const SizedBox.expand(),
          ),
        ],
      );
    }
    // 非 http(s)（本地路径、未知协议）不走网络加载。
    if (!isRemoteHttpUrl(target)) return background;

    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        background,
        Image.network(
          cachedArtworkUrl(target),
          fit: BoxFit.cover,
          // 上限取 2 倍：避免高分屏下按原始大图解码。
          cacheWidth: (decodeWidth * dpr).round().clamp(1, 1024),
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: child,
            );
          },
          // 失败时保留底层占位图标，不显示断图。
          errorBuilder: (_, _, _) => const SizedBox.expand(),
        ),
      ],
    );
  }

  /// 解出 `data:image/(png|jpeg|gif|webp);base64,…` 的字节；SVG 等不支持。
  static Uint8List? _decodeInlineImage(String uri) {
    final comma = uri.indexOf(',');
    if (comma < 0) return null;
    final meta = uri.substring(5, comma).toLowerCase();
    if (!meta.contains(';base64')) return null;
    if (meta.contains('svg')) return null;
    try {
      return base64Decode(uri.substring(comma + 1));
    } catch (_) {
      return null;
    }
  }
}

/// 圆形头像（歌手封面）复用同一套解码/淡入逻辑。
class CoverAvatar extends StatelessWidget {
  const CoverAvatar({super.key, required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: CoverImage(
          url: url,
          decodeWidth: size,
          icon: Icons.person_rounded,
          iconSize: size * 0.5,
        ),
      ),
    );
  }
}
