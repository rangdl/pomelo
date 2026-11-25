import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/layout/window_class.dart';
import '../../../shared/settings/audio_quality.dart';
import '../../../shared/settings/theme_mode.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/widgets.dart';

/// 设置页:分组卡片列表(iOS 设置风格),含主题模式切换。
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeOptionProvider);
    final quality = ref.watch(audioQualityProvider);

    // 超宽窗口限行宽,避免列表被拉满整屏。
    return CenteredMaxWidth(
      child: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          const SectionHeader('偏好'),
          GroupCard(
            children: [
              SettingsItem(
                icon: Icons.dark_mode_rounded,
                title: '主题模式',
                subtitle: _themeModeLabel(themeMode),
                onTap: () => _pickThemeMode(context, ref, themeMode),
              ),
              SettingsItem(
                icon: Icons.graphic_eq_rounded,
                title: '默认音质',
                subtitle: quality.label,
                onTap: () => _pickQuality(context, ref, quality),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader('内容源'),
          GroupCard(
            children: [
              SettingsItem(
                icon: Icons.extension_rounded,
                title: 'MusicFree 插件',
                subtitle: '安装与启停 MusicFree 插件',
                onTap: () => context.push('/plugins'),
              ),
              SettingsItem(
                icon: Icons.code_rounded,
                title: 'LX 音源脚本',
                subtitle: '安装与启停 LX 音源脚本',
                onTap: () => context.push('/lx'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _themeModeLabel(ThemeModeOption mode) => switch (mode) {
        ThemeModeOption.system => '跟随系统',
        ThemeModeOption.light => '浅色模式',
        ThemeModeOption.dark => '深色模式',
      };

  Future<void> _pickThemeMode(
    BuildContext context,
    WidgetRef ref,
    ThemeModeOption current,
  ) async {
    final picked = await showSelectionSheet<ThemeModeOption>(
      context: context,
      title: '主题模式',
      current: current,
      options: [
        for (final mode in ThemeModeOption.values)
          SelectionOption(value: mode, label: _themeModeLabel(mode)),
      ],
    );
    if (picked != null) {
      await ref.read(themeModeOptionProvider.notifier).set(picked);
    }
  }

  Future<void> _pickQuality(
    BuildContext context,
    WidgetRef ref,
    AudioQuality current,
  ) async {
    final picked = await showSelectionSheet<AudioQuality>(
      context: context,
      title: '默认音质',
      current: current,
      options: [
        for (final q in AudioQuality.values)
          SelectionOption(value: q, label: q.label),
      ],
    );
    if (picked != null) {
      await ref.read(audioQualityProvider.notifier).set(picked);
    }
  }
}
