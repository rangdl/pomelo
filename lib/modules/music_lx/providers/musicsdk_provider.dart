import 'package:flutter_js/flutter_js.dart';
import 'package:pomelo/core/pagination/pagination_response.dart';
import 'package:pomelo/modules/music/model/models.dart';

import '../model/js_engine.dart';

/// Lx JS 引擎封装
///
/// 负责管理 quickjs 运行时，注入基础能力（fetch/crypto/AES），
/// 并支持动态加载用户上传的 JS 脚本文件内容。
class LxJsEngine {
  final JsEngine jsEngine;

  LxJsEngine() : jsEngine = JsEngine();

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

  /// 动态加载 JS 脚本内容
  ///
  /// 接受脚本字符串，在 quickjs 中执行。
  /// 脚本需要遵循 musicsdk Registry 协议，自行注册 Searcher/Provider 等。
  ///
  /// 返回是否加载成功。
  bool loadScript(String scriptContent) {
    final result = jsEngine.jsRuntime.evaluate(scriptContent);
    if (result.isError) {
      print('LxJsEngine: 脚本加载失败: ${result.toString()}');
      return false;
    }
    print('LxJsEngine: 脚本加载成功');

    // 调用脚本初始化方法
    final resultSetup = jsEngine.jsRuntime.evaluate('setup()');
    if (resultSetup.isError) {
      print('LxJsEngine: 脚本初始化失败: ${result.toString()}');
      return false;
    }
    print('LxJsEngine: 脚本初始化成功');
    return true;
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
      print(result.toString());
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
    );
  }
}
