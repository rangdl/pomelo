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
  factory PomeloTrackObjectMeta.tx({
    @Default('tx') String source,
    required String songMid,
    @Default([]) List<PomeloTrackExtraType> types,
    // tx
    required String strMediaMid, // 歌曲strMediaMid
    String? id, // 歌曲songId
    String? albumMid, // 歌曲albumMid
  }) = PomeloTrackObjectMetaTx;

  factory PomeloTrackObjectMeta.mg({
    @Default('mg') String source,
    required String songMid,

    // mg
    required String copyrightId, // 歌曲copyrightId
    String? lrcUrl, // 歌曲lrcUrl
    String? mrcUrl, // 歌曲mrcUrl
    String? trcUrl, // 歌曲trcUrl
    @Default([]) List<PomeloTrackExtraType> types,
  }) = PomeloTrackObjectMetaMg;

  factory PomeloTrackObjectMeta.fromJson(Map<String, dynamic> json) =>
      _$PomeloTrackObjectMetaFromJson({...json, "runtimeType": json['source']});
}

@freezed
class PomeloTrackExtraType with _$PomeloTrackExtraType {
  factory PomeloTrackExtraType({required String type, required String size}) =
      _PomeloTrackExtraType;

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

  Map<String, String> toQuery() {
    return {
      "name": name,
      "singer": artists.map((v) => v.name).toList().join(','),
      ...(meta?.toJson().map(
            (key, value) => MapEntry(key, value?.toString() ?? ''),
          ) ??
          {}),
    };
  }
}
