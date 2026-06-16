import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' show PopupMenuButton, PopupMenuItem;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/core/rx.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/modules/music/model/music_source.dart';
import 'package:pomelo/modules/music_subsonic/subsonic_source.dart';
import 'package:pomelo/modules/music_subsonic/providers/subsonic_providers.dart';
import 'package:pomelo/ui/music/providers/music_ui_providers.dart';
import 'package:pomelo/ui/platform/widgets/add_lx_script_dialog.dart';
import 'package:pomelo/ui/platform/widgets/add_subsonic_account_dialog.dart';

/// 支持添加的平台类型
enum _PlatformType {
  lx('Lx 音乐脚本', Icons.code, '通过 JS 脚本加载在线音乐平台'),
  subsonic('Subsonic', Icons.cloud, '连接 Subsonic 兼容的音乐服务器');

  final String label;
  final IconData icon;
  final String description;
  const _PlatformType(this.label, this.icon, this.description);
}

/// 平台页面
///
/// 展示所有已注册的音乐平台来源，按类型分组。
/// 右上角"+"按钮可添加新平台。
@RoutePage()
class FavoritePage extends ConsumerWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourcesAsync = ref.watch(musicSourcesByTypeProvider);
    final subsonicAccounts = ref.watch(subsonicAccountsProvider);

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
      child: sourcesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (sourcesByType) => _buildBody(
          context,
          ref,
          sourcesByType,
          subsonicAccounts,
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    Map<MusicSourceType, List<MusicSource>> sourcesByType,
    List<SubsonicSource> subsonicAccounts,
  ) {
    // 定义展示顺序
    const typeOrder = [
      MusicSourceType.local,
      MusicSourceType.lx,
      MusicSourceType.subsonic,
      MusicSourceType.navidrome,
      MusicSourceType.emby,
    ];

    final hasAny = sourcesByType.values.any((list) => list.isNotEmpty);

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
          if (sourcesByType[type] != null && sourcesByType[type]!.isNotEmpty)
            ..._buildTypeSection(
              context,
              ref,
              type,
              sourcesByType[type]!,
              subsonicAccounts,
            ),
      ],
    );
  }

  /// 构建某个类型下的来源分组
  List<Widget> _buildTypeSection(
    BuildContext context,
    WidgetRef ref,
    MusicSourceType type,
    List<MusicSource> sources,
    List<SubsonicSource> subsonicAccounts,
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
              '${sources.length}',
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
            for (int i = 0; i < sources.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              _buildSourceTile(context, ref, sources[i]),
            ],
          ],
        ),
      ),
      const SizedBox(height: 16),
    ];
  }

  /// 构建单个来源的 ListTile
  Widget _buildSourceTile(
    BuildContext context,
    WidgetRef ref,
    MusicSource source,
  ) {
    final serviceCount = source.services.length;
    final subtitle = serviceCount > 0
        ? '$serviceCount 个音乐服务'
        : '未加载服务';

    return ListTile(
      leading: Icon(_typeIcon(source.type), size: 20),
      title: Text(source.name),
      subtitle: Text(subtitle),
      trailing: _canRemove(source.type)
          ? IconButton.text(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: () => _removeSource(context, ref, source),
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
        Rx.layout(
          context,
          mobile: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const LxScriptPage(),
              ),
            );
            return const SizedBox.shrink();
          },
          tablet: () {
            showDialog(
              context: context,
              builder: (_) => const AddLxScriptDialog(),
            );
            return const SizedBox.shrink();
          },
        );
      case _PlatformType.subsonic:
        showDialog(
          context: context,
          builder: (_) => const AddSubsonicAccountDialog(),
        );
    }
  }

  /// 删除来源
  void _removeSource(
    BuildContext context,
    WidgetRef ref,
    MusicSource source,
  ) {
    switch (source.type) {
      case MusicSourceType.subsonic:
        ref.read(subsonicAccountsProvider.notifier).removeAccount(source.id);
      default:
        break;
    }
  }
}
