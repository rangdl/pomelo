import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/layout/window_class.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../../playback/application/player_actions.dart';
import '../../plugins/domain/plugin_record.dart';
import '../../plugins/presentation/plugin_providers.dart';
import 'search_providers.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final _controller = TextEditingController();
  String _query = '';
  int _page = 1;
  bool _loadingMore = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    final plugins = ref.read(searchablePluginsProvider);
    if (plugins.isEmpty) return;
    final selectedId = ref.read(selectedSearchPluginProvider);
    final plugin = plugins.firstWhere(
      (p) => p.id == selectedId,
      orElse: () => plugins.first,
    );
    FocusScope.of(context).unfocus();
    _query = q;
    _page = 1;
    await ref.read(playerActionsProvider).search(plugin, q, page: 1);
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _query.isEmpty) return;
    final plugins = ref.read(searchablePluginsProvider);
    if (plugins.isEmpty) return;
    final selectedId = ref.read(selectedSearchPluginProvider);
    final plugin = plugins.firstWhere(
      (p) => p.id == selectedId,
      orElse: () => plugins.first,
    );
    setState(() => _loadingMore = true);
    final next = _page + 1;
    await ref.read(playerActionsProvider).search(plugin, _query, page: next);
    if (mounted) {
      setState(() {
        _page = next;
        _loadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final plugins = ref.watch(searchablePluginsProvider);
    final selectedId = ref.watch(selectedSearchPluginProvider);
    final results = ref.watch(searchResultsProvider);

    if (plugins.isEmpty) {
      return const Center(child: Text('没有支持搜索的 MusicFree 插件'));
    }
    final current = plugins.firstWhere(
      (p) => p.id == selectedId,
      orElse: () => plugins.first,
    );

    // 宽屏下限行宽,内容不拉满整窗。
    return CenteredMaxWidth(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.xs,
              AppSpacing.page,
              0,
            ),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '搜索歌曲',
                prefixIcon: const Icon(Icons.search_rounded),
                // 搜索动作收进输入框内部,不再用外置大按钮。
                suffixIcon: results.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        tooltip: '搜索',
                        icon: const Icon(Icons.arrow_forward_rounded),
                        onPressed: _search,
                      ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.sm,
              AppSpacing.page,
              AppSpacing.xs,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _PluginPicker(
                plugins: plugins,
                current: current,
                onSelected: (picked) => ref
                    .read(selectedSearchPluginProvider.notifier)
                    .select(picked.id),
              ),
            ),
          ),
          Expanded(
            child: results.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  '✗ $e',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              data: (items) => items.isEmpty
                  ? const Center(child: Text('输入关键词开始搜索'))
                  : ListView(
                      padding: AppSpacing.pagePadding,
                      children: [
                        // 结果按分组卡片呈现,与设置页同一套行样式。
                        GroupCard(
                          children: [
                            for (final (i, item) in items.indexed)
                              SettingsItem(
                                icon: Icons.music_note_rounded,
                                title: '${item['title'] ?? '未知'}',
                                subtitle: '${item['artist'] ?? ''}',
                                onTap: () => _play(items, i),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // 还有更多结果时提供「加载更多」。
                        Center(
                          child: ref.read(playerActionsProvider).searchHasMore
                              ? TextButton.icon(
                                  onPressed: _loadingMore ? null : _loadMore,
                                  icon: _loadingMore
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.expand_more_rounded),
                                  label: Text(_loadingMore ? '加载中…' : '加载更多'),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// 从搜索结果第 [index] 首开始播放，整个结果列表成为播放队列。
  Future<void> _play(List<Map<String, dynamic>> items, int index) async {
    _toast('解析中: ${items[index]['title']}');
    try {
      await ref.read(playerActionsProvider).playFromList(items, index);
    } catch (e) {
      if (!mounted) return;
      _toast('播放失败: $e');
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

/// 插件选择器:收缩为内容宽度的胶囊按钮(InputDecorator 会拉满,故用 Container)。
class _PluginPicker extends StatelessWidget {
  const _PluginPicker({
    required this.plugins,
    required this.current,
    required this.onSelected,
  });

  final List<PluginRecord> plugins;
  final PluginRecord current;
  final ValueChanged<PluginRecord> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: current.platform,
      tooltip: '选择搜索插件',
      onSelected: (platform) {
        final picked = plugins.firstWhere(
          (p) => p.platform == platform,
          orElse: () => current,
        );
        onSelected(picked);
      },
      itemBuilder: (context) => [
        for (final p in plugins)
          PopupMenuItem(value: p.platform, child: Text(p.platform)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: AppRadius.cardBorder,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.extension_rounded, size: 16),
            const SizedBox(width: 6),
            Text(current.platform),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
