import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/modules/music/model/music_source_type.dart';
import 'package:pomelo/modules/music/model/music_service.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/ui/music/providers/music_ui_providers.dart';
import 'package:pomelo/ui/music/song_list.dart';
import 'package:pomelo/ui/music/widgets/provider_error_banner.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 音乐来源切换按钮（右上角）
///
/// 遍历 MusicModule.services，按 sourceType 分组展示。
/// 多库服务（如 LxMusicService）展示子库选项。
class SourceSwitchButton extends HookConsumerWidget {
  const SourceSwitchButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(musicServicesProvider);
    final selection = ref.watch(selectedSourceProvider);
    final selectedSourceId = selection.sourceId;

    return servicesAsync.when(
      data: (services) {
        // 确定显示名称：如果有 libraryId 则显示库名，否则显示服务名
        final selectedName = selectedSourceId == null
            ? '全部'
            : () {
                final service = services
                    .where((s) => s.sourceId == selectedSourceId)
                    .firstOrNull;
                if (service == null) return '全部';
                if (selection.libraryId != null &&
                    service.libraries.isNotEmpty) {
                  final lib = service.libraries
                      .where((l) => l.id == selection.libraryId)
                      .firstOrNull;
                  return lib?.name ?? service.sourceName;
                }
                return service.sourceName;
              }();

        return GhostButton(
          size: ButtonSize.small,
          onPressed: () =>
              _showSourcePicker(context, ref, services, selectedSourceId),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.album, size: 16),
              const SizedBox(width: 4),
              Text(selectedName),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  void _showSourcePicker(
    BuildContext context,
    WidgetRef ref,
    List<MusicService> services,
    String? selectedSourceId,
  ) {
    final byType = groupServicesByType(services);

    final types = byType.keys.toList();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('选择音乐来源'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GhostButton(
                  onPressed: () {
                    ref.read(selectedSourceProvider.notifier).selectAll();
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    '全部来源',
                    style: TextStyle(
                      fontWeight: selectedSourceId == null ? FontWeight.bold : null,
                    ),
                  ),
                ),
                const Divider(),
                ...types.expand((type) {
                  final typeServices = byType[type] ?? [];
                  return [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                      child: Text(
                        type.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.mutedForeground,
                        ),
                      ),
                    ),
                    ...typeServices.expand((service) {
                      // 如果服务有多个库，展示每个库作为子选项
                      if (service.libraries.isNotEmpty) {
                        return service.libraries.map(
                          (lib) => GhostButton(
                            onPressed: () {
                              // 选中库对应的 sourceId（对于多库服务，sourceId 是服务级别的）
                              // 同时设置服务的默认库
                              ref
                                  .read(selectedSourceProvider.notifier)
                                  .select(service.sourceId, libraryId: lib.id);
                              Navigator.of(dialogContext).pop();
                            },
                            child: Text(
                              lib.name,
                              style: TextStyle(
                                fontWeight: selectedSourceId == service.sourceId &&
                                      service.defaultLibraryId == lib.id
                                  ? FontWeight.bold
                                  : null,
                              ),
                            ),
                          ),
                        );
                      }
                      // 单库/无库服务，直接展示
                      return [
                        GhostButton(
                          onPressed: () {
                            ref
                                .read(selectedSourceProvider.notifier)
                                .select(service.sourceId);
                            Navigator.of(dialogContext).pop();
                          },
                          child: Text(
                            service.sourceName,
                            style: TextStyle(
                              fontWeight: selectedSourceId == service.sourceId
                                  ? FontWeight.bold
                                  : null,
                            ),
                          ),
                        ),
                      ];
                    }),
                  ];
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 音乐列表版块
class MusicSection extends HookConsumerWidget {
  const MusicSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(currentSourceSongsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 12),
          child: Text(
            '我的音乐',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        dataAsync.when(
          data: (data) {
            return Column(
              children: [
                ProviderErrorBanner(errors: data.errors),
                if (data.songs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        '暂无歌曲',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.mutedForeground,
                        ),
                      ),
                    ),
                  )
                else
                  SongList(songs: data.songs),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                '加载失败: $err',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.mutedForeground,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
