/// 音乐搜索结果页面
///
/// 展示根据关键词搜索到的歌曲列表。
library;

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
import 'package:shadcn_flutter/shadcn_flutter.dart'
    hide Colors, TextField, IconButton, showDialog;

import 'package:pomelo/modules/music/model/models.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/ui/music/providers/music_ui_providers.dart';

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
              onPressed: () => context.router.pop(),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ],
          title: SizedBox(
            height: 36,
            child: TextField(
              controller: _searchController,
              autofocus: false,
              decoration: InputDecoration(
                hintText: '搜索歌曲...',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.border,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, size: 20),
                  onPressed: () => _doSearch(_searchController.text),
                  padding: EdgeInsets.zero,
                ),
              ),
              onSubmitted: _doSearch,
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
class _SearchResults extends ConsumerWidget {
  final String keyword;

  const _SearchResults({required this.keyword});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providersAsync = ref.watch(musicProvidersProvider);
    final selectedSourceId = ref.watch(selectedSourceProvider);

    return providersAsync.when(
      data: (providers) {
        // 根据选中的来源过滤
        final filtered = selectedSourceId == null
            ? providers
            : providers.where((p) => p.sourceId == selectedSourceId).toList();
        return _SearchResultsList(providers: filtered, keyword: keyword);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('搜索失败: $error')),
    );
  }
}

/// 搜索结果列表
class _SearchResultsList extends ConsumerStatefulWidget {
  final List<MusicProvider> providers;
  final String keyword;

  const _SearchResultsList({required this.providers, required this.keyword});

  @override
  ConsumerState<_SearchResultsList> createState() => _SearchResultsListState();
}

class _SearchResultsListState extends ConsumerState<_SearchResultsList> {
  List<Song>? _allResults;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  @override
  void didUpdateWidget(covariant _SearchResultsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.keyword != widget.keyword) {
      _allResults = null;
      _isLoading = true;
      _error = null;
      _performSearch();
    }
  }

  Future<void> _performSearch() async {
    if (widget.providers.isEmpty) {
      setState(() {
        _allResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await Future.wait(
        widget.providers.map((p) => p.searchSongs(widget.keyword)),
      );
      final allSongs = results.expand((r) => r.items).toList();
      // 去重（相同 id 只保留一个）
      final seen = <String>{};
      final unique = <Song>[];
      for (final song in allSongs) {
        if (seen.add(song.id)) {
          unique.add(song);
        }
      }
      setState(() {
        _allResults = unique;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('搜索出错: $_error'));
    }

    final songs = _allResults ?? [];
    if (songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('未找到与"${widget.keyword}"相关的歌曲'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            '找到 ${songs.length} 首歌曲',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.music_note,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    title: Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${song.artist}  ·  ${song.formattedDuration}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      song.source.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
