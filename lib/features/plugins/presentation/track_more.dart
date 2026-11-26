import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/cover_image.dart';
import '../../../shared/widgets/track_tile.dart';
import '../../playback/application/player_actions.dart';
import 'plugin_providers.dart';

/// 歌曲行尾部的「更多」入口：歌曲详情 / 评论。
///
/// 只有来源插件实现了对应能力时才出现，避免点了才报"不支持"。
class TrackMoreButton extends ConsumerWidget {
  const TrackMoreButton({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = item['_pluginId'] as String?;
    final repo = ref.watch(pluginRepositoryProvider).value;
    final plugin = ownerId == null
        ? null
        : repo?.plugins.where((p) => p.id == ownerId).firstOrNull;
    final canInfo = plugin?.supportedMethods.contains('getMusicInfo') ?? false;
    final canComments =
        plugin?.supportedMethods.contains('getMusicComments') ?? false;
    if (!canInfo && !canComments) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      tooltip: '更多',
      position: PopupMenuPosition.under,
      icon: const Icon(Icons.more_vert_rounded, size: 20),
      onSelected: (value) {
        if (value == 'info') {
          showTrackInfoSheet(context, ref, item);
        } else {
          showTrackCommentsSheet(context, ref, item);
        }
      },
      itemBuilder: (context) => [
        if (canInfo) const PopupMenuItem(value: 'info', child: Text('歌曲详情')),
        if (canComments)
          const PopupMenuItem(value: 'comments', child: Text('评论')),
      ],
    );
  }
}

/// 歌曲详情弹层。
Future<void> showTrackInfoSheet(
  BuildContext context,
  WidgetRef ref,
  Map<String, dynamic> item,
) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _TrackInfoSheet(item: item),
  );
}

class _TrackInfoSheet extends ConsumerStatefulWidget {
  const _TrackInfoSheet({required this.item});

  final Map<String, dynamic> item;

  @override
  ConsumerState<_TrackInfoSheet> createState() => _TrackInfoSheetState();
}

class _TrackInfoSheetState extends ConsumerState<_TrackInfoSheet> {
  Map<String, dynamic>? _info;
  bool _loading = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final info = await ref
          .read(playerActionsProvider)
          .fetchMusicInfo(widget.item);
      if (!mounted) return;
      setState(() {
        _info = info;
        _loading = false;
      });
    } catch (e) {
      // 拉取详情失败不影响展示已有信息，只把错误收口掉。
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorText = '获取详情失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final merged = {...widget.item, ...?_info};
    final artwork = trackArtwork(merged);
    final rows = <MapEntry<String, String>>[
      if (_text(merged['album'] ?? merged['albumName']) != null)
        MapEntry('专辑', _text(merged['album'] ?? merged['albumName'])!),
      if (_duration(merged) != null) MapEntry('时长', _duration(merged)!),
      if (_text(merged['artist']) != null)
        MapEntry('歌手', _text(merged['artist'])!),
      if (_text(merged['genre']) != null)
        MapEntry('流派', _text(merged['genre'])!),
      if (_text(merged['releaseDate']) != null)
        MapEntry('发行日期', _text(merged['releaseDate'])!),
      if (_text(merged['bitrate']) != null)
        MapEntry('码率', _text(merged['bitrate'])!),
      if (_text(merged['format']) != null)
        MapEntry('格式', _text(merged['format'])!),
      if (_text(merged['_sourceKey']) != null)
        MapEntry('音源', _text(merged['_sourceKey'])!),
    ];

    return SafeArea(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: AppRadius.badgeBorder,
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: CoverImage(url: artwork, decodeWidth: 56),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${merged['title'] ?? '未知'}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: AppText.heading,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${merged['artist'] ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              for (final row in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 72,
                        child: Text(
                          row.key,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(child: Text(row.value)),
                    ],
                  ),
                ),
              if (rows.isEmpty)
                Text(
                  '该插件未返回更多信息',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  String? _text(dynamic value) {
    if (value == null) return null;
    final text = '$value'.trim();
    return text.isEmpty ? null : text;
  }

  String? _duration(Map<String, dynamic> data) {
    final interval = _text(data['interval']);
    if (interval != null) return interval;
    final seconds = data['duration'];
    if (seconds is num && seconds > 0) {
      final d = Duration(seconds: seconds.round());
      final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      return d.inHours > 0 ? '${d.inHours}:$mm:$ss' : '$mm:$ss';
    }
    return null;
  }
}

/// 评论弹层（首屏 20 条，可继续加载）。
Future<void> showTrackCommentsSheet(
  BuildContext context,
  WidgetRef ref,
  Map<String, dynamic> item,
) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.7,
      child: _CommentsSheet(item: item),
    ),
  );
}

class _CommentsSheet extends ConsumerStatefulWidget {
  const _CommentsSheet({required this.item});

  final Map<String, dynamic> item;

  @override
  ConsumerState<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<_CommentsSheet> {
  final List<Map<String, dynamic>> _comments = [];
  int _page = 0;
  bool _loading = false;
  bool _end = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || _end) return;
    setState(() => _loading = true);
    final next = _page + 1;
    try {
      final list = await ref
          .read(playerActionsProvider)
          .fetchMusicComments(widget.item, page: next);
      if (!mounted) return;
      setState(() {
        _page = next;
        _loading = false;
        if (list.isEmpty) {
          _end = true;
        } else {
          _comments.addAll(list);
        }
        if (list.isEmpty && _comments.isEmpty) _error = '暂无评论';
      });
    } catch (e) {
      // 失败必须复位 loading，否则「加载更多」按钮会一直转圈。
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '加载评论失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Text(
                '评论',
                style: const TextStyle(
                  fontSize: AppText.heading,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${_comments.length}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _comments.isEmpty
              ? Center(
                  child: _loading
                      ? const CircularProgressIndicator()
                      : Text(_error ?? '暂无评论'),
                )
              : ListView.separated(
                  itemCount: _comments.length + 1,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    if (index == _comments.length) {
                      if (_end) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: Text('没有更多了')),
                        );
                      }
                      return Center(
                        child: TextButton(
                          onPressed: _loading ? null : _loadMore,
                          child: Text(_loading ? '加载中…' : '加载更多'),
                        ),
                      );
                    }
                    return _buildComment(_comments[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildComment(Map<String, dynamic> comment) {
    final user =
        '${comment['nickname'] ?? comment['userName'] ?? comment['user'] ?? '匿名'}';
    final content =
        '${comment['comment'] ?? comment['content'] ?? comment['text'] ?? ''}';
    final likes = comment['likeCount'] ?? comment['likedCount'];
    final time =
        '${comment['createAt'] ?? comment['createdAt'] ?? comment['time'] ?? ''}';
    return ListTile(
      dense: true,
      title: Row(
        children: [
          Expanded(
            child: Text(
              user,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (time.isNotEmpty)
            Text(
              time,
              style: TextStyle(
                fontSize: AppText.rowSubtitle,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(content),
          if (likes != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '赞 $likes',
                style: TextStyle(
                  fontSize: AppText.rowSubtitle,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
