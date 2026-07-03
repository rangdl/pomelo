import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_undraw/flutter_undraw.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:pomelo/core/framework/inter_scrollbar.dart';
import 'package:pomelo/provider/logs/logs_provider.dart';
import 'package:pomelo/services/logger/logger.dart';
import 'package:auto_route/auto_route.dart';

import '../../core/core.dart';
import '../../core/framework/back_button.dart';

@RoutePage()
class LogPage extends HookConsumerWidget {
  static const name = "logs";

  const LogPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final controller = useScrollController();

    final logsQuery = ref.watch(logsProvider);

    return Scaffold(
      headers: [
        SafeArea(
          bottom: false,
          child: AppBar(
            title: Text('日志'),
            leading: const [BackButton()],
            trailing: [
              IconButton.ghost(
                icon: const Icon(PomeloIcons.clipboard, size: 16),
                onPressed: () async {
                  final logsSnapshot = await ref.read(logsProvider.future);

                  await Clipboard.setData(ClipboardData(text: logsSnapshot));
                  if (context.mounted) {
                    showToast(
                      context: context,
                      location: ToastLocation.topRight,
                      builder: (context, overlay) {
                        return SurfaceCard(
                          child: Basic(title: Text('已复制至剪贴板')),
                        );
                      },
                    );
                  }
                },
              ),
              IconButton.ghost(
                icon: const Icon(PomeloIcons.trash, size: 16),
                onPressed: () async {
                  ref.invalidate(logsProvider);

                  final logsFile = await AppLogger.getLogsPath();

                  await logsFile.writeAsString("");
                },
              ),
            ],
          ),
        ),
      ],
      child: SafeArea(
        child: switch (logsQuery) {
          AsyncData(:final value) => InterScrollbar(
            controller: controller,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              controller: controller,
              child: Card(child: SelectableText(value)),
            ),
          ),
          AsyncError(:final error) => switch (error) {
            StateError() => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Undraw(
                  illustration: UndrawIllustration.noData,
                  height: 200 * context.theme.scaling,
                  width: 200 * context.theme.scaling,
                  color: context.theme.colorScheme.primary,
                ),
                Text('未找到日志').muted().small(),
              ],
            ),
            _ => Center(child: Text(error.toString())),
          },
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}
