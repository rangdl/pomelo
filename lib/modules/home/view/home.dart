import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' show ListTile;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/modules/home/providers/home_providers.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Home 模块 - 视图层
///
/// 使用 M.A.R.S. 模式 + shadcn_flutter 组件。
@RoutePage()
class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(homeRepositoryProvider);
    final theme = Theme.of(context);

    return FutureBuilder(
      future: repository.fetchAll(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: ListTile(
                  leading: Icon(
                    _iconMap[item.icon] ?? Icons.circle,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  title: Text(item.title),
                  subtitle: item.subtitle.isNotEmpty
                      ? Text(item.subtitle)
                      : null,
                  trailing: GhostButton(
                    size: ButtonSize.small,
                    child: const Icon(Icons.chevron_right, size: 16),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

const _iconMap = {
  'home': Icons.home,
  'layers': Icons.layers,
  'bolt': Icons.bolt,
  'route': Icons.route,
  'favorite': Icons.favorite,
  'star': Icons.star,
};
