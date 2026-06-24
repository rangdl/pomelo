import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/routers/app_router.gr.dart';
import 'package:pomelo/ui/music/music_section.dart';
import 'package:pomelo/ui/music/playlist_section.dart';
import 'package:pomelo/ui/music/leaderboard_section.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Home 页面
///
/// 展示排行榜、歌单推荐、我的音乐三大版块。
@RoutePage()
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 排行榜版块
          const LeaderboardSection(),

          // 分隔线
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),

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
      ),
    );
  }
}
