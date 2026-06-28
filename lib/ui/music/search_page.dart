/// 音乐搜索结果页面
///
/// 展示根据关键词搜索到的歌曲列表。
library;

import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:pomelo/core/rx.dart';
import 'package:pomelo/modules/music/model/models.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/ui/music/providers/music_ui_providers.dart';
import 'package:pomelo/ui/music/widgets/app_chip.dart';
import 'package:pomelo/ui/music/widgets/play_pause_button.dart';
import 'package:pomelo/ui/music/widgets/provider_error_banner.dart';
import 'package:pomelo/ui/music/widgets/track_tile.dart';

/// 歌曲搜索结果页面
@RoutePage()
class MusicSearchPage extends HookConsumerWidget {
  final String keyword;

  const MusicSearchPage({super.key, required this.keyword});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController(text: keyword);
    final keywordState = useState(keyword);

    void doSearch(String kw) {
      if (kw.trim().isEmpty) return;
      keywordState.value = kw.trim();
    }

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            GhostButton(
              onPressed: () => context.router.maybePop(),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ],
          title: TextField(
            controller: searchController,
            autofocus: false,
            placeholder: const Text('搜索歌曲...'),
            onSubmitted: doSearch,
            features: [
              InputFeature.trailing(
                GhostButton(
                  density: ButtonDensity.icon,
                  onPressed: () => doSearch(searchController.text),
                  child: const Icon(Icons.search, size: 20),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
      child: keywordState.value.isEmpty
          ? const Center(child: Text('输入关键词搜索歌曲'))
          : _SearchResults(keyword: keywordState.value),
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
          ref: ref,
        );

        // 结果列表组件
        final resultsList = Expanded(
          child: _SearchResultsList(
            key: ValueKey('${tabSourceId.value}_$keyword'),
            keyword: keyword,
            sourceId: tabSourceId.value,
            libraryId: tabSourceId.value == selection.sourceId
                ? selection.libraryId
                : null,
            services: filtered,
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
              Expanded(child: Column(children: [resultsList])),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
    );
  }
}

/// 来源筛选 chips 组件
class _SourceChips extends StatelessWidget {
  final List<MusicServer> services;
  final String? selectedSourceId;
  final ValueNotifier<String?> tabSourceId;
  final ({String? sourceId, String? libraryId}) selection;
  final ColorScheme colorScheme;
  final WidgetRef ref;

  const _SourceChips({
    required this.services,
    required this.selectedSourceId,
    required this.tabSourceId,
    required this.selection,
    required this.colorScheme,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      children: [
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

/// 搜索结果列表
class _SearchResultsList extends ConsumerWidget {
  final String keyword;
  final String? sourceId;
  final String? libraryId;
  final List<MusicServer> services;

  const _SearchResultsList({
    super.key,
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
