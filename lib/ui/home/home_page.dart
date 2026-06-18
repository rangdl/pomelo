import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/routers/app_router.gr.dart';
import 'package:pomelo/modules/home/providers/home_providers.dart';
import 'package:pomelo/ui/music/music_section.dart';
import 'package:pomelo/ui/music/playlist_section.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Home 页面
///
/// 通过 M.A.R.S. 模块的 Provider 获取数据，不直接依赖 Repository。
@RoutePage()
class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(homeRepositoryProvider);
    // final theme = Theme.of(context);

    return Scaffold(
      headers: [
        AppBar(
          title: SizedBox(
            height: 36,
            child: TextField(
              placeholder: const Text('搜索歌曲...'),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  context.pushRoute(MusicSearchRoute(keyword: value.trim()));
                }
              },
              features: [
                InputFeature.leading(
                  const Icon(Icons.search, size: 18),
                ),
              ],
            ),
          ),
          trailing: [const SourceSwitchButton()],
        ),
      ],
      child: FutureBuilder(
        future: repository.fetchAll(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 歌单分类版块
              const PlaylistSection(),

              // 分隔线
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(),
              ),

              // 音乐列表版块
              const MusicSection(),
            ],
          );
        },
      ),
    );
  }
}

// const _iconMap = {
//   'home': Icons.home,
//   'layers': Icons.layers,
//   'bolt': Icons.bolt,
//   'route': Icons.route,
//   'favorite': Icons.favorite,
//   'star': Icons.star,
// };
