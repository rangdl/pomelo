import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/models/metadata/metadata.dart';
import 'package:pomelo/services/dio/dio.dart';
import 'package:pomelo/services/source/index.dart';
import 'package:pomelo/services/sourced_track/sourced_track.dart';

class SourcedTrackNotifier extends Notifier<SourcedTrack?> {
  final String id;
  SourcedTrackNotifier(this.id);
  @override
  SourcedTrack? build() {
    return null;
  }

  void set(SourcedTrack value) {
    state = value;
  }
}

final sourcedTrack2Provider =
    NotifierProvider.family<SourcedTrackNotifier, SourcedTrack?, String>(
      SourcedTrackNotifier.new,
    );

class StringNotifier extends Notifier<String> {
  @override
  String build() {
    // 在这里进行状态初始化，比如从其他 Provider 读取初始值
    return '';
  }

  void set(String value) {
    state = value;
  }
}

final searchTermProvider = NotifierProvider<StringNotifier, String>(
  StringNotifier.new,
);

final searcherProvider = Provider<Searcher>((ref) => TxSearcher());

class SearchNotifier
    extends AsyncNotifier<SpotubePaginationResponseObject<SpotubeTrackObject>> {
  @override
  Future<SpotubePaginationResponseObject<SpotubeTrackObject>> build() async {
    final searchTerm = ref.watch(searchTermProvider);
    final searcher = ref.watch(searcherProvider);
    return await searcher.search(searchTerm);
    // final items = search.items.map((v) {
    //   final track = v['query'] as SpotubeFullTrackObject;
    //   ref
    //       .read(sourcedTrack2Provider(track.id).notifier)
    //       .set(
    //         SourcedTrack(
    //           ref: ref,
    //           info: v['info'] as SpotubeAudioSourceMatchObject,

    //           query: track,
    //           source: v['source'],
    //           siblings: [],
    //           sources: v['sources'] as List<SpotubeAudioSourceStreamObject>,
    //         ),
    //       );
    //   return track;
    // }).toList();

    // return SpotubePaginationResponseObject.page(
    //   limit: search.limit,
    //   page: search.page,
    //   total: search.total,
    //   hasMore: search.hasMore,
    //   items: items,
    // );
  }
}

final searchProvider =
    AsyncNotifierProvider<
      SearchNotifier,
      SpotubePaginationResponseObject<SpotubeTrackObject>
    >(SearchNotifier.new);
