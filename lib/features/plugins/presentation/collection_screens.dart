import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/layout/window_class.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../../playback/application/player_actions.dart';
import '../domain/plugin_record.dart';
import 'plugin_providers.dart';
import 'track_list_view.dart';

/// 从条目上的 `_pluginId` 解析出来源插件。
PluginRecord? pluginOf(WidgetRef ref, Map<String, dynamic> item) {
  final repo = ref.watch(pluginRepositoryProvider).value;
  final id = item['_pluginId'];
  if (repo == null || id is! String) return null;
  return repo.plugins.where((p) => p.id == id).firstOrNull;
}

String _text(
  Map<String, dynamic> item,
  List<String> keys, [
  String fallback = '',
]) {
  for (final k in keys) {
    final v = item[k];
    if (v != null && '$v'.trim().isNotEmpty) return '$v';
  }
  return fallback;
}

/// 歌单详情。
class SheetScreen extends ConsumerWidget {
  const SheetScreen({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = _text(item, const ['title', 'name'], '歌单');
    final plugin = pluginOf(ref, item);
    if (plugin == null) return _Unavailable(title: title);
    final actions = ref.read(playerActionsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: TrackListView(
        header: CollectionHeader(
          title: title,
          subtitle: _text(item, const ['description', 'desc']),
          coverUrl: trackArtwork(item),
        ),
        loader: (page) => actions.fetchSheetSongs(plugin, item, page: page),
      ),
    );
  }
}

/// 专辑详情。
class AlbumScreen extends ConsumerWidget {
  const AlbumScreen({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = _text(item, const ['title', 'name'], '专辑');
    final plugin = pluginOf(ref, item);
    if (plugin == null) return _Unavailable(title: title);
    final actions = ref.read(playerActionsProvider);
    final artistName = _text(item, const ['artist', 'artistName']);
    final date = _text(item, const ['date', 'releaseDate', 'publishTime']);
    // 专辑条目自带歌手 id 时提供「查看歌手」入口(部分插件才有)。
    final rawArtist = item['artist'];
    final artistId =
        item['artistId'] ?? (rawArtist is Map ? rawArtist['id'] : null);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: TrackListView(
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CollectionHeader(
              title: title,
              subtitle: [
                artistName,
                date,
              ].where((e) => e.isNotEmpty).join(' · '),
              coverUrl: trackArtwork(item),
            ),
            if (artistId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: TextButton.icon(
                  onPressed: () => context.push(
                    '/artist',
                    extra: {
                      'id': artistId,
                      'name': artistName,
                      '_pluginId': item['_pluginId'],
                    },
                  ),
                  icon: const Icon(Icons.person_rounded, size: 18),
                  label: Text(artistName.isEmpty ? '查看歌手' : artistName),
                ),
              ),
          ],
        ),
        loader: (page) => actions.fetchAlbumSongs(plugin, item, page: page),
      ),
    );
  }
}

/// 歌手页：单曲 + 专辑两个 Tab。
class ArtistScreen extends ConsumerWidget {
  const ArtistScreen({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = _text(item, const ['name', 'title'], '歌手');
    final plugin = pluginOf(ref, item);
    if (plugin == null) return _Unavailable(title: name);
    final actions = ref.read(playerActionsProvider);
    final avatar = _text(item, const ['avatar', 'artwork', 'coverImgUrl']);
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(name)),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.xs,
                  AppSpacing.page,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 72,
                        height: 72,
                        child: avatar.isEmpty
                            ? _avatarPlaceholder(context)
                            : CoverImage(
                                url: avatar,
                                decodeWidth: 72,
                                icon: Icons.person_rounded,
                                iconSize: 30,
                              ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: AppText.detailTitle,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (_text(item, const [
                            'fans',
                            'description',
                          ]).isNotEmpty)
                            Text(
                              _text(item, const ['fans', 'description']),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: AppText.rowSubtitle,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const TabBar(
                tabs: [
                  Tab(text: '单曲'),
                  Tab(text: '专辑'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    TrackListView(
                      emptyHint: '暂无单曲',
                      loader: (page) =>
                          actions.fetchArtistWorks(plugin, item, page: page),
                    ),
                    _ArtistAlbums(plugin: plugin, artist: item),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarPlaceholder(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerHigh,
    child: Icon(
      Icons.person_rounded,
      size: 36,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}

/// 歌手页「专辑」Tab：分页加载专辑，点击进入专辑详情。
class _ArtistAlbums extends ConsumerStatefulWidget {
  const _ArtistAlbums({required this.plugin, required this.artist});

  final PluginRecord plugin;
  final Map<String, dynamic> artist;

  @override
  ConsumerState<_ArtistAlbums> createState() => _ArtistAlbumsState();
}

class _ArtistAlbumsState extends ConsumerState<_ArtistAlbums> {
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
      final res = await ref
          .read(playerActionsProvider)
          .fetchArtistWorks(
            widget.plugin,
            widget.artist,
            page: _page + 1,
            type: 'album',
          );
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
    if (_items.isEmpty) {
      return const EmptyState(
        icon: Icons.album_rounded,
        title: '暂无专辑',
        message: '换个歌手试试。',
      );
    }
    return CenteredMaxWidth(
      child: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          GroupCard(
            dividerIndent: AppSpacing.dividerIndentTrack,
            children: [
              for (final album in _items)
                CollectionRow(
                  item: album,
                  fallbackTitle: '专辑',
                  placeholderIcon: Icons.album_rounded,
                  onTap: () => context.push('/album', extra: album),
                ),
            ],
          ),
          if (!_end)
            Center(
              child: TextButton(
                onPressed: _loading ? null : _load,
                child: const Text('加载更多'),
              ),
            ),
        ],
      ),
    );
  }
}

/// 插件已被移除/停用时的占位页。
class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const EmptyState(
        icon: Icons.extension_off_rounded,
        title: '插件不可用',
        message: '该内容来自的插件已被移除或停用。',
      ),
    );
  }
}
