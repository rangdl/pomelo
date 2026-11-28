import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/settings/playback_resilience.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/top_toast.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/fallback_chain.dart';
import '../domain/plugin_record.dart';
import '../domain/source_keys.dart';
import 'plugin_providers.dart';

/// 兜底链设置：按音源 Tab 分组排列插件优先级，并配置熔断策略。
///
/// 每个 Tab 是一条独立的兜底链；「默认」始终存在，其余音源可由用户按需添加。
class FallbackChainScreen extends ConsumerStatefulWidget {
  const FallbackChainScreen({super.key});

  @override
  ConsumerState<FallbackChainScreen> createState() =>
      _FallbackChainScreenState();
}

class _FallbackChainScreenState extends ConsumerState<FallbackChainScreen> {
  /// 当前 Tab 的 key；链增删时用它决定重建后停在哪一页。
  String _key = kDefaultChainKey;

  /// 新建一条链：可任选音源 key 或自定义名称。
  Future<void> _addChain(List<String> existing) async {
    final controller = TextEditingController();
    final picked = await showAppModal<String>(
      context: context,
      title: '添加兜底链',
      body: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final remaining = kSourceKeys
              .where((k) => !existing.contains(k))
              .toList();
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '选择音源，或输入自定义名称（如自带音源标识的平台）。',
                style: TextStyle(
                  fontSize: AppText.rowSubtitle,
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (remaining.isNotEmpty)
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final key in remaining)
                      ActionChip(
                        label: Text('${sourceKeyLabel(key)} ($key)'),
                        onPressed: () => Navigator.pop(ctx, key),
                      ),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: '自定义名称',
                  hintText: '任意标识，不能与已有链重名',
                ),
              ),
            ],
          );
        },
      ),
      actions: (ctx) => [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            final manual = controller.text.trim();
            if (manual.isEmpty) {
              Navigator.pop(ctx);
            } else {
              Navigator.pop(ctx, manual);
            }
          },
          child: const Text('添加'),
        ),
      ],
    );
    controller.dispose();
    if (picked == null || picked.trim().isEmpty) return;
    final key = picked.trim();
    if (existing.contains(key)) {
      TopToast.show('该兜底链已存在');
      return;
    }
    _key = key;
    await ref.read(fallbackChainsProvider.notifier).addChain(key);
  }

  Future<void> _removeChain(String key) async {
    if (key == kDefaultChainKey) return;
    final confirmed = await showAppModal<bool>(
      context: context,
      title: '删除兜底链',
      body: (ctx) => Text('确定删除「${_chainLabel(key)}」这条兜底链吗？'),
      actions: (ctx) => [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('删除'),
        ),
      ],
    );
    if (confirmed != true) return;
    _key = kDefaultChainKey;
    await ref.read(fallbackChainsProvider.notifier).removeChain(key);
  }

  String _chainLabel(String key) =>
      key == kDefaultChainKey ? '默认' : sourceKeyLabel(key);

  /// 可作为兜底的插件：启用、允许兜底、能取链、未被禁用取链。
  List<PluginRecord> _fallbackPool(List<PluginRecord> plugins) => plugins
      .where(
        (p) =>
            p.enabled &&
            p.allowFallback &&
            p.canProvideMediaSource &&
            !p.disableResolve,
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final plugins =
        ref.watch(pluginListProvider).value ?? const <PluginRecord>[];
    final chains = ref.watch(fallbackChainsProvider);
    final keys = chains.keys;
    final initialIndex = keys.indexOf(_key).clamp(0, keys.length - 1);

    // 每次链集合变化都用新 key 重建 DefaultTabController，避免手动管理
    // TabController 生命周期（增删 Tab 时它与 TabBarView 容易不同步）。
    return DefaultTabController(
      key: ValueKey(keys.join('|')),
      length: keys.length,
      initialIndex: initialIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('兜底链'),
          actions: [
            IconButton(
              tooltip: '添加兜底链',
              icon: const Icon(Icons.add_rounded),
              onPressed: () => _addChain(keys),
            ),
            IconButton(
              tooltip: '重置熔断',
              icon: const Icon(Icons.restart_alt_rounded),
              onPressed: () {
                ref.read(circuitBreakerProvider).reset();
                TopToast.show('已重置全部熔断状态');
              },
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              for (final key in keys)
                Tab(
                  child: GestureDetector(
                    onLongPress: key == kDefaultChainKey
                        ? null
                        : () => _removeChain(key),
                    child: Text(_chainLabel(key)),
                  ),
                ),
            ],
            onTap: (i) => setState(() => _key = keys[i]),
          ),
        ),
        body: TabBarView(
          children: [
            for (final key in keys)
              _ChainView(
                key: ValueKey(key),
                chainKey: key,
                plugins: plugins,
                chains: chains,
                pool: _fallbackPool(plugins),
                onRemoveChain: key == kDefaultChainKey
                    ? null
                    : () => _removeChain(key),
                onRename: () => _renameChain(key),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _renameChain(String key) async {
    if (key == kDefaultChainKey) return;
    final controller = TextEditingController(text: key);
    final next = await showAppModal<String>(
      context: context,
      title: '重命名兜底链',
      body: (ctx) => TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: '名称'),
      ),
      actions: (ctx) => [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, controller.text.trim()),
          child: const Text('保存'),
        ),
      ],
    );
    controller.dispose();
    if (next == null || next.isEmpty || next == key) return;
    final chains = ref.read(fallbackChainsProvider);
    if (chains.hasKey(next)) {
      TopToast.show('该名称已被占用');
      return;
    }
    // 重命名 = 用新 key 写入同样的顺序，再删掉旧 key。
    await ref
        .read(fallbackChainsProvider.notifier)
        .setChain(next, chains.chainFor(key));
    await ref.read(fallbackChainsProvider.notifier).removeChain(key);
    _key = next;
  }
}

/// 单条兜底链的内容：已加入的插件（可排序/移除）+ 可勾选的候选。
class _ChainView extends ConsumerStatefulWidget {
  const _ChainView({
    super.key,
    required this.chainKey,
    required this.plugins,
    required this.chains,
    required this.pool,
    this.onRemoveChain,
    this.onRename,
  });

  final String chainKey;
  final List<PluginRecord> plugins;
  final FallbackChains chains;
  final List<PluginRecord> pool;
  final VoidCallback? onRemoveChain;
  final VoidCallback? onRename;

  @override
  ConsumerState<_ChainView> createState() => _ChainViewState();
}

class _ChainViewState extends ConsumerState<_ChainView> {
  bool _showOthers = false;
  bool _showBreaker = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final key = widget.chainKey;
    final chainIds = widget.chains.chainFor(key);
    final byId = {for (final p in widget.pool) p.id: p};

    // 已加入的排在最前，其余候选按「音源匹配优先」排列。
    final selected = [
      for (final id in chainIds)
        if (byId[id] != null) byId[id]!,
    ];
    final selectedIds = selected.map((p) => p.id).toSet();
    final unmatched = widget.pool
        .where(
          (p) =>
              !selectedIds.contains(p.id) &&
              !effectiveSourceKeys(p).contains(key),
        )
        .toList();
    final matched = widget.pool
        .where(
          (p) =>
              !selectedIds.contains(p.id) &&
              effectiveSourceKeys(p).contains(key),
        )
        .toList();

    void toggle(PluginRecord p, bool on) {
      final notifier = ref.read(fallbackChainsProvider.notifier);
      if (on) {
        notifier.setChain(key, [...chainIds, p.id]);
      } else {
        notifier.setChain(key, [...chainIds]..remove(p.id));
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.floatingPlayerInset,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  key == kDefaultChainKey
                      ? '未单独配置的音源都会回落到这条链。'
                      : '「${sourceKeyLabel(key)}」取链失败时按此顺序尝试。',
                  style: TextStyle(
                    fontSize: AppText.rowSubtitle,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (widget.onRename != null)
                TextButton(
                  onPressed: widget.onRename,
                  child: const Text('重命名'),
                ),
              if (widget.onRemoveChain != null)
                TextButton(
                  onPressed: widget.onRemoveChain,
                  child: Text('删除', style: TextStyle(color: scheme.error)),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const SectionHeader('已加入的插件'),
        if (selected.isEmpty)
          GroupCard(
            children: const [
              SettingsItem(
                icon: Icons.inbox_rounded,
                title: '还没有插件',
                subtitle: '在下方候选列表勾选即可加入',
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
                  itemCount: selected.length,
                  onReorderItem: (from, to) {
                    final next = selected.map((p) => p.id).toList();
                    final item = next.removeAt(from);
                    next.insert(to, item);
                    ref
                        .read(fallbackChainsProvider.notifier)
                        .setChain(key, next);
                  },
                  itemBuilder: (context, i) {
                    final p = selected[i];
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: '移出此链',
                            icon: const Icon(
                              Icons.remove_circle_outline_rounded,
                            ),
                            onPressed: () => toggle(p, false),
                          ),
                          ReorderableDragStartListener(
                            index: i,
                            child: const Icon(Icons.drag_handle_rounded),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader('候选插件'),
        GroupCard(
          dividerIndent: 0,
          children: [
            if (matched.isEmpty && unmatched.isEmpty)
              const SettingsItem(
                icon: Icons.inbox_rounded,
                title: '没有可用的兜底插件',
                subtitle: '需要插件启用、允许兜底且能取链',
                showChevron: false,
              ),
            for (final p in matched)
              _CandidateRow(
                plugin: p,
                checked: selectedIds.contains(p.id),
                onChanged: (v) => toggle(p, v),
              ),
            if (unmatched.isNotEmpty)
              SettingsItem(
                icon: _showOthers
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                title: '其它插件 (${unmatched.length})',
                subtitle: '不声明该音源的插件，仍可手动加入',
                showChevron: false,
                onTap: () => setState(() => _showOthers = !_showOthers),
              ),
            if (_showOthers)
              for (final p in unmatched)
                _CandidateRow(
                  plugin: p,
                  checked: selectedIds.contains(p.id),
                  onChanged: (v) => toggle(p, v),
                ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '熔断',
                  style: TextStyle(
                    fontSize: AppText.sectionHeader,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _showBreaker = !_showBreaker),
                child: Text(_showBreaker ? '收起' : '展开设置'),
              ),
            ],
          ),
        ),
        if (_showBreaker) _BreakerConfig(),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            '主插件取链失败后，按已加入的顺序依次尝试；未加入的插件不参与。',
            style: TextStyle(
              fontSize: AppText.rowSubtitle,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// 候选插件行：勾选即加入当前链。
class _CandidateRow extends StatelessWidget {
  const _CandidateRow({
    required this.plugin,
    required this.checked,
    required this.onChanged,
  });

  final PluginRecord plugin;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: checked,
      onChanged: (v) => onChanged(v ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        plugin.platform,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${plugin.displayOrigin.label} · '
        '${effectiveSourceKeys(plugin).join(' / ')}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      dense: true,
    );
  }
}

/// 熔断参数。
class _BreakerConfig extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(circuitBreakerConfigProvider);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
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
