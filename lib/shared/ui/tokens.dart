import 'package:flutter/material.dart';

/// Pomelo 设计令牌:全应用唯一的间距/圆角/图标徽章/字号数值来源。
///
/// 与 UI_DESIGN.md §2–§4 一一对应。新增 UI 只允许使用这里的值;
/// 需要新数值时先改这里,再改文档,不允许在页面里发明新令牌。
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// 页面水平边距(桌面端尽量铺满,左右只留 8)。
  static const double page = sm;

  /// 分割线左缩进 = page(8) + leading + horizontalTitleGap(10)，
  /// 保证分隔线起点与行内文字左边缘重合。
  static const double dividerIndentSettings = 46; // 8 + 28 徽章 + 10
  static const double dividerIndentTrack = 58; // 8 + 40 封面 + 10

  /// 底部浮层占用高度：迷你播放胶囊 + 底部导航胶囊 + 间距，
  /// 列表底部留出这么多，避免最后一行被浮层遮住。
  static const double floatingPlayerInset = 150;

  /// 分组列表页整体 padding(底部预留底部浮层空间)。
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(
    page,
    sm,
    page,
    floatingPlayerInset,
  );

  /// 封面网格间距。
  static const double gridGap = md;
}

abstract final class AppRadius {
  /// 图标块。
  static const double badge = 8;

  /// 分组卡 / 输入框 / 封面。
  static const double card = 12;

  /// 浮动卡(迷你播放条等)。
  static const double floating = 16;

  /// 玻璃底栏(全应用唯一玻璃效果)。
  static const double glass = 26;

  /// 弹层顶角。
  static const double sheet = 28;

  static final BorderRadius badgeBorder = BorderRadius.circular(badge);
  static final BorderRadius cardBorder = BorderRadius.circular(card);
  static final BorderRadius floatingBorder = BorderRadius.circular(floating);
}

/// 设置行等"语义图标"的徽章:底色/前景跟随主题色(全应用只有一个强调色)。
abstract final class AppIconBadge {
  static const double size = 28;
  static const double glyphSize = 16;

  static Color background(ColorScheme scheme) =>
      scheme.primary.withValues(alpha: 0.12);

  static Color foreground(ColorScheme scheme) => scheme.primary;
}

/// 字号令牌(字重在使用处声明:w600 用于行标题/选中态)。
abstract final class AppText {
  /// 分组标题。
  static const double sectionHeader = 12;

  /// 列表行主标题。
  static const double rowTitle = 14;

  /// 列表行副标题。
  static const double rowSubtitle = 12;

  /// 紧凑文字:时间、角标、底栏标签(下限 12,保证可读性)。
  static const double compact = 12;

  /// 网格卡标题。
  static const double cardTitle = 13;

  /// 弹层 / 空状态标题。
  static const double heading = 16;

  /// 详情页头部标题、品牌字。
  static const double detailTitle = 18;

  /// 播放页歌名等大标题。
  static const double displayTitle = 22;
}

/// 覆盖在图片/沉浸页上的一次性颜色(§2 例外表)。
abstract final class AppOverlay {
  /// 播放页背景压暗层。
  static const Color scrim = Color(0xB3000000);

  /// 播放页封面投影。
  static const Color coverShadow = Color(0x66000000);
}
