import 'dart:io';

import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    fontFamily: fontFamilyPlatform,
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: Colors.blue,
    ),
    fontFamily: fontFamilyPlatform,
  );
}

/// 系统字体（跨平台）
String get fontFamilyPlatform {
  if (Platform.isIOS || Platform.isMacOS) {
    return 'PingFang SC'; // 苹方，仅苹果设备
  }
  if (Platform.isAndroid) {
    return 'Roboto'; // Android 默认
  }
  if (Platform.isWindows) {
    return 'Microsoft YaHei'; // Windows 微软雅黑
  }
  // if (Platform.isLinux) {
  //   return 'Ubuntu'; // Linux
  // }
  return 'Arial'; // 其他平台回退
}
