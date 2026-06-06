import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart'
    hide
        Card,
        Divider,
        Column,
        Expanded,
        Row,
        Scaffold,
        AppBar,
        Theme,
        CircularProgressIndicator,
        Center,
        Text;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/routers/app_router.gr.dart';
import 'package:pomelo/modules/home/providers/home_providers.dart';
import 'package:pomelo/ui/music/music_section.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Colors, TextField;

/// Home 页面
///
/// 通过 M.A.R.S. 模块的 Provider 获取数据，不直接依赖 Repository。
@RoutePage()
class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(homeRepositoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      headers: [
        AppBar(
          title: SizedBox(
            height: 36,
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索歌曲...',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                prefixIcon: const Icon(Icons.search, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.colorScheme.border),
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  context.pushRoute(MusicSearchRoute(keyword: value.trim()));
                }
              },
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

          final items = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 原有卡片列表
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      leading: Icon(
                        _iconMap[item.icon] ?? Icons.circle,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      title: Text(item.title),
                      subtitle: item.subtitle.isNotEmpty
                          ? Text(item.subtitle)
                          : null,
                      trailing: GhostButton(
                        size: ButtonSize.small,
                        child: const Icon(Icons.chevron_right, size: 16),
                      ),
                    ),
                  ),
                ),
              ),

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

const _iconMap = {
  'home': Icons.home,
  'layers': Icons.layers,
  'bolt': Icons.bolt,
  'route': Icons.route,
  'favorite': Icons.favorite,
  'star': Icons.star,
};
