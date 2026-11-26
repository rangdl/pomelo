import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/logging/app_logger.dart';
import '../../../shared/ui/tokens.dart';
import '../../../shared/widgets/widgets.dart';

/// 最近日志（打开页面时读取一次）。
final _logsProvider = FutureProvider.autoDispose<List<String>>(
  (ref) => AppLogger.instance.readRecent(maxLines: 400),
);

/// 运行日志页：查看最近的错误与运行记录，支持复制、导出、清空。
class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key});

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  bool _busy = false;

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _copyAll(List<String> lines) async {
    if (lines.isEmpty) {
      _toast('暂无日志可复制');
      return;
    }
    await Clipboard.setData(ClipboardData(text: lines.join('\n')));
    if (mounted) _toast('已复制 ${lines.length} 行日志');
  }

  Future<void> _export() async {
    final location = await getSaveLocation(
      suggestedName: 'pomelo-log-${DateTime.now().millisecondsSinceEpoch}.txt',
      acceptedTypeGroups: const [
        XTypeGroup(label: '文本文件', extensions: ['txt', 'log']),
      ],
    );
    if (location == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final count = await AppLogger.instance.exportTo(File(location.path));
      if (mounted) _toast('已导出 $count 行日志');
    } catch (e) {
      AppLogger.instance.error('log', '导出日志失败', e);
      if (mounted) _toast('导出失败: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        title: const Text('清空日志'),
        content: const Text('清空后无法恢复，建议先导出需要保留的内容。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('清空'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await AppLogger.instance.clear();
    if (!mounted) return;
    ref.invalidate(_logsProvider);
    _toast('日志已清空');
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(_logsProvider);
    final lines = logsAsync.value ?? const <String>[];
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('运行日志'),
        actions: [
          IconButton(
            tooltip: '刷新',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(_logsProvider),
          ),
          PopupMenuButton<String>(
            tooltip: '日志操作',
            position: PopupMenuPosition.under,
            enabled: !_busy,
            onSelected: (value) {
              switch (value) {
                case 'copy':
                  _copyAll(lines);
                case 'export':
                  _export();
                default:
                  _clear();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'copy', child: Text('复制全部')),
              PopupMenuItem(value: 'export', child: Text('导出到文件')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'clear', child: Text('清空日志')),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: '读取日志失败',
          message: '$e',
          actions: [
            FilledButton(
              onPressed: () => ref.invalidate(_logsProvider),
              child: const Text('重试'),
            ),
          ],
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return const EmptyState(
              icon: Icons.article_outlined,
              title: '暂无日志',
              message: '运行中出现错误或重要事件时，会自动记录在这里。',
            );
          }
          // 最新日志排在最上面，打开页面即可看到最近发生了什么。
          final reversed = entries.reversed.toList(growable: false);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.sm,
                  AppSpacing.page,
                  AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        '最多显示最近 ${entries.length} 行，最新在最上',
                        style: TextStyle(
                          fontSize: AppText.compact,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SelectionArea(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      AppSpacing.xs,
                      AppSpacing.page,
                      AppSpacing.xl,
                    ),
                    itemCount: reversed.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      thickness: 0.5,
                      color: scheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                    itemBuilder: (context, index) =>
                        _LogLine(text: reversed[index]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 单行日志：错误行用 error 色，其余用等宽字体保证时间戳对齐。
class _LogLine extends StatelessWidget {
  const _LogLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isError = text.contains(' [E] ');
    final isWarning = text.contains(' [W] ');
    final color = isError
        ? scheme.error
        : isWarning
        ? scheme.tertiary
        : scheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          height: 1.35,
          color: color,
          fontFamily: 'Consolas',
          fontFamilyFallback: const ['Menlo', 'monospace'],
        ),
      ),
    );
  }
}
