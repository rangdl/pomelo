import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/layout/window_class.dart';
import '../../../shared/settings/app_font.dart';
import '../../../shared/settings/theme_color.dart';
import '../../../shared/settings/theme_mode.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/widgets.dart';

/// 外观设置：主题模式 / 主题色 / 字体。
class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeOptionProvider);
    final themeColor = ref.watch(themeColorProvider);
    final font = ref.watch(appFontProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('外观设置')),
      body: CenteredMaxWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            AppSpacing.floatingPlayerInset,
          ),
          children: [
            const SectionHeader('外观'),
            GroupCard(
              children: [
                SettingsItem(
                  icon: Icons.dark_mode_rounded,
                  title: '主题模式',
                  subtitle: themeMode.label,
                  onTap: () => _pickThemeMode(context, ref, themeMode),
                ),
                SettingsItem(
                  icon: Icons.palette_rounded,
                  title: '主题色',
                  subtitle: themeColor.label,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: themeColor.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  onTap: () => _pickThemeColor(context, ref, themeColor),
                ),
                SettingsItem(
                  icon: Icons.font_download_rounded,
                  title: '字体',
                  subtitle: font.label,
                  onTap: () => _pickFont(context, ref, font),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
          SelectionOption(value: mode, label: mode.label),
      ],
    );
    if (picked != null) {
      await ref.read(themeModeOptionProvider.notifier).set(picked);
    }
  }

  /// 主题色选择弹层:色板网格,选中项打勾。
  Future<void> _pickThemeColor(
    BuildContext context,
    WidgetRef ref,
    AppThemeColor current,
  ) async {
    final picked = await showAppModal<AppThemeColor>(
      context: context,
      title: '主题色',
      body: (ctx) => Wrap(
        spacing: AppSpacing.xl,
        runSpacing: AppSpacing.lg,
        alignment: WrapAlignment.center,
        children: [
          for (final option in AppThemeColor.values)
            _ColorSwatch(
              color: option,
              selected: option == current,
              onTap: () => Navigator.pop(ctx, option),
            ),
        ],
      ),
    );
    if (picked != null) {
      await ref.read(themeColorProvider.notifier).set(picked);
    }
  }

  /// 字体选择：系统默认 / 内置（与 loomy 同款）/ 自定义上传。
  Future<void> _pickFont(
    BuildContext context,
    WidgetRef ref,
    AppFontSelection current,
  ) async {
    final action = await showAppModal<String>(
      context: context,
      title: '字体',
      isScrollControlled: true,
      body: (ctx) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                '内置字体与 loomy 同款，中英文观感统一；也可以上传本地字体文件。',
                style: TextStyle(
                  fontSize: AppText.rowSubtitle,
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            RadioGroup<AppFontKind>(
              groupValue: current.kind,
              onChanged: (kind) {
                if (kind != null) Navigator.pop(ctx, kind.id);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final kind in AppFontKind.values)
                    RadioListTile<AppFontKind>(
                      value: kind,
                      title: Text(kind.label),
                      subtitle: switch (kind) {
                        AppFontKind.system => null,
                        AppFontKind.bundled => const Text(bundledFontLabel),
                        AppFontKind.custom =>
                          current.customName == null
                              ? const Text('未上传，请从下方导入')
                              : Text(current.customName!),
                      },
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.upload_file_rounded),
              title: const Text('从文件导入字体'),
              subtitle: const Text('支持 .ttf / .otf / .ttc'),
              onTap: () => Navigator.pop(ctx, 'import'),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    if (action == 'import') {
      await _importFont(context, ref);
      return;
    }
    final notifier = ref.read(appFontProvider.notifier);
    switch (action) {
      case 'system':
        await notifier.useSystem();
      case 'bundled':
        await notifier.useBundled();
      case 'custom':
        final ok = await notifier.useCustom();
        if (!ok && context.mounted) _toast(context, '还没有可用的自定义字体，请先导入');
    }
  }

  /// 选择本地字体文件并立即应用。
  Future<void> _importFont(BuildContext context, WidgetRef ref) async {
    const typeGroup = XTypeGroup(
      label: '字体文件',
      extensions: ['ttf', 'otf', 'ttc'],
    );
    XFile? file;
    try {
      file = await openFile(acceptedTypeGroups: const [typeGroup]);
    } catch (e) {
      if (context.mounted) _toast(context, '打开文件选择器失败: $e');
      return;
    }
    if (file == null || !context.mounted) return;
    final ok = await ref
        .read(appFontProvider.notifier)
        .importFont(File(file.path), originalName: file.name);
    if (!context.mounted) return;
    _toast(context, ok ? '已应用字体：${file.name}' : '字体加载失败，请确认文件是有效的字体');
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

/// 主题色色板圆:44 直径,选中时中心打勾。
class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final AppThemeColor color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.color,
              shape: BoxShape.circle,
            ),
            child: selected
                ? const Icon(Icons.check_rounded, color: Colors.white)
                : null,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            color.label,
            style: TextStyle(
              fontSize: AppText.rowSubtitle,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
