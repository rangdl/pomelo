import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/routers/router.provider.dart';

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
