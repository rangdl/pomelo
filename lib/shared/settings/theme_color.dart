import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_store.dart';

/// 主题色选项:全应用唯一强调色来源,持久化到 settings.json。
/// 默认蓝色;新增颜色只许加在这个枚举里。
enum AppThemeColor {
  blue(Color(0xFF3B82F6), '蓝色'),
  orange(Color(0xFFFF7A45), '橙色'),
  green(Color(0xFF34A853), '绿色'),
  purple(Color(0xFF8B5CF6), '紫色'),
  pink(Color(0xFFEC4899), '粉色'),
  teal(Color(0xFF14B8A6), '青色');

  const AppThemeColor(this.color, this.label);

  /// 作为 ColorScheme seed 的颜色值。
  final Color color;

  /// 设置页展示名。
  final String label;
}

/// 主题色初值,由 main() 从设置里读出后注入。
final themeColorInitializerProvider = Provider<AppThemeColor>(
  (ref) => throw UnimplementedError('must be overridden at startup'),
);

final themeColorProvider = NotifierProvider<ThemeColorNotifier, AppThemeColor>(
  ThemeColorNotifier.new,
);

class ThemeColorNotifier extends Notifier<AppThemeColor> {
  @override
  AppThemeColor build() => ref.watch(themeColorInitializerProvider);

  Future<void> set(AppThemeColor color) async {
    if (color == state) return;
    state = color;
    await ref.read(settingsStoreProvider).patch({'themeColor': color.name});
  }
}

/// 启动时读取持久化的主题色;无记录或损坏时默认蓝色。
Future<AppThemeColor> loadThemeColor(SettingsStore store) => Future.value(
  AppThemeColor.values.firstWhere(
    (c) => c.name == store.read<String>('themeColor'),
    orElse: () => AppThemeColor.blue,
  ),
);
