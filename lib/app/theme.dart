import 'package:flutter/material.dart';

import '../shared/ui/tokens.dart';

/// 构建指定亮度和主题色的应用主题。
///
/// 主题色由设置页的 [AppThemeColor] 提供(seed),全应用唯一强调色来源。
/// 背景走 iOS 分组列表风格(浅灰底 + 卡片 / 深灰底 + 深卡片),
/// 组件样式集中在这里统一,页面不写样式覆盖。
ThemeData pomeloTheme(Brightness brightness, Color seedColor) {
  final base = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
  );
  final isDark = brightness == Brightness.dark;
  final scaffoldBg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
  // 列表/卡片底色:浅色下纯白,与灰底形成清爽分层(参照 iOS 设置分组)。
  final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
  // 中性色 surface 家族:seed 派生会带上橙色调,这里统一压成中性灰/白,
  // 让全应用背景、卡片、输入框、浮动条都走同一套干净底色(只在一处定义)。
  final neutralSurface = isDark ? const Color(0xFF2C2C2E) : Colors.white;
  final neutralSurfaceLow = isDark
      ? const Color(0xFF232325)
      : const Color(0xFFF7F7FA);
  final neutralSurfaceHigh = isDark
      ? const Color(0xFF333336)
      : const Color(0xFFEFEFF4);
  final scheme = base.copyWith(
    surface: neutralSurface,
    surfaceContainerLowest: isDark ? const Color(0xFF141416) : Colors.white,
    surfaceContainerLow: neutralSurfaceLow,
    surfaceContainer: isDark
        ? const Color(0xFF282829)
        : const Color(0xFFF7F7FA),
    surfaceContainerHigh: neutralSurfaceHigh,
    surfaceContainerHighest: isDark
        ? const Color(0xFF3A3A3D)
        : const Color(0xFFE8E8EE),
    onSurface: isDark ? const Color(0xFFEDEDED) : const Color(0xFF1C1C1E),
    onSurfaceVariant: isDark
        ? const Color(0xFFA8A8AD)
        : const Color(0xFF6B6B70),
  );
  final buttonShape = RoundedRectangleBorder(
    borderRadius: AppRadius.cardBorder,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scaffoldBg,

    // 顶栏:与页面背景融为一体,标题字号收敛(参照图二「设置」的小标题)。
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: scaffoldBg,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 44,
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
    ),

    // 卡片:无阴影,圆角 12,白底(深色为深卡片),分层只靠色块差。
    cardTheme: CardThemeData(
      elevation: 0,
      color: cardColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
    ),

    // 分割线：0.5 逻辑像素（细分隔线），列表看起来更轻。
    dividerTheme: DividerThemeData(
      space: 1,
      thickness: 0.5,
      color: scheme.outlineVariant,
    ),

    // 桌面侧栏:与内容区有轻微分层(iPad 设置风格)。
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: scheme.surfaceContainerLow,
    ),

    // 列表行:紧凑化(iOS 分组列表的精致密度),全局一处定义。
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: 0,
      ),
      minVerticalPadding: 10,
      dense: true,
      horizontalTitleGap: 10,
      minLeadingWidth: AppIconBadge.size,
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
      labelStyle: const TextStyle(
        fontSize: AppText.rowTitle,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: AppText.rowTitle),
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(width: 2, color: scheme.primary),
      ),
      dividerColor: Colors.transparent,
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
    ),

    // 标签/开关胶囊:Chip 不再用 M3 默认全圆角与描边。
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.badgeBorder),
      side: BorderSide.none,
      backgroundColor: scheme.surfaceContainerHigh,
      selectedColor: scheme.primary.withValues(alpha: 0.14),
      showCheckmark: false,
      labelStyle: TextStyle(
        fontSize: AppText.rowSubtitle,
        color: scheme.onSurface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    ),

    // 滑杆:全应用统一轨道/滑块,播放页只覆盖颜色。
    sliderTheme: SliderThemeData(
      trackHeight: 3,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
      activeTrackColor: scheme.primary,
      inactiveTrackColor: scheme.primary.withValues(alpha: 0.2),
      thumbColor: scheme.primary,
      overlayColor: scheme.primary.withValues(alpha: 0.12),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.onPrimary
            : scheme.outline,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.primary
            : scheme.surfaceContainerHighest,
      ),
    ),

    // 下拉菜单:圆角 12、无重投影,与卡片语言一致。
    popupMenuTheme: PopupMenuThemeData(
      color: scheme.surfaceContainerHigh,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
      textStyle: TextStyle(fontSize: AppText.rowTitle, color: scheme.onSurface),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
    ),

    // 页面转场:桌面用轻量淡入,移动端保持系统缩放过渡。
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
      },
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
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
