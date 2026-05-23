import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/models/metadata/metadata.dart';
// import 'package:pomelo/provider/metadata_plugin/audio_source/quality_presets.dart';
// import 'package:pomelo/provider/metadata_plugin/metadata_plugin_provider.dart';
import 'package:pomelo/services/sourced_track/sourced_track.dart';

class SourcedTrackNotifier extends AsyncNotifier<SourcedTrack> {
  final SpotubeFullTrackObject query;
  SourcedTrackNotifier(this.query);
  @override
  FutureOr<SourcedTrack> build() {
    // ref.watch(audioSourcePluginProvider);
    // ref.watch(audioSourcePresetsProvider);

    return SourcedTrack.fetchFromTrack(query: query, ref: ref);
  }

  Future<SourcedTrack> refreshStreamingUrl() async {
    return await update((prev) async {
      return await prev.refreshStream();
    });
  }

  Future<SourcedTrack> copyWithSibling() async {
    return await update((prev) async {
      return prev.copyWithSibling();
    });
  }

  Future<SourcedTrack> swapWithSibling(
    SpotubeAudioSourceMatchObject sibling,
  ) async {
    return await update((prev) async {
      return await prev.swapWithSibling(sibling) ?? prev;
    });
  }

  Future<SourcedTrack> swapWithNextSibling() async {
    return await update((prev) async {
      return await prev.swapWithSibling(prev.siblings.first) as SourcedTrack;
    });
  }
}

final sourcedTrackProvider =
    AsyncNotifierProvider.family<
      SourcedTrackNotifier,
      SourcedTrack,
      SpotubeFullTrackObject
    >(SourcedTrackNotifier.new);
