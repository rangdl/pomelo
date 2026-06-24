/// 音乐搜索结果页面
///
/// 展示根据关键词搜索到的歌曲列表。
library;

import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/modules/music/model/models.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/ui/music/providers/music_ui_providers.dart';
import 'package:pomelo/ui/music/widgets/app_chip.dart';
import 'package:pomelo/ui/music/widgets/play_pause_button.dart';
import 'package:pomelo/ui/music/widgets/provider_error_banner.dart';

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
          title: SizedBox(
            height: 36,
            child: TextField(
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

    final servicesAsync = ref.watch(musicServicesProvider);
    final selection = ref.watch(selectedSourceProvider);
    final selectedSourceId = selection.sourceId;

    return servicesAsync.when(
      data: (services) {
        final byType = groupServicesByType(services);
        final types = byType.keys.toList();

        final filtered = tabSourceId.value == null
            ? services
            : services.where((s) => s.sourceId == tabSourceId.value).toList();

        final colorScheme = Theme.of(context).colorScheme;

        return Column(
          children: [
            SizedBox(
              height: 44,
              child: ListView(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    borderRadius: 8,
                    fontSize: 13,
                  ),
                  ...types.expand((type) {
                    final typeServices = byType[type] ?? [];
                    if (typeServices.isEmpty) return <Widget>[];
                    return [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Center(
                          child: Text(
                            type.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.foreground.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ...typeServices.expand((service) {
                        // 多库服务：展示每个库作为 tab
                        if (service.libraries.isNotEmpty) {
                          return service.libraries.map(
                            (lib) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: AppChip(
                                label: lib.name,
                                isSelected:
                                    tabSourceId.value == service.sourceId &&
                                    service.defaultLibraryId == lib.id,
                                onTap: () {
                                  tabSourceId.value = service.sourceId;
                                  ref
                                      .read(selectedSourceProvider.notifier)
                                      .select(
                                        service.sourceId,
                                        libraryId: lib.id,
                                      );
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
                    ];
                  }),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: _SearchResultsList(
                key: ValueKey('${tabSourceId.value}_$keyword'),
                keyword: keyword,
                sourceId: tabSourceId.value,
                libraryId: tabSourceId.value == selection.sourceId
                    ? selection.libraryId
                    : null,
                services: filtered,
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
    );
  }
}

/// 搜索结果列表
class _SearchResultsList extends ConsumerWidget {
  final String keyword;
  final String? sourceId;
  final String? libraryId;
  final List<MusicService> services;

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

        final songs = data.songs;

        return Column(
          children: [
            ProviderErrorBanner(errors: data.errors),
            if (songs.isEmpty)
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
                      const SizedBox(height: 12),
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
                                leading: Icon(
                                  Icons.music_note,
                                  color: colorScheme.primary,
                                  size: 24,
                                ),
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
                                trailing: Row(
                                  children: [
                                    Text(
                                      merged.displaySources,
                                      style: const TextStyle(fontSize: 12),
                                    ).muted,
                                    PlayPauseButton(song: merged.primary),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
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
      },
    );
  }
}
