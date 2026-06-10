/// 日志模块 - UI 视图
///
/// 提供日志列表浏览、筛选和查看详情的界面。
library;

import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/modules/log/model/log_entry.dart';
import 'package:pomelo/modules/log/providers/log_providers.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 日志主页面
@RoutePage()
class LogPage extends ConsumerWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(latestLogsProvider);

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('应用日志'),
          trailing: [
            GhostButton(
              size: ButtonSize.small,
              onPressed: () {
                ref.read(logServiceProvider).cleanAll();
                ref.invalidate(latestLogsProvider);
                ref.invalidate(logLevelStatsProvider);
              },
              child: const Text('清空'),
            ),
          ],
        ),
        const Divider(),
      ],
      child: logsAsync.when(
        data: (logs) => _LogListView(logs: logs),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('加载失败: $error')),
      ),
    );
  }
}

/// 日志列表视图
class _LogListView extends StatelessWidget {
  final List<LogEntry> logs;

  const _LogListView({required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Center(child: Text('暂无日志记录'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: logs.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = logs[index];
        return _LogTile(entry: entry);
      },
    );
  }
}

/// 单条日志条目组件
class _LogTile extends StatelessWidget {
  final LogEntry entry;

  const _LogTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: _LogLevelBadge(level: entry.level),
        title: Text(
          entry.message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${entry.timestamp.toString().substring(0, 19)}  [${entry.tag}]'
          '${entry.sourceModuleId != null ? ' (${entry.sourceModuleId})' : ''}',
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        onTap: () => _showLogDetail(context, entry),
      ),
    );
  }

  /// 显示日志详情对话框
  void _showLogDetail(BuildContext context, LogEntry entry) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('日志详情'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow(context, '级别', entry.level.name.toUpperCase()),
              _detailRow(context, '标签', entry.tag),
              _detailRow(context, '时间', entry.timestamp.toString()),
              if (entry.sourceModuleId != null)
                _detailRow(context, '来源模块', entry.sourceModuleId!),
              const SizedBox(height: 12),
              Text(
                '消息',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(height: 4),
              Text(entry.message),
              if (entry.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  '错误详情',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.mutedForeground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.error.toString(),
                  style: const TextStyle(color: Color(0xFFEF4444)),
                ),
              ],
              if (entry.stackTrace != null) ...[
                const SizedBox(height: 12),
                Text(
                  '堆栈跟踪',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.mutedForeground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.stackTrace.toString(),
                  style: const TextStyle(fontSize: 11),
                ),
              ],
              if (entry.metadata != null && entry.metadata!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '元数据',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.mutedForeground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(entry.metadata.toString()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

/// 日志级别徽章
class _LogLevelBadge extends StatelessWidget {
  final LogLevel level;

  const _LogLevelBadge({required this.level});

  static const _levelColors = {
    LogLevel.debug: Color(0xFF9E9E9E),
    LogLevel.info: Color(0xFF2196F3),
    LogLevel.warning: Color(0xFFFF9800),
    LogLevel.error: Color(0xFFEF4444),
    LogLevel.fatal: Color(0xFF9C27B0),
  };

  @override
  Widget build(BuildContext context) {
    final color = _levelColors[level]!;
    final label = switch (level) {
      LogLevel.debug => 'DBG',
      LogLevel.info => 'INF',
      LogLevel.warning => 'WRN',
      LogLevel.error => 'ERR',
      LogLevel.fatal => 'FTL',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
