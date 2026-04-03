// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/routers/constants.dart';
import 'settings.widgets.dart';

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
