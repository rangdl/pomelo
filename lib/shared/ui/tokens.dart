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

  /// 页面水平边距。
  static const double page = lg;

  /// 分组列表页整体 padding(底部预留浮动条/底栏空间)。
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(page, sm, page, xl);

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

/// 设置行等"语义图标"的徽章底色/前景(参照 uzn 的蓝色图标块)。
abstract final class AppIconBadge {
  static const double size = 34;
  static const double glyphSize = 20;

  static Color background(Brightness b) => b == Brightness.dark
      ? const Color(0xFF2C3B52)
      : const Color(0xFFE7F0FE);

  static Color foreground(Brightness b) => b == Brightness.dark
      ? const Color(0xFF9DBEFF)
      : const Color(0xFF3B82F6);
}

/// 字号令牌(字重在使用处声明:w600 用于行标题/选中态)。
abstract final class AppText {
  /// 分组标题。
  static const double sectionHeader = 13;

  /// 列表行主标题。
  static const double rowTitle = 15;

  /// 列表行副标题。
  static const double rowSubtitle = 12.5;

  /// 紧凑文字:时间、角标、底栏标签。
  static const double compact = 11;
}
