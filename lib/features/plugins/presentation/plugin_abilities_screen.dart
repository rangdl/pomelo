import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/layout/window_class.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/top_toast.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/plugin_record.dart';
import 'plugin_checker.dart';
import 'plugin_providers.dart';

/// 单个插件的能力清单：按方法级逐条列出「支持 / 不支持」。
///
/// 静态判定来自安装时反射到的 `supportedMethods`；「运行检查」会真实调用
/// 只读接口验证一次，结果写回 provider，返回本页仍可见。
class PluginAbilitiesScreen extends ConsumerStatefulWidget {
  const PluginAbilitiesScreen({super.key, required this.pluginId});

  final String pluginId;

  @override
  ConsumerState<PluginAbilitiesScreen> createState() =>
      _PluginAbilitiesScreenState();
}

class _PluginAbilitiesScreenState extends ConsumerState<PluginAbilitiesScreen> {
  bool _checking = false;

  PluginRecord? _find(List<PluginRecord> list) =>
      list.where((p) => p.id == widget.pluginId).firstOrNull;

  Future<void> _check(PluginRecord plugin) async {
    setState(() => _checking = true);
    try {
      final report = await ref
          .read(pluginCheckerProvider)
          .run(plugin)
          .timeout(const Duration(seconds: 60));
      ref.read(pluginCheckResultsProvider.notifier).put(report);
      TopToast.show('${plugin.platform}：${report.passed}/${report.total} 项可用');
    } catch (e) {
      TopToast.error('检查失败: $e');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(pluginListProvider).value ?? const <PluginRecord>[];
    final plugin = _find(list);

    if (plugin == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('插件能力')),
        body: const EmptyState(
          icon: Icons.extension_off_rounded,
          title: '插件不存在',
          message: '它可能已被删除。',
        ),
      );
    }

    final report = ref.watch(pluginCheckResultsProvider)[plugin.id];
    final supported = plugin.supportedMethods.toSet();
    final declared = kPluginAbilities.where(
      (a) => supported.contains(a.method),
    );
    // 插件实现了清单之外的自定义方法，也一并展示，避免能力被藏起来。
    final extras =
        supported
            .where((m) => !kPluginAbilities.any((a) => a.method == m))
            .toList()
          ..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('插件能力'),
        actions: [
          if (_checking)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              tooltip: '运行检查',
              icon: const Icon(Icons.play_circle_outline_rounded),
              onPressed: () => _check(plugin),
            ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: CenteredMaxWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            AppSpacing.floatingPlayerInset,
          ),
          children: [
            const SectionHeader('概况'),
            GroupCard(
              children: [
                SettingsItem(
                  icon: Icons.extension_rounded,
                  title: plugin.platform,
                  subtitle:
                      '${plugin.displayOrigin.label} · '
                      '${plugin.version.isEmpty ? '版本未知' : 'v${plugin.version}'}',
                  showChevron: false,
                ),
                SettingsItem(
                  icon: Icons.checklist_rounded,
                  title: '已支持能力',
                  subtitle: '${declared.length} / ${kPluginAbilities.length} 项',
                  showChevron: false,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader('能力清单'),
            GroupCard(
              dividerIndent: 0,
              children: [
                for (final a in kPluginAbilities)
                  _AbilityRow(
                    label: a.label,
                    desc: a.desc,
                    method: a.method,
                    ok: supported.contains(a.method),
                    result: report?.results
                        .where((r) => r.ability == a.method)
                        .firstOrNull,
                  ),
              ],
            ),
            if (extras.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader('自定义方法'),
              GroupCard(
                dividerIndent: 0,
                children: [
                  for (final method in extras)
                    _AbilityRow(
                      label: kPluginAbilityNames[method] ?? method,
                      desc: '插件自定义方法',
                      method: method,
                      ok: true,
                      result: report?.results
                          .where((r) => r.ability == method)
                          .firstOrNull,
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                report == null
                    ? '「支持」代表插件导出了该方法；点右上角可运行检查验证实际可用性。'
                    : '检查结果：${report.passed}/${report.total} 项通过（右侧为实测结果）。',
                style: TextStyle(
                  fontSize: AppText.rowSubtitle,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton.icon(
                onPressed: _checking ? null : () => _check(plugin),
                icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
                label: const Text('运行检查'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 单条能力：能力名 + 方法名 + 支持状态（绿/红）。
class _AbilityRow extends StatelessWidget {
  const _AbilityRow({
    required this.label,
    required this.desc,
    required this.method,
    required this.ok,
    this.result,
  });

  final String label;
  final String desc;
  final String method;
  final bool ok;
  final AbilityCheck? result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = ok ? scheme.primary : scheme.error;
    final r = result;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 20,
            color: color,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 能力名放首行，方法名单独一行，长方法名不会把标题挤断。
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppText.rowTitle,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHigh,
                        borderRadius: AppRadius.badgeBorder,
                      ),
                      child: Text(
                        method,
                        style: TextStyle(
                          fontSize: AppText.compact,
                          fontFamily: 'monospace',
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  r == null
                      ? desc
                      : '实测：${r.ok ? (r.detail ?? '可用') : (r.detail ?? '不可用')}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppText.rowSubtitle,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            ok ? '支持' : '不支持',
            style: TextStyle(
              fontSize: AppText.compact,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
