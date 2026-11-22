import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    final plugins = ref.read(searchablePluginsProvider);
    if (plugins.isEmpty) return;
    final selectedId = ref.read(selectedSearchPluginProvider);
    final plugin = plugins.firstWhere(
      (p) => p.id == selectedId,
      orElse: () => plugins.first,
    );
    FocusScope.of(context).unfocus();
    await ref.read(playerActionsProvider).search(plugin, q);
  }

  @override
  Widget build(BuildContext context) {
    final plugins = ref.watch(searchablePluginsProvider);
    final selectedId = ref.watch(selectedSearchPluginProvider);
    final results = ref.watch(searchResultsProvider);

    if (plugins.isEmpty) {
      return const Center(child: Text('没有支持搜索的 MusicFree 插件'));
    }
    final current = plugins.firstWhere(
      (p) => p.id == selectedId,
      orElse: () => plugins.first,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: DropdownButtonFormField<String>(
            initialValue: current.id,
            decoration: const InputDecoration(
              labelText: '插件',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: plugins
                .map((p) => DropdownMenuItem(value: p.id, child: Text(p.platform)))
                .toList(),
            onChanged: (id) {
              if (id != null) {
                ref.read(selectedSearchPluginProvider.notifier).select(id);
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  decoration: const InputDecoration(
                    hintText: '搜索歌曲',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: results.isLoading ? null : _search,
                child: const Text('搜索'),
              ),
            ],
          ),
        ),
        if (results.isLoading) const LinearProgressIndicator(),
        Expanded(
          child: results.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '✗ $e',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            data: (items) => items.isEmpty
                ? const Center(child: Text('输入关键词开始搜索'))
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return ListTile(
                        leading: const Icon(Icons.music_note),
                        title: Text('${item['title'] ?? '未知'}'),
                        subtitle: Text('${item['artist'] ?? ''}'),
                        trailing: const Icon(Icons.play_circle_outline),
                        onTap: () => _play(item),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _play(Map<String, dynamic> item) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      messenger.showSnackBar(
        SnackBar(content: Text('解析中: ${item['title']}')),
      );
      await ref.read(playerActionsProvider).playItem(item);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('播放失败: $e')));
    }
  }
}
