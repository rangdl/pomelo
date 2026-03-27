import 'dart:io';

import 'package:flutter/foundation.dart';

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
}
