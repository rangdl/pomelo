import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 音乐流缓存目录管理
///
/// 提供音频流缓存文件的目录路径管理。
/// 缓存目录同时作为本地音乐的默认扫描目录。
class MusicCacheDir {
  static const String _subDir = 'music_cache';

  /// 获取缓存目录路径（确保目录存在）
  static Future<String> get path async {
    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory(p.join(tempDir.path, _subDir));
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir.path;
  }

  /// 已缓存的目录路径 Future（首次调用时初始化）
  static Future<String>? _cachedPath;

  /// 获取缓存目录路径（缓存 Future，避免重复 IO）
  static Future<String> getOrCreate() {
    return _cachedPath ??= path;
  }

  /// 生成缓存文件路径
  ///
  /// [trackId] 曲目 ID（会被清理为安全文件名）
  /// [extension] 文件扩展名（如 '.mp3'、'.flac'）
  static Future<File> getCacheFile(String trackId, String extension) async {
    final dir = await getOrCreate();
    // 清理 trackId 为安全文件名
    final safeName = trackId.replaceAll(RegExp(r'[^\w\-]'), '_');
    return File(p.join(dir, '$safeName$extension'));
  }

  /// 从 Content-Type 推断扩展名
  static String extensionFromContentType(String? contentType) {
    if (contentType == null) return '.mp3';
    final ct = contentType.toLowerCase();
    if (ct.contains('flac')) return '.flac';
    if (ct.contains('wav')) return '.wav';
    if (ct.contains('ogg')) return '.ogg';
    if (ct.contains('m4a') || ct.contains('mp4')) return '.m4a';
    if (ct.contains('aac')) return '.aac';
    return '.mp3';
  }

  /// 从 URL 推断扩展名
  static String extensionFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final dotIndex = path.lastIndexOf('.');
      if (dotIndex >= 0) {
        final ext = path.substring(dotIndex).toLowerCase();
        if ({'.mp3', '.flac', '.wav', '.ogg', '.m4a', '.aac', '.wma'}
            .contains(ext)) {
          return ext;
        }
      }
    } catch (_) {}
    return '.mp3';
  }

  /// 检查缓存文件是否存在
  static Future<bool> exists(String trackId, String extension) async {
    final file = await getCacheFile(trackId, extension);
    return file.exists();
  }

  /// 清空缓存目录
  static Future<void> clear() async {
    try {
      final dir = await getOrCreate();
      final cacheDir = Directory(dir);
      if (await cacheDir.exists()) {
        await for (final entity in cacheDir.list()) {
          await entity.delete(recursive: true);
        }
      }
    } catch (_) {}
  }
}
