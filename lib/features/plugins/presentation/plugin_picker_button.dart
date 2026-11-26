import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/plugin_record.dart';
import 'plugin_providers.dart';

/// 标题栏左侧的插件切换入口。
///
/// 全应用单选统一走 [showSelectionSheet];按插件 **id** 匹配,
/// 避免两个插件 platform 同名时选错。
class PluginPickerButton extends ConsumerWidget {
  const PluginPickerButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plugins = ref.watch(searchablePluginsProvider);
    if (plugins.isEmpty) return const SizedBox.shrink();
    final selectedId = ref.watch(selectedSearchPluginProvider);
    final current = plugins.firstWhere(
      (p) => p.id == selectedId,
      orElse: () => plugins.first,
    );
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => _pick(context, ref, plugins, current),
        icon: const Icon(Icons.extension_rounded, size: 16),
        label: Text(
          current.platform,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: TextButton.styleFrom(
          foregroundColor: scheme.onSurface,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          visualDensity: VisualDensity.compact,
          textStyle: const TextStyle(fontSize: AppText.rowTitle),
        ),
      ),
    );
  }

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    List<PluginRecord> plugins,
    PluginRecord current,
  ) async {
    final picked = await showSelectionSheet<String>(
      context: context,
      title: '选择插件',
      current: current.id,
      options: [
        for (final plugin in plugins)
          SelectionOption(
            value: plugin.id,
            label: plugin.platform,
            icon: Icons.extension_rounded,
          ),
      ],
    );
    if (picked != null) {
      ref.read(selectedSearchPluginProvider.notifier).select(picked);
    }
  }
}
