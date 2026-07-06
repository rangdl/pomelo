import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' show PopupMenuButton, PopupMenuItem;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/models/metadata/music_server.dart';
import 'package:pomelo/core/models/metadata/music_source_type.dart';
import 'package:pomelo/core/models/music_server_config.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/core/toast.dart';
import 'package:pomelo/modules/music/providers/music_providers.dart';
import 'package:pomelo/modules/music_lx_server/providers/lx_server_providers.dart';
import 'package:pomelo/modules/music_subsonic/providers/subsonic_providers.dart';
import 'package:pomelo/modules/music_subsonic/repository/subsonic_music_server.dart';
import 'package:pomelo/provider/music/music_server_config_provider.dart';
import 'package:pomelo/ui/music/providers/music_ui_providers.dart';
import 'package:pomelo/ui/platform/providers/lx_metadata_plugin_paths_provider.dart';
import 'package:pomelo/ui/platform/providers/lx_source_plugin_paths_provider.dart';
import 'package:pomelo/ui/platform/widgets/add_lx_script_dialog.dart';
import 'package:pomelo/ui/platform/widgets/add_lx_server_dialog.dart';
import 'package:pomelo/ui/platform/widgets/add_subsonic_account_dialog.dart';
import 'package:pomelo/ui/platform/widgets/edit_local_music_dialog.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 支持添加的平台类型
enum _PlatformType {
  lx('Lx 音乐插件', Icons.code, '元数据与音源插件管理'),
  lxServer('Lx Server', Icons.dns, '连接 lx-server HTTP API 服务'),
  subsonic('Subsonic', Icons.cloud, '连接 Subsonic 兼容的音乐服务器');

  final String label;
  final IconData icon;
  final String description;
  const _PlatformType(this.label, this.icon, this.description);
}

/// 平台页面
///
/// 展示所有已注册的音乐服务，按类型分组。
/// 右上角"+"按钮可添加新平台。
@RoutePage()
class ServicePage extends HookConsumerWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(musicServersProvider);
    final subsonicAccounts = ref.watch(subsonicAccountsProvider);
    final sourcePlugins = ref.watch(lxSourcePluginPathsProvider);

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
      child: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (services) =>
            _buildBody(context, ref, services, subsonicAccounts, sourcePlugins),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    List<MusicServer> services,
    List<SubsonicMusicServer> subsonicAccounts,
    List<String> sourcePlugins,
  ) {
    final byType = groupServicesByType(services);

    // 定义展示顺序
    const typeOrder = [
      MusicSourceType.local,
      MusicSourceType.lx,
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
        sections.add(
          _buildTypeSection(
            context,
            ref,
            type,
            byType[type]!,
            subsonicAccounts,
          ),
        );
      }
    }

    // 桌面端双栏：将分区均分到左右两列
    final half = (sections.length + 1) ~/ 2;
    final leftSections = sections.sublist(0, half);
    final rightSections = sections.sublist(half);

    return Rx.layout(
      context,
      mobile: () =>
          ListView(padding: const EdgeInsets.all(16), children: sections),
      tablet: () => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(padding: EdgeInsets.zero, children: leftSections),
            ),
            const Gap(16),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: rightSections,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建某个类型下的服务分组
  Widget _buildTypeSection(
    BuildContext context,
    WidgetRef ref,
    MusicSourceType type,
    List<MusicServer> services,
    List<SubsonicMusicServer> subsonicAccounts,
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
                '${services.length}',
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
              for (int i = 0; i < services.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                _buildServiceTile(context, ref, services[i], subsonicAccounts),
              ],
            ],
          ),
        ),
        const Gap(16),
      ],
    );
  }

  /// 构建单个服务的 ListTile
  Widget _buildServiceTile(
    BuildContext context,
    WidgetRef ref,
    MusicServer service,
    List<SubsonicMusicServer> subsonicAccounts,
  ) {
    final libraryCount = service.libraries.length;
    final subtitle = libraryCount > 0 ? '$libraryCount 个库' : '已加载';

    // 是否允许编辑（本地 + LxServer + Subsonic 可编辑，Lx 插件由文件管理）
    final canEdit =
        service.sourceType == MusicSourceType.local ||
        service.sourceType == MusicSourceType.lxServer ||
        service.sourceType == MusicSourceType.subsonic ||
        service.sourceType == MusicSourceType.navidrome ||
        service.sourceType == MusicSourceType.emby;

    return ListTile(
      leading: Icon(_typeIcon(service.sourceType), size: 20),
      title: Text(service.sourceName),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canEdit)
            IconButton.text(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: () => _editService(context, ref, service),
            ),
          if (_canRemove(service.sourceType))
            IconButton.text(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: () =>
                  _removeService(context, ref, service, subsonicAccounts),
            ),
        ],
      ),
    );
  }

  /// 编辑服务配置
  void _editService(BuildContext context, WidgetRef ref, MusicServer service) {
    switch (service.sourceType) {
      case MusicSourceType.local:
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
      case MusicSourceType.lxServer:
        final configs = ref.read(musicServerConfigsProvider).value ?? const [];
        final config = configs.whereType<LxServerConfig>().firstOrNull;
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
      case MusicSourceType.subsonic:
      case MusicSourceType.navidrome:
      case MusicSourceType.emby:
        final config = ref
            .read(subsonicAccountsProvider.notifier)
            .getAccount(service.sourceId);
        Rx.action(
          context,
          mobile: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AddSubsonicAccountPage(
                  initialConfig: config,
                  sourceId: service.sourceId,
                ),
              ),
            );
          },
          tablet: () {
            showDialog(
              context: context,
              builder: (_) => AddSubsonicAccountDialog(
                initialConfig: config,
                sourceId: service.sourceId,
              ),
            );
          },
        );
      default:
        break;
    }
  }

  /// 类型对应的图标
  IconData _typeIcon(MusicSourceType type) => switch (type) {
    MusicSourceType.local => Icons.folder,
    MusicSourceType.lx => Icons.code,
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
      case _PlatformType.lx:
        Rx.action(
          context,
          mobile: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const LxPluginPage()),
            );
          },
          tablet: () {
            showDialog(
              context: context,
              builder: (_) => const AddLxPluginDialog(),
            );
          },
        );
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

  /// 删除服务
  Future<void> _removeService(
    BuildContext context,
    WidgetRef ref,
    MusicServer service,
    List<SubsonicMusicServer> subsonicAccounts,
  ) async {
    try {
      switch (service.sourceType) {
        case MusicSourceType.lx:
          await ref
              .read(lxMetadataPluginPathsProvider.notifier)
              .removePlugin('');
        case MusicSourceType.lxServer:
          await ref.read(lxServerConnectionProvider.notifier).disconnect();
        case MusicSourceType.subsonic:
          await ref
              .read(subsonicAccountsProvider.notifier)
              .removeAccount(service.sourceId);
        default:
          break;
      }
      // 若删除的正是当前选中来源，清除选中态避免 stale sourceId 导致歌单循环切换
      final selection = ref.read(selectedSourceProvider);
      if (selection.sourceId == service.sourceId) {
        ref.read(selectedSourceProvider.notifier).selectAll();
      }
      AppToast().success('已移除 ${service.sourceName}');
    } catch (e) {
      AppToast().error('移除失败: $e');
    }
  }
}
