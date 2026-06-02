import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/models/metadata/metadata.dart';
import 'package:pomelo/services/js_engine/js_engine.dart';

class MusicsdkNotifier extends Notifier<JavascriptRuntime> {
  @override
  JavascriptRuntime build() {
    var jsEngine = JsEngine();
    Future.microtask(() => init());
    ref.onDispose(jsEngine.dispose);
    return jsEngine.jsRuntime;
  }

  Future<void> init() async {
    // 加载 sdk
    final musicsdk = await rootBundle.loadString('assets/js/musicsdk.umd.js');
    final resultSdk = state.evaluate(musicsdk);
    if (resultSdk.isError) {
      print('js: ${resultSdk.toString()}');
    } else {
      print('musicsdk加载成功');
    }

    // 加载插件
    final result = state.evaluate("""
const registry = new globalThis.musicsdk.Registry();
registry.register(new musicsdk.KgSearcher());
registry.register(new musicsdk.KwSearcher());
registry.register(new musicsdk.TxSearcher());
registry.register(new musicsdk.WySearcher());
registry.register(new musicsdk.MgSearcher());

registry.registerSongListProvider(new musicsdk.KgSongListProvider());
registry.registerSongListProvider(new musicsdk.KwSongListProvider());
registry.registerSongListProvider(new musicsdk.TxSongListProvider());
registry.registerSongListProvider(new musicsdk.WySongListProvider());
registry.registerSongListProvider(new musicsdk.MgSongListProvider());

registry.registerLyricFetcher(new musicsdk.KgLyricFetcher());
registry.registerLyricFetcher(new musicsdk.KwLyricFetcher());
registry.registerLyricFetcher(new musicsdk.TxLyricFetcher());
registry.registerLyricFetcher(new musicsdk.WyLyricFetcher());
registry.registerLyricFetcher(new musicsdk.MgLyricFetcher());

registry.registerLeaderboardProvider(new musicsdk.KgLeaderboardProvider());
registry.registerLeaderboardProvider(new musicsdk.KwLeaderboardProvider());
registry.registerLeaderboardProvider(new musicsdk.TxLeaderboardProvider());
registry.registerLeaderboardProvider(new musicsdk.WyLeaderboardProvider());
registry.registerLeaderboardProvider(new musicsdk.MgLeaderboardProvider());

registry.registerHotSearchFetcher(new musicsdk.KgHotSearchFetcher());
registry.registerHotSearchFetcher(new musicsdk.KwHotSearchFetcher());
registry.registerHotSearchFetcher(new musicsdk.TxHotSearchFetcher());
registry.registerHotSearchFetcher(new musicsdk.WyHotSearchFetcher());
registry.registerHotSearchFetcher(new musicsdk.MgHotSearchFetcher());

registry.registerTipSearchProvider(new musicsdk.KgTipSearchProvider());
registry.registerTipSearchProvider(new musicsdk.KwTipSearchProvider());
registry.registerTipSearchProvider(new musicsdk.TxTipSearchProvider());
registry.registerTipSearchProvider(new musicsdk.WyTipSearchProvider());
registry.registerTipSearchProvider(new musicsdk.MgTipSearchProvider());
""");
    if (result.isError) {
      print('js: ${result.toString()}');
    } else {
      print('musicsdk插件注册成功');
    }
  }

  Future<SpotubePaginationResponseObject<SpotubeTrackObject>> search(
    String keyword, {
    int page = 1,
    int limit = 20,
    type = 'tx',
  }) async {
    final result = await state.evaluateAsync(
      "registry.get(`$type`)?.search(`$keyword`, $page, $limit)",
      // "typeof `$keyword`",
    );
    state.executePendingJob();
    if (result.isError) {
      print(result.toString());
    }
    final asyncResult = await state.handlePromise(result);
    final json = Map<String, dynamic>.from(await asyncResult.rawResult);
    final total = json['total'] ?? 0;
    final items = (json['list'] ?? []) as List<dynamic>;
    final res = SpotubePaginationResponseObject.page(
      limit: limit,
      page: page,
      total: total,
      hasMore: (page * limit) < total,
      items: items
          .map(
            (item) => PomeloTrackObjectMeta.fromJson(
              Map<String, dynamic>.from(item),
            ).toSpotubeFullTrackObject(),
          )
          .toList(),
    );
    return res;
  }
}

final musicsdkProvider = NotifierProvider<MusicsdkNotifier, JavascriptRuntime>(
  MusicsdkNotifier.new,
);
