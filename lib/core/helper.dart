import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

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

  /// 获取应用数据目录（用于 hive_ce 存储）
  /// 如果不可用则回退到当前工作目录
  static String getAppDataDir() {
    try {
      return Directory.current.path;
    } catch (_) {
      return '.';
    }
  }
}
