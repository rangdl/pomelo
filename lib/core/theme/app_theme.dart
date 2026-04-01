import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme.harmonized(),
    fontFamily: fontFamilyPlatform,
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme.harmonized(),
    fontFamily: fontFamilyPlatform,
    brightness: Brightness.dark,
    // TODO bottom sheet theme is not working
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: darkColorScheme.surface,
    ),
  );
}

const brandColor = Color(0xFF311B92);
const brandColorLight = Color(0xFF604CEC);

final lightColorScheme = ColorScheme.fromSeed(
  seedColor: brandColor,
  brightness: Brightness.light,
);

final darkColorScheme = ColorScheme.fromSeed(
  seedColor: brandColorLight,
  brightness: Brightness.dark,
);

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
