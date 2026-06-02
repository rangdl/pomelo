import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomelo/models/metadata/metadata.dart';
import 'package:pomelo/models/playback/track_sources.dart';
import 'package:pomelo/provider/source/audio_source_provider.dart';
import 'package:pomelo/services/logger/logger.dart';

final officialMusicRegex = RegExp(
  r"official\s(video|audio|music\svideo|lyric\svideo|visualizer)",
  caseSensitive: false,
);

class SourcedTrack extends BasicSourcedTrack {
  final Ref ref;

  SourcedTrack({
    required this.ref,
    required super.info,
    required super.query,
    required super.source,
    required super.siblings,
    required super.sources,
  });

  static Future<SourcedTrack> fetchFromTrack({
    required SpotubeFullTrackObject query,
    required Ref ref,
  }) async {
    final sourcedTrack = query.toSourcedTrack(ref);
    AppLogger.log.i("${query.name}: ${sourcedTrack.url}");
    return sourcedTrack;
  }

  static List<SpotubeAudioSourceMatchObject> rankResults(
    List<SpotubeAudioSourceMatchObject> results,
    SpotubeFullTrackObject track,
  ) {
    return results
        .map((sibling) {
          int score = 0;

          for (final artist in track.artists) {
            final isSameChannelArtist = sibling.artists.any(
              (a) => a.toLowerCase() == artist.name,
            );

            if (isSameChannelArtist) {
              score += 1;
            }

            final titleContainsArtist = sibling.title.toLowerCase().contains(
              artist.name.toLowerCase(),
            );

            if (titleContainsArtist) {
              score += 1;
            }
          }

          final titleContainsTrackName = sibling.title.toLowerCase().contains(
            track.name.toLowerCase(),
          );

          final hasOfficialFlag = officialMusicRegex.hasMatch(
            sibling.title.toLowerCase(),
          );

          if (titleContainsTrackName) {
            score += 3;
          }

          if (hasOfficialFlag) {
            score += 1;
          }

          if (hasOfficialFlag && titleContainsTrackName) {
            score += 2;
          }

          return (sibling: sibling, score: score);
        })
        .sorted((a, b) => b.score.compareTo(a.score))
        .map((e) => e.sibling)
        .toList();
  }

  static Future<List<SpotubeAudioSourceMatchObject>> fetchSiblings({
    required SpotubeFullTrackObject query,
    required Ref ref,
  }) async {
    // final audioSource = await ref.read(audioSourcePluginProvider.future);

    // if (audioSource == null) {
    //   throw MetadataPluginException.noDefaultAudioSourcePlugin();
    // }

    // final videoResults = <SpotubeAudioSourceMatchObject>[];

    // final searchResults = await audioSource.audioSource.matches(query);

    // if (ServiceUtils.onlyContainsEnglish(query.name)) {
    //   videoResults.addAll(searchResults);
    // } else {
    //   videoResults.addAll(rankResults(searchResults, query));
    // }

    // return videoResults.toSet().toList();
    return [];
  }

  Future<SourcedTrack> copyWithSibling() async {
    if (siblings.isNotEmpty) {
      return this;
    }
    final fetchedSiblings = await fetchSiblings(ref: ref, query: query);

    return SourcedTrack(
      ref: ref,
      siblings: fetchedSiblings.where((s) => s.id != info.id).toList(),
      source: source,
      sources: sources,
      info: info,
      query: query,
    );
  }

  Future<SourcedTrack?> swapWithSibling(
    SpotubeAudioSourceMatchObject sibling,
  ) async {
    if (sibling.id == info.id) {
      return null;
    }

    // final audioSource = await ref.read(audioSourcePluginProvider.future);
    // final audioSourceConfig = await ref.read(
    //   metadataPluginsProvider.selectAsync(
    //     (data) => data.defaultAudioSourcePluginConfig,
    //   ),
    // );
    // if (audioSource == null || audioSourceConfig == null) {
    //   throw MetadataPluginException.noDefaultAudioSourcePlugin();
    // }

    // // a sibling source that was fetched from the search results
    // final isStepSibling = siblings.none((s) => s.id == sibling.id);

    // final newSourceInfo = isStepSibling
    //     ? sibling
    //     : siblings.firstWhere((s) => s.id == sibling.id);

    // final newSiblings = siblings.where((s) => s.id != sibling.id).toList()
    //   ..insert(0, info);

    // final manifest = await audioSource.audioSource.streams(newSourceInfo);

    // final database = ref.read(databaseProvider);

    // // Delete the old Entry
    // await (database.sourceMatchTable.delete()..where(
    //       (table) =>
    //           table.trackId.equals(query.id) &
    //           table.sourceType.equals(audioSourceConfig.slug),
    //     ))
    //     .go();

    // await database
    //     .into(database.sourceMatchTable)
    //     .insert(
    //       SourceMatchTableCompanion.insert(
    //         trackId: query.id,
    //         sourceInfo: Value(jsonEncode(sibling)),
    //         sourceType: audioSourceConfig.slug,
    //         createdAt: Value(DateTime.now()),
    //       ),
    //       mode: InsertMode.replace,
    //     );

    // return SourcedTrack(
    //   ref: ref,
    //   source: source,
    //   siblings: newSiblings,
    //   sources: manifest,
    //   info: newSourceInfo,
    //   query: query,
    // );
    return null;
  }

  Future<SourcedTrack?> swapWithSiblingOfIndex(int index) {
    return swapWithSibling(siblings[index]);
  }

  Future<SourcedTrack> refreshStream() async {
    List<SpotubeAudioSourceStreamObject> validStreams = [];
    final stringBuffer = StringBuffer();
    final currentSource = getStreamOfQuality2();
    for (final source in sources) {
      if (source == currentSource && source.url.isEmpty) {
        final url = await ref
            .read(audioSourcesProvider.notifier)
            .musicUrl2(query, quality: source.tag);
        validStreams.add(source.copyWith(url: url ?? ''));
      } else {
        validStreams.add(source);
      }
    }
    AppLogger.log.d(stringBuffer.toString());

    final sourcedTrack = SourcedTrack(
      ref: ref,
      siblings: siblings,
      source: source,
      sources: validStreams,
      info: info,
      query: query,
    );
    // sourcedTrack.sources.map((source) {}).toList();
    AppLogger.log.i("Refreshing ${query.name}: ${sourcedTrack.url}");
    return sourcedTrack;
  }

  String? get url {
    return getStreamOfQuality2()?.url;
    // final preferences = ref.read(audioSourcePresetsProvider);

    // return getUrlOfQuality(
    //   preferences.presets[preferences.selectedStreamingContainerIndex],
    //   preferences.selectedStreamingQualityIndex,
    // );
  }

  /// Returns the URL of the track based on the codec and quality preferences.
  /// If an exact match is not found, it will return the closest match based on
  /// the user's audio quality preference.
  ///
  /// If no sources match the codec, it will return the first or last source
  /// based on the user's audio quality preference.
  SpotubeAudioSourceStreamObject? getStreamOfQuality(
    SpotubeAudioSourceContainerPreset preset,
    int qualityIndex,
  ) {
    if (sources.isEmpty) return null;

    final quality = preset.qualities[qualityIndex];

    final exactMatch = sources.firstWhereOrNull((source) {
      if (source.container != preset.name) return false;

      if (quality case SpotubeAudioLosslessContainerQuality()) {
        return source.sampleRate == quality.sampleRate &&
            source.bitDepth == quality.bitDepth;
      } else {
        return source.bitrate ==
            (quality as SpotubeAudioLossyContainerQuality).bitrate;
      }
    });

    if (exactMatch != null) {
      return exactMatch;
    }

    // Find the preset with closest quality to the supplied quality
    return sources
        .where((source) {
          return source.container == preset.name;
        })
        .reduce((prev, curr) {
          if (quality is SpotubeAudioLosslessContainerQuality) {
            final prevDiff =
                ((prev.sampleRate ?? 0) - quality.sampleRate).abs() +
                ((prev.bitDepth ?? 0) - quality.bitDepth).abs();
            final currDiff =
                ((curr.sampleRate ?? 0) - quality.sampleRate).abs() +
                ((curr.bitDepth ?? 0) - quality.bitDepth).abs();
            return currDiff < prevDiff ? curr : prev;
          } else {
            final prevDiff =
                ((prev.bitrate ?? 0) -
                        (quality as SpotubeAudioLossyContainerQuality).bitrate)
                    .abs();
            final currDiff = ((curr.bitrate ?? 0) - quality.bitrate).abs();
            return currDiff < prevDiff ? curr : prev;
          }
        });
  }

  SpotubeAudioSourceStreamObject? getStreamOfQuality2() {
    if (sources.isEmpty) return null;
    if (sources.length <= 1) return sources.first;
    const quality = '128k';
    return sources.firstWhereOrNull((s) => s.tag == quality);
  }

  String? getUrlOfQuality(
    SpotubeAudioSourceContainerPreset preset,
    int qualityIndex,
  ) {
    return getStreamOfQuality(preset, qualityIndex)?.url;
  }

  SpotubeAudioSourceContainerPreset? get qualityPreset {
    // final presetState = ref.read(audioSourcePresetsProvider);
    // return presetState.presets.elementAtOrNull(
    //   presetState.selectedStreamingContainerIndex,
    // );
  }
  String? getFileExtension() {
    return getStreamOfQuality2()?.container;

    // final presetState = ref.read(audioSourcePresetsProvider);
    // return presetState.presets.elementAtOrNull(
    //   presetState.selectedStreamingContainerIndex,
    // );
  }
}

extension ToSourcedTrackSpotubeFullTrackObject on SpotubeFullTrackObject {
  SourcedTrack toSourcedTrack(ref) {
    return SourcedTrack(
      info: SpotubeAudioSourceMatchObject(
        id: meta!.musicId,
        title: name,
        artists: artists.map((v) => v.name).toList(),
        duration: Duration(seconds: durationMs),
        externalUri: '',
        thumbnail: album.externalUri,
      ),
      ref: ref,
      query: this,
      source: meta!.source,
      siblings: [],
      sources: meta!.types
          .map(
            (v) => SpotubeAudioSourceStreamObject(
              url: '',
              container: switch (v.type) {
                'flac24bit' => 'flac',
                'flac' => 'flac',
                _ => 'm4a',
              },
              type: switch (v.type) {
                'flac24bit' => SpotubeMediaCompressionType.lossless,
                'flac' => SpotubeMediaCompressionType.lossless,
                _ => SpotubeMediaCompressionType.lossy,
              },
              // codec: switch (v.type) {
              //   'flac24bit' => 'flac',
              //   'flac' => 'flac',
              //   _ => 'mp3',
              // },
              tag: v.type,
            ),
          )
          .toList(),
    );
  }
}
