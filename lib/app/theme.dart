import 'package:flutter/material.dart';

import '../shared/ui/tokens.dart';

/// 品牌色:全应用唯一的强调色来源。
const Color pomeloBrandColor = Color(0xFFFF7A45);

/// 全应用双主题:浅色 / 深色,seed 均为品牌橙。
/// 背景走 iOS 分组列表风格(浅灰底 + 卡片 / 深灰底 + 深卡片),
/// 组件样式集中在这里统一,页面不写样式覆盖。
ThemeData _buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: pomeloBrandColor,
    brightness: brightness,
  );
  final scaffoldBg = brightness == Brightness.dark
      ? const Color(0xFF1C1C1E)
      : const Color(0xFFF2F2F7);
  final buttonShape = RoundedRectangleBorder(borderRadius: AppRadius.cardBorder);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scaffoldBg,

    // 顶栏:与页面背景融为一体,无分层阴影(iOS 大标题感的收敛版)。
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: scaffoldBg,
      surfaceTintColor: Colors.transparent,
    ),

    // 卡片:无阴影,圆角 12,分层只靠色块差。
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
    ),

    dividerTheme: DividerThemeData(space: 1, thickness: 1, color: scheme.outlineVariant),

    // 桌面侧栏:与内容区有轻微分层(iPad 设置风格)。
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: scheme.surfaceContainerLow,
    ),

    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: AppSpacing.xs,
      ),
    ),

    // 输入框:iOS 搜索框风格,填充色圆角无边框。
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHigh,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadius.cardBorder,
        borderSide: BorderSide.none,
      ),
    ),

    // 标签页:主题色下划线指示,未选中次要色。
    tabBarTheme: TabBarThemeData(
      labelColor: scheme.primary,
      unselectedLabelColor: scheme.onSurfaceVariant,
      labelStyle: const TextStyle(fontSize: AppText.rowTitle, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: AppText.rowTitle),
      indicatorSize: TabBarIndicatorSize.label,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(width: 2, color: scheme.primary),
      ),
      dividerColor: Colors.transparent,
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
    ),

    // 按钮统一圆角 12(替代 M3 默认全圆角,贴合整体卡片语言)。
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(shape: buttonShape),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(shape: buttonShape),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(shape: buttonShape),
    ),
  );
}

final ThemeData pomeloLightTheme = _buildTheme(Brightness.light);
final ThemeData pomeloDarkTheme = _buildTheme(Brightness.dark);
