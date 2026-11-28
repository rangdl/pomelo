import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/layout/window_class.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/top_toast.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/plugin_repository.dart';
import '../domain/fallback_chain.dart';
import '../domain/plugin_record.dart';
import '../domain/source_keys.dart';
import 'plugin_providers.dart';

/// 插件设置页：类型、音源标识、兜底相关开关与熔断状态。
///
/// 能力清单已拆到独立子页（`/plugin-abilities`）。
class PluginDetailScreen extends ConsumerStatefulWidget {
  const PluginDetailScreen({super.key, required this.pluginId});

  final String pluginId;

  @override
  ConsumerState<PluginDetailScreen> createState() => _PluginDetailScreenState();
}

class _PluginDetailScreenState extends ConsumerState<PluginDetailScreen> {
  bool _busy = false;

  PluginRecord? _find(List<PluginRecord> list) =>
      list.where((p) => p.id == widget.pluginId).firstOrNull;

  Future<void> _run(Future<void> Function(PluginRepository repo) action) async {
    setState(() => _busy = true);
    try {
      final repo = await ref.read(pluginRepositoryProvider.future);
      await action(repo);
      ref.invalidate(pluginListProvider);
    } catch (e) {
      if (mounted) TopToast.error('操作失败: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// 编辑用户手动指定的音源 key。
  Future<void> _editSourceKeys(PluginRecord plugin) async {
    final effective = effectiveSourceKeys(plugin);
    final picked = <String>{...effective};

    final confirmed = await showAppModal<bool>(
      context: context,
      title: '音源标识',
      body: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '决定该插件参与哪条兜底链。自动推断不准时可在此手动指定。',
              style: TextStyle(
                fontSize: AppText.rowSubtitle,
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final key in kSourceKeys)
                  FilterChip(
                    label: Text('${sourceKeyLabel(key)} ($key)'),
                    selected: picked.contains(key),
                    onSelected: (on) => setLocal(() {
                      if (on) {
                        picked.add(key);
                      } else {
                        picked.remove(key);
                      }
                    }),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: (ctx) => [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            // 清空手动指定 = 恢复自动推断。
            picked.clear();
            Navigator.pop(ctx, true);
          },
          child: const Text('恢复自动'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('保存'),
        ),
      ],
    );
    if (confirmed != true) return;
    await _run((repo) async {
      final keys = List<String>.of(picked)..sort();
      await repo.setUserSourceKeys(plugin.id, keys.isEmpty ? null : keys);
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(pluginListProvider).value ?? const <PluginRecord>[];
    final plugin = _find(list);
    if (plugin == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('插件设置')),
        body: const EmptyState(
          icon: Icons.extension_off_rounded,
          title: '插件不存在',
          message: '它可能已被删除。',
        ),
      );
    }

    final breaker = ref.watch(circuitBreakerProvider);
    final effective = effectiveSourceKeys(plugin);

    return Scaffold(
      appBar: AppBar(title: Text(plugin.platform)),
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
                  icon: Icons.badge_rounded,
                  title: '类型',
                  subtitle: plugin.displayOrigin.label,
                  showChevron: false,
                ),
                SettingsItem(
                  icon: Icons.info_outline_rounded,
                  title: '版本',
                  subtitle: plugin.version.isEmpty ? '未知' : plugin.version,
                  showChevron: false,
                ),
                SettingsItem(
                  icon: Icons.tag_rounded,
                  title: '音源标识',
                  subtitle: effective.isEmpty
                      ? '未识别'
                      : effective.map(sourceKeyLabel).join(' · '),
                  onTap: _busy ? null : () => _editSourceKeys(plugin),
                ),
                SettingsItem(
                  icon: Icons.extension_rounded,
                  title: '脚本自报音源',
                  subtitle: plugin.sourceKeys.isEmpty
                      ? '无'
                      : plugin.sourceKeys.join(' · '),
                  showChevron: false,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionHeader('能力与检查'),
            GroupCard(
              children: [
                SettingsItem(
                  icon: Icons.fact_check_rounded,
                  title: '查看能力清单',
                  subtitle: '按方法级列出该插件支持的能力，可运行检查',
                  onTap: () =>
                      context.push('/plugin-abilities', extra: plugin.id),
                ),
              ],
            ),
            if (plugin.canProvideMediaSource) ...[
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader('取链与兜底'),
              GroupCard(
                children: [
                  _SwitchRow(
                    title: '允许作为兜底源',
                    subtitle: '其它插件失败时可调用本插件',
                    value: plugin.allowFallback,
                    onChanged: _busy
                        ? null
                        : (v) => _run(
                            (repo) => repo.setAllowFallback(plugin.id, v),
                          ),
                  ),
                  _SwitchRow(
                    title: '插件自行解析链接',
                    subtitle: '关闭后仅通过兜底链提供链接',
                    value: !plugin.disableResolve,
                    onChanged: _busy
                        ? null
                        : (v) => _run(
                            (repo) => repo.setDisableResolve(plugin.id, !v),
                          ),
                  ),
                  for (final key in effective)
                    _BreakerRow(
                      plugin: plugin,
                      sourceKey: key,
                      breaker: breaker,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 某个插件+音源组合的熔断状态行。
class _BreakerRow extends StatelessWidget {
  const _BreakerRow({
    required this.plugin,
    required this.sourceKey,
    required this.breaker,
  });

  final PluginRecord plugin;
  final String sourceKey;
  final CircuitBreaker breaker;

  @override
  Widget build(BuildContext context) {
    final state = breaker.stateOf(BreakerKey(plugin.id, sourceKey));
    final now = DateTime.now();
    final open = state.isOpen(now);
    final scheme = Theme.of(context).colorScheme;

    final subtitle = open
        ? '熔断中 · 约 ${state.remaining(now).inMinutes + 1} 分钟后恢复'
        : (state.failures > 0 ? '连续失败 ${state.failures} 次' : '正常');

    return SettingsItem(
      icon: open ? Icons.flash_off_rounded : Icons.flash_on_rounded,
      title: '${sourceKeyLabel(sourceKey)} 取链状态',
      subtitle: subtitle,
      showChevron: false,
      trailing: open
          ? Icon(Icons.block_rounded, color: scheme.error)
          : (state.failures > 0
                ? Icon(Icons.warning_amber_rounded, color: scheme.tertiary)
                : null),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsItem(
      icon: value ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
      title: title,
      subtitle: subtitle,
      showChevron: false,
      trailing: Switch(value: value, onChanged: onChanged),
      onTap: onChanged == null ? null : () => onChanged!(!value),
    );
  }
}
