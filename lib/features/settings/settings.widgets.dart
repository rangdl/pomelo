// 外观设置
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/app/app.provider.dart';

// 深色浅色模式切换
class SettingsThemeModeWidget extends HookConsumerWidget {
  const SettingsThemeModeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appSettingsProvider.select((v) => v.themeMode));

    return SizedBox(
      width: 330,
      child: SegmentedButton(
        expandedInsets: const EdgeInsets.only(top: 8.0),
        showSelectedIcon: true,
        selectedIcon: const Icon(Icons.check),
        selected: {themeMode},
        onSelectionChanged: (newSelection) {
          ref
              .read(appSettingsAsyncProvider.notifier)
              .setThemeMode(newSelection.first);
        },
        segments: [
          ButtonSegment(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode),
            label: Text('浅色'),
          ),
          ButtonSegment(
            value: ThemeMode.system,
            icon: Icon(Icons.auto_awesome),
            label: Text('自动'),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode),
            label: Text('深色'),
          ),
        ],
      ),
    );
  }
}
