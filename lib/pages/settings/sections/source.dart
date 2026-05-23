import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' show BuildContext, ListTile;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/components/dialogs/aduio_source_dialog.dart';
import 'package:pomelo/modules/settings/section_card_with_heading.dart';
import 'package:pomelo/provider/source/audio_source_provider.dart';
import 'package:pomelo/services/dio/dio.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class SettingsSourceSection extends HookConsumerWidget {
  const SettingsSourceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources = ref.watch(sourcesProvider);
    return SectionCardWithHeading(
      heading: '音源',
      children: [
        Column(
          children: sources.when(
            data: (data) => data
                .map(
                  (source) => ListTile(
                    title: Text(source.name),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // ActiveDotItem(
                        //   size: 12,
                        //   color: source.inited ? Colors.green : Colors.red,
                        // ),
                        Switch(
                          value: source.enable,
                          onChanged: (value) {
                            ref
                                .read(sourcesProvider.notifier)
                                .enableSwitch(source.id, value);
                          },
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SettingsSourceSectionTrailing(source.id),
                        IconButton.text(
                          onPressed: () {
                            ref.read(sourcesProvider.notifier).del(source.id);
                          },
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            error: (err, _) => [Text(err.toString())],
            loading: () => [const CircularProgressIndicator()],
          ),
        ),
        Row(
          children: [
            TextButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  allowedExtensions: ['js'],
                );
                if (result != null) {
                  File file = File(result.files.single.path!);
                  final script = await file.readAsString();
                  ref.read(sourcesProvider.notifier).add(script);
                }
              },
              child: const Text('本地导入'),
            ),
            TextButton(
              onPressed: () async {
                final url =
                    await showDialog<String>(
                      context: context,
                      builder: (context) => const AudioSourceDialog(),
                    ) ??
                    '';
                ref.read(sourcesProvider.notifier).addRemote(url);
              },
              child: const Text('网络导入'),
            ),
          ],
        ),
      ],
    );
  }
}

class SettingsSourceSectionTrailing extends HookConsumerWidget {
  final int id;
  const SettingsSourceSectionTrailing(this.id, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioSource = ref.watch(audioSourceProvider(id));
    if (audioSource?.jsEngine == null) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: audioSource!.jsEngine!.platforms
          .map(
            (p) => Tooltip(
              // Tooltip wraps a target widget and shows TooltipContainer on hover/focus.
              tooltip: TooltipContainer(
                child: Text(audioSource.jsEngine!.qualities(p).join(',')),
              ).call,
              child: OutlineBadge(child: Text(p), onPressed: () {}),
            ),
          )
          .toList(),
    );
  }
}
