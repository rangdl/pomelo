import 'dart:io';

import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 应用主题配置 — 基于 shadcn_flutter
///
/// 提供 light / dark 两套主题，统一通过此类获取。
/// 全局字体根据平台自动选择：
/// - iOS/macOS: PingFang SC（苹方）
/// - Android: Roboto
/// - Windows: Microsoft YaHei（微软雅黑）
/// - 其他: GeistSans（shadcn_flutter 默认）
class AppTheme {
  /// 浅色主题
  static ThemeData get light => ThemeData(
    colorScheme: ColorSchemes.lightSlate,
    typography: _typography,
  );

  /// 深色主题
  static ThemeData get dark => ThemeData(
    colorScheme: ColorSchemes.darkSlate,
    typography: _typography,
  );

  /// 全局字体 — 覆盖 shadcn_flutter 默认的 GeistSans
  static TextStyle get _sans => TextStyle(fontFamily: _fontFamilyPlatform);

  /// 全局 Typography
  static Typography get _typography => Typography.geist(sans: _sans);
}

/// 跨平台系统字体
String get _fontFamilyPlatform {
  if (Platform.isIOS || Platform.isMacOS) {
    return 'PingFang SC'; // 苹方，仅苹果设备
  }
  if (Platform.isAndroid) {
    return 'Roboto'; // Android 默认
  }
  if (Platform.isWindows) {
    return 'Microsoft YaHei'; // Windows 微软雅黑
  }
  // Linux 或其他平台使用 shadcn_flutter 默认 GeistSans
  return 'GeistSans';
}
