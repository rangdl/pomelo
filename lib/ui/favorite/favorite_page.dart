import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' show PopupMenuButton, PopupMenuItem;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/modules/music/model/music_source_type.dart';
import 'package:pomelo/modules/music/model/music_service.dart';
import 'package:pomelo/modules/music_subsonic/repository/subsonic_music_service.dart';
import 'package:pomelo/modules/music_subsonic/providers/subsonic_providers.dart';
import 'package:pomelo/ui/music/providers/music_ui_providers.dart';
import 'package:pomelo/ui/platform/providers/lx_metadata_plugin_paths_provider.dart';
import 'package:pomelo/ui/platform/providers/lx_source_plugin_paths_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/ui/platform/widgets/add_lx_script_dialog.dart';
import 'package:pomelo/ui/platform/widgets/add_subsonic_account_dialog.dart';

/// 支持添加的平台类型
enum _PlatformType {
  lx('Lx 音乐插件', Icons.code, '元数据与音源插件管理'),
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
class FavoritePage extends HookConsumerWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(musicServicesListProvider);
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
                      const SizedBox(width: 12),
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
        data: (services) => _buildBody(
          context,
          ref,
          services,
          subsonicAccounts,
          sourcePlugins,
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    List<MusicService> services,
    List<SubsonicMusicService> subsonicAccounts,
    List<String> sourcePlugins,
  ) {
    // 按来源类型分组
    final byType = <MusicSourceType, List<MusicService>>{};
    for (final s in services) {
      byType.putIfAbsent(s.sourceType, () => []).add(s);
    }

    // 定义展示顺序
    const typeOrder = [
      MusicSourceType.local,
      MusicSourceType.lx,
      MusicSourceType.subsonic,
      MusicSourceType.navidrome,
      MusicSourceType.emby,
    ];

    final hasAny = byType.values.any((list) => list.isNotEmpty) ||
        sourcePlugins.isNotEmpty;

    if (!hasAny) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.layers_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.mutedForeground),
            const SizedBox(height: 16),
            Text(
              '暂无平台',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final type in typeOrder)
          if (byType[type] != null && byType[type]!.isNotEmpty)
            ..._buildTypeSection(
              context,
              ref,
              type,
              byType[type]!,
              subsonicAccounts,
            ),

        // 音源插件独立区域
        if (sourcePlugins.isNotEmpty)
          ..._buildSourcePluginsSection(context, ref, sourcePlugins),
      ],
    );
  }

  /// 构建某个类型下的服务分组
  List<Widget> _buildTypeSection(
    BuildContext context,
    WidgetRef ref,
    MusicSourceType type,
    List<MusicService> services,
    List<SubsonicMusicService> subsonicAccounts,
  ) {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        child: Row(
          children: [
            Icon(_typeIcon(type),
                size: 18,
                color: Theme.of(context).colorScheme.mutedForeground),
            const SizedBox(width: 8),
            Text(
              type.displayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(width: 8),
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
      const SizedBox(height: 16),
    ];
  }

  /// 构建音源插件区域
  List<Widget> _buildSourcePluginsSection(
    BuildContext context,
    WidgetRef ref,
    List<String> plugins,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        child: Row(
          children: [
            Icon(Icons.audiotrack, size: 18, color: colorScheme.mutedForeground),
            const SizedBox(width: 8),
            Text(
              '音源插件',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${plugins.length}',
              style: TextStyle(fontSize: 12, color: colorScheme.mutedForeground),
            ),
          ],
        ),
      ),
      Card(
        child: Column(
          children: [
            for (int i = 0; i < plugins.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.description, size: 20, color: colorScheme.primary),
                title: Text(
                  p.basename(plugins[i]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  plugins[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton.text(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () =>
                      ref.read(lxSourcePluginPathsProvider.notifier).removePlugin(plugins[i]),
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 16),
    ];
  }

  /// 构建单个服务的 ListTile
  Widget _buildServiceTile(
    BuildContext context,
    WidgetRef ref,
    MusicService service,
    List<SubsonicMusicService> subsonicAccounts,
  ) {
    final libraryCount = service.libraries.length;
    final subtitle = libraryCount > 0
        ? '$libraryCount 个库'
        : '已加载';

    return ListTile(
      leading: Icon(_typeIcon(service.sourceType), size: 20),
      title: Text(service.sourceName),
      subtitle: Text(subtitle),
      trailing: _canRemove(service.sourceType)
          ? IconButton.text(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: () => _removeService(context, ref, service, subsonicAccounts),
            )
          : null,
    );
  }

  /// 类型对应的图标
  IconData _typeIcon(MusicSourceType type) => switch (type) {
        MusicSourceType.local => Icons.folder,
        MusicSourceType.lx => Icons.code,
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
              MaterialPageRoute<void>(
                builder: (_) => const LxPluginPage(),
              ),
            );
          },
          tablet: () {
            showDialog(
              context: context,
              builder: (_) => const AddLxPluginDialog(),
            );
          },
        );
      case _PlatformType.subsonic:
        showDialog(
          context: context,
          builder: (_) => const AddSubsonicAccountDialog(),
        );
    }
  }

  /// 删除服务
  void _removeService(
    BuildContext context,
    WidgetRef ref,
    MusicService service,
    List<SubsonicMusicService> subsonicAccounts,
  ) {
    switch (service.sourceType) {
      case MusicSourceType.lx:
        ref.read(lxMetadataPluginPathsProvider.notifier).removePlugin('');
      case MusicSourceType.subsonic:
        ref.read(subsonicAccountsProvider.notifier).removeAccount(service.sourceId);
      default:
        break;
    }
  }
}
