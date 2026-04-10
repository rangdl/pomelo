import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/collections/routes.gr.dart';
import 'package:pomelo/collections/spotube_icons.dart';
import 'package:pomelo/components/titlebar/titlebar.dart';
import 'package:pomelo/extensions/constrains.dart';
import 'package:pomelo/extensions/context.dart';
import 'package:pomelo/models/database/database.dart';
import 'package:pomelo/provider/user_preferences/user_preferences_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

@RoutePage()
class HomePage extends HookConsumerWidget {
  static const name = "home";
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final theme = Theme.of(context);
    final controller = useScrollController();
    final mediaQuery = MediaQuery.of(context);
    final layoutMode = ref.watch(
      userPreferencesProvider.select((s) => s.layoutMode),
    );
    return Scaffold(
      headers: [if (kTitlebarVisible) const TitleBar(height: 30)],
      child: CustomScrollView(
        controller: controller,
        slivers: [
          if (mediaQuery.smAndDown || layoutMode == LayoutMode.compact)
            SliverAppBar(
              floating: true,
              title: DefaultTextStyle(
                style: TextStyle(
                  fontFamily: "Cookie",
                  fontSize: 30,
                  letterSpacing: 1.8,
                  color: theme.colorScheme.foreground,
                ),
                child: const Text("Spotube"),
              ),
              backgroundColor: theme.colorScheme.background,
              foregroundColor: theme.colorScheme.foreground,
              actions: [
                // const ConnectDeviceButton(),
                const Gap(10),
                IconButton.ghost(
                  icon: const Icon(SpotubeIcons.settings, size: 20),
                  onPressed: () {
                    context.navigateTo(const SettingsRoute());
                  },
                ),
                const Gap(10),
              ],
            ),
        ],
      ),
    );
  }
}
