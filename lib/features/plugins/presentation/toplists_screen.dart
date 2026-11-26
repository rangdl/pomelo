import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/layout/window_class.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../../playback/application/player_actions.dart';
import '../../playback/presentation/player_sheet.dart';
import '../domain/plugin_record.dart';
import '../domain/track_origin.dart';
import 'plugin_providers.dart';
import 'track_more.dart';
import 'toplists_providers.dart';

/// 榜单页：按榜单分组展示，点榜单看歌曲，点歌播放。
///
/// [initialItem] 非空时(如从搜索发现区点榜单封面跳入)直接进入该榜单的歌曲列表。
class TopListsScreen extends ConsumerStatefulWidget {
  const TopListsScreen({super.key, this.initialItem});

  /// 进入页面即打开的榜单项(与插件 getTopLists 返回的 item 同构)。
  final Map<String, dynamic>? initialItem;

  @override
  ConsumerState<TopListsScreen> createState() => _TopListsScreenState();
}

class _TopListsScreenState extends ConsumerState<TopListsScreen> {
  /// 当前选中的榜单（null 表示还在榜单目录页）。
  Map<String, dynamic>? _selected;
  List<Map<String, dynamic>>? _songs;
  bool _loadingSongs = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialItem;
    if (initial != null) {
      _selected = initial;
      _loadingSongs = true;
      // 等首帧后再读 provider 并拉取歌曲,避免 build 期间改状态。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final plugin = ref.read(toplistPluginProvider);
        if (plugin != null) _openList(plugin, initial);
      });
    }
  }

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
              message: '安装一个支持榜单的插件后即可浏览榜单。',
            )
          : (_selected == null ? _buildCatalog(plugin) : _buildSongs(plugin)),
    );
  }

  Widget _buildCatalog(PluginRecord plugin) {
    final groups = ref.watch(topListGroupsProvider(plugin.id));
    return groups.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(
        icon: Icons.error_outline_rounded,
        title: '加载榜单失败',
        message: '$e',
        actions: [
          FilledButton.tonalIcon(
            onPressed: () => ref.invalidate(topListGroupsProvider(plugin.id)),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('重试'),
          ),
        ],
      ),
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
                        onTap: () => _openList(plugin, item),
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
      return const EmptyState(
        icon: Icons.queue_music_rounded,
        title: '该榜单暂无歌曲',
        message: '换个榜单或稍后再试。',
      );
    }
    return CenteredMaxWidth(
      child: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          GroupCard(
            dividerIndent: AppSpacing.dividerIndentTrack,
            children: [
              for (final (i, item) in songs.indexed)
                TrackTile(
                  item: item,
                  trailing: TrackMoreButton(item: item),
                  onTap: () => _play(songs, i),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openList(PluginRecord plugin, Map<String, dynamic> item) async {
    setState(() {
      _selected = item;
      _loadingSongs = true;
      _songs = null;
    });
    try {
      final rt = await ref.read(pluginRuntimeProvider(plugin.id).future);
      final songs = await rt.getTopListDetail(item);
      // 统一补上来源标记（插件 id + 音源 key），保证能解析播放。
      final enriched = songs.map((s) => tagTrackOrigin(s, plugin)).toList();
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('加载榜单歌曲失败: $e')));
    }
  }

  Future<void> _play(List<Map<String, dynamic>> songs, int index) async {
    try {
      await ref.read(playerActionsProvider).playFromList(songs, index);
      if (mounted) showPlayerSheet(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('播放失败: $e')));
      }
    }
  }
}
