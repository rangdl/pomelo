import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/layout/window_class.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/top_toast.dart';
import '../../../shared/widgets/widgets.dart';
import '../../playback/application/player_actions.dart';
import '../../playback/presentation/playback_providers.dart';
import '../../plugins/domain/plugin_record.dart';
import '../../plugins/presentation/plugin_providers.dart';
import '../../plugins/presentation/track_more.dart';
import 'search_providers.dart';

/// 搜索页主体:搜索框 + 类型筛选 + 结果列表。
///
/// 插件切换已上移到标题栏左侧(见 `PluginPickerButton`),这里只展示当前音源。
class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final _controller = TextEditingController();
  String _query = '';
  String _type = 'music';
  int _page = 1;
  bool _loadingMore = false;

  /// 输入防抖：停止输入 450ms 后再真正发起搜索。
  Timer? _debounce;

  static const _allTypes = <(String, String)>[
    ('music', '单曲'),
    ('sheet', '歌单'),
    ('artist', '歌手'),
    ('album', '专辑'),
    ('lyric', '歌词'),
  ];

  /// 当前选中插件支持的搜索类型标签（未声明 supportedSearchType 时展示常规类型）。
  List<(String, String)> _typesFor(PluginRecord plugin) {
    final allowed = plugin.supportedSearchTypes;
    if (allowed.isEmpty) {
      return _allTypes.where((t) => t.$1 != 'lyric').toList();
    }
    return _allTypes.where((t) => allowed.contains(t.$1)).toList();
  }

  /// 换插件后，把当前类型纠正为插件支持的类型。
  void _ensureTypeSupported(PluginRecord plugin) {
    final types = _typesFor(plugin);
    if (types.isEmpty || types.any((t) => t.$1 == _type)) return;
    final preferred = types.first.$1;
    if (_type == preferred) return;
    _type = preferred;
    ref
        .read(searchResultsProvider.notifier)
        .set(const AsyncValue.data(<Map<String, dynamic>>[]));
  }

  String get _typeLabel => _allTypes
      .firstWhere((t) => t.$1 == _type, orElse: () => _allTypes.first)
      .$2;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// 输入变化：防抖后自动搜索；清空时立即清空结果。
  void _onChanged(String text) {
    setState(() {});
    _debounce?.cancel();
    final q = text.trim();
    if (q.isEmpty) return;
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted || _controller.text.trim() != q) return;
      _search(unfocus: false);
    });
  }

  Future<void> _search({bool unfocus = true}) async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    final plugins = ref.read(searchablePluginsProvider);
    if (plugins.isEmpty) return;
    final selectedId = ref.read(selectedSearchPluginProvider);
    final plugin = plugins.firstWhere(
      (p) => p.id == selectedId,
      orElse: () => plugins.first,
    );
    if (unfocus) FocusScope.of(context).unfocus();
    setState(() {
      _query = q;
      _page = 1;
    });
    unawaited(ref.read(searchHistoryProvider.notifier).add(q));
    await ref
        .read(playerActionsProvider)
        .search(plugin, q, page: 1, type: _type);
  }

  /// 切换搜索类型：清空旧结果；已有词则立即按新类型重搜。
  void _switchType(String type) {
    if (_type == type) return;
    setState(() {
      _type = type;
      _query = '';
      _page = 1;
    });
    ref
        .read(searchResultsProvider.notifier)
        .set(const AsyncValue.data(<Map<String, dynamic>>[]));
    if (_controller.text.trim().isNotEmpty) _search();
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
    await ref
        .read(playerActionsProvider)
        .search(plugin, _query, page: next, type: _type);
    if (mounted) {
      setState(() {
        _page = next;
        _loadingMore = false;
      });
    }
  }

  void _clearQuery() {
    _controller.clear();
    ref
        .read(searchResultsProvider.notifier)
        .set(const AsyncValue.data(<Map<String, dynamic>>[]));
    setState(() {
      _query = '';
      _page = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final plugins = ref.watch(searchablePluginsProvider);
    final selectedId = ref.watch(selectedSearchPluginProvider);
    final results = ref.watch(searchResultsProvider);

    if (plugins.isEmpty) {
      return const EmptyState(
        icon: Icons.extension_off_rounded,
        title: '没有可用的搜索插件',
        message: '先到「插件管理」安装或启用一个支持搜索的插件。',
      );
    }
    final current = plugins.firstWhere(
      (p) => p.id == selectedId,
      orElse: () => plugins.first,
    );
    // 插件切换后可能不再支持当前类型：在 build 前纠正，避免请求注定为空。
    _ensureTypeSupported(current);
    final types = _typesFor(current);

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
                hintText: '搜索$_typeLabel',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: results.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_controller.text.isNotEmpty)
                            IconButton(
                              tooltip: '清除',
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: _clearQuery,
                            ),
                          IconButton(
                            tooltip: '搜索',
                            icon: const Icon(Icons.arrow_forward_rounded),
                            onPressed: () => _search(),
                          ),
                        ],
                      ),
              ),
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              onSubmitted: (_) => _search(),
            ),
          ),
          // 类型筛选:纯文字横排,选中 primary + w600,无 Chip 容器。
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.xs,
              AppSpacing.page,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                for (final (value, label) in types)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.lg),
                    child: _TypeTab(
                      label: label,
                      selected: _type == value,
                      onTap: () => _switchType(value),
                    ),
                  ),
                const Spacer(),
                Text(
                  current.platform,
                  style: TextStyle(
                    fontSize: AppText.compact,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (_query.isEmpty) _historyBar(),
          Expanded(
            child: results.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => EmptyState(
                icon: Icons.error_outline_rounded,
                title: '搜索失败',
                message: '$e',
                actions: [
                  FilledButton.tonalIcon(
                    onPressed: () => _search(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('重试'),
                  ),
                ],
              ),
              data: (items) {
                if (items.isEmpty) {
                  return _query.isEmpty
                      ? const EmptyState(
                          icon: Icons.search_rounded,
                          title: '开始搜索',
                          message: '输入关键词，按单曲 / 歌单 / 歌手 / 专辑查看结果。',
                        )
                      : EmptyState(
                          icon: Icons.search_off_rounded,
                          title: '没有找到相关结果',
                          message: '试试更短的关键词，或切换到「$_typeLabel」以外的类型。',
                          actions: [
                            FilledButton.tonalIcon(
                              onPressed: _clearQuery,
                              icon: const Icon(Icons.close_rounded),
                              label: const Text('清空关键词'),
                            ),
                          ],
                        );
                }
                return _type == 'music'
                    ? _trackResults(items)
                    : _collectionResults(items);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 最近搜索（点击直接搜；可单条删除或全部清空）。
  Widget _historyBar() {
    final history = ref.watch(searchHistoryProvider);
    if (history.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xs,
        AppSpacing.page,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: AppSpacing.xs),
            child: Icon(
              Icons.history_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 2,
              children: [
                for (final q in history)
                  InputChip(
                    label: Text(q, style: const TextStyle(fontSize: 12)),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      _controller.text = q;
                      _search();
                    },
                    onDeleted: () =>
                        ref.read(searchHistoryProvider.notifier).remove(q),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: '清空搜索历史',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.delete_sweep_rounded, size: 18),
            onPressed: () => ref.read(searchHistoryProvider.notifier).clear(),
          ),
        ],
      ),
    );
  }

  /// 滚动接近底部时自动加载下一页（桌面端滚轮也能连续翻）。
  Widget _withAutoLoad(Widget list) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 400 &&
            !_loadingMore &&
            ref.read(playerActionsProvider).searchHasMore) {
          _loadMore();
        }
        return false;
      },
      child: list,
    );
  }

  /// 单曲结果：分组卡片 + 点击播放。
  Widget _trackResults(List<Map<String, dynamic>> items) {
    final playing = ref.watch(nowPlayingProvider);
    return _withAutoLoad(
      ListView(
        padding: AppSpacing.pagePadding,
        children: [
          GroupCard(
            dividerIndent: AppSpacing.dividerIndentTrack,
            children: [
              for (final (i, item) in items.indexed)
                TrackTile(
                  item: item,
                  isPlaying: _isSameTrack(item, playing),
                  trailing: TrackMoreButton(item: item),
                  onTap: () => _play(items, i),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _loadMoreFooter(),
        ],
      ),
    );
  }

  /// 判断结果项是否为当前播放曲目。
  bool _isSameTrack(Map<String, dynamic> item, Map<String, dynamic>? playing) {
    if (playing == null) return false;
    if ('${item['_pluginId'] ?? ''}' != '${playing['_pluginId'] ?? ''}') {
      return false;
    }
    final a = '${item['id'] ?? item['title'] ?? ''}';
    return a.isNotEmpty && a == '${playing['id'] ?? playing['title'] ?? ''}';
  }

  /// 歌单/专辑/歌手结果：带封面的行,点击进入详情页。
  Widget _collectionResults(List<Map<String, dynamic>> items) {
    final route = switch (_type) {
      'sheet' => '/sheet',
      'album' => '/album',
      _ => '/artist',
    };
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        GroupCard(
          dividerIndent: AppSpacing.dividerIndentTrack,
          children: [
            for (final item in items)
              CollectionRow(
                item: item,
                fallbackTitle: _typeLabel,
                onTap: () => context.push(route, extra: item),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _loadMoreFooter(),
      ],
    );
  }

  Widget _loadMoreFooter() {
    if (!ref.read(playerActionsProvider).searchHasMore) {
      return const SizedBox.shrink();
    }
    return Center(
      child: TextButton.icon(
        onPressed: _loadingMore ? null : _loadMore,
        icon: _loadingMore
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.expand_more_rounded),
        label: Text(_loadingMore ? '加载中…' : '加载更多'),
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

  void _toast(String message) => TopToast.show(message);
}

/// 纯文字筛选标签。
class _TypeTab extends StatelessWidget {
  const _TypeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: AppRadius.badgeBorder,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppText.rowTitle,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
