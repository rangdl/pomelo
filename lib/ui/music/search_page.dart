/// 音乐搜索结果页面
///
/// 展示根据关键词搜索到的歌曲/歌手/专辑/歌单列表。
/// 搜索框左侧提供搜索类型下拉菜单，类型来源于当前选中服务支持的搜索类型。
///
/// 未输入关键词时展示「搜索历史」与「热搜词」两个区块，点击即触发搜索。
library;

import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/preferences/user_preference_provider.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/core/models/metadata/metadata.dart';
import 'package:pomelo/core/models/music_server_config.dart';
import 'package:pomelo/provider/music/music_server_config_provider.dart';
import 'package:pomelo/ui/music/providers/music_ui_providers.dart';
import 'package:pomelo/ui/music/widgets/app_chip.dart';
import 'package:pomelo/ui/music/widgets/cover_image.dart';
import 'package:pomelo/ui/music/widgets/playable_track_tile.dart';
import 'package:pomelo/ui/music/widgets/provider_error_banner.dart';
import 'package:pomelo/ui/music/album_detail_page.dart';
import 'package:pomelo/ui/music/artist_detail_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 歌曲搜索结果页面
@RoutePage()
class MusicSearchPage extends HookConsumerWidget {
  final String keyword;

  const MusicSearchPage({super.key, this.keyword = ''});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController(text: keyword);
    final keywordState = useState(keyword);
    final focusNode = useFocusNode();

    void doSearch(String kw) {
      final trimmed = kw.trim();
      if (trimmed.isEmpty) return;
      keywordState.value = trimmed;
      focusNode.unfocus();
      // 记录到搜索历史
      ref.read(userPreferenceProvider.notifier).addSearchKeyword(trimmed);
    }

    return Scaffold(
      headers: [
        AppBar(
          title: _SearchInputBar(
            controller: searchController,
            focusNode: focusNode,
            onSearch: doSearch,
          ),
        ),
        const Divider(),
      ],
      child: keywordState.value.isEmpty
          ? _SearchLanding(onSearch: doSearch)
          : _SearchResults(keyword: keywordState.value),
    );
  }
}

/// 搜索落地页 — 未输入关键词时展示热搜词与搜索历史
class _SearchLanding extends HookConsumerWidget {
  final void Function(String keyword) onSearch;

  const _SearchLanding({required this.onSearch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchKeywords = ref.watch(
      userPreferenceProvider.select((p) => p.searchKeywords),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索历史
          if (searchKeywords.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.history,
                  size: 16,
                  color: Theme.of(context).colorScheme.mutedForeground,
                ),
                const Gap(6),
                Text(
                  '搜索历史',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.foreground,
                  ),
                ),
                const Spacer(),
                GhostButton(
                  density: ButtonDensity.compact,
                  size: ButtonSize.small,
                  onPressed: () => ref
                      .read(userPreferenceProvider.notifier)
                      .clearSearchKeywords(),
                  child: const Icon(Icons.delete_sweep_outlined, size: 16),
                ),
              ],
            ),
            const Gap(8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final kw in searchKeywords)
                  _HistoryChip(
                    text: kw,
                    onTap: () => onSearch(kw),
                    onRemove: () => ref
                        .read(userPreferenceProvider.notifier)
                        .removeSearchKeyword(kw),
                  ),
              ],
            ),
            const Gap(24),
          ],
          // 热搜词
          _HotSearchSection(onSearch: onSearch),
        ],
      ),
    );
  }
}

/// 搜索历史单项 chip（带删除按钮）
class _HistoryChip extends HookConsumerWidget {
  final String text;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _HistoryChip({
    required this.text,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHovered = useState(false);
    final colorScheme = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isHovered.value
                ? colorScheme.muted.withValues(alpha: 0.6)
                : colorScheme.muted.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(fontSize: 12, color: colorScheme.foreground),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Gap(4),
              GestureDetector(
                onTap: onRemove,
                child: Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Icon(
                    Icons.close,
                    size: 12,
                    color: colorScheme.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 热搜词区块
class _HotSearchSection extends HookConsumerWidget {
  final void Function(String keyword) onSearch;

  const _HotSearchSection({required this.onSearch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hotSearchAsync = ref.watch(hotSearchProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return hotSearchAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (hotWords) {
        if (hotWords.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const Gap(6),
                Text(
                  '热门搜索',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.foreground,
                  ),
                ),
              ],
            ),
            const Gap(8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int i = 0; i < hotWords.length; i++)
                  _HotWordChip(
                    text: hotWords[i],
                    index: i + 1,
                    colorScheme: colorScheme,
                    onTap: () => onSearch(hotWords[i]),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// 热搜词单项 chip
class _HotWordChip extends HookConsumerWidget {
  final String text;
  final int index;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _HotWordChip({
    required this.text,
    required this.index,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHovered = useState(false);
    final indexColor = index <= 3
        ? colorScheme.primary
        : colorScheme.mutedForeground;
    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isHovered.value
                ? colorScheme.muted.withValues(alpha: 0.6)
                : colorScheme.muted.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$index',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: indexColor,
                ),
              ),
              const Gap(6),
              Text(
                text,
                style: TextStyle(fontSize: 12, color: colorScheme.foreground),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 搜索输入栏 — 包含搜索类型下拉按钮 + 输入框
class _SearchInputBar extends HookConsumerWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onSearch;

  const _SearchInputBar({
    required this.controller,
    required this.focusNode,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supportedTypesAsync = ref.watch(supportedSearchTypesProvider);
    final selectedType = ref.watch(selectedSearchTypeProvider);
    final suggestionsState = useState<List<String>>([]);

    // 更新搜索建议 — 使用 ref.read 避免在回调中创建订阅
    void updateSuggestions(String value) async {
      final tips = await ref.read(searchTipProvider(value).future);
      if (!context.mounted) return;
      suggestionsState.value = tips;
    }

    return Row(
      children: [
        // 搜索类型下拉按钮 — 仅当支持多种搜索类型时显示
        supportedTypesAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (types) {
            if (types.length <= 1) return const SizedBox.shrink();
            return GhostButton(
              density: ButtonDensity.compact,
              size: ButtonSize.small,
              onPressed: () => _showSearchTypePicker(context, ref, types),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(selectedType.label),
                  const Gap(4),
                  const Icon(Icons.arrow_drop_down, size: 16),
                ],
              ),
            );
          },
        ),
        if (supportedTypesAsync.maybeWhen(
          data: (types) => types.length > 1,
          orElse: () => false,
        ))
          const Gap(8),
        // 搜索输入框
        Expanded(
          child: AutoComplete(
            suggestions: suggestionsState.value,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: false,
              placeholder: Text('搜索${selectedType.label}...'),
              onSubmitted: onSearch,
              onChanged: updateSuggestions,
              features: [
                InputFeature.trailing(
                  GhostButton(
                    density: ButtonDensity.icon,
                    onPressed: () => onSearch(controller.text),
                    child: const Icon(Icons.search, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSearchTypePicker(
    BuildContext context,
    WidgetRef ref,
    List<SearchType> types,
  ) {
    final selected = ref.read(selectedSearchTypeProvider);
    showSelectionPicker<SearchType>(
      context: context,
      title: '搜索类型',
      options: types
          .map(
            (t) => SelectionOption<SearchType>(
              value: t,
              label: t.label,
              selected: t == selected,
            ),
          )
          .toList(),
      onSelected: (value) =>
          ref.read(selectedSearchTypeProvider.notifier).select(value),
    );
  }
}

/// 搜索结果组件
class _SearchResults extends HookConsumerWidget {
  final String keyword;

  const _SearchResults({required this.keyword});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabSourceId = useState<String?>(null);
    final selectedType = ref.watch(selectedSearchTypeProvider);

    // 初始 tab 默认选中持久化来源
    useEffect(() {
      tabSourceId.value = ref.read(selectedSourceProvider).sourceId;
      return null;
    }, const []);

    final configsAsync = ref.watch(musicServerConfigsProvider);
    final selection = ref.watch(selectedSourceProvider);
    final selectedSourceId = selection.sourceId;

    return configsAsync.whenOrDefault(
      (configs) {
        final filtered = tabSourceId.value == null
            ? configs
            : configs.where((c) => c.id == tabSourceId.value).toList();

        final colorScheme = Theme.of(context).colorScheme;

        // 结果列表组件 — 根据搜索类型选择
        final resultsContent = _SearchResultsContainer(
          key: ValueKey('${tabSourceId.value}_${selectedType}_$keyword'),
          keyword: keyword,
          sourceId: tabSourceId.value,
          libraryId: tabSourceId.value == selection.sourceId
              ? selection.libraryId
              : null,
          configs: filtered,
          searchType: selectedType,
        );

        return Rx.layout(
          context,
          mobile: () => Column(
            children: [
              SizedBox(
                height: 44,
                child: _SourceChips(
                  configs: configs,
                  selectedSourceId: selectedSourceId,
                  tabSourceId: tabSourceId,
                  selection: selection,
                  colorScheme: colorScheme,
                ),
              ),
              const Divider(),
              Expanded(child: resultsContent),
            ],
          ),
          tablet: () => Row(
            children: [
              SizedBox(
                width: 220,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '来源',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.mutedForeground,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _SourceChips(
                        configs: configs,
                        selectedSourceId: selectedSourceId,
                        tabSourceId: tabSourceId,
                        selection: selection,
                        colorScheme: colorScheme,
                        direction: Axis.vertical,
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: resultsContent),
            ],
          ),
        );
      },
    );
  }
}

/// 搜索结果容器 — 根据搜索类型分发到对应的结果列表
class _SearchResultsContainer extends ConsumerWidget {
  final String keyword;
  final String? sourceId;
  final String? libraryId;
  final List<MusicServerConfig> configs;
  final SearchType searchType;

  const _SearchResultsContainer({
    super.key,
    required this.keyword,
    required this.sourceId,
    required this.libraryId,
    required this.configs,
    required this.searchType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    // 非歌曲搜索需要指定具体来源
    if (searchType != SearchType.song && sourceId == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.source, size: 48, color: colorScheme.mutedForeground),
            const Gap(12),
            Text(
              '请先在上方选择具体的音乐来源',
              style: TextStyle(color: colorScheme.mutedForeground),
            ),
          ],
        ),
      );
    }

    switch (searchType) {
      case SearchType.song:
        return _SongResultsList(
          keyword: keyword,
          sourceId: sourceId,
          libraryId: libraryId,
          configs: configs,
        );
      case SearchType.artist:
        return _ArtistResultsList(
          keyword: keyword,
          sourceId: sourceId!,
          libraryId: libraryId,
        );
      case SearchType.album:
        return _AlbumResultsList(
          keyword: keyword,
          sourceId: sourceId!,
          libraryId: libraryId,
        );
      case SearchType.playlist:
        return _PlaylistResultsList(
          keyword: keyword,
          sourceId: sourceId!,
          libraryId: libraryId,
        );
    }
  }
}

/// 来源筛选 chips 组件
class _SourceChips extends ConsumerWidget {
  final List<MusicServerConfig> configs;
  final String? selectedSourceId;
  final ValueNotifier<String?> tabSourceId;
  final ({String? sourceId, String? libraryId}) selection;
  final ColorScheme colorScheme;
  final Axis direction;

  const _SourceChips({
    required this.configs,
    required this.selectedSourceId,
    required this.tabSourceId,
    required this.selection,
    required this.colorScheme,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedSearchTypeProvider);

    return ListView(
      scrollDirection: direction,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      children: [
        // 非歌曲搜索时不支持"全部来源"
        if (selectedType == SearchType.song)
          AppChip(
            label: '全部',
            isSelected: selectedSourceId == null,
            onTap: () {
              tabSourceId.value = null;
              ref.read(selectedSourceProvider.notifier).selectAll();
            },
            fill: true,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            borderRadius: 8,
            fontSize: 13,
          ),
        // 扁平展示所有平台配置，不按类型分组
        ...configs.map((config) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: AppChip(
              label: config.name,
              isSelected: tabSourceId.value == config.id,
              onTap: () {
                tabSourceId.value = config.id;
                ref.read(selectedSourceProvider.notifier).select(config.id);
              },
              fill: true,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              borderRadius: 8,
              fontSize: 13,
            ),
          );
        }),
      ],
    );
  }
}

/// 通用网格结果展示组件
///
/// 统一歌手/专辑/歌单搜索结果中结构相同的
/// 「空状态 + 标题 + 响应式网格」布局，通过 [itemBuilder] 区分各自的卡片内容与点击行为。
class _SourceGrid<T> extends StatelessWidget {
  final List<T> items;
  final IconData emptyIcon;
  final String emptyText;
  final String Function(int count) headerText;
  final Widget Function(BuildContext context, T item) itemBuilder;

  const _SourceGrid({
    required this.items,
    required this.emptyIcon,
    required this.emptyText,
    required this.headerText,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 48, color: colorScheme.mutedForeground),
            const Gap(12),
            Text(
              emptyText,
              style: TextStyle(color: colorScheme.mutedForeground),
            ),
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
            headerText(items.length),
            style: TextStyle(color: colorScheme.mutedForeground),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = Rx.gridColumns(constraints.maxWidth, base: 2);
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) =>
                    itemBuilder(context, items[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 歌曲搜索结果列表
class _SongResultsList extends ConsumerWidget {
  final String keyword;
  final String? sourceId;
  final String? libraryId;
  final List<MusicServerConfig> configs;

  const _SongResultsList({
    required this.keyword,
    required this.sourceId,
    required this.libraryId,
    required this.configs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(
      searchResultsProvider((
        keyword: keyword,
        sourceId: sourceId,
        libraryId: libraryId,
      )),
    );

    return resultsAsync.whenOrDefault(
      (data) {
        if (configs.isEmpty) {
          return const Center(child: Text('无可用来源'));
        }

        final tracks = data.tracks;
        // 整表只展开一次：原实现在 itemBuilder 内 map().toList()，
        // 每渲染一项就重建一份全表副本（O(n²) 分配）
        final primaryTracks = [for (final m in tracks) m.primary];
        final isMobile = Rx.isMobile(context);

        return Column(
          children: [
            ProviderErrorBanner(errors: data.errors),
            if (tracks.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: Theme.of(context).colorScheme.mutedForeground,
                      ),
                      const Gap(12),
                      Text('未找到与"$keyword"相关的歌曲'),
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
                        '找到 ${tracks.length} 首歌曲',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.mutedForeground,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: tracks.length,
                        addAutomaticKeepAlives: false,
                        itemBuilder: (context, index) {
                          final merged = tracks[index];
                          return PlayableTrackTile(
                            track: merged.primary,
                            playlist: primaryTracks,
                            playlistIndex: index,
                            isMobile: isMobile,
                            trailingExtra: Text(
                              merged.displaySources,
                              style: const TextStyle(fontSize: 12),
                            ).muted,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
      error: (err, _) => Center(child: Text('搜索失败: $err')),
    );
  }
}

/// 歌手搜索结果列表
class _ArtistResultsList extends ConsumerWidget {
  final String keyword;
  final String sourceId;
  final String? libraryId;

  const _ArtistResultsList({
    required this.keyword,
    required this.sourceId,
    required this.libraryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistsAsync = ref.watch(
      searchArtistsProvider((
        keyword: keyword,
        sourceId: sourceId,
        libraryId: libraryId,
      )),
    );

    return artistsAsync.whenOrDefault(
      (artists) => _SourceGrid<Artist>(
        items: artists,
        emptyIcon: Icons.person_search,
        emptyText: '未找到与"$keyword"相关的歌手',
        headerText: (n) => '找到 $n 位歌手',
        itemBuilder: (context, a) => GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ArtistDetailPage(
                artistId: a.id,
                sourceId: a.source?.id ?? sourceId,
                artistName: a.name,
                coverUrl: a.coverArt ?? a.artistImageUrl,
                albumCount: a.albumCount,
              ),
            ),
          ),
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: CoverImage(
                      coverArt: a.coverArt ?? a.artistImageUrl,
                      colorScheme: Theme.of(context).colorScheme,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    a.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      error: (err, _) => Center(child: Text('搜索失败: $err')),
    );
  }
}

/// 专辑搜索结果列表
class _AlbumResultsList extends ConsumerWidget {
  final String keyword;
  final String sourceId;
  final String? libraryId;

  const _AlbumResultsList({
    required this.keyword,
    required this.sourceId,
    required this.libraryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsAsync = ref.watch(
      searchAlbumsProvider((
        keyword: keyword,
        sourceId: sourceId,
        libraryId: libraryId,
      )),
    );

    return albumsAsync.whenOrDefault(
      (albums) => _SourceGrid<Album>(
        items: albums,
        emptyIcon: Icons.album,
        emptyText: '未找到与"$keyword"相关的专辑',
        headerText: (n) => '找到 $n 张专辑',
        itemBuilder: (context, a) => GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AlbumDetailPage(
                albumId: a.id,
                sourceId: a.source?.id ?? sourceId,
                albumName: a.name,
                coverUrl: a.coverArt,
                artist: a.artist,
                year: a.year,
                songCount: a.songCount,
              ),
            ),
          ),
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: CoverImage(
                      coverArt: a.coverArt,
                      colorScheme: Theme.of(context).colorScheme,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
                  child: Text(
                    a.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.foreground,
                    ),
                  ),
                ),
                if ((a.artist ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: Text(
                      a.artist ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.mutedForeground,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      error: (err, _) => Center(child: Text('搜索失败: $err')),
    );
  }
}

/// 歌单搜索结果列表
class _PlaylistResultsList extends ConsumerWidget {
  final String keyword;
  final String sourceId;
  final String? libraryId;

  const _PlaylistResultsList({
    required this.keyword,
    required this.sourceId,
    required this.libraryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(
      searchPlaylistsProvider((
        keyword: keyword,
        sourceId: sourceId,
        libraryId: libraryId,
      )),
    );

    return playlistsAsync.whenOrDefault(
      (playlists) => _SourceGrid<Playlist>(
        items: playlists,
        emptyIcon: Icons.queue_music,
        emptyText: '未找到与"$keyword"相关的歌单',
        headerText: (n) => '找到 $n 个歌单',
        itemBuilder: (context, p) => Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: CoverImage(
                    coverArt: p.coverArt,
                    colorScheme: Theme.of(context).colorScheme,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
                child: Text(
                  p.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.foreground,
                  ),
                ),
              ),
              if ((p.owner ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Text(
                    p.owner ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.mutedForeground,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      error: (err, _) => Center(child: Text('搜索失败: $err')),
    );
  }
}
