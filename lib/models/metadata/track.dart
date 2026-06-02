part of 'metadata.dart';

@freezed
class SpotubeTrackObject with _$SpotubeTrackObject {
  factory SpotubeTrackObject.local({
    required String id,
    required String name, // 歌曲名
    required String externalUri,
    @Default([]) List<SpotubeSimpleArtistObject> artists, // 艺术家
    required SpotubeSimpleAlbumObject album, // 专辑
    required int durationMs, // 时长
    required String path, // 文件路径
  }) = SpotubeLocalTrackObject;

  factory SpotubeTrackObject.full({
    required String id,
    required String name, // 歌曲名
    required String externalUri,
    @Default([]) List<SpotubeSimpleArtistObject> artists, // 艺术家
    required SpotubeSimpleAlbumObject album, // 专辑
    required int durationMs, // 时长
    required String isrc, // 播放链接 如果为空则从源查找
    required bool explicit,
    PomeloTrackObjectMeta? meta, // 元信息
  }) = SpotubeFullTrackObject;

  factory SpotubeTrackObject.localTrackFromFile(
    File file, {
    Metadata? metadata,
    String? art,
  }) {
    return SpotubeLocalTrackObject(
      id: file.absolute.path,
      name: metadata?.title ?? basenameWithoutExtension(file.path),
      externalUri: "file://${file.absolute.path}",
      artists:
          metadata?.artist?.split(",").map((a) {
            return SpotubeSimpleArtistObject(
              id: a.trim(),
              name: a.trim(),
              externalUri: "file://${file.absolute.path}",
            );
          }).toList() ??
          [
            SpotubeSimpleArtistObject(
              id: "unknown",
              name: "Unknown Artist",
              externalUri: "file://${file.absolute.path}",
            ),
          ],
      album: SpotubeSimpleAlbumObject(
        albumType: SpotubeAlbumType.album,
        id: metadata?.album ?? "unknown",
        name: metadata?.album ?? "Unknown Album",
        externalUri: "file://${file.absolute.path}",
        artists: [
          SpotubeSimpleArtistObject(
            id: metadata?.albumArtist ?? "unknown",
            name: metadata?.albumArtist ?? "Unknown Artist",
            externalUri: "file://${file.absolute.path}",
          ),
        ],
        releaseDate: metadata?.year != null
            ? "${metadata!.year}-01-01"
            : "1970-01-01",
        images: [
          if (art != null)
            SpotubeImageObject(url: art, width: 300, height: 300),
        ],
      ),
      durationMs: metadata?.durationMs?.toInt() ?? 0,
      path: file.path,
    );
  }

  factory SpotubeTrackObject.fromJson(Map<String, dynamic> json) =>
      _$SpotubeTrackObjectFromJson(
        json.containsKey("path")
            ? {...json, "runtimeType": "local"}
            : {...json, "runtimeType": "full"},
      );
}

@freezed
class PomeloTrackObjectMeta with _$PomeloTrackObjectMeta {
  factory PomeloTrackObjectMeta({
    required String name, // 歌曲名称
    required String singer, // 歌手
    required String album, // 专辑
    String? albumId, // 专辑 ID
    required int duration, // 时长（秒）
    required String source, // 平台标识 kg/kw/tx/wy/mg
    required String musicId, // 平台歌曲唯一标识
    String? img, // 封面图 URL
    @Default([]) List<PomeloTrackExtraType> types, // 可用音质列表
    // 平台特有字段（getMusicUrl 时需要）
    String? hash, // kg
    String? copyrightId, // mg
    String? strMediaMid, // tx
    String? albumMid, // tx
    String? songmid, // tx/wy
  }) = _PomeloTrackObjectMeta;
  factory PomeloTrackObjectMeta.fromJson(Map<String, dynamic> json) =>
      _$PomeloTrackObjectMetaFromJson({...json, "runtimeType": json['source']});
}

@freezed
class PomeloTrackExtraType with _$PomeloTrackExtraType {
  factory PomeloTrackExtraType({
    required String type, // 音质类型: "128k", "320k", "flac", "flac24bit"
    String? size, // 文件大小（可选）
    String? hash, // 文件 hash（kg 特有）
  }) = _PomeloTrackExtraType;

  factory PomeloTrackExtraType.fromJson(Map<String, dynamic> json) =>
      _$PomeloTrackExtraTypeFromJson(json);
}

extension AsMediaListSpotubeTrackObject on Iterable<SpotubeTrackObject> {
  List<SpotubeMedia> asMediaList() {
    return map((track) => SpotubeMedia(track)).toList();
  }
}

extension ToMetadataSpotubeFullTrackObject on SpotubeFullTrackObject {
  Metadata toMetadata({
    required int fileLength,
    Uint8List? imageBytes,
    String? mimeType,
  }) {
    return Metadata(
      title: name,
      artist: artists.map((a) => a.name).join(", "),
      album: album.name,
      albumArtist: artists.map((a) => a.name).join(", "),
      year: album.releaseDate == null
          ? 1970
          : DateTime.tryParse(album.releaseDate!)?.year ??
                int.tryParse(album.releaseDate!) ??
                1970,
      durationMs: durationMs.toDouble(),
      fileSize: BigInt.from(fileLength),
      picture: imageBytes != null
          ? Picture(
              data: imageBytes,
              mimeType:
                  mimeType ??
                  lookupMimeType("", headerBytes: imageBytes) ??
                  "image/jpeg",
            )
          : null,
    );
  }
}

extension ToSpotubeFullTrackObject on PomeloTrackObjectMeta {
  SpotubeTrackObject toSpotubeFullTrackObject() {
    return SpotubeTrackObject.full(
      id: musicId,
      name: name,
      externalUri: '',
      artists: singer
          .split('、')
          .map(
            (s) => SpotubeSimpleArtistObject(
              id: '',
              name: s,
              externalUri: '',
              images: [],
            ),
          )
          .toList(),
      album: SpotubeSimpleAlbumObject(
        id: albumId ?? '$source-$musicId-${albumId ?? ''}',
        name: album,
        externalUri: '',
        images: [
          if (img != null && img!.isNotEmpty) SpotubeImageObject(url: img!),
        ],
        artists: [],
        albumType: SpotubeAlbumType.album,
      ),
      durationMs: duration,
      isrc: '',
      explicit: false,
      meta: this,
    );
  }
}
