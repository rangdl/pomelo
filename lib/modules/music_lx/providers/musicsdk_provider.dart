import 'dart:convert';

import 'package:flutter_js/flutter_js.dart';
import 'package:pomelo/core/log.dart';
import 'package:pomelo/core/pagination/pagination_response.dart';
import 'package:pomelo/modules/music/model/models.dart';

import '../model/js_engine.dart';

/// Lx 元数据引擎
///
/// 负责管理 quickjs 运行时，注入基础能力（fetch/crypto/AES），
/// 并支持动态加载用户上传的元数据插件脚本。
/// 元数据插件提供音乐搜索、歌曲详情等元信息能力。
class LxMetadataEngine {
  final JsEngine jsEngine;

  LxMetadataEngine() : jsEngine = JsEngine();

  /// 初始化引擎（注入 fetch/crypto/AES 基础能力）
  ///
  /// 注意：JsEngine 构造函数中已自动调用 init() 注入基础能力，
  /// 此方法用于额外初始化逻辑（如预加载 polyfill）。
  Future<void> init() async {
    // 注入polyfill兼容能力
    // final polyfill = await rootBundle.loadString('assets/js/polyfill.umd.js');
    // final resultPolyfill = jsEngine.jsRuntime.evaluate(polyfill);
    // if (resultPolyfill.isError) {
    //   print('js: ${resultPolyfill.toString()}');
    // } else {
    //   print('polyfill加载成功');
    // }
  }

  /// 加载元数据插件脚本
  ///
  /// 接受脚本字符串，在 quickjs 中执行。
  /// 脚本需要遵循 musicsdk Registry 协议，自行注册 Searcher/Provider 等。
  ///
  /// 返回是否加载成功。
  bool loadPlugin(String scriptContent) {
    final result = jsEngine.jsRuntime.evaluate(scriptContent);
    if (result.isError) {
      log.error('LxMetadataEngine', '元数据插件加载失败: ${result.toString()}');
      return false;
    }
    log.info('LxMetadataEngine', '元数据插件加载成功');

    // 调用脚本初始化方法
    final resultSetup = jsEngine.jsRuntime.evaluate('setup()');
    if (resultSetup.isError) {
      log.error('LxMetadataEngine', '元数据插件初始化失败: ${result.toString()}');
      return false;
    }
    log.info('LxMetadataEngine', '元数据插件初始化成功');
    return true;
  }

  /// 获取 registry 中已注册的所有库信息
  ///
  /// 返回 `(id, name)` 列表，如 `[(id: 'tx', name: '腾讯音乐')]`。
  Future<List<({String id, String name})>> getRegisteredLibraries() async {
    try {
      final result = await jsEngine.jsRuntime.evaluateAsync(
        'JSON.stringify(Array.from(registry.all()))',
      );
      jsEngine.jsRuntime.executePendingJob();
      if (result.isError) return [];
      final asyncResult = await jsEngine.jsRuntime.handlePromise(result);
      final raw = asyncResult.rawResult;
      if (raw is String) {
        final items = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
        return items
            .map((v) => (
                  id: v['id'] as String? ?? '',
                  name: v['name'] as String? ?? v['id'] as String? ?? '',
                ))
            .toList();
      }
      return [];
    } catch (e) {
      log.error('LxMetadataEngine', e.toString(), error: e);
      return [];
    }
  }

  /// 加载元数据插件并返回新注册的库信息列表
  ///
  /// 加载前记录已有的库，加载后对比得出新增的库。
  Future<List<({String id, String name})>> loadPluginWithLibraries(
      String scriptContent) async {
    final before = await getRegisteredLibraries();
    final beforeIds = before.map((e) => e.id).toSet();
    final success = loadPlugin(scriptContent);
    if (!success) return [];
    final after = await getRegisteredLibraries();
    return after.where((e) => !beforeIds.contains(e.id)).toList();
  }

  /// 执行 JS 搜索
  Future<PaginationResponse<Song>> search(
    String keyword, {
    int page = 1,
    int limit = 20,
    type = 'tx',
  }) async {
    final result = await jsEngine.jsRuntime.evaluateAsync(
      "registry.get(`$type`)?.search(`$keyword`, $page, $limit)",
    );
    jsEngine.jsRuntime.executePendingJob();
    if (result.isError) {
      log.error('LxMetadataEngine', '搜索失败: ${result.toString()}');
    }
    final asyncResult = await jsEngine.jsRuntime.handlePromise(result);
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

  /// 获取歌单分类
  ///
  /// 从元数据插件获取歌单分类列表。
  /// 返回结果包含 tags（分类组 + 子分类）和 hot（热门排行榜）。
  /// tags 中的组（如“风格”“语种”）作为父分类，其 list 中的项作为子分类。
  /// hot 作为特殊的“排行榜”父分类，其项作为子分类。
  Future<List<PlaylistCategory>> getPlaylistCategories({
    String type = 'tx',
  }) async {
    final result = await jsEngine.jsRuntime.evaluateAsync(
      "registry.getSongListProvider(`$type`)?.getTags()",
    );
    jsEngine.jsRuntime.executePendingJob();
    if (result.isError) {
      log.error('LxMetadataEngine', '获取歌单分类失败: ${result.toString()}');
      return [];
    }
    final asyncResult = await jsEngine.jsRuntime.handlePromise(result);
    final json = Map<String, dynamic>.from(await asyncResult.rawResult);
    
    final categories = <PlaylistCategory>[];

    // 解析 hot: 作为“排行榜”分类组
    final hot = json['hot'] as List<dynamic>?;
    if (hot != null && hot.isNotEmpty) {
      const hotGroupId = 'hot';
      categories.add(const PlaylistCategory(id: hotGroupId, name: '排行榜'));
      for (final item in hot) {
        final itemMap = Map<String, dynamic>.from(item as Map);
        categories.add(PlaylistCategory(
          id: itemMap['id'] as String? ?? '',
          name: itemMap['name'] as String? ?? '',
          parentId: hotGroupId,
        ));
      }
    }

    // 解析 tags: 每个 tag 组作为父分类，其 list 作为子分类
    final tags = json['tags'] as List<dynamic>?;
    if (tags != null) {
      for (final tag in tags) {
        final tagMap = Map<String, dynamic>.from(tag as Map);
        final groupId = tagMap['id'] as String? ?? '';
        final groupName = tagMap['name'] as String? ?? '';
        // 添加父分类（歌单分组）
        categories.add(PlaylistCategory(id: groupId, name: groupName));
        // 添加子分类
        final list = tagMap['list'] as List<dynamic>?;
        if (list != null) {
          for (final item in list) {
            final itemMap = Map<String, dynamic>.from(item as Map);
            categories.add(PlaylistCategory(
              id: itemMap['id'] as String? ?? '',
              name: itemMap['name'] as String? ?? '',
              parentId: groupId,
            ));
          }
        }
      }
    }

    return categories;
  }

  /// 获取指定分类下的歌单列表
  ///
  /// 调用元数据插件的 getSongList 方法，按分类 id 获取歌单。
  /// 返回 [PaginationResponse<Playlist>]。
  Future<List<Playlist>> getPlaylistsByCategory(
    String categoryId, {
    String type = 'tx',
  }) async {
    final result = await jsEngine.jsRuntime.evaluateAsync(
      "registry.getSongListProvider(`$type`)?.getList('', `$categoryId`, 1)",
    );
    jsEngine.jsRuntime.executePendingJob();
    if (result.isError) {
      log.error('LxMetadataEngine', '获取歌单列表失败: ${result.toString()}');
      return [];
    }
    final asyncResult = await jsEngine.jsRuntime.handlePromise(result);
    final json = Map<String, dynamic>.from(await asyncResult.rawResult);
    final list = (json['list'] ?? []) as List<dynamic>;
    final source = (id: type, name: type);
    final items = list.map((item) {
      final m = Map<String, dynamic>.from(item as Map);
      return Playlist(
        id: '$type-${m['id']}',
        name: m['name'] as String? ?? '',
        coverUrl: m['img'] as String?,
        creator: m['author'] as String? ?? '',
        description: m['desc'] as String?,
        source: source,
        meta: m,
      );
    }).toList();

    return items;
  }

  Future<List<Song>> getPlaylistsDetail(
    String id, {
    String type = 'tx',
  }) async {
    // 提取原始 id（去掉 `${type}-` 前缀）
    final prefix = '$type-';
    final originalId = id.startsWith(prefix) ? id.substring(prefix.length) : id;

    final result = await jsEngine.jsRuntime.evaluateAsync(
      "registry.getSongListProvider(`$type`)?.getListDetail(`$originalId`)",
    );
    jsEngine.jsRuntime.executePendingJob();
    if (result.isError) {
      log.error('LxMetadataEngine', '获取歌单详情失败: ${result.toString()}');
      return [];
    }
    final asyncResult = await jsEngine.jsRuntime.handlePromise(result);
    final json = Map<String, dynamic>.from(await asyncResult.rawResult);
    final list = (json['list'] ?? []) as List<dynamic>;

    return list
        .map(
          (item) => PomeloTrackObjectMeta.fromJson(
            Map<String, dynamic>.from(item),
          ).toSong(),
        )
        .toList();
  }

  void dispose() {
    jsEngine.dispose();
  }
}

// ============================================================
// 音乐元数据模型（用于 JS SDK 返回数据的解析）
// ============================================================

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
    return Song.full(
      id: '$source-$musicId',
      name: name,
      artist: singer,
      albumId: albumId,
      albumName: album,
      coverUrl: img,
      src: '', // 需要根据类型选择合适的链接
      duration: duration,
      source: (id: source, name: source), // 简化处理
      meta: toMap()
    );
  }
}
