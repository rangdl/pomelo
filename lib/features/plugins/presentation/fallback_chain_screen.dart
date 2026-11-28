import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/layout/window_class.dart';
import '../../../shared/settings/playback_resilience.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/fallback_chain.dart';
import '../domain/plugin_record.dart';
import '../domain/source_keys.dart';
import 'plugin_providers.dart';

/// 兜底链设置：按音源分组排列插件优先级，并配置熔断策略。
class FallbackChainScreen extends ConsumerStatefulWidget {
  const FallbackChainScreen({super.key});

  @override
  ConsumerState<FallbackChainScreen> createState() =>
      _FallbackChainScreenState();
}

class _FallbackChainScreenState extends ConsumerState<FallbackChainScreen> {
  /// 当前编辑的音源 key。
  String _key = kSourceKeys.first;

  @override
  Widget build(BuildContext context) {
    final plugins =
        ref.watch(pluginListProvider).value ?? const <PluginRecord>[];
    final chains = ref.watch(fallbackChainsProvider);
    final config = ref.watch(circuitBreakerConfigProvider);

    // 能提供当前音源的插件。
    final providers = plugins
        .where((p) => effectiveSourceKeys(p).contains(_key))
        .toList();
    // 已排序的 id 在前，其余按安装顺序补齐。
    final ordered = <String>[
      for (final id in chains.chainFor(_key))
        if (providers.any((p) => p.id == id)) id,
      for (final p in providers)
        if (!chains.chainFor(_key).contains(p.id)) p.id,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('兜底链'),
        actions: [
          IconButton(
            tooltip: '重置熔断',
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: () {
              ref.read(circuitBreakerProvider).reset();
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('已重置全部熔断状态')));
            },
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
            const SectionHeader('音源'),
            GroupCard(
              dividerIndent: 0,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final key in kSourceKeys)
                        ChoiceChip(
                          label: Text('${sourceKeyLabel(key)} ($key)'),
                          selected: _key == key,
                          onSelected: (_) => setState(() => _key = key),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionHeader('${sourceKeyLabel(_key)} 兜底顺序'),
            if (ordered.isEmpty)
              GroupCard(
                children: const [
                  SettingsItem(
                    icon: Icons.inbox_rounded,
                    title: '没有插件声明该音源',
                    subtitle: '可在插件详情页手动指定音源标识',
                    showChevron: false,
                  ),
                ],
              )
            else
              GroupCard(
                dividerIndent: 0,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      buildDefaultDragHandles: false,
                      itemCount: ordered.length,
                      onReorderItem: (from, to) {
                        final next = [...ordered];
                        final item = next.removeAt(from);
                        next.insert(to, item);
                        ref
                            .read(fallbackChainsProvider.notifier)
                            .setChain(_key, next);
                      },
                      itemBuilder: (context, i) {
                        final p = providers.firstWhere(
                          (e) => e.id == ordered[i],
                        );
                        return ListTile(
                          key: ValueKey(p.id),
                          leading: Text('${i + 1}'),
                          title: Text(
                            p.platform,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${p.displayOrigin.label} · '
                            '${effectiveSourceKeys(p).join(' / ')}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: ReorderableDragStartListener(
                            index: i,
                            child: const Icon(Icons.drag_handle_rounded),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                '主插件取链失败后，按此顺序依次尝试。未在此列出的插件排在后面。',
                style: TextStyle(
                  fontSize: AppText.rowSubtitle,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader('熔断'),
            GroupCard(
              dividerIndent: 0,
              children: [
                _StepperRow(
                  title: '连续失败次数',
                  subtitle: '达到后暂停使用该插件（按音源分别计数）',
                  value: config.failureThreshold,
                  min: 1,
                  max: 10,
                  unit: '次',
                  onChanged: (v) => ref
                      .read(circuitBreakerConfigProvider.notifier)
                      .set(config.copyWith(failureThreshold: v)),
                ),
                _StepperRow(
                  title: '冷却时长',
                  subtitle: '熔断期间跳过该插件，到期后放行一次试探',
                  value: config.cooldownMinutes,
                  min: 1,
                  max: 60,
                  unit: '分钟',
                  onChanged: (v) => ref
                      .read(circuitBreakerConfigProvider.notifier)
                      .set(config.copyWith(cooldownMinutes: v)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                '熔断状态仅保存在内存中，重启应用会清空。',
                style: TextStyle(
                  fontSize: AppText.rowSubtitle,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 带 +/- 的数值行（比滑杆更容易精确调到整数）。
class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final int value;
  final int min;
  final int max;
  final String unit;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppText.rowTitle,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: AppText.rowSubtitle,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline_rounded),
            onPressed: value <= min ? null : () => onChanged(value - 1),
          ),
          SizedBox(
            width: 64,
            child: Text(
              '$value$unit',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppText.rowTitle,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: value >= max ? null : () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}
