/// 音乐搜索结果页面
///
/// 展示根据关键词搜索到的歌曲/歌手/专辑/歌单列表。
/// 搜索框左侧提供搜索类型下拉菜单，类型来源于当前选中服务支持的搜索类型。
library;

import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/core/models/metadata/metadata.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/ui/music/providers/music_ui_providers.dart';
import 'package:pomelo/ui/music/widgets/app_chip.dart';
import 'package:pomelo/ui/music/widgets/cover_image.dart';
import 'package:pomelo/ui/music/widgets/play_pause_button.dart';
import 'package:pomelo/ui/music/widgets/provider_error_banner.dart';
import 'package:pomelo/ui/music/widgets/track_tile.dart';
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
    // 输入框当前文本，用于触发搜索提示
    final inputText = useState(keyword);
    // 是否展示搜索提示浮层
    final showSuggestions = useState(false);
    final focusNode = useFocusNode();

    void doSearch(String kw) {
      final trimmed = kw.trim();
      if (trimmed.isEmpty) return;
      keywordState.value = trimmed;
      showSuggestions.value = false;
      focusNode.unfocus();
    }

    useEffect(() {
      void onFocusChanged() {
        // 失焦时延迟关闭，等待点击事件处理
        if (!focusNode.hasFocus) {
          Future.delayed(const Duration(milliseconds: 150), () {
            showSuggestions.value = false;
          });
        }
      }

      focusNode.addListener(onFocusChanged);
      return () => focusNode.removeListener(onFocusChanged);
    }, [focusNode]);

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            GhostButton(
              onPressed: () => context.router.maybePop(),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ],
          title: _SearchInputBar(
            controller: searchController,
            focusNode: focusNode,
            onSearch: doSearch,
            onChanged: (text) {
              inputText.value = text;
              // 输入非空且与当前搜索关键词不同时显示提示
              showSuggestions.value =
                  text.trim().isNotEmpty && text.trim() != keywordState.value;
            },
          ),
        ),
        const Divider(),
      ],
      child: Stack(
        children: [
          keywordState.value.isEmpty
              ? const Center(child: Text('输入关键词搜索'))
              : _SearchResults(keyword: keywordState.value),
          // 搜索提示浮层
          if (showSuggestions.value && inputText.value.trim().isNotEmpty)
            Positioned.fill(
              top: 0,
              child: _SearchSuggestions(
                keyword: inputText.value.trim(),
                onSelected: (suggestion) {
                  searchController.text = suggestion;
                  doSearch(suggestion);
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// 搜索输入栏 — 包含搜索类型下拉按钮 + 输入框
class _SearchInputBar extends HookConsumerWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onSearch;
  final void Function(String) onChanged;

  const _SearchInputBar({
    required this.controller,
    required this.focusNode,
    required this.onSearch,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supportedTypesAsync = ref.watch(supportedSearchTypesProvider);
    final selectedType = ref.watch(selectedSearchTypeProvider);

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
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: false,
            placeholder: Text('搜索${selectedType.label}...'),
            onSubmitted: onSearch,
            onChanged: onChanged,
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

/// 单条搜索提示项 — 带悬停高亮效果
class _SuggestionItem extends HookConsumerWidget {
  final String text;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _SuggestionItem({
    required this.text,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHovered = useState(false);
    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isHovered.value
                ? colorScheme.muted.withValues(alpha: 0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                size: 16,
                color: colorScheme.mutedForeground,
              ),
              const Gap(10),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 搜索提示浮层组件
///
/// 监听 [searchTipProvider] 获取联想词列表，点击联想词触发搜索。
/// 使用半透明背景遮罩 + 顶部对齐的提示卡片。
class _SearchSuggestions extends HookConsumerWidget {
  final String keyword;
  final void Function(String suggestion) onSelected;

  const _SearchSuggestions({
    required this.keyword,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipsAsync = ref.watch(searchTipProvider(keyword));
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      // 点击空白处关闭提示
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            constraints: const BoxConstraints(maxWidth: 640),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.border,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: tipsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '获取提示失败',
                  style: TextStyle(
                    color: colorScheme.mutedForeground,
                    fontSize: 13,
                  ),
                ),
              ),
              data: (tips) {
                if (tips.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '暂无搜索提示',
                      style: TextStyle(
                        color: colorScheme.mutedForeground,
                        fontSize: 13,
                      ),
                    ),
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '搜索提示',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        itemCount: tips.length,
                        itemBuilder: (context, index) {
                          final tip = tips[index];
                          return _SuggestionItem(
                            text: tip,
                            colorScheme: colorScheme,
                            onTap: () => onSelected(tip),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
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

    final servicesAsync = ref.watch(musicServersProvider);
    final selection = ref.watch(selectedSourceProvider);
    final selectedSourceId = selection.sourceId;

    return servicesAsync.when(
      data: (services) {
        final filtered = tabSourceId.value == null
            ? services
            : services.where((s) => s.sourceId == tabSourceId.value).toList();

        final colorScheme = Theme.of(context).colorScheme;

        // 来源筛选 chips 组件
        final sourceChips = _SourceChips(
          services: services,
          selectedSourceId: selectedSourceId,
          tabSourceId: tabSourceId,
          selection: selection,
          colorScheme: colorScheme,
        );

        // 结果列表组件 — 根据搜索类型选择
        final resultsList = Expanded(
          child: _SearchResultsContainer(
            key: ValueKey('${tabSourceId.value}_${selectedType}_$keyword'),
            keyword: keyword,
            sourceId: tabSourceId.value,
            libraryId: tabSourceId.value == selection.sourceId
                ? selection.libraryId
                : null,
            services: filtered,
            searchType: selectedType,
          ),
        );

        return Rx.layout(
          context,
          mobile: () => Column(
            children: [
              SizedBox(height: 44, child: sourceChips),
              const Divider(),
              resultsList,
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
                    Expanded(child: SingleChildScrollView(child: sourceChips)),
                    const Divider(),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: resultsList),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
    );
  }
}

/// 搜索结果容器 — 根据搜索类型分发到对应的结果列表
class _SearchResultsContainer extends ConsumerWidget {
  final String keyword;
  final String? sourceId;
  final String? libraryId;
  final List<MusicServer> services;
  final SearchType searchType;

  const _SearchResultsContainer({
    super.key,
    required this.keyword,
    required this.sourceId,
    required this.libraryId,
    required this.services,
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
            Icon(
              Icons.source,
              size: 48,
              color: colorScheme.mutedForeground,
            ),
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
          services: services,
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
  final List<MusicServer> services;
  final String? selectedSourceId;
  final ValueNotifier<String?> tabSourceId;
  final ({String? sourceId, String? libraryId}) selection;
  final ColorScheme colorScheme;

  const _SourceChips({
    required this.services,
    required this.selectedSourceId,
    required this.tabSourceId,
    required this.selection,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedSearchTypeProvider);

    return ListView(
      scrollDirection: Axis.horizontal,
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
        // 扁平展示所有平台，不按类型分组；
        // 多库服务展开为每个库一个 chip
        ...services.expand((service) {
          if (service.libraries.isNotEmpty) {
            return service.libraries.map(
              (lib) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: AppChip(
                  label: lib.name,
                  isSelected:
                      tabSourceId.value == service.sourceId &&
                      service.defaultLibraryId == lib.id,
                  onTap: () {
                    tabSourceId.value = service.sourceId;
                    ref
                        .read(selectedSourceProvider.notifier)
                        .select(service.sourceId, libraryId: lib.id);
                  },
                  fill: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  borderRadius: 8,
                  fontSize: 13,
                ),
              ),
            );
          }
          return [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: AppChip(
                label: service.sourceName,
                isSelected: tabSourceId.value == service.sourceId,
                onTap: () {
                  tabSourceId.value = service.sourceId;
                  ref
                      .read(selectedSourceProvider.notifier)
                      .select(service.sourceId);
                },
                fill: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                borderRadius: 8,
                fontSize: 13,
              ),
            ),
          ];
        }),
      ],
    );
  }
}

/// 歌曲搜索结果列表
class _SongResultsList extends ConsumerWidget {
  final String keyword;
  final String? sourceId;
  final String? libraryId;
  final List<MusicServer> services;

  const _SongResultsList({
    required this.keyword,
    required this.sourceId,
    required this.libraryId,
    required this.services,
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
    final colorScheme = Theme.of(context).colorScheme;

    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('搜索失败: $err')),
      data: (data) {
        if (services.isEmpty) {
          return const Center(child: Text('无可用来源'));
        }

        final tracks = data.tracks;

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
                        color: colorScheme.mutedForeground,
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
                        style: TextStyle(color: colorScheme.mutedForeground),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: tracks.length,
                        itemBuilder: (context, index) {
                          final merged = tracks[index];
                          return TrackTile(
                            track: merged.primary,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  merged.displaySources,
                                  style: const TextStyle(fontSize: 12),
                                ).muted,
                                PlayPauseButton(track: merged.primary),
                              ],
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
      },
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
    final colorScheme = Theme.of(context).colorScheme;

    return artistsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('搜索失败: $err')),
      data: (artists) {
        if (artists.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_search,
                  size: 48,
                  color: colorScheme.mutedForeground,
                ),
                const Gap(12),
                Text(
                  '未找到与"$keyword"相关的歌手',
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
                '找到 ${artists.length} 位歌手',
                style: TextStyle(color: colorScheme.mutedForeground),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  int crossAxisCount;
                  if (width < ResponsiveBreakpoints.mobile) {
                    crossAxisCount = 2;
                  } else if (width < ResponsiveBreakpoints.tablet) {
                    crossAxisCount = 3;
                  } else if (width < ResponsiveBreakpoints.desktop) {
                    crossAxisCount = 4;
                  } else {
                    crossAxisCount = 5;
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: artists.length,
                    itemBuilder: (context, index) {
                      final a = artists[index];
                      return GestureDetector(
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
                                    coverArt:
                                        a.coverArt ?? a.artistImageUrl,
                                    colorScheme: colorScheme,
                                    borderRadius:
                                        const BorderRadius.vertical(
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
                                    color: colorScheme.foreground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
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
    final colorScheme = Theme.of(context).colorScheme;

    return albumsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('搜索失败: $err')),
      data: (albums) {
        if (albums.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.album,
                  size: 48,
                  color: colorScheme.mutedForeground,
                ),
                const Gap(12),
                Text(
                  '未找到与"$keyword"相关的专辑',
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
                '找到 ${albums.length} 张专辑',
                style: TextStyle(color: colorScheme.mutedForeground),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  int crossAxisCount;
                  if (width < ResponsiveBreakpoints.mobile) {
                    crossAxisCount = 2;
                  } else if (width < ResponsiveBreakpoints.tablet) {
                    crossAxisCount = 3;
                  } else if (width < ResponsiveBreakpoints.desktop) {
                    crossAxisCount = 4;
                  } else {
                    crossAxisCount = 5;
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: albums.length,
                    itemBuilder: (context, index) {
                      final a = albums[index];
                      return GestureDetector(
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
                                    colorScheme: colorScheme,
                                    borderRadius:
                                        const BorderRadius.vertical(
                                      top: Radius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(8, 8, 8, 2),
                                child: Text(
                                  a.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colorScheme.foreground,
                                  ),
                                ),
                              ),
                              if ((a.artist ?? '').isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                  child: Text(
                                    a.artist ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          colorScheme.mutedForeground,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
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
    final colorScheme = Theme.of(context).colorScheme;

    return playlistsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('搜索失败: $err')),
      data: (playlists) {
        if (playlists.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.queue_music,
                  size: 48,
                  color: colorScheme.mutedForeground,
                ),
                const Gap(12),
                Text(
                  '未找到与"$keyword"相关的歌单',
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
                '找到 ${playlists.length} 个歌单',
                style: TextStyle(color: colorScheme.mutedForeground),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  int crossAxisCount;
                  if (width < ResponsiveBreakpoints.mobile) {
                    crossAxisCount = 2;
                  } else if (width < ResponsiveBreakpoints.tablet) {
                    crossAxisCount = 3;
                  } else if (width < ResponsiveBreakpoints.desktop) {
                    crossAxisCount = 4;
                  } else {
                    crossAxisCount = 5;
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final p = playlists[index];
                      return Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: CoverImage(
                                  coverArt: p.coverArt,
                                  colorScheme: colorScheme,
                                  borderRadius:
                                      const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(8, 8, 8, 2),
                              child: Text(
                                p.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.foreground,
                                ),
                              ),
                            ),
                            if ((p.owner ?? '').isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: Text(
                                  p.owner ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        colorScheme.mutedForeground,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
