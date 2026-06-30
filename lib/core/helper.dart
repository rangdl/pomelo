import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class Helper {
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  static bool get isIOS => !kIsWeb && Platform.isIOS;

  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  static bool get isWindows => !kIsWeb && Platform.isWindows;

  static bool get isMacos => !kIsWeb && Platform.isMacOS;

  static bool get isLinux => !kIsWeb && Platform.isLinux;

  static bool get isWeb => kIsWeb;
  static String get operatingSystem => Platform.operatingSystem;

  // 深色模式
  static bool isDark(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  static bool get isDebug => kDebugMode;

  /// 获取应用文档目录（用于 drift 数据库和日志存储）
  ///
  /// 各平台路径:
  /// - Windows: C:\Users\<用户名>\Documents\pomelo\
  /// - macOS:   ~/Documents/pomelo/
  /// - Linux:   ~/Documents/pomelo/
  /// - 移动端:  应用文档目录
  ///
  /// 确保数据不随项目目录变更而丢失。
  static Future<String> getAppDataDir() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final appDir = Directory('${dir.path}/pomelo');
      if (!await appDir.exists()) {
        await appDir.create(recursive: true);
      }
      return appDir.path;
    } catch (_) {
      // 回退到当前目录
      return Directory.current.path;
    }
  }
}
