import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/layout/window_class.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../../playback/application/player_actions.dart';
import '../domain/plugin_record.dart';
import 'plugin_providers.dart';
import 'toplists_providers.dart';

/// 榜单页：按榜单分组展示，点榜单看歌曲，点歌播放。
class TopListsScreen extends ConsumerStatefulWidget {
  const TopListsScreen({super.key});

  @override
  ConsumerState<TopListsScreen> createState() => _TopListsScreenState();
}

class _TopListsScreenState extends ConsumerState<TopListsScreen> {
  /// 当前选中的榜单（null 表示还在榜单目录页）。
  Map<String, dynamic>? _selected;
  List<Map<String, dynamic>>? _songs;
  bool _loadingSongs = false;

  @override
  Widget build(BuildContext context) {
    final plugin = ref.watch(toplistPluginProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selected == null ? '榜单' : '${_selected!['title'] ?? '榜单'}',
        ),
        leading: _selected == null
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() {
                  _selected = null;
                  _songs = null;
                }),
              ),
      ),
      body: plugin == null
          ? const EmptyState(
              icon: Icons.leaderboard_rounded,
              title: '没有支持榜单的插件',
              message: '安装一个带 getTopLists 能力的 MusicFree 插件后即可浏览榜单。',
            )
          : (_selected == null
              ? _buildCatalog(plugin)
              : _buildSongs(plugin)),
    );
  }

  Widget _buildCatalog(PluginRecord plugin) {
    final groups = ref.watch(topListGroupsProvider(plugin.id));
    return groups.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载榜单失败: $e')),
      data: (list) {
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.leaderboard_rounded,
            title: '暂无榜单',
            message: '插件未返回榜单数据。',
          );
        }
        return CenteredMaxWidth(
          child: ListView(
            padding: AppSpacing.pagePadding,
            children: [
              for (final group in list) ...[
                SectionHeader(group.title),
                GroupCard(
                  children: [
                    for (final item in group.items)
                      SettingsItem(
                        icon: Icons.trending_up_rounded,
                        title: '${item['title'] ?? '榜单'}',
                        subtitle: '${item['description'] ?? ''}'.isEmpty
                            ? null
                            : '${item['description']}',
                        onTap: () => _openList(plugin, group, item),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSongs(PluginRecord plugin) {
    if (_loadingSongs) {
      return const Center(child: CircularProgressIndicator());
    }
    final songs = _songs ?? const [];
    if (songs.isEmpty) {
      return const Center(child: Text('该榜单暂无歌曲'));
    }
    return CenteredMaxWidth(
      child: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          GroupCard(
            children: [
              for (final (i, item) in songs.indexed)
                SettingsItem(
                  icon: Icons.music_note_rounded,
                  title: '${item['title'] ?? '未知'}',
                  subtitle: '${item['artist'] ?? ''}',
                  onTap: () => _play(songs, i),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openList(
    PluginRecord plugin,
    TopListGroup group,
    Map<String, dynamic> item,
  ) async {
    setState(() {
      _selected = item;
      _loadingSongs = true;
      _songs = null;
    });
    try {
      final rt = await ref.read(musicFreeRuntimeProvider(plugin).future);
      final songs = await rt.getTopListDetail(item);
      // 补上来源插件与默认 lxSource，保证能解析播放。
      final enriched = songs
          .map((s) => {
                ...s,
                '_pluginId': plugin.id,
                if (s['lxSource'] == null && plugin.lxSource != null)
                  'lxSource': plugin.lxSource,
              })
          .toList();
      if (!mounted) return;
      setState(() {
        _songs = enriched;
        _loadingSongs = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingSongs = false;
        _songs = const [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载榜单歌曲失败: $e')),
      );
    }
  }

  Future<void> _play(List<Map<String, dynamic>> songs, int index) async {
    try {
      await ref.read(playerActionsProvider).playFromList(songs, index);
      if (mounted) context.push('/player');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('播放失败: $e')),
        );
      }
    }
  }
}
