import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/layout/window_class.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../../playback/application/player_actions.dart';
import '../domain/plugin_record.dart';
import 'plugin_providers.dart';

/// 推荐歌单：按插件提供的标签分页浏览歌单。
class SheetsBrowseScreen extends ConsumerStatefulWidget {
  const SheetsBrowseScreen({super.key});

  @override
  ConsumerState<SheetsBrowseScreen> createState() => _SheetsBrowseScreenState();
}

class _SheetsBrowseScreenState extends ConsumerState<SheetsBrowseScreen> {
  PluginRecord? _plugin;
  List<Map<String, dynamic>> _tags = const [];
  Map<String, dynamic>? _tag;
  final List<Map<String, dynamic>> _sheets = [];
  int _page = 0;
  bool _end = false;
  bool _loading = false;
  bool _booting = true;
  Object? _error;

  /// 初始化（找插件 / 拉标签）失败的原因，非空时展示重试入口。
  Object? _bootError;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _booting = true;
      _bootError = null;
    });
    try {
      final repo = await ref.read(pluginRepositoryProvider.future);
      final plugin = repo.enabledPlugins
          .where((p) => p.supportedMethods.contains('getRecommendSheetTags'))
          .firstOrNull;
      if (!mounted) return;
      if (plugin == null) {
        setState(() => _booting = false);
        return;
      }
      final tags = await ref
          .read(playerActionsProvider)
          .fetchRecommendSheetTags(plugin);
      if (!mounted) return;
      setState(() {
        _plugin = plugin;
        _tags = tags;
        _tag = tags.isNotEmpty ? tags.first : null;
        _booting = false;
      });
      if (_tag != null) await _load();
    } catch (e) {
      // 初始化异常必须收口，否则页面会一直停在转圈状态。
      if (!mounted) return;
      setState(() {
        _booting = false;
        _bootError = e;
      });
    }
  }

  Future<void> _load() async {
    final plugin = _plugin;
    final tag = _tag;
    if (plugin == null || tag == null || _loading || _end) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ref
          .read(playerActionsProvider)
          .fetchRecommendSheets(plugin, tag, page: _page + 1);
      if (!mounted) return;
      setState(() {
        _page += 1;
        _sheets.addAll(res.data);
        _end = res.isEnd || res.data.isEmpty;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _selectTag(Map<String, dynamic> tag) {
    if (_tag?['id'] == tag['id']) return;
    setState(() {
      _tag = tag;
      _sheets.clear();
      _page = 0;
      _end = false;
      _error = null;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('推荐歌单')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_booting) return const Center(child: CircularProgressIndicator());
    if (_bootError != null) {
      return EmptyState(
        icon: Icons.error_outline_rounded,
        title: '加载推荐歌单失败',
        message: '$_bootError',
        actions: [
          FilledButton.tonalIcon(
            onPressed: _bootstrap,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('重试'),
          ),
        ],
      );
    }
    if (_plugin == null) {
      return const EmptyState(
        icon: Icons.queue_music_rounded,
        title: '没有可用的推荐歌单',
        message: '当前插件没有实现 getRecommendSheetTags。',
      );
    }
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        if (_tags.isNotEmpty)
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _tags.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, i) {
                final tag = _tags[i];
                final selected = _tag?['id'] == tag['id'];
                return ChoiceChip(
                  label: Text('${tag['title'] ?? tag['name'] ?? '标签'}'),
                  selected: selected,
                  onSelected: (_) => _selectTag(tag),
                );
              },
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        if (_error != null && _sheets.isEmpty && !_loading)
          EmptyState(
            icon: Icons.error_outline_rounded,
            title: '加载歌单失败',
            message: '$_error',
            actions: [
              FilledButton.tonalIcon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('重试'),
              ),
            ],
          )
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text('加载失败: $_error'),
          ),
        if (_sheets.isEmpty && _loading)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_sheets.isEmpty && !_loading && _error == null)
          const EmptyState(
            icon: Icons.queue_music_rounded,
            title: '暂无歌单',
            message: '换个标签试试。',
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: mediaGridDelegate(context.windowClass),
            itemCount: _sheets.length,
            itemBuilder: (context, i) {
              final sheet = _sheets[i];
              return PosterCard(
                title: '${sheet['title'] ?? sheet['name'] ?? '歌单'}',
                subtitle: '${sheet['description'] ?? sheet['playCount'] ?? ''}',
                coverUrl: trackArtwork(sheet).isEmpty
                    ? null
                    : trackArtwork(sheet),
                onTap: () => context.push('/sheet', extra: sheet),
              );
            },
          ),
        if (_sheets.isNotEmpty && !_end)
          Center(
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
      ],
    );
  }
}
