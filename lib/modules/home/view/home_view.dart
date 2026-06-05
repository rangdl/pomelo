import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/modules/home/providers/home_providers.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Home 模块 - 视图层
///
/// 使用 M.A.R.S. 模式 + shadcn/ui 组件。
class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(homeRepositoryProvider);
    final theme = ShadTheme.of(context);

    return FutureBuilder(
      future: repository.fetchAll(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: ShadProgress());
        }

        final items = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ShadCard(
                title: Text(item.title, style: theme.textTheme.h4),
                description: item.subtitle.isNotEmpty
                    ? Text(item.subtitle, style: theme.textTheme.muted)
                    : null,
                leading: Icon(
                  _iconMap[item.icon] ?? LucideIcons.circle,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                trailing: ShadButton.ghost(
                  size: ShadButtonSize.sm,
                  child: const Icon(LucideIcons.chevronRight, size: 16),
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
  'home': LucideIcons.house,
  'layers': LucideIcons.layers,
  'bolt': LucideIcons.zap,
  'route': LucideIcons.route,
  'favorite': LucideIcons.heart,
  'star': LucideIcons.star,
};
