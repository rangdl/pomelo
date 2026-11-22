import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../plugins/demo_plugin.dart';
import '../providers/app_providers.dart';

class PluginManagerScreen extends ConsumerStatefulWidget {
  const PluginManagerScreen({super.key});

  @override
  ConsumerState<PluginManagerScreen> createState() =>
      _PluginManagerScreenState();
}

class _PluginManagerScreenState extends ConsumerState<PluginManagerScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(pluginListProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _installDemo() => _run(() async {
        final repo = await ref.read(pluginRepositoryProvider.future);
        final r = await repo.install(demoPluginSource);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('已安装: ${r.platform}')));
        }
      });

  Future<void> _installPaste() async {
    final controller = TextEditingController();
    final source = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('安装 MusicFree 插件'),
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
    await _run(() async {
      final repo = await ref.read(pluginRepositoryProvider.future);
      final r = await repo.install(source);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('已安装: ${r.platform}')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(pluginListProvider);
    final list = listAsync.value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MusicFree 插件'),
        actions: [
          IconButton(
            onPressed: _busy ? null : _installDemo,
            icon: const Icon(Icons.auto_awesome),
            tooltip: '安装示例插件',
          ),
          IconButton(
            onPressed: _busy ? null : _installPaste,
            icon: const Icon(Icons.add),
            tooltip: '粘贴安装',
          ),
        ],
      ),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : listAsync.isLoading && list.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : list.isEmpty
                  ? const Center(child: Text('暂无插件'))
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final p = list[i];
                        return ListTile(
                          leading: Switch(
                            value: p.enabled,
                            onChanged: (v) => _run(() async {
                              final repo =
                                  await ref.read(pluginRepositoryProvider.future);
                              await repo.setEnabled(p.id, v);
                            }),
                          ),
                          title: Text(p.platform),
                          subtitle: Text(
                            'v${p.version.isEmpty ? '?' : p.version}'
                            ' · ${p.supportedMethods.length} 个方法'
                            '${p.lxSource == null ? '' : ' · LX源 ${p.lxSource}'}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _run(() async {
                              final repo =
                                  await ref.read(pluginRepositoryProvider.future);
                              await repo.remove(p.id);
                            }),
                          ),
                        );
                      },
                    ),
    );
  }
}
