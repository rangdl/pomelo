import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/collections/routes.gr.dart';
import 'package:pomelo/components/titlebar/titlebar.dart';
import 'package:pomelo/modules/root/bottom_player.dart';
import 'package:pomelo/modules/root/sidebar/sidebar.dart';
import 'package:pomelo/modules/root/spotube_navigation_bar.dart';
import 'package:pomelo/provider/search/search.dart';
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
              child: AutoRouter(
                builder: (context, content) => Column(
                  children: [
                    if (kTitlebarVisible)
                      TitleBar(
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 200,
                              child: TextField(
                                features: [
                                  // Leading icon only visible when the text is empty
                                  InputFeature.leading(
                                    StatedWidget.builder(
                                      builder: (context, states) {
                                        // Use a muted icon normally, switch to the full icon on hover
                                        if (states.hovered) {
                                          return const Icon(Icons.search);
                                        } else {
                                          return const Icon(
                                            Icons.search,
                                          ).iconMutedForeground();
                                        }
                                      },
                                    ),
                                    visibility:
                                        InputFeatureVisibility.textEmpty,
                                  ),
                                  // Clear button visible when there is text and the field is focused,
                                  // or whenever the field is hovered
                                  InputFeature.clear(
                                    visibility:
                                        (InputFeatureVisibility.textNotEmpty &
                                            InputFeatureVisibility.focused) |
                                        InputFeatureVisibility.hovered,
                                  ),
                                ],
                                placeholder: const Text('搜索'),
                                onSubmitted: (value) {
                                  ref
                                      .watch(searchTermProvider.notifier)
                                      .set(value);
                                  context.navigateTo(const SearchRoute());
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(child: content),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return scaffold;
  }
}
