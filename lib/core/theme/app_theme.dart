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
    density: Density.compactDensity,
  );

  /// 深色主题
  static ThemeData get dark => ThemeData(
    colorScheme: ColorSchemes.darkSlate,
    typography: _typography,
    density: Density.compactDensity,
  );

  /// 全局字体 — 覆盖 shadcn_flutter 默认的 GeistSans
  static TextStyle get _sans => TextStyle(fontFamily: _fontFamilyPlatform);

  /// 全局 Typography
  static Typography get _typography => Typography.geist(sans: _sans);
}

/// 语义状态色
///
/// 表达「成功 / 警告 / 错误 / 提示」这类与品牌色无关的固定语义，
/// 在深浅两套主题下取值一致，故不放进 [ColorScheme]。
/// Toast、可用性指示等场景一律引用此处，不要再各自写色值。
abstract final class AppStatusColors {
  /// 成功、可用、健康
  static const success = Color(0xFF22C55E);

  /// 警告、部分可用
  static const warning = Color(0xFFF59E0B);

  /// 错误、不可用
  static const error = Color(0xFFEF4444);

  /// 中性提示
  static const info = Color(0xFF3B82F6);
}

/// 布局尺寸常量 — 集中管理 shell 级魔法数字（侧边栏、标题栏）
///
/// 把宽度写死在多个布局 widget 里难以统一调整，故收拢到此处。
abstract final class AppLayout {
  /// 展开态侧边栏宽度（desktop / TV）
  static const double sidebarExpandedWidth = 180;

  /// 收起态侧边栏宽度（tablet）
  static const double sidebarCollapsedWidth = 80;

  /// 顶部标题栏高度
  static const double topBarHeight = 48;
}

/// 侧边栏字号 — 收起态在图标下方显示小标签，展开态显示标签文本
abstract final class AppSidebarText {
  /// 应用名
  static const double appTitle = 16;

  /// 展开态导航 / 条目标签
  static const double label = 13;

  /// 收起态图标下方小标签
  static const double collapsedLabel = 11;
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
