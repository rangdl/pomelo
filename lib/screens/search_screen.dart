import 'package:flutter/material.dart';

import '../plugins/plugin_store.dart';
import '../state/app_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.app});

  final AppState app;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  PluginRecord? _plugin;
  List<Map<String, dynamic>> _results = const [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pickDefault();
  }

  void _pickDefault() {
    final enabled = widget.app.pluginStore.enabledPlugins;
    final searchable = enabled
        .where((p) => p.supportedMethods.contains('search'))
        .toList();
    _plugin = searchable.isNotEmpty ? searchable.first : null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final plugin = _plugin;
    final q = _controller.text.trim();
    if (plugin == null || q.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _results = const [];
    });
    try {
      final r = await widget.app.search(plugin, q);
      if (!mounted) return;
      setState(() => _results = r);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _play(Map<String, dynamic> item) async {
    final id = item['_pluginId'] as String?;
    final plugin = widget.app.pluginStore.plugins
        .where((p) => p.id == id)
        .toList();
    if (plugin.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      messenger.showSnackBar(
        SnackBar(content: Text('解析播放地址: ${item['title']}')),
      );
      await widget.app.playItem(plugin.first, item);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('播放失败: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchable = widget.app.pluginStore.enabledPlugins
        .where((p) => p.supportedMethods.contains('search'))
        .toList();
    if (searchable.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('没有支持 search 的已启用插件'),
        ),
      );
    }
    if (_plugin == null || !searchable.contains(_plugin)) {
      _plugin = searchable.first;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<PluginRecord>(
                  initialValue: _plugin,
                  decoration: const InputDecoration(
                    labelText: '插件',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: searchable
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(p.platform),
                        ),
                      )
                      .toList(),
                  onChanged: (p) => setState(() => _plugin = p),
                ),
              ),
            ],
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
                onPressed: _loading ? null : _search,
                child: const Text('搜索'),
              ),
            ],
          ),
        ),
        if (_loading) const LinearProgressIndicator(),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              '✗ $_error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        Expanded(
          child: _results.isEmpty
              ? const Center(child: Text('输入关键词开始搜索'))
              : ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final item = _results[i];
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
      ],
    );
  }
}
