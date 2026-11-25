import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/demo_lx_script.dart';
import 'plugin_providers.dart';

/// LX 音源脚本管理页(从设置页进入的全屏二级页)。
class LxManagerScreen extends ConsumerStatefulWidget {
  const LxManagerScreen({super.key});

  @override
  ConsumerState<LxManagerScreen> createState() => _LxManagerScreenState();
}

class _LxManagerScreenState extends ConsumerState<LxManagerScreen> {
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
    final r = await repo.installLx(demoLxScript);
    if (mounted) {
      _toast('已安装 LX: ${r.platform}');
    }
  });

  Future<void> _installPaste() async {
    final nameController = TextEditingController();
    final sourceController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('安装 LX 音源脚本'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: '显示名称（可选）',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: sourceController,
                maxLines: 10,
                minLines: 6,
                decoration: const InputDecoration(
                  hintText: '粘贴 lx.on(...) / lx.send(...) 脚本',
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('安装'),
          ),
        ],
      ),
    );
    if (result != true || sourceController.text.trim().isEmpty) return;
    await _run(() async {
      final repo = await ref.read(pluginRepositoryProvider.future);
      final r = await repo.installLx(
        sourceController.text,
        displayName: nameController.text.trim().isEmpty
            ? null
            : nameController.text.trim(),
      );
      if (mounted) {
        _toast('已安装 LX: ${r.platform}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lxPlugins = ref.watch(lxPluginsProvider);
    final selectedId = ref.watch(selectedLxPluginProvider);
    final all = ref.watch(pluginListProvider).value ?? const [];
    final lxAll = all.where((p) => p.isLx).toList();
    final selectedLabel = lxPlugins
        .where((p) => p.id == selectedId)
        .map((p) => p.platform)
        .firstOrNull;
    const autoLabel = '自动（第一个可用的）';

    return Scaffold(
      appBar: AppBar(
        title: const Text('LX 音源脚本'),
        actions: [
          IconButton(
            tooltip: '安装演示脚本',
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
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      PopupMenuButton<String>(
                        initialValue: selectedLabel ?? autoLabel,
                        tooltip: '选择默认 LX 音源',
                        onSelected: (platform) {
                          final picked = lxPlugins
                              .where((p) => p.platform == platform)
                              .firstOrNull;
                          ref
                              .read(selectedLxPluginProvider.notifier)
                              .select(picked?.id);
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: autoLabel, child: Text(autoLabel)),
                          for (final p in lxPlugins)
                            PopupMenuItem(
                              value: p.platform,
                              child: Text(p.platform),
                            ),
                        ],
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.tune_rounded, size: 16),
                              const SizedBox(width: 6),
                              Text(selectedLabel ?? autoLabel),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: lxAll.isEmpty
                      ? const Center(child: Text('暂无 LX 脚本'))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                          itemCount: lxAll.length,
                          itemBuilder: (context, i) {
                            final p = lxAll[i];
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
                                  '源: ${p.lxSources.isEmpty ? '未知' : p.lxSources.join(", ")}'
                                  '${p.version.isEmpty ? '' : ' · v${p.version}'}',
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
                ),
              ],
            ),
    );
  }
}
