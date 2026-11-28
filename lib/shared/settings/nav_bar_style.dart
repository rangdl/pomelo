import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_store.dart';

/// 底部导航胶囊的全部可调尺寸。
///
/// 所有数值都是逻辑像素；改这里即可在设置里实时预览。
class NavBarMetrics {
  const NavBarMetrics({
    this.height = 48,
    this.itemWidth = 58,
    this.inset = 2,
    this.iconSize = 20,
    this.fontSize = 12,
    this.iconTextGap = 1,
    this.iconTopPadding = 4,
  });

  /// 胶囊整体高度（含内边距）。
  final double height;

  /// 单个标签的宽度。
  final double itemWidth;

  /// 选中圆与胶囊外框的间距，同时也是胶囊内边距。
  final double inset;

  final double iconSize;
  final double fontSize;

  /// 图标与文字之间的竖直间距。
  final double iconTextGap;

  /// 图标上方的留白。
  final double iconTopPadding;

  /// 选中圆的直径：受高度与格子宽度共同约束，保证不会压到相邻格。
  double get indicatorSize {
    final byHeight = height - inset * 2;
    final byWidth = itemWidth - inset * 2;
    return byHeight < byWidth ? byHeight : byWidth;
  }

  NavBarMetrics copyWith({
    double? height,
    double? itemWidth,
    double? inset,
    double? iconSize,
    double? fontSize,
    double? iconTextGap,
    double? iconTopPadding,
  }) {
    return NavBarMetrics(
      height: height ?? this.height,
      itemWidth: itemWidth ?? this.itemWidth,
      inset: inset ?? this.inset,
      iconSize: iconSize ?? this.iconSize,
      fontSize: fontSize ?? this.fontSize,
      iconTextGap: iconTextGap ?? this.iconTextGap,
      iconTopPadding: iconTopPadding ?? this.iconTopPadding,
    );
  }

  /// 各字段的持久化键名。
  static const _keys = {
    'height': 'navHeight',
    'itemWidth': 'navItemWidth',
    'inset': 'navInset',
    'iconSize': 'navIconSize',
    'fontSize': 'navFontSize',
    'iconTextGap': 'navIconTextGap',
    'iconTopPadding': 'navIconTopPadding',
  };

  /// 只写出与默认值不同的字段，避免 settings.json 里堆冗余。
  Map<String, dynamic> diffToJson() {
    const base = NavBarMetrics();
    final map = <String, dynamic>{};
    void put(String field, double value, double fallback) {
      if (value != fallback) map[_keys[field]!] = value;
    }

    put('height', height, base.height);
    put('itemWidth', itemWidth, base.itemWidth);
    put('inset', inset, base.inset);
    put('iconSize', iconSize, base.iconSize);
    put('fontSize', fontSize, base.fontSize);
    put('iconTextGap', iconTextGap, base.iconTextGap);
    put('iconTopPadding', iconTopPadding, base.iconTopPadding);
    return map;
  }

  /// 从设置里还原；缺失或损坏时回落到默认值。
  static NavBarMetrics fromStore(SettingsStore store) {
    const base = NavBarMetrics();
    double read(
      String field,
      double fallback, {
      double min = 0,
      double max = 200,
    }) {
      final v = store.read<num>(_keys[field]!)?.toDouble();
      if (v == null || v.isNaN) return fallback;
      return v.clamp(min, max).toDouble();
    }

    return NavBarMetrics(
      height: read('height', base.height, min: 36, max: 96),
      itemWidth: read('itemWidth', base.itemWidth, min: 40, max: 120),
      inset: read('inset', base.inset, min: 0, max: 16),
      iconSize: read('iconSize', base.iconSize, min: 12, max: 32),
      fontSize: read('fontSize', base.fontSize, min: 8, max: 18),
      iconTextGap: read('iconTextGap', base.iconTextGap, min: 0, max: 12),
      iconTopPadding: read(
        'iconTopPadding',
        base.iconTopPadding,
        min: 0,
        max: 24,
      ),
    );
  }
}

/// 启动时由 main() 注入已保存的尺寸。
final navBarMetricsInitializerProvider = Provider<NavBarMetrics>(
  (ref) => const NavBarMetrics(),
);

class NavBarMetricsNotifier extends Notifier<NavBarMetrics> {
  @override
  NavBarMetrics build() => ref.watch(navBarMetricsInitializerProvider);

  Future<void> set(NavBarMetrics metrics) async {
    state = metrics;
    await ref.read(settingsStoreProvider).patch(metrics.diffToJson());
  }

  /// 只改其中一个字段（滑杆拖动时用）。
  Future<void> patch({
    double? height,
    double? itemWidth,
    double? inset,
    double? iconSize,
    double? fontSize,
    double? iconTextGap,
    double? iconTopPadding,
  }) {
    return set(
      state.copyWith(
        height: height,
        itemWidth: itemWidth,
        inset: inset,
        iconSize: iconSize,
        fontSize: fontSize,
        iconTextGap: iconTextGap,
        iconTopPadding: iconTopPadding,
      ),
    );
  }
}

final navBarMetricsProvider =
    NotifierProvider<NavBarMetricsNotifier, NavBarMetrics>(
      NavBarMetricsNotifier.new,
    );
