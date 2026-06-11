import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/modules/music/model/music_service.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/ui/music/providers/music_ui_providers.dart';
import 'package:pomelo/ui/music/song_list.dart';
import 'package:pomelo/ui/music/widgets/provider_error_banner.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 音乐来源切换按钮（右上角）
class SourceSwitchButton extends ConsumerWidget {
  const SourceSwitchButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(musicServicesProvider);
    final selectedSourceId = ref.watch(selectedSourceProvider);

    return servicesAsync.when(
      data: (services) {
        final selectedName = selectedSourceId == null
            ? '全部'
            : services
                      .where((s) => s.sourceId == selectedSourceId)
                      .firstOrNull
                      ?.sourceName ??
                  '全部';

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
    final module = ref.read(musicModuleProvider);
    final categories = module?.categories ?? [];
    final byCategory = module?.servicesByCategory() ?? {};

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
                ...categories.expand((category) {
                  final catServices = byCategory[category.id] ?? [];
                  return [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                      child: Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.mutedForeground,
                        ),
                      ),
                    ),
                    ...catServices.map(
                      (s) => GhostButton(
                        onPressed: () {
                          ref
                              .read(selectedSourceProvider.notifier)
                              .select(s.sourceId);
                          Navigator.of(dialogContext).pop();
                        },
                        child: Text(
                          s.sourceName,
                          style: TextStyle(
                            fontWeight: selectedSourceId == s.sourceId
                                ? FontWeight.bold
                                : null,
                          ),
                        ),
                      ),
                    ),
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
class MusicSection extends ConsumerWidget {
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
