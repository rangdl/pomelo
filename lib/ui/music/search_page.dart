/// 音乐搜索结果页面
///
/// 展示根据关键词搜索到的歌曲列表。
library;

import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/pagination/pagination_response.dart';
import 'package:pomelo/modules/music/model/models.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/ui/music/model/merged_song.dart';
import 'package:pomelo/ui/music/model/service_result.dart';
import 'package:pomelo/ui/music/providers/music_ui_providers.dart';
import 'package:pomelo/ui/music/widgets/provider_error_banner.dart';

/// 歌曲搜索结果页面
@RoutePage()
class MusicSearchPage extends ConsumerStatefulWidget {
  final String keyword;

  const MusicSearchPage({super.key, required this.keyword});

  @override
  ConsumerState<MusicSearchPage> createState() => _MusicSearchPageState();
}

class _MusicSearchPageState extends ConsumerState<MusicSearchPage> {
  late final TextEditingController _searchController;
  late String _keyword;

  @override
  void initState() {
    super.initState();
    _keyword = widget.keyword;
    _searchController = TextEditingController(text: _keyword);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _doSearch(String keyword) {
    if (keyword.trim().isEmpty) return;
    setState(() => _keyword = keyword.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          leading: [
            GhostButton(
              onPressed: () => context.router.maybePop(),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ],
          title: SizedBox(
            height: 36,
            child: TextField(
              controller: _searchController,
              autofocus: false,
              placeholder: const Text('搜索歌曲...'),
              onSubmitted: _doSearch,
              features: [
                InputFeature.trailing(
                  GhostButton(
                    density: ButtonDensity.icon,
                    onPressed: () => _doSearch(_searchController.text),
                    child: const Icon(Icons.search, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(),
      ],
      child: _keyword.isEmpty
          ? const Center(child: Text('输入关键词搜索歌曲'))
          : _SearchResults(keyword: _keyword),
    );
  }
}

/// 搜索结果组件
class _SearchResults extends ConsumerStatefulWidget {
  final String keyword;

  const _SearchResults({required this.keyword});

  @override
  ConsumerState<_SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends ConsumerState<_SearchResults> {
  /// 当前选中的 tab 对应的 sourceId，null 表示"全部"
  String? _tabSourceId;

  @override
  void initState() {
    super.initState();
    // 初始 tab 默认选中持久化来源
    _tabSourceId = ref.read(selectedSourceProvider);
  }

  @override
  Widget build(BuildContext context) {
    final module = ref.watch(musicModuleProvider);
    final services = module?.services ?? [];
    final sources = module?.sources ?? [];

    // 按来源类型分组
    final byType = <MusicSourceType, List<MusicSource>>{};
    for (final s in sources) {
      byType.putIfAbsent(s.type, () => []).add(s);
    }
    final types = byType.keys.toList();

    final filtered = _tabSourceId == null
        ? services
        : services.where((s) => s.sourceId == _tabSourceId).toList();

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            children: [
              _TabChip(
                label: '全部',
                selected: _tabSourceId == null,
                onTap: () => setState(() => _tabSourceId = null),
              ),
              ...types.expand((type) {
                final typeSources = byType[type] ?? [];
                if (typeSources.isEmpty) return <Widget>[];
                return [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Center(
                      child: Text(
                        type.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.foreground.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                  ...typeSources.expand((source) {
                    return source.services.map(
                      (p) => _TabChip(
                        label: p.sourceName,
                        selected: _tabSourceId == p.sourceId,
                        onTap: () => setState(() => _tabSourceId = p.sourceId),
                      ),
                    );
                  }),
                ];
              }),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: _SearchResultsList(
            key: ValueKey('${_tabSourceId}_${widget.keyword}'),
            services: filtered,
            keyword: widget.keyword,
          ),
        ),
      ],
    );
  }
}

/// 搜索来源 Tab 标签
class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primary : const Color(0x00000000),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: selected
                  ? colorScheme.primaryForeground
                  : colorScheme.foreground,
              fontWeight: selected ? FontWeight.w600 : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// 搜索结果列表
class _SearchResultsList extends ConsumerStatefulWidget {
  final List<MusicService> services;
  final String keyword;

  const _SearchResultsList({
    super.key,
    required this.services,
    required this.keyword,
  });

  @override
  ConsumerState<_SearchResultsList> createState() => _SearchResultsListState();
}

class _SearchResultsListState extends ConsumerState<_SearchResultsList> {
  List<MergedSong>? _allResults;
  bool _isLoading = true;
  List<({String sourceId, String sourceName, Object error})> _errors = [];

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  @override
  void didUpdateWidget(covariant _SearchResultsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.keyword != widget.keyword ||
        oldWidget.services != widget.services) {
      _allResults = null;
      _isLoading = true;
      _errors = [];
      _performSearch();
    }
  }

  Future<void> _performSearch() async {
    if (widget.services.isEmpty) {
      setState(() {
        _allResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    final results = await safeCallServices<PaginationResponse<Song>>(
      widget.services,
      (s) => (s as MusicService).searchSongs(widget.keyword),
      getId: (s) => (s as MusicService).sourceId,
      getName: (s) => (s as MusicService).sourceName,
    );

    final allSongs = <Song>[];
    final errors = <({String sourceId, String sourceName, Object error})>[];
    for (final r in results) {
      if (r.isSuccess && r.data != null) {
        allSongs.addAll(r.data!.items);
      } else if (r.isError && r.error != null) {
        errors.add((
          sourceId: r.sourceId,
          sourceName: r.sourceName,
          error: r.error!,
        ));
      }
    }

    final merged = mergeSongs(allSongs);

    setState(() {
      _allResults = merged;
      _errors = errors;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final songs = _allResults ?? [];
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        ProviderErrorBanner(errors: _errors),
        if (songs.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 48, color: colorScheme.mutedForeground),
                  const SizedBox(height: 12),
                  Text('未找到与"${widget.keyword}"相关的歌曲'),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    '找到 ${songs.length} 首歌曲',
                    style: TextStyle(color: colorScheme.mutedForeground),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final merged = songs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Card(
                          child: ListTile(
                            leading: Icon(Icons.music_note, color: colorScheme.primary, size: 24),
                            title: Text(
                              merged.primary.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${merged.primary.artist}  ·  ${merged.primary.formattedDuration}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              merged.displaySources,
                              style: const TextStyle(fontSize: 12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
