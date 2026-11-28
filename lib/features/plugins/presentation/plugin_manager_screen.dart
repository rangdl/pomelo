import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/layout/window_class.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/widgets.dart';
import '../../playback/application/player_actions.dart';
import '../data/plugin_repository.dart';
import '../domain/plugin_record.dart';
import 'library_providers.dart';
import 'plugin_providers.dart';

/// 插件管理页（从设置页进入的全屏二级页）。
///
/// 插件格式在导入时自动识别：自有格式插件与 LX 音源脚本统一管理，
/// 用户无需关心脚本出身。列表支持拖拽手动排序，顺序即播放/兜底时的优先级。
class PluginManagerScreen extends ConsumerStatefulWidget {
  const PluginManagerScreen({super.key});

  @override
  ConsumerState<PluginManagerScreen> createState() =>
      _PluginManagerScreenState();
}

class _PluginManagerScreenState extends ConsumerState<PluginManagerScreen> {
  bool _busy = false;

  /// 出身筛选；null 表示全部。
  PluginOrigin? _originFilter;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(pluginListProvider);
    } catch (e) {
      if (mounted) _toast('失败: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// 轻量操作（开关/删除等）：不切全屏 loading，避免页面闪一下。
  Future<void> _runQuiet(Future<void> Function() action) async {
    try {
      await action();
      ref.invalidate(pluginListProvider);
    } catch (e) {
      if (mounted) _toast('失败: $e');
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// 更新地址未必是 JS 直链（可能是发布页/仓库/主页），统一支持浏览器打开。
  Future<void> _openInBrowser(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      _toast('更新地址无效: $url');
      return;
    }
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) _toast('无法打开浏览器');
    } catch (e) {
      _toast('无法打开浏览器: $e');
    }
  }

  /// 导入插件分享链接（歌单/单曲）。
  Future<void> _importShared() async {
    final controller = TextEditingController();
    final url = await showAppModal<String>(
      context: context,
      title: '导入分享链接',
      body: (ctx) => TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: '粘贴插件分享的歌单/单曲链接或口令'),
      ),
      actions: (ctx) => [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, controller.text),
          child: const Text('导入'),
        ),
      ],
    );
    // 对话框关闭后输入框已销毁，及时释放 controller。
    controller.dispose();
    if (url == null || url.trim().isEmpty) return;

    setState(() => _busy = true);
    List<Map<String, dynamic>> tracks;
    try {
      tracks = await ref.read(playerActionsProvider).importShared(url.trim());
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        _toast('导入失败: $e');
      }
      return;
    }
    if (!mounted) return;
    setState(() => _busy = false);

    if (tracks.isEmpty) {
      _toast('没有插件能导入该链接');
      return;
    }
    await showAppModal<void>(
      context: context,
      title: '已导入 ${tracks.length} 首',
      isScrollControlled: true,
      body: (ctx) => SizedBox(
        height: 420,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final added = await ref
                        .read(favoritesProvider.notifier)
                        .addAll(tracks);
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text(
                            added > 0 ? '已收藏 $added 首' : '这些歌曲已在收藏中',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.favorite_rounded, size: 18),
                  label: const Text('全部收藏'),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tracks.length,
                itemBuilder: (ctx, index) => TrackTile(
                  item: tracks[index],
                  onTap: () {
                    ref.read(playerActionsProvider).playFromList(tracks, index);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 从本地文件安装插件脚本（.js / .txt）。
  Future<void> _installFile() async {
    const typeGroup = XTypeGroup(label: '插件脚本', extensions: ['js', 'txt']);
    XFile? file;
    try {
      file = await openFile(acceptedTypeGroups: const [typeGroup]);
    } catch (e) {
      _toast('打开文件选择器失败: $e');
      return;
    }
    if (file == null) return;

    final String source;
    try {
      source = await file.readAsString();
    } catch (e) {
      _toast('读取文件失败: $e');
      return;
    }
    final base = file.name.replaceAll(
      RegExp(r'\.(js|txt)$', caseSensitive: false),
      '',
    );
    await _installSource(source, fallbackName: base);
  }

  /// 从网络地址导入插件脚本。
  Future<void> _installFromUrl() async {
    final controller = TextEditingController();
    final url = await showAppModal<String>(
      context: context,
      title: '从网络导入',
      body: (ctx) => TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'https://example.com/plugin.js',
          helperText: '支持自有格式插件与 LX 音源脚本直链',
        ),
      ),
      actions: (ctx) => [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, controller.text),
          child: const Text('导入'),
        ),
      ],
    );
    controller.dispose();
    if (url == null || url.trim().isEmpty) return;

    await _run(() async {
      final repo = await ref.read(pluginRepositoryProvider.future);
      final r = await repo.installFromUrl(url.trim());
      ref.invalidate(pluginRuntimeProvider(r.id));
      if (mounted) _toast('已安装${_typeOf(r)}: ${r.platform}');
    });
  }

  /// 安装一段脚本源码（文件与网络导入共用）。
  Future<void> _installSource(String source, {String? fallbackName}) async {
    if (source.trim().isEmpty) {
      _toast('脚本内容为空');
      return;
    }
    await _run(() async {
      final repo = await ref.read(pluginRepositoryProvider.future);
      final r = await repo.install(source, fallbackName: fallbackName);
      ref.invalidate(pluginRuntimeProvider(r.id));
      if (mounted) _toast('已安装${_typeOf(r)}: ${r.platform}');
    });
  }

  String _typeOf(PluginRecord r) =>
      r.canProvideMediaSource && r.supportedMethods.length == 1 ? '音源脚本' : '插件';

  Future<void> _checkUpdate(PluginRecord plugin, PluginRepository repo) async {
    setState(() => _busy = true);
    PluginUpdateResult? update;
    try {
      update = await repo.checkUpdate(plugin);
    } catch (e) {
      if (mounted) {
        _toast('检查更新失败: $e（可尝试"在浏览器打开更新地址"）');
      }
      if (mounted) setState(() => _busy = false);
      return;
    }
    if (!mounted) return;
    setState(() => _busy = false);

    if (update == null) {
      _toast('已是最新版本');
      return;
    }

    final srcUrl = plugin.srcUrl?.trim();
    final confirmed = await showAppModal<bool>(
      context: context,
      title: '发现新版本 ${update.version}',
      body: (ctx) => Text(update!.log ?? '是否更新 ${plugin.platform}？'),
      actions: (ctx) => [
        // 更新地址未必是 JS 直链，也允许直接到浏览器里查看发布页。
        if (srcUrl != null && srcUrl.isNotEmpty)
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, false);
              _openInBrowser(srcUrl);
            },
            child: const Text('浏览器打开'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('稍后'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('更新'),
        ),
      ],
    );
    if (confirmed != true) return;
    await _run(() async {
      final r = await repo.install(
        update!.source,
        fallbackName: plugin.platform,
      );
      ref.invalidate(pluginRuntimeProvider(r.id));
      if (mounted) _toast('已更新: ${plugin.platform}');
    });
  }

  Future<void> _toggleEnabled(PluginRecord p, bool value) =>
      _runQuiet(() async {
        final repo = await ref.read(pluginRepositoryProvider.future);
        await repo.setEnabled(p.id, value);
      });

  Future<void> _toggleFallback(PluginRecord p, bool value) =>
      _runQuiet(() async {
        final repo = await ref.read(pluginRepositoryProvider.future);
        await repo.setAllowFallback(p.id, value);
      });

  Future<void> _toggleResolve(PluginRecord p, bool disabled) =>
      _runQuiet(() async {
        final repo = await ref.read(pluginRepositoryProvider.future);
        await repo.setDisableResolve(p.id, disabled);
      });

  /// 删除插件：先二次确认，避免误点导致脚本丢失。
  Future<void> _remove(PluginRecord p) async {
    final confirmed = await showAppConfirm(
      context: context,
      title: '删除插件',
      message: '确定删除「${p.platform}」吗？删除后其配置与音源信息将一并移除。',
      confirmLabel: '删除',
      danger: true,
    );
    if (!confirmed || !mounted) return;
    await _runQuiet(() async {
      final repo = await ref.read(pluginRepositoryProvider.future);
      await repo.remove(p.id);
      ref.invalidate(pluginRuntimeProvider(p.id));
    });
  }

  Future<void> _ignoreUpdate(PluginRecord p) async {
    final repo = await ref.read(pluginRepositoryProvider.future);
    await repo.clearUpdateLog(p.id);
    ref.invalidate(pluginListProvider);
  }

  Future<void> _checkUpdateById(PluginRecord p) async {
    final repo = await ref.read(pluginRepositoryProvider.future);
    await _checkUpdate(p, repo);
  }

  /// 拖拽排序：原地保存，不触发全屏 loading，避免拖动结束列表闪一下。
  Future<void> _reorder(int oldIndex, int newIndex) async {
    try {
      final repo = await ref.read(pluginRepositoryProvider.future);
      await repo.moveTo(oldIndex, newIndex);
      ref.invalidate(pluginListProvider);
    } catch (e) {
      if (mounted) _toast('排序失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(pluginListProvider);
    final allPlugins = listAsync.value ?? const <PluginRecord>[];
    final list = _originFilter == null
        ? allPlugins
        : allPlugins.where((p) => p.displayOrigin == _originFilter).toList();
    final clearedLegacy =
        ref.watch(pluginRepositoryProvider).value?.clearedLegacy ?? false;
    final scheme = Theme.of(context).colorScheme;
    final cardColor = Theme.of(context).cardTheme.color ?? scheme.surface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('插件管理'),
        actions: [
          IconButton(
            tooltip: '兜底链',
            icon: const Icon(Icons.account_tree_rounded),
            onPressed: () => context.push('/fallback-chain'),
          ),
          PopupMenuButton<String>(
            tooltip: '添加插件',
            position: PopupMenuPosition.under,
            enabled: !_busy,
            icon: const Icon(Icons.add_rounded),
            onSelected: (value) {
              switch (value) {
                case 'url':
                  _installFromUrl();
                case 'import':
                  _importShared();
                default:
                  _installFile();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'file', child: Text('从文件安装')),
              PopupMenuItem(value: 'url', child: Text('从网络导入')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'import', child: Text('导入分享链接')),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      // 安装/更新期间保留列表可见,只在标题栏下方显示进度,避免整页闪一下。
      body: listAsync.isLoading && allPlugins.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : allPlugins.isEmpty
          ? EmptyState(
              icon: Icons.extension_rounded,
              title: clearedLegacy ? '插件体系已升级' : '暂无插件',
              message: clearedLegacy
                  ? '新版统一了插件格式，旧的 MusicFree 插件与 LX 脚本记录已清空，请重新导入。'
                  : '安装插件后即可搜索、浏览榜单并解析播放链接。',
              actions: [
                FilledButton.icon(
                  onPressed: _installFile,
                  icon: const Icon(Icons.file_open_rounded),
                  label: const Text('从文件安装'),
                ),
                OutlinedButton.icon(
                  onPressed: _installFromUrl,
                  icon: const Icon(Icons.cloud_download_rounded),
                  label: const Text('从网络导入'),
                ),
              ],
            )
          : CenteredMaxWidth(
              child: Column(
                children: [
                  if (_busy) const LinearProgressIndicator(minHeight: 2),
                  _OriginFilterBar(
                    selected: _originFilter,
                    counts: {
                      for (final o in PluginOrigin.values)
                        o: allPlugins.where((p) => p.displayOrigin == o).length,
                    },
                    onSelect: (o) => setState(() => _originFilter = o),
                  ),
                  if (list.isNotEmpty) const _ReorderHint(),
                  if (list.isEmpty)
                    const Expanded(child: Center(child: Text('该分类下没有插件')))
                  // 整个可排序列表共用一张卡片,与设置页的分组卡语言一致。
                  else
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.page,
                          AppSpacing.xs,
                          AppSpacing.page,
                          0,
                        ),
                        child: Material(
                          color: cardColor,
                          borderRadius: AppRadius.cardBorder,
                          clipBehavior: Clip.antiAlias,
                          child: ReorderableListView.builder(
                            // 列表延伸到播放胶囊下方,底部留出胶囊高度,
                            // 保证最后一项也能滚动到胶囊上方。
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.floatingPlayerInset,
                            ),
                            buildDefaultDragHandles: false,
                            itemCount: list.length,
                            onReorderItem: _reorder,
                            proxyDecorator: (child, index, animation) =>
                                Material(
                                  color: cardColor,
                                  elevation: 6,
                                  borderRadius: AppRadius.cardBorder,
                                  child: child,
                                ),
                            itemBuilder: (context, index) {
                              final p = list[index];
                              return Column(
                                key: ValueKey(p.id),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _PluginCard(
                                    plugin: p,
                                    index: index,
                                    busy: _busy,
                                    onToggleEnabled: (v) =>
                                        _toggleEnabled(p, v),
                                    onToggleFallback: (v) =>
                                        _toggleFallback(p, v),
                                    onToggleResolve: (v) =>
                                        _toggleResolve(p, v),
                                    onCheckUpdate: () => _checkUpdateById(p),
                                    onOpenUpdateUrl: () =>
                                        _openInBrowser(p.srcUrl!.trim()),
                                    onIgnoreUpdate: () => _ignoreUpdate(p),
                                    onRemove: () => _remove(p),
                                    onOpenDetail: () => context.push(
                                      '/plugin-detail',
                                      extra: p.id,
                                    ),
                                  ),
                                  if (index != list.length - 1)
                                    Divider(
                                      height: 1,
                                      indent: AppSpacing.dividerIndentSettings,
                                      endIndent: AppSpacing.sm,
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

/// 顶部说明条：强调拖动排序会改变插件优先级。
class _ReorderHint extends StatelessWidget {
  const _ReorderHint();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Icon(
            Icons.drag_indicator_rounded,
            size: 16,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              '拖动右侧手柄可调整顺序，越靠前优先级越高',
              style: TextStyle(
                fontSize: AppText.compact,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 单个插件卡片：信息 + 状态 + 操作 + 兜底/取链开关。
class _PluginCard extends StatelessWidget {
  const _PluginCard({
    required this.plugin,
    required this.index,
    required this.busy,
    required this.onToggleEnabled,
    required this.onToggleFallback,
    required this.onToggleResolve,
    required this.onCheckUpdate,
    required this.onOpenUpdateUrl,
    required this.onIgnoreUpdate,
    required this.onRemove,
    required this.onOpenDetail,
  });

  final PluginRecord plugin;
  final int index;
  final bool busy;
  final ValueChanged<bool> onToggleEnabled;
  final ValueChanged<bool> onToggleFallback;
  final ValueChanged<bool> onToggleResolve;
  final VoidCallback onCheckUpdate;
  final VoidCallback onOpenUpdateUrl;
  final VoidCallback onIgnoreUpdate;
  final VoidCallback onRemove;
  final VoidCallback onOpenDetail;

  /// 版本号文本：插件有时自带 `v` 前缀，避免显示成 `vv3.2.20`。
  static String _versionText(String version) =>
      version.startsWith('v') || version.startsWith('V')
      ? version
      : 'v$version';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;
    final version = plugin.version.trim().isEmpty ? '?' : plugin.version.trim();
    final sources = plugin.sourceKeys.isEmpty
        ? '未知音源'
        : plugin.sourceKeys.join(' · ');
    final hasUrl = plugin.srcUrl != null && plugin.srcUrl!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppIconBadge.background(scheme),
                  borderRadius: AppRadius.badgeBorder,
                ),
                child: Icon(
                  Icons.extension_rounded,
                  size: 20,
                  color: AppIconBadge.foreground(scheme),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 名字独占首行：chip 全部下移，避免窄屏时把名称挤下去。
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            plugin.platform,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: AppText.rowTitle,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (plugin.hasUpdate) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Icon(
                            Icons.new_releases_rounded,
                            size: 14,
                            color: scheme.primary,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _OriginChip(origin: plugin.displayOrigin),
                        _MetaChip(_versionText(version)),
                        // Wrap 不支持 flex 子项，音源文字用宽松高度包一层。
                        Text(
                          sources,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppText.rowSubtitle,
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 右侧三个操作统一放进 40 高的槽位并居中，避免高度不一致看着错位。
              Tooltip(
                message: plugin.enabled ? '停用' : '启用',
                child: SizedBox(
                  width: 44,
                  height: 40,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Switch(
                      value: plugin.enabled,
                      onChanged: busy ? null : onToggleEnabled,
                    ),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: '更多操作',
                position: PopupMenuPosition.under,
                enabled: !busy,
                padding: EdgeInsets.zero,
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.more_vert_rounded, size: 20),
                ),
                onSelected: (value) {
                  if (value == 'check') {
                    onCheckUpdate();
                  } else if (value == 'open') {
                    onOpenUpdateUrl();
                  } else if (value == 'ignore') {
                    onIgnoreUpdate();
                  } else if (value == 'delete') {
                    onRemove();
                  }
                },
                itemBuilder: (context) => [
                  if (hasUrl)
                    const PopupMenuItem(value: 'check', child: Text('检查更新')),
                  if (hasUrl)
                    const PopupMenuItem(
                      value: 'open',
                      child: Text('在浏览器打开更新地址'),
                    ),
                  if (plugin.hasUpdate)
                    const PopupMenuItem(value: 'ignore', child: Text('忽略更新提示')),
                  if (hasUrl || plugin.hasUpdate) const PopupMenuDivider(),
                  const PopupMenuItem(value: 'delete', child: Text('删除插件')),
                ],
              ),
              ReorderableDragStartListener(
                index: index,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    size: 20,
                    color: muted,
                  ),
                ),
              ),
            ],
          ),
          if (plugin.hasUpdate)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    Icons.new_releases_rounded,
                    size: 14,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      plugin.updateLog ?? '有新版本',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppText.compact,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (plugin.canProvideMediaSource) ...[
            const SizedBox(height: AppSpacing.xs),
            _SwitchRow(
              label: '允许兜底取链',
              subtitle: '本插件失败时可用其他插件补齐链接',
              value: plugin.allowFallback,
              onChanged: busy ? null : onToggleFallback,
            ),
            _SwitchRow(
              label: '插件自行解析链接',
              subtitle: '关闭后由 pomelo 统一解析',
              value: !plugin.disableResolve,
              onChanged: busy ? null : (v) => onToggleResolve(!v),
            ),
          ],
          if (!plugin.enabled)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                '已停用，不会参与搜索与取链',
                style: TextStyle(fontSize: AppText.compact, color: muted),
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onOpenDetail,
              icon: const Icon(Icons.tune_rounded, size: 16),
              label: const Text('能力与设置'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 轻量开关行:文字在左、Switch 在右,替代原来的 FilterChip。
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: AppText.rowSubtitle,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppText.compact,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 44,
          height: 36,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Switch(value: value, onChanged: onChanged),
          ),
        ),
      ],
    );
  }
}

/// 轻量信息胶囊（版本号等）。
class _MetaChip extends StatelessWidget {
  const _MetaChip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: AppRadius.badgeBorder,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: AppText.compact,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// 按出身筛选的 chips 行。
class _OriginFilterBar extends StatelessWidget {
  const _OriginFilterBar({
    required this.selected,
    required this.counts,
    required this.onSelect,
  });

  final PluginOrigin? selected;
  final Map<PluginOrigin, int> counts;
  final ValueChanged<PluginOrigin?> onSelect;

  @override
  Widget build(BuildContext context) {
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    Widget chip(String label, bool on, VoidCallback onTap) => Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: on,
        onSelected: (_) => onTap(),
        visualDensity: VisualDensity.compact,
      ),
    );

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.page,
          vertical: AppSpacing.sm,
        ),
        children: [
          chip('全部 ($total)', selected == null, () => onSelect(null)),
          for (final origin in PluginOrigin.values)
            chip(
              '${origin.label} (${counts[origin] ?? 0})',
              selected == origin,
              () => onSelect(origin),
            ),
        ],
      ),
    );
  }
}

/// 插件出身标签。
class _OriginChip extends StatelessWidget {
  const _OriginChip({required this.origin});

  final PluginOrigin origin;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (origin) {
      PluginOrigin.official => scheme.primary,
      PluginOrigin.musicfree => scheme.tertiary,
      PluginOrigin.lx => scheme.secondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppRadius.badgeBorder,
      ),
      child: Text(
        origin.label,
        style: TextStyle(fontSize: AppText.compact, color: color),
      ),
    );
  }
}
