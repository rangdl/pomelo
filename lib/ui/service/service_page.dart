import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' show PopupMenuButton, PopupMenuItem;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/models/metadata/music_source_type.dart';
import 'package:pomelo/core/models/music_server_config.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/core/toast.dart';
import 'package:pomelo/modules/music_lx_server/providers/lx_server_providers.dart';
import 'package:pomelo/modules/music_subsonic/providers/subsonic_providers.dart';
import 'package:pomelo/provider/music/music_server_config_provider.dart';
import 'package:pomelo/ui/music/providers/music_ui_providers.dart';
import 'package:pomelo/ui/platform/widgets/add_lx_server_dialog.dart';
import 'package:pomelo/ui/platform/widgets/add_subsonic_account_dialog.dart';
import 'package:pomelo/ui/platform/widgets/edit_local_music_dialog.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 支持添加的平台类型
enum _PlatformType {
  lxServer('Lx Server', Icons.dns, '连接 lx-server HTTP API 服务'),
  subsonic('Subsonic', Icons.cloud, '连接 Subsonic 兼容的音乐服务器');

  final String label;
  final IconData icon;
  final String description;
  const _PlatformType(this.label, this.icon, this.description);
}

/// 平台页面
///
/// 展示所有已配置的音乐服务（基于 [musicServerConfigsProvider]，不初始化服务实例），
/// 按类型分组。右上角"+"按钮可添加新平台。
@RoutePage()
class ServicePage extends HookConsumerWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configsAsync = ref.watch(musicServerConfigsProvider);

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('平台'),
          trailing: [
            PopupMenuButton<_PlatformType>(
              icon: const Icon(Icons.add),
              tooltip: '添加平台',
              onSelected: (type) => _showAddDialog(context, type),
              itemBuilder: (context) => _PlatformType.values.map((t) {
                return PopupMenuItem<_PlatformType>(
                  value: t,
                  child: Row(
                    children: [
                      Icon(t.icon, size: 20),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(t.label),
                            Text(
                              t.description,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ],
      child: configsAsync.whenOrDefault(
        (configs) => _buildBody(context, ref, configs),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    List<MusicServerConfig> configs,
  ) {
    // 按类型分组配置
    final byType = <MusicSourceType, List<MusicServerConfig>>{};
    for (final c in configs) {
      byType.putIfAbsent(c.type, () => []).add(c);
    }

    // 定义展示顺序
    const typeOrder = [
      MusicSourceType.local,
      MusicSourceType.lxServer,
      MusicSourceType.subsonic,
      MusicSourceType.navidrome,
      MusicSourceType.emby,
    ];

    final hasAny = byType.values.any((list) => list.isNotEmpty);

    if (!hasAny) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.layers_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
            const Gap(16),
            Text(
              '暂无平台',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
            const Gap(8),
            Text(
              '点击右上角 + 添加音乐平台',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      );
    }

    // 收集所有分区为独立 widget
    final sections = <Widget>[];
    for (final type in typeOrder) {
      if (byType[type] != null && byType[type]!.isNotEmpty) {
        sections.add(_buildTypeSection(context, ref, type, byType[type]!));
      }
    }

    // 单列布局：移动端和桌面端统一使用单列 ListView
    return CenteredListView(
      maxWidth: 800,
      padding: const EdgeInsets.all(16),
      children: sections,
    );
  }

  /// 构建某个类型下的配置分组
  Widget _buildTypeSection(
    BuildContext context,
    WidgetRef ref,
    MusicSourceType type,
    List<MusicServerConfig> configs,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: Row(
            children: [
              Icon(
                _typeIcon(type),
                size: 18,
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
              const Gap(8),
              Text(
                type.displayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.mutedForeground,
                ),
              ),
              const Gap(8),
              Text(
                '${configs.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            children: [
              for (int i = 0; i < configs.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                _buildConfigTile(context, ref, configs[i]),
              ],
            ],
          ),
        ),
        const Gap(16),
      ],
    );
  }

  /// 构建单个配置的 ListTile
  Widget _buildConfigTile(
    BuildContext context,
    WidgetRef ref,
    MusicServerConfig config,
  ) {
    // 是否允许编辑（本地 + LxServer + Subsonic 可编辑）
    final canEdit =
        config.type == MusicSourceType.local ||
        config.type == MusicSourceType.lxServer ||
        config.type == MusicSourceType.subsonic ||
        config.type == MusicSourceType.navidrome ||
        config.type == MusicSourceType.emby;

    return ListTile(
      leading: Icon(_typeIcon(config.type), size: 20),
      title: Text(config.name),
      subtitle: const Text('已配置'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canEdit)
            IconButton.text(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: () => _editConfig(context, ref, config),
            ),
          if (_canRemove(config.type))
            IconButton.text(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: () => _removeConfig(context, ref, config),
            ),
        ],
      ),
    );
  }

  /// 编辑配置
  void _editConfig(
    BuildContext context,
    WidgetRef ref,
    MusicServerConfig config,
  ) {
    switch (config) {
      case LocalMusicConfig():
        Rx.action(
          context,
          mobile: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const EditLocalMusicPage(),
              ),
            );
          },
          tablet: () {
            showDialog(
              context: context,
              builder: (_) => const EditLocalMusicDialog(),
            );
          },
        );
      case LxServerConfig():
        Rx.action(
          context,
          mobile: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AddLxServerAccountPage(initialConfig: config),
              ),
            );
          },
          tablet: () {
            showDialog(
              context: context,
              builder: (_) => AddLxServerAccountDialog(initialConfig: config),
            );
          },
        );
      case SubsonicConfig():
        Rx.action(
          context,
          mobile: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AddSubsonicAccountPage(
                  initialConfig: config,
                  sourceId: config.id,
                ),
              ),
            );
          },
          tablet: () {
            showDialog(
              context: context,
              builder: (_) => AddSubsonicAccountDialog(
                initialConfig: config,
                sourceId: config.id,
              ),
            );
          },
        );
    }
  }

  /// 类型对应的图标
    IconData _typeIcon(MusicSourceType type) => switch (type) {
    MusicSourceType.local => Icons.folder,
    MusicSourceType.lxServer => Icons.dns,
    MusicSourceType.subsonic => Icons.cloud,
    MusicSourceType.navidrome => Icons.navigation,
    MusicSourceType.emby => Icons.play_circle,
  };

  /// 是否允许删除（local 不可删除）
  bool _canRemove(MusicSourceType type) => type != MusicSourceType.local;

  /// 显示添加平台页面/对话框
  void _showAddDialog(BuildContext context, _PlatformType type) {
    switch (type) {
      case _PlatformType.lxServer:
        Rx.action(
          context,
          mobile: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AddLxServerAccountPage(),
              ),
            );
          },
          tablet: () {
            showDialog(
              context: context,
              builder: (_) => const AddLxServerAccountDialog(),
            );
          },
        );
      case _PlatformType.subsonic:
        Rx.action(
          context,
          mobile: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AddSubsonicAccountPage(),
              ),
            );
          },
          tablet: () {
            showDialog(
              context: context,
              builder: (_) => const AddSubsonicAccountDialog(),
            );
          },
        );
    }
  }

  /// 删除配置
  Future<void> _removeConfig(
    BuildContext context,
    WidgetRef ref,
    MusicServerConfig config,
  ) async {
    try {
      switch (config) {
        case LxServerConfig():
          await ref.read(lxServerConnectionProvider.notifier).disconnect();
        case SubsonicConfig():
          await ref
              .read(subsonicAccountsProvider.notifier)
              .removeAccount(config.id);
        case LocalMusicConfig():
          break;
      }
      // 若删除的正是当前选中来源，清除选中态避免 stale sourceId 导致歌单循环切换
      final selection = ref.read(selectedSourceProvider);
      if (selection.sourceId == config.id) {
        ref.read(selectedSourceProvider.notifier).selectAll();
      }
      AppToast().success('已移除 ${config.name}');
    } catch (e) {
      AppToast().error('移除失败: $e');
    }
  }
}
