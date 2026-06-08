import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 提供者错误信息横幅
///
/// 展示调用出错的音乐提供者列表，点击后可查看错误详情。
class ProviderErrorBanner extends StatelessWidget {
  final List<({String sourceId, String sourceName, Object error})> errors;

  const ProviderErrorBanner({super.key, required this.errors});

  @override
  Widget build(BuildContext context) {
    if (errors.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: GestureDetector(
        onTap: () => _showErrorDetail(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.destructive.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.destructive.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: colorScheme.destructive,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${errors.length} 个来源加载失败，点击查看详情',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.destructive,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: colorScheme.destructive,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDetail(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('来源加载错误'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: errors.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final e = errors[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.sourceName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.destructive,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${e.error}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.primaryForeground.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }
}
