import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/modules/music/model/music_provider.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/ui/music/providers/music_ui_providers.dart';
import 'package:pomelo/ui/music/song_list.dart';
import 'package:pomelo/ui/music/widgets/provider_error_banner.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart'
    show GhostButton, ButtonSize;

/// 音乐来源切换按钮（右上角）
class SourceSwitchButton extends ConsumerWidget {
  const SourceSwitchButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providersAsync = ref.watch(musicProvidersProvider);
    final selectedSourceId = ref.watch(selectedSourceProvider);

    return providersAsync.when(
      data: (providers) {
        final selectedName = selectedSourceId == null
            ? '全部'
            : providers
                      .where((p) => p.sourceId == selectedSourceId)
                      .firstOrNull
                      ?.sourceName ??
                  '全部';

        return GhostButton(
          size: ButtonSize.small,
          onPressed: () =>
              _showSourcePicker(context, ref, providers, selectedSourceId),
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
    List<MusicProvider> providers,
    String? selectedSourceId,
  ) {
    final module = ref.read(musicModuleProvider);
    final categories = module?.categories ?? [];
    final byCategory = module?.providersByCategory() ?? {};

    showDialog(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('选择音乐来源'),
          children: [
            SimpleDialogOption(
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
            const Divider(height: 1),
            ...categories.expand((category) {
              final catProviders = byCategory[category.id] ?? [];
              return [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                ...catProviders.map(
                  (p) => SimpleDialogOption(
                    onPressed: () {
                      ref
                          .read(selectedSourceProvider.notifier)
                          .select(p.sourceId);
                      Navigator.of(dialogContext).pop();
                    },
                    child: Text(
                      p.sourceName,
                      style: TextStyle(
                        fontWeight: selectedSourceId == p.sourceId
                            ? FontWeight.bold
                            : null,
                      ),
                    ),
                  ),
                ),
              ];
            }),
          ],
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
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
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
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
