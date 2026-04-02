// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/app/app.provider.dart';
import '../../core/routers/router.dart';
import '../../core/routers/router.provider.dart';
import 'settings.provider.dart';

class SettingsView extends HookConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsList(
      sections: [
        SettingsSection(
          title: Text('通用'),
          tiles: [
            SettingsTile(
              title: Text('外观'),
              trailing: const SettingsThemeModeWidget(),
            ),
            SettingsTile.navigation(
              title: Text('首页'),
              onPressed: (context) =>
                  GoRouter.of(context).pushNamed(Routes.settingsHome.name),
            ),
          ],
        ),
      ],
    );
  }
}

class SettingsHomeView extends HookConsumerWidget {
  const SettingsHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navs = ref.watch(navsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('导航设置'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(navsSortProvider),
            icon: Icon(Icons.replay_outlined),
          ),
        ],
      ),
      // 排序
      // body: Container(
      //   width: MediaQuery.of(context).size.width,
      //   alignment: Alignment.center,
      //   padding: EdgeInsetsDirectional.symmetric(horizontal: 24),
      //   child: ReorderableListView.builder(
      //     onReorder: (oldIndex, newIndex) =>
      //         ref.watch(navsProvider.notifier).reorder(oldIndex, newIndex),
      //     itemCount: navs.length,
      //     itemBuilder: (context, index) {
      //       final nav = navs[index];
      //       return ListTile(
      //         key: Key('${nav.id}_$index'),
      //         title: Text(nav.label),
      //       );
      //     },
      //   ),
      // ),
      body: SettingsList(
        sections: [
          SettingsSection(
            tiles: navs
                .map(
                  (nav) => SettingsTile.switchTile(
                    title: Text(nav.label),
                    initialValue: nav.visible,
                    enabled: nav.id != 'home',
                    onToggle: (visible) {
                      ref
                          .watch(settingsNavsAsyncProvider.notifier)
                          .set(nav.id, visible);
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// 外观设置
class SettingsThemeModeWidget extends HookConsumerWidget {
  const SettingsThemeModeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingsProvider.select((v) => v.themeMode));

    return SizedBox(
      width: 330,
      child: SegmentedButton(
        expandedInsets: const EdgeInsets.only(top: 8.0),
        showSelectedIcon: true,
        selectedIcon: const Icon(Icons.check),
        selected: {themeMode},
        onSelectionChanged: (newSelection) {
          ref
              .read(appSettingsProvider.notifier)
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
