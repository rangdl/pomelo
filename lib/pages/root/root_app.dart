import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/modules/root/bottom_player.dart';
import 'package:pomelo/modules/root/sidebar/sidebar.dart';
import 'package:pomelo/modules/root/spotube_navigation_bar.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';

@RoutePage()
class RootAppPage extends HookConsumerWidget {
  const RootAppPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final scaffold = MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: SafeArea(
        top: false,
        child: Scaffold(
          footers: const [BottomPlayer(), SpotubeNavigationBar()],
          floatingFooter: true,
          child: Sidebar(
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: MediaQuery.paddingOf(
                  context,
                ).copyWith(bottom: 100 * context.theme.scaling),
              ),
              child: const AutoRouter(),
            ),
          ),
        ),
      ),
    );

    return scaffold;
  }
}
