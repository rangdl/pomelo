import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/demo_plugin.dart';
import '../domain/plugin_record.dart';
import 'plugin_providers.dart';

/// MusicFree 插件管理页(从设置页进入的全屏二级页)。
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
        _toast('失败: $e');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _installDemo() => _run(() async {
    final repo = await ref.read(pluginRepositoryProvider.future);
    final r = await repo.install(demoPluginSource);
    if (mounted) {
      _toast('已安装: ${r.platform}');
    }
  });

  Future<void> _installPaste() async {
    final controller = TextEditingController();
    final source = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('安装 MusicFree 插件'),
        content: SizedBox(
          width: 420,
          child: TextField(
            controller: controller,
            maxLines: 12,
            minLines: 8,
            decoration: const InputDecoration(
              hintText: '粘贴插件 JS 源码（module.exports = {...}）',
            ),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
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
        _toast('已安装: ${r.platform}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(pluginListProvider);
    // 本页只展示 MusicFree 插件；LX 脚本在独立页面管理
    final list = (listAsync.value ?? const <PluginRecord>[])
        .where((p) => p.isMusicFree)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MusicFree 插件'),
        actions: [
          IconButton(
            tooltip: '安装演示插件',
            onPressed: _busy ? null : _installDemo,
            icon: const Icon(Icons.auto_awesome_rounded),
          ),
          IconButton(
            tooltip: '粘贴源码安装',
            onPressed: _busy ? null : _installPaste,
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : listAsync.isLoading && list.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : list.isEmpty
          ? const Center(child: Text('暂无插件'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final p = list[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Switch(
                      value: p.enabled,
                      onChanged: _busy
                          ? null
                          : (v) => _run(() async {
                              final repo = await ref.read(
                                pluginRepositoryProvider.future,
                              );
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
                      tooltip: '删除',
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: _busy
                          ? null
                          : () => _run(() async {
                              final repo = await ref.read(
                                pluginRepositoryProvider.future,
                              );
                              await repo.remove(p.id);
                            }),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
