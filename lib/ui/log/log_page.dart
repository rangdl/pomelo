/// 日志模块 - UI 视图
///
/// 提供日志列表浏览、筛选、搜索和详情的界面。
/// 支持级别筛选、标签筛选、关键词搜索和存储级别设置。
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/core/framework/framework.dart';
import 'package:pomelo/core/rx.dart';
import 'package:pomelo/core/log/log_entry.dart';
import 'package:pomelo/core/log/log_providers.dart';
import 'package:pomelo/ui/music/widgets/app_chip.dart';
import 'package:flutter/material.dart' show PopupMenuButton, PopupMenuItem;
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 日志主页面
@RoutePage()
class LogPage extends HookConsumerWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      headers: [
        AppBar(
          leading: [
            GhostButton(
              onPressed: () => context.router.maybePop(),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ],
          title: const Text('应用日志'),
          trailing: [
            // 存储设置按钮
            GhostButton(
              size: ButtonSize.small,
              onPressed: () => _showStorageSettings(context, ref),
              child: const Icon(Icons.settings, size: 16),
            ),
            // 清空按钮
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
      child: const _LogContent(),
    );
  }

  /// 显示存储级别设置对话框
  void _showStorageSettings(BuildContext context, WidgetRef ref) {
    final currentLevel = ref.read(logStorageLevelProvider);
    final filePath = ref.read(logFilePathProvider);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('日志存储设置'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '文件存储最低级别',
              style: TextStyle(
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '低于此级别的日志仅存内存，重启后丢失。',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 12),
            ...LogLevel.values.map((level) {
              return GhostButton(
                onPressed: () {
                  ref
                      .read(logStorageLevelProvider.notifier)
                      .setLevel(level);
                  Navigator.of(dialogContext).pop();
                },
                child: Row(
                  children: [
                    _LogLevelDot(level: level),
                    const SizedBox(width: 8),
                    Text(_levelDisplayName(level)),
                    if (level == currentLevel) ...[
                      const Spacer(),
                      const Icon(Icons.check, size: 16),
                    ],
                  ],
                ),
              );
            }),
            if (filePath != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                '日志文件路径',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                filePath,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 日志内容区域（筛选 + 列表）
class _LogContent extends HookConsumerWidget {
  const _LogContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLevels = useState<Set<LogLevel>>({});
    final selectedTag = useState<String?>(null);
    final searchKeyword = useState('');
    final searchController = useTextEditingController();

    // 每次打开日志页面都重新加载数据（三个 Provider 非 autoDispose，需手动 invalidate）
    useEffect(() {
      ref.invalidate(latestLogsProvider);
      ref.invalidate(logLevelStatsProvider);
      ref.invalidate(logTagsProvider);
      return null;
    }, []);

    final logsAsync = ref.watch(latestLogsProvider);
    final statsAsync = ref.watch(logLevelStatsProvider);
    final tagsAsync = ref.watch(logTagsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Rx.layout(
      context,
      mobile: () => Column(
        children: [
          _FilterPanel(
            selectedLevels: selectedLevels,
            selectedTag: selectedTag,
            searchKeyword: searchKeyword,
            searchController: searchController,
            statsAsync: statsAsync,
            tagsAsync: tagsAsync,
            colorScheme: colorScheme,
            isSidebar: false,
          ),
          Expanded(child: _LogListView(
            logsAsync: logsAsync,
            selectedLevels: selectedLevels,
            selectedTag: selectedTag,
            searchKeyword: searchKeyword,
            colorScheme: colorScheme,
          )),
        ],
      ),
      tablet: () => Row(
        children: [
          SizedBox(
            width: 240,
            child: Column(
              children: [
                _FilterPanel(
                  selectedLevels: selectedLevels,
                  selectedTag: selectedTag,
                  searchKeyword: searchKeyword,
                  searchController: searchController,
                  statsAsync: statsAsync,
                  tagsAsync: tagsAsync,
                  colorScheme: colorScheme,
                  isSidebar: true,
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _LogListView(
            logsAsync: logsAsync,
            selectedLevels: selectedLevels,
            selectedTag: selectedTag,
            searchKeyword: searchKeyword,
            colorScheme: colorScheme,
          )),
        ],
      ),
    );
  }
}

/// 筛选面板
class _FilterPanel extends StatelessWidget {
  final ValueNotifier<Set<LogLevel>> selectedLevels;
  final ValueNotifier<String?> selectedTag;
  final ValueNotifier<String> searchKeyword;
  final TextEditingController searchController;
  final AsyncValue<Map<LogLevel, int>> statsAsync;
  final AsyncValue<Set<String>> tagsAsync;
  final ColorScheme colorScheme;
  final bool isSidebar;

  const _FilterPanel({
    required this.selectedLevels,
    required this.selectedTag,
    required this.searchKeyword,
    required this.searchController,
    required this.statsAsync,
    required this.tagsAsync,
    required this.colorScheme,
    required this.isSidebar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: colorScheme.muted.withAlpha(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: isSidebar ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // 搜索框
          TextField(
            controller: searchController,
            placeholder: const Text('搜索日志...'),
            onChanged: (value) {
              searchKeyword.value = value;
            },
            features: [
              InputFeature.leading(
                const Icon(Icons.search, size: 16),
              ),
              if (searchKeyword.value.isNotEmpty)
                InputFeature.trailing(
                  GestureDetector(
                    onTap: () {
                      searchController.clear();
                      searchKeyword.value = '';
                    },
                    child: const Icon(Icons.clear, size: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // 级别筛选 chips
          if (isSidebar)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _buildLevelChips(),
            )
          else
            SizedBox(
              height: 30,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: LogLevel.values.length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isSelected = selectedLevels.value.isEmpty;
                    return AppChip(
                      label: '全部',
                      isSelected: isSelected,
                      onTap: () => selectedLevels.value = {},
                      borderWhenUnselected: true,
                    );
                  }
                  final level = LogLevel.values[index - 1];
                  final isSelected = selectedLevels.value.contains(level);
                  return AppChip(
                    label: _levelShortName(level),
                    isSelected: isSelected,
                    selectedColor: _levelColor(level),
                    onTap: () {
                      if (isSelected) {
                        selectedLevels.value = {...selectedLevels.value}..remove(level);
                      } else {
                        selectedLevels.value = {...selectedLevels.value, level};
                      }
                    },
                    borderWhenUnselected: true,
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          // 标签筛选 + 统计
          Row(
            children: [
              tagsAsync.when(
                data: (tags) {
                  final tagList = tags.toList()..sort();
                  return PopupMenuButton<String?>(
                    initialValue: selectedTag.value,
                    onSelected: (value) {
                      selectedTag.value = value;
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: null,
                        child: Text('所有标签'),
                      ),
                      ...tagList.map(
                        (tag) => PopupMenuItem(
                          value: tag,
                          child: Text(tag),
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colorScheme.muted.withAlpha(60),
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedTag.value ?? '标签',
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down, size: 18),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const Spacer(),
              statsAsync.when(
                data: (stats) {
                  final total = stats.values.fold(0, (a, b) => a + b);
                  return Text(
                    '$total 条',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.mutedForeground,
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLevelChips() {
    final chips = <Widget>[
      AppChip(
        label: '全部',
        isSelected: selectedLevels.value.isEmpty,
        onTap: () => selectedLevels.value = {},
        borderWhenUnselected: true,
      ),
    ];
    for (final level in LogLevel.values) {
      final isSelected = selectedLevels.value.contains(level);
      chips.add(AppChip(
        label: _levelShortName(level),
        isSelected: isSelected,
        selectedColor: _levelColor(level),
        onTap: () {
          if (isSelected) {
            selectedLevels.value = {...selectedLevels.value}..remove(level);
          } else {
            selectedLevels.value = {...selectedLevels.value, level};
          }
        },
        borderWhenUnselected: true,
      ));
    }
    return chips;
  }
}

/// 日志列表视图
class _LogListView extends StatelessWidget {
  final AsyncValue<List<LogEntry>> logsAsync;
  final ValueNotifier<Set<LogLevel>> selectedLevels;
  final ValueNotifier<String?> selectedTag;
  final ValueNotifier<String> searchKeyword;
  final ColorScheme colorScheme;

  const _LogListView({
    required this.logsAsync,
    required this.selectedLevels,
    required this.selectedTag,
    required this.searchKeyword,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return logsAsync.when(
      data: (logs) {
        var filtered = logs;
        if (selectedLevels.value.isNotEmpty) {
          filtered =
              filtered.where((e) => selectedLevels.value.contains(e.level)).toList();
        }
        if (selectedTag.value != null) {
          filtered =
              filtered.where((e) => e.tag == selectedTag.value).toList();
        }
        if (searchKeyword.value.isNotEmpty) {
          final kw = searchKeyword.value.toLowerCase();
          filtered = filtered
              .where(
                (e) =>
                    e.message.toLowerCase().contains(kw) ||
                    e.tag.toLowerCase().contains(kw),
              )
              .toList();
        }

        if (filtered.isEmpty) {
          return Center(
            child: Text(
              logs.isEmpty ? '暂无日志记录' : '无匹配日志',
              style: TextStyle(color: colorScheme.mutedForeground),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return _LogTile(entry: filtered[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载失败: $error')),
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

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(level);
    final label = _levelShortName(level);

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

/// 日志级别小圆点
class _LogLevelDot extends StatelessWidget {
  final LogLevel level;

  const _LogLevelDot({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: _levelColor(level),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// 级别显示名称
String _levelDisplayName(LogLevel level) {
  return switch (level) {
    LogLevel.debug => '调试 (Debug)',
    LogLevel.info => '信息 (Info)',
    LogLevel.warning => '警告 (Warning)',
    LogLevel.error => '错误 (Error)',
    LogLevel.fatal => '严重 (Fatal)',
  };
}

/// 级别短名称
String _levelShortName(LogLevel level) {
  return switch (level) {
    LogLevel.debug => 'DBG',
    LogLevel.info => 'INF',
    LogLevel.warning => 'WRN',
    LogLevel.error => 'ERR',
    LogLevel.fatal => 'FTL',
  };
}

/// 级别对应颜色
Color _levelColor(LogLevel level) {
  return switch (level) {
    LogLevel.debug => const Color(0xFF9E9E9E),
    LogLevel.info => const Color(0xFF2196F3),
    LogLevel.warning => const Color(0xFFFF9800),
    LogLevel.error => const Color(0xFFEF4444),
    LogLevel.fatal => const Color(0xFF9C27B0),
  };
}
