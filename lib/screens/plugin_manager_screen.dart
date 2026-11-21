import 'package:flutter/material.dart';

import '../plugins/demo_plugin.dart';
import '../state/app_state.dart';

class PluginManagerScreen extends StatefulWidget {
  const PluginManagerScreen({super.key, required this.app});

  final AppState app;

  @override
  State<PluginManagerScreen> createState() => _PluginManagerScreenState();
}

class _PluginManagerScreenState extends State<PluginManagerScreen> {
  bool _busy = false;

  Future<void> _installDialog() async {
    final controller = TextEditingController();
    final source = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('安装插件'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            maxLines: 12,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            decoration: const InputDecoration(
              hintText: '粘贴插件 JS 源码（module.exports = {...}）',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('安装'),
          ),
        ],
      ),
    );
    if (source == null || source.trim().isEmpty) return;

    setState(() => _busy = true);
    try {
      final record = await widget.app.pluginStore.install(source);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已安装: ${record.platform}')),
      );
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('安装失败: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _installDemo() async {
    setState(() => _busy = true);
    try {
      final r = await widget.app.pluginStore.install(demoPluginSource);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已安装示例插件: ${r.platform}')),
      );
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('安装失败: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.app.pluginStore;
    final list = store.plugins;

    return Scaffold(
      appBar: AppBar(
        title: const Text('插件管理'),
        actions: [
          IconButton(
            onPressed: _busy ? null : _installDemo,
            icon: const Icon(Icons.auto_awesome),
            tooltip: '安装示例插件',
          ),
          IconButton(
            onPressed: _busy ? null : _installDialog,
            icon: const Icon(Icons.add),
            tooltip: '粘贴安装',
          ),
        ],
      ),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : list.isEmpty
              ? const Center(child: Text('暂无插件，点右上角 + 安装'))
              : ReorderableListView.builder(
                  itemCount: list.length,
                  onReorderItem: (o, n) async {
                    await store.reorder(o, n);
                    setState(() {});
                  },
                  itemBuilder: (context, i) {
                    final p = list[i];
                    return ListTile(
                      key: ValueKey(p.id),
                      leading: Switch(
                        value: p.enabled,
                        onChanged: (v) async {
                          await store.setEnabled(p.id, v);
                          setState(() {});
                        },
                      ),
                      title: Text(p.platform),
                      subtitle: Text(
                        'v${p.version.isEmpty ? '?' : p.version}'
                        ' · ${p.supportedMethods.length} 个方法'
                        '${p.author.isEmpty ? '' : ' · ${p.author}'}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            tooltip: '方法列表',
                            onPressed: () => showDialog<void>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(p.platform),
                                content: Text(
                                  '支持方法:\n${p.supportedMethods.join('\n')}',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('关闭'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await store.remove(p.id);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
