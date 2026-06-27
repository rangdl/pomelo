/// 应用更新检查服务
///
/// 流程：
/// 1. 通过 jsDelivr 拉取 `@latest` 标签的 `pubspec.yaml`，
///    解析其中的 `version` 字段（含 build number，如 `1.0.26+27`）。
/// 2. 将远程主版本号与本地版本号比对，判断是否有新版本。
/// 3. 有新版本时，根据完整版本号构建当前平台的资源文件名与下载路径。
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pomelo/core/helper.dart';
import 'package:pomelo/core/log.dart';

/// 更新检查结果
@immutable
class UpdateCheckResult {
  /// 是否存在新版本
  final bool hasUpdate;

  /// 本地版本号（如 `1.0.25`）
  final String currentVersion;

  /// 最新版本 tag（如 `v1.0.26`）
  final String? latestTag;

  /// 最新完整版本号（来自 pubspec.yaml，如 `1.0.26+27`）
  final String? latestVersion;

  /// 构建出的下载链接
  final String? downloadUrl;

  /// 失败时的错误信息
  final String? errorMessage;

  const UpdateCheckResult({
    required this.hasUpdate,
    required this.currentVersion,
    this.latestTag,
    this.latestVersion,
    this.downloadUrl,
    this.errorMessage,
  });
}

class UpdateService {
  UpdateService() : _dio = Dio();

  final Dio _dio;

  static const _pubspecLatestUrl =
      'https://cdn.jsdelivr.net/gh/rangdl/pomelo@latest/pubspec.yaml';
  static const _downloadUrlTemplate =
      'https://github.com/rangdl/pomelo/releases/download/{tag}/{filename}';
  static const releasesLatestUrl =
      'https://github.com/rangdl/pomelo/releases/latest';

  /// 将 GitHub 加速地址应用到下载链接
  ///
  /// [proxy] 为用户输入的加速域名，如 `https://proxy.116224.xyz/` 或
  /// `https://116224.xyz`；为空则原样返回 [downloadUrl]。
  ///
  /// 规则：去掉 [proxy] 末尾 `/`，去掉 [downloadUrl] 开头 `https://`，
  /// 拼接为 `{proxy}/{strippedDownloadUrl}`。
  /// 例如：`https://116224.xyz` + `https://github.com/.../file.ipa`
  ///   → `https://116224.xyz/github.com/.../file.ipa`
  static String applyProxy(String downloadUrl, String proxy) {
    final trimmed = proxy.trim();
    if (trimmed.isEmpty) return downloadUrl;
    final normalized = trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    final stripped = downloadUrl.replaceFirst('https://', '');
    return '$normalized/$stripped';
  }

  /// 检查更新
  ///
  /// [currentVersion] 为本地版本号（不含 build number，如 `1.0.25`）。
  Future<UpdateCheckResult> checkForUpdate(String currentVersion) async {
    try {
      final fullVersion = await _fetchPubspecVersion();
      if (fullVersion == null) {
        return UpdateCheckResult(
          hasUpdate: false,
          currentVersion: currentVersion,
          errorMessage: '无法读取远程 pubspec.yaml',
        );
      }

      final remoteMain = _mainVersion(fullVersion);
      final tag = 'v$remoteMain';
      if (!_isNewer(remoteMain, currentVersion)) {
        return UpdateCheckResult(
          hasUpdate: false,
          currentVersion: currentVersion,
          latestTag: tag,
          latestVersion: fullVersion,
        );
      }

      final filename = _buildFilename(fullVersion);
      final downloadUrl = _downloadUrlTemplate
          .replaceAll('{tag}', tag)
          .replaceAll('{filename}', filename);

      log.info(
        'UpdateService',
        '发现新版本: $currentVersion → $fullVersion, 下载: $downloadUrl',
      );

      return UpdateCheckResult(
        hasUpdate: true,
        currentVersion: currentVersion,
        latestTag: tag,
        latestVersion: fullVersion,
        downloadUrl: downloadUrl,
      );
    } catch (e, s) {
      log.error('UpdateService', '检查更新失败', error: e, stackTrace: s);
      return UpdateCheckResult(
        hasUpdate: false,
        currentVersion: currentVersion,
        errorMessage: '检查更新失败: $e',
      );
    }
  }

  /// 从 jsDelivr `@latest` 拉取 pubspec.yaml，解析 version 字段
  Future<String?> _fetchPubspecVersion() async {
    final response = await _dio.get<String>(
      _pubspecLatestUrl,
      options: Options(responseType: ResponseType.plain),
    );
    final body = response.data;
    if (body == null) return null;
    return _parsePubspecVersion(body);
  }

  /// 解析 pubspec.yaml 中的 `version:` 字段
  String? _parsePubspecVersion(String body) {
    final lines = body.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('version:')) {
        final value = trimmed.substring('version:'.length).trim();
        // 去掉可能的引号
        if (value.isEmpty) return null;
        if (value.startsWith('"') && value.endsWith('"')) {
          return value.substring(1, value.length - 1);
        }
        if (value.startsWith("'") && value.endsWith("'")) {
          return value.substring(1, value.length - 1);
        }
        return value;
      }
    }
    return null;
  }

  /// 取版本号 `+` 之前的主版本部分（如 `1.0.26+27` → `1.0.26`）
  String _mainVersion(String fullVersion) {
    return fullVersion.split('+').first;
  }

  /// 判断 [remote] 是否新于 [current]
  ///
  /// 按数字段逐段比较。
  bool _isNewer(String remote, String current) {
    final remoteParts = _parseVersionParts(remote);
    final currentParts = _parseVersionParts(current);
    final len = remoteParts.length > currentParts.length
        ? remoteParts.length
        : currentParts.length;
    for (var i = 0; i < len; i++) {
      final r = i < remoteParts.length ? remoteParts[i] : 0;
      final c = i < currentParts.length ? currentParts[i] : 0;
      if (r > c) return true;
      if (r < c) return false;
    }
    return false;
  }

  /// 将版本号字符串解析为数字段列表
  ///
  /// 仅取 `+` 之前的部分，按 `.` 切分。
  List<int> _parseVersionParts(String version) {
    final main = version.split('+').first;
    return main.split('.').map((e) => int.tryParse(e.trim()) ?? 0).toList();
  }

  /// 根据当前平台构建资源文件名
  ///
  /// 命名约定：`pomelo-{fullVersion}-{platform}.{ext}`
  /// 例如：`pomelo-1.0.26+27-ios.ipa`
  String _buildFilename(String fullVersion) {
    final suffix = _platformAssetSuffix();
    return 'pomelo-$fullVersion-$suffix';
  }

  /// 当前平台对应的资源后缀
  String _platformAssetSuffix() {
    if (Helper.isWindows) return 'windows.zip';
    if (Helper.isMacos) return 'macos.dmg';
    if (Helper.isLinux) return 'linux.tar.gz';
    if (Helper.isAndroid) return 'android.apk';
    if (Helper.isIOS) return 'ios.ipa';
    return 'unknown.zip';
  }
}
