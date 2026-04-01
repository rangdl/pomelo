import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/app/app.provider.dart';
import '../../core/routers/router.dart';
import '../../core/rx.dart';

class ExView extends HookConsumerWidget {
  const ExView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      appSettingsProvider.select((v) => v.value!.themeMode),
    );
    // return Fx.box().bg.black.child(Fx.text('page: $name'));
    return Scaffold(
      appBar: AppBar(
        title: Text('示例'),
        // 以下两项确保在滚动后背景色不变
        // elevation: 0 是保持 AppBar 不变的关键
        elevation: 0,
        // 设置 forceMaterialTransparency 防止滚动时的透明度变化
        forceMaterialTransparency: true,
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('外观'),
            trailing: SizedBox(
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
            ),
          ),
          ListTile(
            title: Text('示例1'),
            onTap: () => GoRouter.of(context).pushNamed(Routes.ex1.name),
          ),
          ListTile(
            title: Text('示例2'),
            onTap: () => GoRouter.of(context).pushNamed(Routes.ex2.name),
          ),
        ],
      ),
    );
  }
}

class Ex1View extends HookConsumerWidget {
  const Ex1View({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // return Fx.box().bg.black.child(Fx.text('page: $name'));
    return Scaffold(
      appBar: AppBar(title: Text('示例1')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            onPressed: () {
              final notifier = ref.read(appSettingsProvider.notifier);
              final themeMode = ref.watch(
                appSettingsProvider.select((v) => v.value!.themeMode),
              );
              if (themeMode == ThemeMode.dark) {
                notifier.setThemeMode(ThemeMode.light);
              } else {
                notifier.setThemeMode(ThemeMode.dark);
              }
            },
            child: Text('切换'),
          ),
          TextButton(
            onPressed: () {
              Rx.toast.success("Welcome back!");
            },
            child: Text('toast'),
          ),
        ],
      ),
    );
  }
}

class Ex2View extends StatelessWidget {
  const Ex2View({super.key});
  @override
  Widget build(BuildContext context) {
    // return Fx.box().bg.black.child(Fx.text('page: $name'));
    return Scaffold(
      appBar: AppBar(title: Text('示例2')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            onPressed: () {
              GoRouter.of(context).pop();
            },
            child: Text('back'),
          ),
        ],
      ),
    );
  }
}
