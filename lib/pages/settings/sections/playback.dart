import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show ListTile;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pomelo/collections/routes.gr.dart';
import 'package:pomelo/collections/spotube_icons.dart';
import 'package:pomelo/components/adaptive/adaptive_select_tile.dart';
import 'package:pomelo/models/database/database.dart';
// import 'package:pomelo/modules/settings/playback/edit_connect_port_dialog.dart';
import 'package:pomelo/modules/settings/section_card_with_heading.dart';
import 'package:pomelo/extensions/context.dart';
// import 'package:pomelo/modules/settings/youtube_engine_not_installed_dialog.dart';
// import 'package:pomelo/provider/metadata_plugin/audio_source/quality_presets.dart';
import 'package:pomelo/provider/user_preferences/user_preferences_provider.dart';
import 'package:pomelo/services/kv_store/kv_store.dart';
// import 'package:pomelo/services/youtube_engine/yt_dlp_engine.dart';

import 'package:pomelo/utils/platform.dart';

class SettingsPlaybackSection extends HookConsumerWidget {
  const SettingsPlaybackSection({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final preferences = ref.watch(userPreferencesProvider);
    final preferencesNotifier = ref.watch(userPreferencesProvider.notifier);
    // final sourcePresets = ref.watch(audioSourcePresetsProvider);
    // final sourcePresetsNotifier =
    //     ref.watch(audioSourcePresetsProvider.notifier);
    final theme = Theme.of(context);

    return SectionCardWithHeading(
      heading: context.l10n.playback,
      children: [
        // if (sourcePresets.presets.isNotEmpty) ...[
        // AdaptiveSelectTile(
        //   secondary: const Icon(SpotubeIcons.plugin),
        //   title: Text(context.l10n.streaming_music_format),
        //   value: sourcePresets.selectedStreamingContainerIndex,
        //   options: [
        //     for (final MapEntry(:key, value: preset)
        //         in sourcePresets.presets.asMap().entries)
        //       SelectItemButton(value: key, child: Text(preset.name)),
        //   ],
        //   onChanged: (value) {
        //     if (value == null) return;
        //     sourcePresetsNotifier.setSelectedStreamingContainerIndex(value);
        //   },
        // ),
        // AdaptiveSelectTile(
        //   secondary: const Icon(SpotubeIcons.audioQuality),
        //   title: Text(context.l10n.streaming_music_quality),
        //   value: sourcePresets.selectedStreamingQualityIndex,
        //   options: [
        //     for (final MapEntry(:key, value: quality) in sourcePresets
        //         .presets[sourcePresets.selectedStreamingContainerIndex]
        //         .qualities
        //         .asMap()
        //         .entries)
        //       SelectItemButton(value: key, child: Text(quality.toString())),
        //   ],
        //   onChanged: (value) {
        //     if (value == null) return;
        //     sourcePresetsNotifier.setSelectedStreamingQualityIndex(value);
        //   },
        // ),
        // AdaptiveSelectTile(
        //   secondary: const Icon(SpotubeIcons.plugin),
        //   title: Text(context.l10n.download_music_format),
        //   value: sourcePresets.selectedDownloadingContainerIndex,
        //   options: [
        //     for (final MapEntry(:key, value: preset)
        //         in sourcePresets.presets.asMap().entries)
        //       SelectItemButton(value: key, child: Text(preset.name)),
        //   ],
        //   onChanged: (value) {
        //     if (value == null) return;
        //     sourcePresetsNotifier.setSelectedDownloadingContainerIndex(value);
        //   },
        // ),
        // AdaptiveSelectTile(
        //   secondary: const Icon(SpotubeIcons.audioQuality),
        //   title: Text(context.l10n.download_music_quality),
        //   value: sourcePresets.selectedStreamingQualityIndex,
        //   options: [
        //     for (final MapEntry(:key, value: quality) in sourcePresets
        //         .presets[sourcePresets.selectedDownloadingContainerIndex]
        //         .qualities
        //         .asMap()
        //         .entries)
        //       SelectItemButton(value: key, child: Text(quality.toString())),
        //   ],
        //   onChanged: (value) {
        //     if (value == null) return;
        //     sourcePresetsNotifier.setSelectedStreamingQualityIndex(value);
        //   },
        // ),
        // ],
        ListTile(
          title: Text(context.l10n.cache_music),
          subtitle: kIsMobile
              ? null
              : Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: "${context.l10n.open} "),
                      TextSpan(
                        text: context.l10n.cache_folder.toLowerCase(),
                        recognizer: TapGestureRecognizer()
                          ..onTap = preferencesNotifier.openCacheFolder,
                        style: theme.typography.normal.copyWith(
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
          leading: const Icon(SpotubeIcons.cache),
          trailing: Switch(
            value: preferences.cacheMusic,
            onChanged: preferencesNotifier.setCacheMusic,
          ),
        ),
        ListTile(
          leading: const Icon(SpotubeIcons.playlistRemove),
          title: Text(context.l10n.blacklist),
          subtitle: Text(context.l10n.blacklist_description),
          onTap: () {
            // context.navigateTo(const BlackListRoute());
          },
          trailing: const Icon(SpotubeIcons.angleRight),
        ),
        ListTile(
          leading: const Icon(SpotubeIcons.normalize),
          title: Text(context.l10n.normalize_audio),
          trailing: Switch(
            value: preferences.normalizeAudio,
            onChanged: preferencesNotifier.setNormalizeAudio,
          ),
        ),
        // ListTile(
        //     leading: const Icon(SpotubeIcons.repeat),
        //     title: Text(context.l10n.endless_playback),
        //     trailing: Switch(
        //       value: preferences.endlessPlayback,
        //       onChanged: preferencesNotifier.setEndlessPlayback,
        //     )),
      ],
    );
  }
}
