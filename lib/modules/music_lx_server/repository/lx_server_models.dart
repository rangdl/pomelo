import 'package:pomelo/modules/music/model/models.dart';

/// Lx Server 歌曲质量类型
class LxServerQuality {
  /// 质量标识：128k / 320k / flac / flac24bit
  final String type;

  /// 文件大小（展示用）
  final String? size;

  /// 该质量对应的 hash
  final String? hash;

  const LxServerQuality({required this.type, this.size, this.hash});

  factory LxServerQuality.fromJson(Map<String, dynamic> json) {
    return LxServerQuality(
      type: json['type'] as String,
      size: json['size'] as String?,
      hash: json['hash'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    if (size != null) 'size': size,
    'hash': hash,
  };
}

/// Lx Server 歌曲（原始 API 数据）
///
/// 对应 lx-server 的 `normalizeSongInfo` 逻辑：
/// API 返回的歌曲数据中，实际字段可能嵌套在 `meta` 子对象里，
/// [fromJson] 会将 meta 中的字段扁平化到根级别作为备用。
class LxServerSong {
  final String singer;
  final String name;
  final String? albumName;
  final String? albumId;
  final dynamic songmid;
  final String source;
  final String? interval;
  final String? img;
  final String? lrc;
  final List<LxServerQuality> types;
  final Map<String, LxServerQuality> typesMap;

  // 平台特有字段（供 getMusicUrl 构造 songInfo 使用）
  /// 酷狗(kg) hash
  final String? hash;

  /// 腾讯(tx) strMediaMid
  final String? strMediaMid;

  /// 腾讯(tx) albumMid
  final String? albumMid;

  /// 咪咕(mg) copyrightId
  final String? copyrightId;

  /// 咪咕(mg) lrcUrl
  final String? lrcUrl;

  /// 网易(wy)/腾讯(tx)/咪咕(mg) songId
  final dynamic songId;

  const LxServerSong({
    required this.singer,
    required this.name,
    this.albumName,
    this.albumId,
    this.songmid,
    required this.source,
    this.interval,
    this.img,
    this.lrc,
    this.types = const [],
    this.typesMap = const {},
    this.hash,
    this.strMediaMid,
    this.albumMid,
    this.copyrightId,
    this.lrcUrl,
    this.songId,
  });

  /// 从 JSON 创建，应用 normalizeSongInfo 扁平化逻辑
  ///
  /// 1. 音质信息：meta.qualitys/types → types，meta._qualitys/_types → _types
  /// 2. 基础字段备用根节点映射：meta.picUrl → img 等
  /// 3. 通用 ID 转换：meta.songId 或 id（去除 source_ 前缀）→ songmid
  /// 4. 平台特有字段补全
  factory LxServerSong.fromJson(Map<String, dynamic> json) {
    final meta = (json['meta'] as Map<String, dynamic>?) ?? const {};

    // 1. 处理音质信息 (types / _types)
    final typesRaw = json['types'] ?? meta['qualitys'] ?? meta['types'];
    final typesList =
        (typesRaw as List<dynamic>?)
            ?.map((e) => LxServerQuality.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final typesMapRaw = json['_types'] ?? meta['_qualitys'] ?? meta['_types'];
    final typesMapJson = (typesMapRaw as Map<String, dynamic>?) ?? {};
    final typesMap = <String, LxServerQuality>{};
    for (final entry in typesMapJson.entries) {
      final v = entry.value as Map<String, dynamic>;
      typesMap[entry.key] = LxServerQuality(
        type: entry.key,
        size: v['size'] as String?,
        hash: v['hash'] as String?,
      );
    }

    // 2. 基础字段备用根节点映射
    final source =
        (json['source'] as String? ?? meta['source'] as String?) ?? '';
    final name = json['name'] as String? ?? meta['name'] as String? ?? '';
    final singer = json['singer'] as String? ?? meta['singer'] as String? ?? '';
    final albumName =
        json['albumName'] as String? ?? meta['albumName'] as String?;
    final albumId = json['albumId']?.toString() ?? meta['albumId']?.toString();
    final img = json['img'] as String? ?? meta['picUrl'] as String?;
    final interval = json['interval'] as String? ?? meta['interval'] as String?;
    final lrc = json['lrc'] as String?;
    final hash = json['hash'] as String? ?? meta['hash'] as String?;

    // 3. 通用 ID 转换 (id -> songmid)
    dynamic songmid = json['songmid'];
    if (songmid == null) {
      final metaSongId = meta['songId'];
      if (metaSongId != null) {
        songmid = metaSongId;
      } else {
        final id = json['id'];
        if (id != null) {
          final sourcePrefix = '${source}_';
          if (id is String && id.startsWith(sourcePrefix)) {
            songmid = id.substring(sourcePrefix.length);
          } else {
            songmid = id;
          }
        }
      }
    }

    // 4. 平台特有字段补全
    String? strMediaMid =
        json['strMediaMid'] as String? ?? meta['strMediaMid'] as String?;
    String? albumMid =
        json['albumMid'] as String? ?? meta['albumMid'] as String?;
    String? copyrightId =
        json['copyrightId'] as String? ?? meta['copyrightId'] as String?;
    String? lrcUrl = json['lrcUrl'] as String? ?? meta['lrcUrl'] as String?;
    dynamic songId = json['songId'];

    switch (source) {
      case 'wy': // 网易云
        if (songId == null && meta['songId'] != null) {
          songId = meta['songId'] is int
              ? meta['songId']
              : int.tryParse('${meta['songId']}');
        }
        songmid ??= songId?.toString();
      case 'kg': // 酷狗
        // hash 已在步骤 2 中处理
        break;
      case 'tx': // 腾讯
        // 只有当 meta 中的 songId 是纯数字时才回填
        final metaSongIdStr = '${meta['songId'] ?? ''}';
        if (RegExp(r'^\d+$').hasMatch(metaSongIdStr)) {
          songId ??= metaSongIdStr;
        }
      case 'mg': // 咪咕
        songId ??= songmid;
      case 'kw': // 酷我
        // 已在步骤 3 中通用处理
        break;
    }

    return LxServerSong(
      singer: singer,
      name: name,
      albumName: albumName,
      albumId: albumId,
      songmid: songmid,
      source: source,
      interval: interval,
      img: img,
      lrc: lrc,
      hash: hash,
      types: typesList,
      typesMap: typesMap,
      strMediaMid: strMediaMid,
      albumMid: albumMid,
      copyrightId: copyrightId,
      lrcUrl: lrcUrl,
      songId: songId,
    );
  }

  /// 解析时长字符串 "MM:SS" 为秒
  int get durationSeconds {
    final s = interval;
    if (s == null || s.isEmpty) return 0;
    final parts = s.split(':');
    if (parts.length == 2) {
      final m = int.tryParse(parts[0]) ?? 0;
      final sec = int.tryParse(parts[1]) ?? 0;
      return m * 60 + sec;
    }
    return 0;
  }

  /// 构造完整的 songInfo Map（供 POST /api/music/url 使用）
  ///
  /// 包含所有平台特有字段，服务端 normalizeSongInfo 会根据 source 选取所需字段。
  Map<String, dynamic> toSongInfo() {
    final info = <String, dynamic>{
      'source': source,
      'name': name,
      'singer': singer,
      if (albumName != null) 'albumName': albumName,
      if (albumId != null) 'albumId': albumId,
      if (img != null) 'img': img,
      if (interval != null) 'interval': interval,
      if (hash != null) 'hash': hash,
      if (songmid != null) 'songmid': songmid,
      if (songId != null) 'songId': songId,
      if (strMediaMid != null) 'strMediaMid': strMediaMid,
      if (albumMid != null) 'albumMid': albumMid,
      if (copyrightId != null) 'copyrightId': copyrightId,
      if (lrcUrl != null) 'lrcUrl': lrcUrl,
      'types': types.map((t) => t.toJson()).toList(),
      '_types': {
        for (final entry in typesMap.entries)
          entry.key: {'hash': entry.value.hash, 'size': entry.value.size},
      },
    };
    return info;
  }

  /// 转换为项目统一的 [Song] 模型
  ///
  /// [sourceId] 为服务标识，[sourceName] 为服务显示名，
  /// [libraryId] 为来源库（kg/kw 等），[libraryName] 为库显示名。
  /// 完整 songInfo 存入 meta，供 [LxServerMusicService.getMusicUrl] 使用。
  Song toSong({
    required String sourceId,
    required String sourceName,
    required String libraryId,
    required String libraryName,
  }) {
    return Song.full(
      id: songmid?.toString() ?? hash ?? '',
      name: name,
      artist: singer.isEmpty ? '未知艺术家' : singer,
      albumId: albumId,
      albumName: albumName,
      coverUrl: img,
      duration: durationSeconds,
      source: (id: sourceId, name: sourceName, libraryId: libraryId, libraryName: libraryName),
      meta: toSongInfo(),
      src: '',
    );
  }
}

/// Lx Server 歌单（列表项）
class LxServerPlaylist {
  final String id;
  final String name;
  final String? img;
  final String author;
  final String? desc;
  final String? playCount;
  final String? time;

  const LxServerPlaylist({
    required this.id,
    required this.name,
    this.img,
    this.author = '',
    this.desc,
    this.playCount,
    this.time,
  });

  factory LxServerPlaylist.fromJson(Map<String, dynamic> json) {
    return LxServerPlaylist(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      img: json['img'] as String?,
      author: json['author'] as String? ?? '',
      desc: json['desc'] as String?,
      playCount: json['play_count']?.toString(),
      time: json['time'] as String?,
    );
  }

  /// 转换为项目统一的 [Playlist] 模型
  Playlist toPlaylist({
    required String sourceId,
    required String sourceName,
    required String libraryId,
    required String libraryName,
  }) {
    return Playlist(
      id: id,
      name: name,
      coverUrl: img,
      creator: author,
      description: desc,
      source: (id: sourceId, name: sourceName, libraryId: libraryId, libraryName: libraryName),
      meta: {'id': id, 'play_count': playCount, 'time': time},
    );
  }
}

/// Lx Server 排行榜
class LxServerLeaderboard {
  final String id;
  final String name;
  final String bangid;

  const LxServerLeaderboard({
    required this.id,
    required this.name,
    required this.bangid,
  });

  factory LxServerLeaderboard.fromJson(Map<String, dynamic> json) {
    return LxServerLeaderboard(
      id: json['bangid']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      bangid: json['bangid']?.toString() ?? '',
    );
  }

  /// 转换为项目统一的 [Leaderboard] 模型
  /// 使用 bangid 作为 id，供 getLeaderboardSongs 直接使用。
  Leaderboard toLeaderboard() => Leaderboard(id: bangid, name: name);
}

/// Lx Server 歌单分类标签组
class LxServerTagGroup {
  final String name;
  final List<LxServerTag> list;

  const LxServerTagGroup({required this.name, this.list = const []});

  factory LxServerTagGroup.fromJson(Map<String, dynamic> json) {
    return LxServerTagGroup(
      name: json['name'] as String? ?? '',
      list:
          (json['list'] as List<dynamic>?)
              ?.map((e) => LxServerTag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Lx Server 歌单分类标签
class LxServerTag {
  final String id;
  final String name;
  final String? parentId;
  final String? parentName;

  const LxServerTag({
    required this.id,
    required this.name,
    this.parentId,
    this.parentName,
  });

  factory LxServerTag.fromJson(Map<String, dynamic> json) {
    return LxServerTag(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      parentId: json['parent_id']?.toString(),
      parentName: json['parent_name'] as String?,
    );
  }
}

/// Lx Server 歌单分类标签响应
class LxServerTagsResponse {
  final List<LxServerTag> hotTags;
  final List<LxServerTagGroup> tagGroups;
  final List<({String id, String name})> sortList;

  const LxServerTagsResponse({
    this.hotTags = const [],
    this.tagGroups = const [],
    this.sortList = const [],
  });

  factory LxServerTagsResponse.fromJson(Map<String, dynamic> json) {
    return LxServerTagsResponse(
      hotTags:
          (json['hotTag'] as List<dynamic>?)
              ?.map((e) => LxServerTag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tagGroups:
          (json['tags'] as List<dynamic>?)
              ?.map((e) => LxServerTagGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      sortList:
          (json['sortList'] as List<dynamic>?)?.map((e) {
            final m = e as Map<String, dynamic>;
            return (
              id: m['id']?.toString() ?? '',
              name: m['name'] as String? ?? '',
            );
          }).toList() ??
          [],
    );
  }
}
