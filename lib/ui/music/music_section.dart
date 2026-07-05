import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/models/metadata/music_server.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/ui/music/providers/music_ui_providers.dart';
import 'package:pomelo/ui/music/track_list.dart';
import 'package:pomelo/ui/music/widgets/provider_error_banner.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 音乐平台切换按钮（右上角）
///
/// 仅切换音乐平台（服务），不展示平台提供的库。
/// 多库服务（如 LxServer）的库切换由 [LibrarySwitchButton] 负责。
class SourceSwitchButton extends HookConsumerWidget {
  const SourceSwitchButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(musicServersProvider);
    final selection = ref.watch(selectedSourceProvider);
    final selectedSourceId = selection.sourceId;

    return servicesAsync.when(
      data: (services) {
        // 显示名称：仅显示服务名（不显示库名）
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
              const Gap(4),
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
    List<MusicServer> services,
    String? selectedSourceId,
  ) {
    showSelectionPicker<String?>(
      context: context,
      title: '选择音乐平台',
      options: [
        SelectionOption<String?>(
          value: null,
          label: '全部来源',
          selected: selectedSourceId == null,
        ),
        ...services.map(
          (service) => SelectionOption<String?>(
            value: service.sourceId,
            label: service.sourceName,
            selected: service.sourceId == selectedSourceId,
          ),
        ),
      ],
      onSelected: (value) {
        if (value == null) {
          ref.read(selectedSourceProvider.notifier).selectAll();
        } else {
          ref.read(selectedSourceProvider.notifier).select(value);
        }
      },
    );
  }
}

/// 库切换按钮（左侧）
///
/// 仅当选中的平台（服务）提供多个库时显示。
/// 点击弹出库选择对话框，选中后更新 [selectedSourceProvider] 的 libraryId。
class LibrarySwitchButton extends HookConsumerWidget {
  const LibrarySwitchButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(musicServersProvider);
    final selection = ref.watch(selectedSourceProvider);

    return servicesAsync.when(
      data: (services) {
        final sourceId = selection.sourceId;
        if (sourceId == null) return const SizedBox.shrink();
        final service = services
            .where((s) => s.sourceId == sourceId)
            .firstOrNull;
        // 平台未提供库，或仅有一个库，则不显示
        if (service == null || service.libraries.length <= 1) {
          return const SizedBox.shrink();
        }

        // 当前库名
        final currentLibId = selection.libraryId ?? service.defaultLibraryId;
        final currentLibName =
            service.libraries
                .where((l) => l.id == currentLibId)
                .firstOrNull
                ?.name ??
            '选择库';

        return GhostButton(
          size: ButtonSize.small,
          onPressed: () => _showLibraryPicker(context, ref, service, sourceId),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.library_music, size: 16),
              const Gap(4),
              Text(currentLibName),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  void _showLibraryPicker(
    BuildContext context,
    WidgetRef ref,
    MusicServer service,
    String sourceId,
  ) {
    final selection = ref.read(selectedSourceProvider);
    final currentLibId = selection.libraryId ?? service.defaultLibraryId;

    showSelectionPicker<String>(
      context: context,
      title: '选择库',
      options: service.libraries
          .map(
            (lib) => SelectionOption<String>(
              value: lib.id,
              label: lib.name,
              selected: lib.id == currentLibId,
            ),
          )
          .toList(),
      onSelected: (libId) {
        ref
            .read(selectedSourceProvider.notifier)
            .select(sourceId, libraryId: libId);
      },
    );
  }
}

/// 音乐列表版块
class MusicSection extends HookConsumerWidget {
  const MusicSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(currentSourceTracksProvider);

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
                if (data.tracks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        '暂无歌曲',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.mutedForeground,
                        ),
                      ),
                    ),
                  )
                else
                  TrackList(tracks: data.tracks),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                '加载失败: $err',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.mutedForeground,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
