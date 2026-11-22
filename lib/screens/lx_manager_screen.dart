import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../plugins/demo_lx_script.dart';
import '../providers/app_providers.dart';

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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _installDemo() => _run(() async {
        final repo = await ref.read(pluginRepositoryProvider.future);
        final r = await repo.installLx(demoLxScript);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已安装 LX: ${r.platform}')),
          );
        }
      });

  Future<void> _installPaste() async {
    final nameController = TextEditingController();
    final sourceController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('安装 LX 音源脚本'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '显示名称（可选）',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: sourceController,
                maxLines: 10,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                decoration: const InputDecoration(
                  hintText: '粘贴 lx.on(...) / lx.send(...) 脚本',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已安装 LX: ${r.platform}')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lxPlugins = ref.watch(lxPluginsProvider);
    final selectedId = ref.watch(selectedLxPluginProvider);
    final all = ref.watch(pluginListProvider).value ?? const [];
    final lxAll = all.where((p) => p.isLx).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('LX 音源脚本'),
        actions: [
          IconButton(
            onPressed: _busy ? null : _installDemo,
            icon: const Icon(Icons.auto_awesome),
            tooltip: '安装示例脚本',
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
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: DropdownButtonFormField<String?>(
                    initialValue: selectedId,
                    decoration: const InputDecoration(
                      labelText: '默认播放链接解析脚本',
                      helperText: 'MusicFree 搜到歌曲后，按平台用这个脚本解析直链',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('自动（第一个可用的）'),
                      ),
                      ...lxPlugins.map(
                        (p) => DropdownMenuItem<String?>(
                          value: p.id,
                          child: Text(p.platform),
                        ),
                      ),
                    ],
                    onChanged: (v) =>
                        ref.read(selectedLxPluginProvider.notifier).select(v),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: lxAll.isEmpty
                      ? const Center(child: Text('暂无 LX 脚本'))
                      : ListView.builder(
                          itemCount: lxAll.length,
                          itemBuilder: (context, i) {
                            final p = lxAll[i];
                            return ListTile(
                              leading: Switch(
                                value: p.enabled,
                                onChanged: (v) => _run(() async {
                                  final repo = await ref
                                      .read(pluginRepositoryProvider.future);
                                  await repo.setEnabled(p.id, v);
                                }),
                              ),
                              title: Text(p.platform),
                              subtitle: Text(
                                '源: ${p.lxSources.isEmpty ? '未知' : p.lxSources.join(", ")}'
                                '${p.version.isEmpty ? '' : ' · v${p.version}'}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _run(() async {
                                  final repo = await ref
                                      .read(pluginRepositoryProvider.future);
                                  await repo.remove(p.id);
                                }),
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
