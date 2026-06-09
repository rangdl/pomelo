import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pomelo/modules/music/model/models.dart';

import '../model/js_engine.dart';

class LxJsEngine {
  final JsEngine jsEngine;

  LxJsEngine() : jsEngine = JsEngine();

  Future<void> init() async {
    final polyfill = await rootBundle.loadString('assets/js/polyfill.umd.js');
    final resultPolyfill = jsEngine.jsRuntime.evaluate(polyfill);
    if (resultPolyfill.isError) {
      print('js: ${resultPolyfill.toString()}');
    } else {
      print('polyfill加载成功');
    }
    // 加载 sdk
    final musicsdk = await rootBundle.loadString('assets/js/musicsdk.umd.js');
    final resultSdk = jsEngine.jsRuntime.evaluate(musicsdk);
    if (resultSdk.isError) {
      print('js: ${resultSdk.toString()}');
    } else {
      print('musicsdk加载成功');
    }
    // 加载插件
    final result = jsEngine.jsRuntime.evaluate("""
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

  Future<PaginationResponse<Song>> search(
    String keyword, {
    int page = 1,
    int limit = 20,
    type = 'tx',
  }) async {
    final result = await jsEngine.jsRuntime.evaluateAsync(
      "registry.get(`$type`)?.search(`$keyword`, $page, $limit)",
      // "typeof `$keyword`",
    );
    jsEngine.jsRuntime.executePendingJob();
    if (result.isError) {
      print(result.toString());
    }
    final asyncResult = await jsEngine.jsRuntime.handlePromise(result);
    final json = Map<String, dynamic>.from(await asyncResult.rawResult);
    // final json = Map<String, dynamic>.from(
    //   jsonDecode(asyncResult.stringResult),
    // );

    final total = json['total'] ?? 0;
    final items = (json['list'] ?? []) as List<dynamic>;
    final res = PaginationResponse<Song>(
      limit: limit,
      page: page,
      total: total,
      hasMore: (page * limit) < total,
      items: items
          .map(
            (item) => PomeloTrackObjectMeta.fromJson(
              Map<String, dynamic>.from(item),
            ).toSong(),
          )
          .toList(),
    );
    return res;
  }

  void dispose() {
    jsEngine.dispose();
  }
}

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

  Future<PaginationResponse<Song>> search(
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
    final res = PaginationResponse<Song>(
      limit: limit,
      page: page,
      total: total,
      hasMore: (page * limit) < total,
      items: items
          .map(
            (item) => PomeloTrackObjectMeta.fromJson(
              Map<String, dynamic>.from(item),
            ).toSong(),
          )
          .toList(),
    );
    return res;
  }
}

final musicsdkProvider = NotifierProvider<MusicsdkNotifier, JavascriptRuntime>(
  MusicsdkNotifier.new,
);

class PomeloTrackExtraType {
  final String type; // 音质类型: "128k", "320k", "flac", "flac24bit"
  final String? size; // 文件大小（可选）
  final String? hash; // 文件 hash（kg 特有）

  // 普通构造函数（推荐使用）
  const PomeloTrackExtraType({required this.type, this.size, this.hash});

  /// 从 JSON Map 创建实例
  factory PomeloTrackExtraType.fromJson(Map<String, dynamic> json) {
    return PomeloTrackExtraType(
      type: json['type'] as String,
      size: json['size'] as String?,
      hash: json['hash'] as String?,
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      if (size != null) 'size': size, // 可选字段，若为 null 则不加入
      if (hash != null) 'hash': hash,
    };
  }
}

class PomeloTrackObjectMeta {
  final String name;
  final String singer;
  final String album;
  final String? albumId;
  final int duration;
  final String source;
  final String musicId;
  final String? img;
  final List<PomeloTrackExtraType> types; // 默认空列表
  // 平台特有字段
  final String? hash;
  final String? copyrightId;
  final String? strMediaMid;
  final String? albumMid;
  final String? songmid;

  const PomeloTrackObjectMeta({
    required this.name,
    required this.singer,
    required this.album,
    this.albumId,
    required this.duration,
    required this.source,
    required this.musicId,
    this.img,
    this.types = const [], // 手动处理默认值
    this.hash,
    this.copyrightId,
    this.strMediaMid,
    this.albumMid,
    this.songmid,
  });

  /// 从 JSON Map 创建实例
  factory PomeloTrackObjectMeta.fromJson(Map<String, dynamic> json) {
    // 处理 types 列表：将原始 JSON 数组转换为 PomeloTrackExtraType 列表
    final typesList = json['types'] as List<dynamic>?;
    final List<PomeloTrackExtraType> parsedTypes = typesList != null
        ? typesList
              .map(
                (item) => PomeloTrackExtraType.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : const []; // 默认空列表

    return PomeloTrackObjectMeta(
      name: json['name'] as String,
      singer: json['singer'] as String,
      album: json['album'] as String,
      albumId: json['albumId'] as String?,
      duration: json['duration'] as int,
      source: json['source'] as String,
      musicId: json['musicId'] as String,
      img: json['img'] as String?,
      types: parsedTypes,
      hash: json['hash'] as String?,
      copyrightId: json['copyrightId'] as String?,
      strMediaMid: json['strMediaMid'] as String?,
      albumMid: json['albumMid'] as String?,
      songmid: json['songmid'] as String?,
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'singer': singer,
      'album': album,
      if (albumId != null) 'albumId': albumId,
      'duration': duration,
      'source': source,
      'musicId': musicId,
      if (img != null) 'img': img,
      // types 列表转换为 Map 列表
      'types': types.map((type) => type.toMap()).toList(),
      if (hash != null) 'hash': hash,
      if (copyrightId != null) 'copyrightId': copyrightId,
      if (strMediaMid != null) 'strMediaMid': strMediaMid,
      if (albumMid != null) 'albumMid': albumMid,
      if (songmid != null) 'songmid': songmid,
    };
  }

  Song toSong() {
    return Song(
      id: '$source-$musicId',
      name: name,
      artist: singer,
      albumId: albumId,
      albumName: album,
      coverUrl: img,
      path: '', // 需要根据类型选择合适的链接
      duration: duration,
      source: (id: source, name: source), // 简化处理
    );
  }
}
