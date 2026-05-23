import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/components/track_tile/track_tile.dart';
import 'package:pomelo/provider/audio_player/audio_player.dart';
import 'package:pomelo/provider/search/search.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

@RoutePage()
class SearchPage extends HookConsumerWidget {
  static const name = "search";
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final controller = useScrollController();
    // final theme = Theme.of(context);
    // final mediaQuery = MediaQuery.of(context);
    // final layoutMode = ref.watch(
    //   userPreferencesProvider.select((s) => s.layoutMode),
    // );
    final search = ref.watch(searchProvider);
    final playlist = ref.watch(audioPlayerProvider);
    return Scaffold(
      child: CustomScrollView(
        controller: controller,
        slivers: [
          search.when(
            data: (data) {
              return SliverList.builder(
                itemCount: data.items.length,
                itemBuilder: (context, index) {
                  final track = data.items[index];
                  return TrackTile(
                    track: track,
                    playlist: playlist,
                    onTap: () async {
                      await ref.read(audioPlayerProvider.notifier).load([
                        track,
                      ], autoPlay: true);
                    },
                  );
                },
              );
            },
            error: (err, _) => SliverToBoxAdapter(child: Text(err.toString())),
            loading: () =>
                const SliverToBoxAdapter(child: CircularProgressIndicator()),
          ),

          const SliverSafeArea(sliver: SliverGap(10)),
        ],
      ),
    );
  }
}
