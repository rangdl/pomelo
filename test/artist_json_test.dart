import 'package:flutter_test/flutter_test.dart';
import 'package:pomelo/core/models/metadata/artist.dart';

void main() {
  group('Artist JSON', () {
    test('完整字段往返一致', () {
      final json = {
        'id': 'a1',
        'name': '周杰伦',
        'coverArt': 'cover.jpg',
        'artistImageUrl': 'img.jpg',
        'albumCount': 15,
        'starred': '2024-01-02T03:04:05.000',
        'source': {
          'id': 's1',
          'name': 'Subsonic',
          'libraryId': 'lib1',
          'libraryName': '主库',
        },
        'meta': {'raw': 1},
      };

      final artist = Artist.fromJson(json);
      expect(artist.id, 'a1');
      expect(artist.name, '周杰伦');
      expect(artist.albumCount, 15);
      expect(artist.starred, DateTime.parse('2024-01-02T03:04:05.000'));
      expect(artist.source?.id, 's1');
      expect(artist.source?.libraryName, '主库');
      expect(artist.meta?['raw'], 1);

      final out = artist.toJson();
      expect(out['id'], 'a1');
      expect(out['albumCount'], 15);
      expect(out['starred'], '2024-01-02T03:04:05.000');
      expect(out['source'], {
        'id': 's1',
        'name': 'Subsonic',
        'libraryId': 'lib1',
        'libraryName': '主库',
      });
      expect(out['meta'], {'raw': 1});

      // 二次往返稳定
      expect(Artist.fromJson(out).toJson(), out);
    });

    test('最小字段 / null 不写入', () {
      final artist = Artist.fromJson({'id': 'a2', 'name': 'X'});
      expect(artist.albumCount, 0);
      expect(artist.starred, isNull);
      expect(artist.source, isNull);
      expect(artist.meta, isNull);

      final out = artist.toJson();
      expect(out.containsKey('coverArt'), isFalse);
      expect(out.containsKey('starred'), isFalse);
      expect(out.containsKey('source'), isFalse);
      expect(out.containsKey('meta'), isFalse);
      expect(out['albumCount'], 0);
    });

    test('starred 兼容时间戳与非标准格式', () {
      final ts = Artist.fromJson({
        'id': 'a3',
        'name': 'Y',
        'starred': 1704153845000,
      });
      expect(ts.starred, isNotNull);

      final bad = Artist.fromJson({
        'id': 'a4',
        'name': 'Z',
        'starred': 'not-a-date',
      });
      expect(bad.starred, isNull);
    });

    test('ArtistWithAlbums 含专辑往返', () {
      final json = {
        'id': 'a5',
        'name': 'W',
        'albumCount': 2,
        'albums': [
          {'id': 'b1', 'name': '专辑一'},
          {'id': 'b2', 'name': '专辑二'},
        ],
      };
      final awa = ArtistWithAlbums.fromJson(json);
      expect(awa.albums.length, 2);
      expect(awa.albums.first.name, '专辑一');

      final out = awa.toJson();
      expect((out['albums'] as List).length, 2);
      expect(ArtistWithAlbums.fromJson(out).albums.last.name, '专辑二');
    });

    test('copyWith 与相等性', () {
      const a = Artist(id: 'a6', name: 'N', albumCount: 3);
      expect(a.copyWith(name: 'M').name, 'M');
      expect(a.copyWith(name: 'M').albumCount, 3);
      expect(a.copyWith(), a);
      expect(
        a.copyWith(starred: DateTime(2024)).copyWith(clearStarred: true).starred,
        isNull,
      );
    });
  });
}
