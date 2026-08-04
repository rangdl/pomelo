import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pomelo/core/helper.dart';
import 'package:pomelo/services/logger/logger.dart';

/// 音乐流缓存目录管理
///
/// 提供音频流缓存文件的目录路径管理。
/// 缓存目录同时作为本地音乐的默认扫描目录。
///
/// 支持通过 [setCustomDirectory] 设置自定义目录路径，
/// 未设置时使用系统临时目录下的 `music_cache` 子目录。
class MusicCacheDir {
  static const String _subDir = 'music_cache';

  /// 自定义缓存目录路径，null 表示使用系统默认临时目录
  static String? _customPath;

  /// 缓存大小上限（GB），由 [setSizeLimit] 设置，默认 1GB
  static int _sizeLimitGB = 1;

  /// 设置自定义缓存目录路径
  ///
  /// 传入 null 恢复为系统默认临时目录。
  /// 调用后会重置缓存的路径 Future，下次 [getOrCreate] 会重新初始化。
  static void setCustomDirectory(String? path) {
    _customPath = path;
    _cachedPath = null;
  }

  /// 设置缓存大小上限（GB），范围 1~5
  static void setSizeLimit(int gb) {
    _sizeLimitGB = gb.clamp(1, 5);
  }

  /// 获取当前缓存大小上限（GB）
  static int get sizeLimitGB => _sizeLimitGB;

  /// 获取缓存目录路径（确保目录存在）
  static Future<String> get path async {
    final cacheDir = _customPath != null
        ? Directory(_customPath!)
        : Directory(p.join((await getTemporaryDirectory()).path, _subDir));
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

  static Future<String> getCacheFilePath(
    String trackId,
    String extension,
  ) async {
    final dir = await getOrCreate();
    // 清理 trackId 为安全文件名
    final safeName = trackId.replaceAll(RegExp(r'[^\w\-]'), '_');
    return p.join(dir, '$safeName$extension');
  }

  /// 从 Content-Type 推断扩展名
  static String extensionFromContentType(String? contentType) {
    if (contentType == null) return '.mp3';
    final ct = contentType.toLowerCase();
    if (ct.contains('flac') || ct.contains('ogg')) return '.flac';
    if (ct.contains('wav')) return '.wav';
    // if (ct.contains('ogg')) return '.ogg';
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
        if ({
          '.mp3',
          '.flac',
          '.wav',
          '.ogg',
          '.m4a',
          '.aac',
          '.wma',
        }.contains(ext)) {
          return ext;
        }
      }
    } catch (_) {}
    return '.mp3';
  }

  /// 从扩展名推断 Content-Type
  ///
  /// 与 [extensionFromContentType] / [extensionFromUrl] 互逆，用于本地缓存文件响应。
  static String contentTypeFromExtension(String extension) {
    final ext = extension.toLowerCase();
    if (!ext.startsWith('.')) {
      return 'audio/mpeg';
    }
    switch (ext) {
      case '.flac':
        return 'audio/flac';
      case '.wav':
        return 'audio/wav';
      case '.ogg':
        return 'audio/ogg';
      case '.m4a':
      case '.mp4':
        return 'audio/mp4';
      case '.aac':
        return 'audio/aac';
      case '.wma':
        return 'audio/x-ms-wma';
      case '.mp3':
      default:
        return 'audio/mpeg';
    }
  }

  /// 检查缓存文件是否存在
  static Future<bool> exists(String trackId, String extension) async {
    final file = await getCacheFile(trackId, extension);
    return file.exists();
  }

  /// 已知的音频缓存文件扩展名
  static const _audioExtensions = {
    '.mp3',
    '.flac',
    '.wav',
    '.ogg',
    '.m4a',
    '.aac',
    '.wma',
  };

  /// 清空缓存目录
  ///
  /// 仅删除已知音频扩展名的文件，避免误删同目录下的非缓存文件（如数据库）。
  static Future<void> clear() async {
    try {
      final dir = await getOrCreate();
      final cacheDir = Directory(dir);
      if (await cacheDir.exists()) {
        await for (final entity in cacheDir.list()) {
          if (entity is File) {
            final ext = p.extension(entity.path).toLowerCase();
            if (_audioExtensions.contains(ext)) {
              await entity.delete();
            }
          }
        }
      }
    } catch (e, s) {
      AppLogger.reportError(e, s, '[MusicCacheDir] 清空缓存失败');
    }
  }

  /// 获取当前缓存总大小（字节）
  ///
  /// 仅统计已知音频扩展名的文件大小。
  /// 目录不存在或读取失败返回 0。
  static Future<int> getCacheSize() async {
    try {
      final dir = await getOrCreate();
      final cacheDir = Directory(dir);
      if (!await cacheDir.exists()) return 0;
      var total = 0;
      await for (final entity in cacheDir.list(recursive: false)) {
        if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();
          if (!_audioExtensions.contains(ext)) continue;
          try {
            total += await entity.length();
          } catch (_) {}
        }
      }
      return total;
    } catch (e, s) {
      AppLogger.reportError(e, s, '[MusicCacheDir] 读取缓存大小失败');
      return 0;
    }
  }

  /// 按当前上限清理旧缓存文件
  ///
  /// 如果缓存总大小超过 [_sizeLimitGB] 转换的字节数，
  /// 按 `lastModified` 升序删除最旧的文件，直到总大小 <= 上限。
  static Future<void> enforceLimit() async {
    try {
      final limitBytes = _sizeLimitGB * 1024 * 1024 * 1024;
      final dir = await getOrCreate();
      final cacheDir = Directory(dir);
      if (!await cacheDir.exists()) return;

      // 收集所有音频缓存文件及其大小和修改时间
      final files = <_CacheFileEntry>[];
      await for (final entity in cacheDir.list(recursive: false)) {
        if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();
          if (!_audioExtensions.contains(ext)) continue;
          try {
            final stat = await entity.stat();
            files.add(
              _CacheFileEntry(
                file: entity,
                size: stat.size,
                modified: stat.modified,
              ),
            );
          } catch (_) {}
        }
      }

      var totalSize = files.fold<int>(0, (sum, e) => sum + e.size);
      if (totalSize <= limitBytes) return;

      // 按修改时间升序（最旧先删）
      files.sort((a, b) => a.modified.compareTo(b.modified));
      for (final entry in files) {
        if (totalSize <= limitBytes) break;
        try {
          await entry.file.delete();
          totalSize -= entry.size;
        } catch (_) {}
      }
    } catch (e, s) {
      AppLogger.reportError(e, s, '[MusicCacheDir] 缓存淘汰失败');
    }
  }

  /// 在系统文件管理器中打开缓存目录
  ///
  /// 各平台调用方式：
  /// - Windows: `explorer.exe "<path>"`
  /// - macOS:   `open "<path>"`
  /// - Linux:   `xdg-open "<path>"`
  ///
  /// 返回 true 表示成功打开，false 表示平台不支持或调用失败。
  static Future<bool> openDirectory() async {
    try {
      final dir = await getOrCreate();
      String command;
      List<String> args;
      if (Helper.isWindows) {
        command = 'explorer.exe';
        args = [dir];
      } else if (Helper.isMacos) {
        command = 'open';
        args = [dir];
      } else if (Helper.isLinux) {
        command = 'xdg-open';
        args = [dir];
      } else {
        return false;
      }
      final result = await Process.run(command, args);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}

/// 缓存文件条目（内部用于 [MusicCacheDir.enforceLimit] 排序）
class _CacheFileEntry {
  final File file;
  final int size;
  final DateTime modified;

  const _CacheFileEntry({
    required this.file,
    required this.size,
    required this.modified,
  });
}
