import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/layout/window_class.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../../playback/application/player_actions.dart';
import '../../playback/presentation/playback_providers.dart';
import '../../playback/presentation/player_sheet.dart';
import 'track_more.dart';

/// 一页歌曲的加载器：返回本页数据与是否到底。
typedef TrackPageLoader =
    Future<({List<Map<String, dynamic>> data, bool isEnd})> Function(int page);

/// 歌单/专辑/歌手单曲共用的分页歌曲列表。
///
/// 只负责「翻页 + 播放」，头部信息由调用方以 [header] 传入。
class TrackListView extends ConsumerStatefulWidget {
  const TrackListView({
    super.key,
    required this.loader,
    this.header,
    this.emptyHint = '这里还没有歌曲',
  });

  final TrackPageLoader loader;
  final Widget? header;
  final String emptyHint;

  @override
  ConsumerState<TrackListView> createState() => _TrackListViewState();
}

class _TrackListViewState extends ConsumerState<TrackListView> {
  final List<Map<String, dynamic>> _items = [];
  int _page = 0;
  bool _end = false;
  bool _loading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading || _end) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await widget.loader(_page + 1);
      if (!mounted) return;
      setState(() {
        _page += 1;
        _items.addAll(res.data);
        _end = res.isEnd || res.data.isEmpty;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty && _error != null) {
      return EmptyState(
        icon: Icons.error_outline_rounded,
        title: '加载失败',
        message: '$_error',
        actions: [
          FilledButton.tonalIcon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('重试'),
          ),
        ],
      );
    }
    final playing = ref.watch(nowPlayingProvider);
    return CenteredMaxWidth(
      child: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          if (widget.header != null) widget.header!,
          if (_items.isNotEmpty) ...[
            Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: () =>
                      ref.read(playerActionsProvider).playAll(_items),
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: const Text('播放全部'),
                ),
                const SizedBox(width: AppSpacing.sm),
                TextButton.icon(
                  onPressed: () =>
                      ref.read(playerActionsProvider).shufflePlay(_items),
                  icon: const Icon(Icons.shuffle_rounded, size: 18),
                  label: const Text('随机播放'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (_items.isEmpty)
            EmptyState(
              icon: Icons.music_note_rounded,
              title: widget.emptyHint,
              message: '换个歌单或稍后重试。',
            )
          else
            GroupCard(
              dividerIndent: AppSpacing.dividerIndentTrack,
              children: [
                for (final (i, item) in _items.indexed)
                  TrackTile(
                    item: item,
                    isPlaying: _isCurrent(item, playing),
                    trailing: TrackMoreButton(item: item),
                    onTap: () async {
                      try {
                        await ref
                            .read(playerActionsProvider)
                            .playFromList(_items, i);
                        if (context.mounted) showPlayerSheet(context);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('播放失败: $e')));
                        }
                      }
                    },
                  ),
              ],
            ),
          if (_items.isNotEmpty && !_end)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: TextButton(
                  onPressed: _loading ? null : _load,
                  child: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('加载更多'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 判断列表项是否就是当前正在播放的曲目（插件 id + 曲目 id）。
  bool _isCurrent(Map<String, dynamic> item, Map<String, dynamic>? playing) {
    if (playing == null) return false;
    if ('${item['_pluginId'] ?? ''}' != '${playing['_pluginId'] ?? ''}') {
      return false;
    }
    final a = '${item['id'] ?? item['title'] ?? ''}';
    final b = '${playing['id'] ?? playing['title'] ?? ''}';
    return a.isNotEmpty && a == b;
  }
}

/// 详情页通用头部：大封面 + 标题 + 副标题。
class CollectionHeader extends StatelessWidget {
  const CollectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.coverUrl,
  });

  final String title;
  final String? subtitle;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: AppRadius.cardBorder,
            child: SizedBox(
              width: 108,
              height: 108,
              child: CoverImage(
                url: coverUrl ?? '',
                decodeWidth: 108,
                icon: Icons.queue_music_rounded,
                iconSize: 40,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppText.detailTitle,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppText.rowSubtitle,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
