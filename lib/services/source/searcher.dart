// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pomelo/models/metadata/metadata.dart';

interface class Searcher {
  late final Dio _dio;
  Future<SpotubePaginationResponseObject<SpotubeTrackObject>> search(
    String keyword, {
    int page = 1,
    int limit = 30,
  }) {
    // TODO: implement search
    throw UnimplementedError();
  }
}

/// 将字节大小转换为人类可读的字符串 (如 "3.5 MB")
String sizeToStr(int sizeInBytes) {
  if (sizeInBytes <= 0) return '0 B';
  const List<String> units = ['B', 'KB', 'MB', 'GB'];
  double size = sizeInBytes.toDouble();
  int unitIdx = 0;
  while (size >= 1024 && unitIdx < units.length - 1) {
    size /= 1024;
    unitIdx++;
  }
  return '${size.toStringAsFixed(2)} ${units[unitIdx]}';
}

/// 简单解码名称中的转义字符 (如 Unicode 转义)
String decodeName(String name) {
  if (name.isEmpty) return '';
  try {
    // 处理常见的 Unicode 转义序列 (如 \u4E2D\u6587)
    return name.replaceAllMapped(RegExp(r'\\u([0-9a-fA-F]{4})'), (match) {
      final hex = match.group(1)!;
      return String.fromCharCode(int.parse(hex, radix: 16));
    });
  } catch (_) {
    return name; // 解码失败时返回原始值
  }
}

/// QQ音乐搜索API端点
const String txApiUrl = 'https://u.y.qq.com/cgi-bin/musicu.fcg';

/// User-Agent，模拟Android客户端
const String txUa = 'QQMusic 14090508(android 12)';

/// 平台标识
const String txSourceId = 'tx';

class TxSearcher implements Searcher {
  @override
  late Dio _dio;
  TxSearcher({required Dio? dio}) {
    _dio = dio ?? Dio();
    _dio.options.baseUrl = txApiUrl;
    _dio.options.headers.addAll({
      'Content-Type': 'application/json',
      'User-Agent': txUa,
    });
  }

  /// 获取平台标识
  String get id => txSourceId;

  /// 获取平台名称
  String get name => 'tx';

  /// 执行搜索
  /// [keyword] 搜索关键词
  /// [page] 页码(从1开始)，默认1
  /// [limit] 每页结果数量，默认30
  @override
  Future<SpotubePaginationResponseObject<SpotubeTrackObject>> search(
    String keyword, {
    int page = 1,
    int limit = 30,
  }) async {
    // 参数有效性检查
    page = page < 1 ? 1 : page;
    limit = limit <= 0 ? 30 : limit;

    // 构造请求体
    final Map<String, dynamic> reqBody = {
      'comm': {
        'ct': '11',
        'cv': '14090508',
        'v': '14090508',
        'tmeAppID': 'qqmusic',
        'phonetype': 'EBG-AN10',
        'deviceScore': '553.47',
        'devicelevel': '50',
        'newdevicelevel': '20',
        'rom': 'HuaWei/EMOTION/EmotionUI_14.2.0',
        'os_ver': '12',
        'OpenUDID': '0',
        'OpenUDID2': '0',
        'QIMEI36': '0',
        'udid': '0',
        'chid': '0',
        'aid': '0',
        'oaid': '0',
        'taid': '0',
        'tid': '0',
        'wid': '0',
        'uid': '0',
        'sid': '0',
        'modeSwitch': '6',
        'teenMode': '0',
        'ui_mode': '2',
        'nettype': '1020',
        'v4ip': '',
      },
      'req': {
        'module': 'music.search.SearchCgiService',
        'method': 'DoSearchForQQMusicMobile',
        'param': {
          'search_type': 0,
          'query': keyword,
          'page_num': page,
          'num_per_page': limit,
          'highlight': 0,
          'nqc_flag': 0,
          'multi_zhida': 0,
          'cat': 2,
          'grp': 1,
          'sin': 0,
          'sem': 0,
        },
      },
    };

    // 打印调试信息
    print('[TxSearcher] search {keyword: $keyword, page: $page}');

    // 发送请求
    Response<dynamic> response;
    try {
      response = await _dio.post(
        '',
        data: reqBody,
        options: Options(responseType: ResponseType.plain),
      );
    } catch (e) {
      throw Exception('HTTP request failed: $e');
    }

    // 调试模式下打印原始响应（仅当长度不大时）
    if (const bool.fromEnvironment('DEBUG')) {
      final respStr = response.data.toString();
      if (respStr.length <= 2000) {
        print('[TxSearcher] raw response: $respStr');
      } else {
        print(
          '[TxSearcher] raw response (truncated): ${respStr.substring(0, 2000)}',
        );
      }
    }

    // 解析并验证响应
    final parsed = _parseResponse(jsonDecode(response.data));
    if (parsed == null) {
      throw Exception('Failed to parse response');
    }

    // 检查API返回码
    if (parsed['code'] != 0 || parsed['reqCode'] != 0) {
      throw Exception(
        'API error: code=${parsed['code']}, req.code=${parsed['reqCode']}',
      );
    }

    // 转换结果
    final List<SpotubeTrackObject> items = [];
    final songs = parsed['songs'] as List<dynamic>;
    for (final song in songs) {
      // 跳过没有 media_mid 的歌曲
      final file = song['file'] as Map<String, dynamic>?;
      if (file == null || file['media_mid'] == null) {
        continue;
      }
      final item = _convertSongItem(song);
      items.add(item);
    }

    return SpotubePaginationResponseObject.page(
      items: items,
      limit: limit,
      total: parsed['total'],
      page: page,
      hasMore: items.length == limit,
    );
  }

  /// 解析QQ音乐API响应
  /// 返回包含 code, reqCode, total, songs 的Map，或null
  Map<String, dynamic>? _parseResponse(Map<String, dynamic> resp) {
    try {
      final code = resp['code'];
      final reqCode = resp['req']?['code'];
      final estimateSum = resp['req']?['data']?['meta']?['estimate_sum'] ?? 0;
      final itemSong = resp['req']?['data']?['body']?['item_song'] ?? [];

      print(
        '[TxSearcher] search result {code: $code, reqCode: $reqCode, total: $estimateSum, items: ${itemSong.length}}',
      );

      return {
        'code': code,
        'reqCode': reqCode,
        'total': estimateSum,
        'songs': itemSong,
      };
    } catch (err) {
      print('[TxSearcher] parse error: $err');
      return null;
    }
  }

  /// 将QQ音乐歌曲项转换为通用格式
  SpotubeTrackObject _convertSongItem(Map<String, dynamic> song) {
    // 拼接歌手名
    final List<SpotubeSimpleArtistObject> singers = [];
    final singersDy = song['singer'] as List<dynamic>?;
    if (singersDy != null) {
      for (final singer in singersDy) {
        final singerName = singer['name'] as String?;
        final singerId = singer['name'] as String?;
        if (singerName != null && singerName.isNotEmpty) {
          singers.add(
            SpotubeSimpleArtistObject(
              id: '$name-$singerId',
              name: singerName,
              externalUri: '',
            ),
          );
        }
      }
    }

    // 生成封面URL
    String img = '';
    final album = song['album'] as Map<String, dynamic>?;
    final albumMid = album?['mid'] as String?;
    if (albumMid != null && albumMid.isNotEmpty && albumMid != '空') {
      img = 'https://y.gtimg.cn/music/photo_new/T002R500x500M000$albumMid.jpg';
    } else {
      final firstSinger = song['singer'] as List<dynamic>?;
      if (firstSinger != null && firstSinger.isNotEmpty) {
        final singerMid = firstSinger[0]['mid'] as String?;
        if (singerMid != null && singerMid.isNotEmpty) {
          img =
              'https://y.gtimg.cn/music/photo_new/T001R500x500M000$singerMid.jpg';
        }
      }
    }

    // 构建音质列表
    final List<PomeloTrackExtraType> types = [];
    final file = song['file'] as Map<String, dynamic>? ?? {};

    final size128 = file['size_128mp3'] as int? ?? 0;
    if (size128 > 0) {
      types.add(PomeloTrackExtraType(type: '128k', size: sizeToStr(size128)));
      // types.add(
      //   SpotubeAudioSourceStreamObject(
      //     url: '',
      //     container: 'm4a',
      //     type: SpotubeMediaCompressionType.lossy,
      //     codec: 'aac',
      //     tag: '128k',
      //   ),
      // );
    }
    final size320 = file['size_320mp3'] as int? ?? 0;
    if (size320 > 0) {
      types.add(PomeloTrackExtraType(type: '320k', size: sizeToStr(size320)));
      // types.add(
      //   SpotubeAudioSourceStreamObject(
      //     url: '',
      //     container: 'm4a',
      //     type: SpotubeMediaCompressionType.lossy,
      //     codec: 'aac',
      //     tag: '320k',
      //   ),
      // );
    }
    final sizeFlac = file['size_flac'] as int? ?? 0;
    if (sizeFlac > 0) {
      types.add(PomeloTrackExtraType(type: 'flac', size: sizeToStr(sizeFlac)));
      // types.add(
      //   SpotubeAudioSourceStreamObject(
      //     url: '',
      //     container: 'flac',
      //     type: SpotubeMediaCompressionType.lossy,
      //     codec: 'flac',
      //     tag: 'flac',
      //   ),
      // );
    }
    final sizeHiRes = file['size_hires'] as int? ?? 0;
    if (sizeHiRes > 0) {
      types.add(
        PomeloTrackExtraType(type: 'flac24bit', size: sizeToStr(sizeHiRes)),
      );
      // types.add(
      //   SpotubeAudioSourceStreamObject(
      //     url: '',
      //     container: 'flac',
      //     type: SpotubeMediaCompressionType.lossy,
      //     codec: 'flac',
      //     tag: 'flac24bit',
      //   ),
      // );
    }

    // 获取mid值 (优先使用song.mid，否则使用song.id)
    final musicId = (song['mid'] as String?) ?? (song['id']?.toString() ?? '');

    // final sourcedTrack = {
    //   "siblings": [],
    //   "sources": types,
    //   "info": SpotubeAudioSourceMatchObject(
    //     id: musicId,
    //     title: decodeName(song['name'] ?? ''),
    //     artists: singers.map((v) => v.name).toList(),
    //     duration: Duration(seconds: song['interval'] ?? 0),
    //     externalUri: '',
    //     thumbnail: img,
    //   ),
    //   "query": SpotubeTrackObject.full(
    //     id: '$name-$musicId',
    //     name: decodeName(song['name'] ?? ''),
    //     externalUri: '',
    //     artists: singers,
    //     album: SpotubeSimpleAlbumObject(
    //       id: '$name-$musicId-${album?['id'] ?? ''}',
    //       name: decodeName(album?['name'] ?? ''),
    //       externalUri: '',
    //       images: [SpotubeImageObject(url: img)],
    //       artists: [],
    //       albumType: SpotubeAlbumType.album,
    //     ),
    //     durationMs: song['interval'] ?? 0,
    //     isrc: '',
    //     explicit: false,
    //   ),
    //   "source": name,
    // };
    // return sourcedTrack;
    return SpotubeTrackObject.full(
      // source: name,
      id: '$name-$musicId',
      name: decodeName(song['name'] ?? ''),
      externalUri: '',
      artists: singers,
      album: SpotubeSimpleAlbumObject(
        id: '$name-$musicId-${album?['id'] ?? ''}',
        name: decodeName(album?['name'] ?? ''),
        externalUri: '',
        images: [SpotubeImageObject(url: img)],
        artists: [],
        albumType: SpotubeAlbumType.album,
      ),
      durationMs: song['interval'] ?? 0,
      isrc: '',
      explicit: false,
      extra: PomeloTrackObjectExtra.tx(
        source: "tx",
        songMid: '0039MnYb0qxYhV',
        types: types,
      ),
      // musicId: musicId,
      // types: types,
      // songMid: musicId,
      // albumMid: albumMid ?? '',
      // strMediaMid: file['media_mid'] ?? '',
    );
  }
}
