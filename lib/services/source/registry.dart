import 'package:pomelo/models/metadata/metadata.dart';

import 'types.dart';

// Searcher 搜索器接口
abstract interface class Searcher {
  String id();
  String name();

  Future<SpotubePaginationResponseObject<SpotubeTrackObject>> search(
    String keyword, {
    int page = 1,
    int limit = 30,
  });
  // Future<SearchResult> search(String keyword, int page, int limit);
}

// LyricFetcher 歌词获取器接口
abstract class LyricFetcher {
  String id();
  // getLyric(songInfo: Record<string, unknown>): Promise<LyricResult>;
}

// SongListProvider 歌单提供者接口
interface class SongListProvider {
  late final String id;
  late final String name;
  // getSortList(): SortItem[];
  // getList(sortId: string, tagId: string, page: number): Promise<SongListResult>;
  // getTags(): Promise<TagResult>;
  // getListDetail(id: string, page: number): Promise<SongListDetailResult>;
  // searchSongList(keyword: string, page: number, limit: number): Promise<SongListResult>;
}

// LeaderboardProvider 排行榜提供者接口
interface class LeaderboardProvider {
  late final String id;
  late final String name;

  Future<SpotubeTrackObject> getBoards(String source) {
    throw UnimplementedError();
  }

  Future<(List<SpotubeTrackObject> list, int total)> getList(
    String source,
    String boardId,
    int page,
  ) {
    throw UnimplementedError();
  }

  // getBoards(source: string): BoardItem[];
  // getList(source: string, boardId: string, page: number): Promise<{ list: SearchItem[]; total: number }>;
}

// HotSearchFetcher 热搜获取器接口
interface class HotSearchFetcher {
  late final String id;
  late final String name;
  // getHotSearch(source: string): Promise<string[]>;
}

/// TipSearchProvider 搜索联想提供者接口
interface class TipSearchProvider {
  late final String id;
  late final String name;
  // getTips(source: string, keyword: string): Promise<string[]>;
}

/// Registry 统一注册表
class Registry {
  final Map<String, Searcher> searchers = {};
  final Map<String, LyricFetcher> lyricFetchers = {};
  final Map<String, SongListProvider> songListProviders = {};
  final Map<String, HotSearchFetcher> hotSearchFetchers = {};
  final Map<String, LeaderboardProvider> leaderboardProviders = {};
  final Map<String, TipSearchProvider> tipSearchProviders = {};
  final List<String> order = [];

  // 记录平台 id 顺序（首次出现时追加，重复 id 不再追加）
  void trackOrder(String id) {
    if (!order.contains(id)) {
      order.add(id);
    }
  }

  // 注册搜索器
  void register(Searcher s) {
    trackOrder(s.id());
    searchers[s.id()] = s;
  }

  // 获取指定 ID 的搜索器
  Searcher? get(String id) {
    return searchers[id];
  }

  // 返回有序的平台列表
  // all(): PlatformInfo[] {
  //   const platforms: PlatformInfo[] = [];
  //   for (const id of this.order) {
  //     const s = this.searchers.get(id);
  //     if (s) {
  //       platforms.push({ id: s.id(), name: s.name() });
  //     }
  //   }
  //   return platforms;
  // }

  // 注册歌词获取器
  void registerLyricFetcher(LyricFetcher f) {
    lyricFetchers[f.id()] = f;
  }

  // 获取指定 ID 的歌词获取器
  LyricFetcher? getLyricFetcher(String id) {
    return lyricFetchers[id];
  }

  // 注册歌单提供者
  void registerSongListProvider(SongListProvider p) {
    songListProviders[p.id] = p;
  }

  // 获取指定 ID 的歌单提供者

  SongListProvider? getSongListProvider(String id) {
    return songListProviders[id];
  }

  // 返回所有歌单提供者的平台信息
  // allSongListProviders(): PlatformInfo[] {
  //   const platforms: PlatformInfo[] = [];
  //   for (const id of this.order) {
  //     const p = this.songListProviders.get(id);
  //     if (p) {
  //       platforms.push({ id: p.id(), name: p.name() });
  //     }
  //   }
  //   return platforms;
  // }

  // 注册排行榜提供者
  void registerLeaderboardProvider(LeaderboardProvider p) {
    trackOrder(p.id);
    leaderboardProviders[p.id] = p;
  }

  // 获取指定 ID 的排行榜提供者
  LeaderboardProvider? getLeaderboardProvider(String id) {
    return leaderboardProviders[id];
  }

  // 注册热搜获取器
  void registerHotSearchFetcher(HotSearchFetcher f) {
    trackOrder(f.id);
    hotSearchFetchers[f.id] = f;
  }

  // 获取指定 ID 的热搜获取器
  HotSearchFetcher? getHotSearchFetcher(String id) {
    return hotSearchFetchers[id];
  }

  // 注册搜索联想提供者
  void registerTipSearchProvider(TipSearchProvider p) {
    trackOrder(p.id);
    tipSearchProviders[p.id] = p;
  }

  // 获取指定 ID 的搜索联想提供者
  TipSearchProvider? getTipSearchProvider(String id) {
    return tipSearchProviders[id];
  }
}
